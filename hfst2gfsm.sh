#!/bin/bash

##==============================================================
## Globals
hfst=""
dummy=""
keep=""
brackets=""

##==============================================================
## Subs
show_usage() {
    cat <<EOF >&2

Usage: $0 [OPTIONS] HFST

Options:
   -h , -help       # this help message
   -o , -out BASE   # set output basename (default=\${HFST%.hfst*})
   -d , -dummy      # just print commands
   -b , -brackets   # keep bracketed symbols in lab files? (default=map [X] to _X)
   -k , -keep       # keep temporary tfst? (default=no)

EOF
}

runcmd() {
    echo "$@" >& 2
    test -n "$dummy" || "$@"
}
evalcmd() {
    echo "$@" >& 2
    test -n "$dummy" || eval "$*"
}

die() {
    echo "$0: ERROR: $*" >&2
    exit 255
}

##==============================================================
## MAIN
while test $# -gt 0; do
  case "$1" in
    ""|"-h"|"-help"|"--help")
	show_usage;
	exit 0;
	;;
    "-d"|"-dummy"|"-dry-run")
	dummy=y
	;;
    "-k"|"-keep")
	keep=y
	;;
    "-b"|"-brackets")
	brackets=y
	;;
    *)
	hfst="$1"
	;;
  esac
  shift
done

if test $# -gt 1 ; then
    obase="$2"
else
    obase=`basename "$hfst"`
    obase="${obase%.hfst*}"
fi

##-- convert to text
runcmd hfst-fst2txt --output="$obase.tfst" "$hfst" \
    || die "hfst-fst2txt failed"

##-- hack brackets labels?
if test -z "$brackets"; then
    runcmd perl -i -pe 's/(\s)\[(\S+)\](\s)/$1_$2$3/sg;' "$obase.tfst"
fi

##-- generate labels
evalcmd "echo -e '@0@\\t0' > '$obase.lab'"
evalcmd "tfst-labels.sh '$obase.tfst' \
    | tt-1grams.perl -freqsort \
    | tt-cut.awk '\$2' \
    | fgrep -vx '@0@' \
    | awk '{print \$1 \"\\t\" NR}' \
    >> '$obase.lab'"

##-- compile
evalcmd "gfsmcompile -l '$obase.lab' '$obase.tfst' -z0 | gfsmarcsort -l -F '$obase.gfst'"

##-- cleanup
test -n "$keep" || runcmd rm -f "$obase.tfst"

##-- report
echo "$0: created GFSM file(s) '$obase.gfst', '$obase.lab" >&2
