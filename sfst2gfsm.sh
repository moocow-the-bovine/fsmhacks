#!/bin/bash

##==============================================================
## Globals
sfst=""
dummy=""
keep=""
brackets=""
invert=""

##==============================================================
## Subs
show_usage() {
    cat <<EOF >&2

Usage: $0 [OPTIONS] SFST

Options:
   -h , -help       # this help message
   -o , -out BASE   # set output basename (default=\${SFST%.a})
   -d , -dummy      # just print commands
   -b , -brackets   # keep bracketed symbols in lab files? (default=map <X> to _X)
   -i , -invert     # don't implicitly invert automaton (default=do)
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
	sfst="$1"
	;;
  esac
  shift
done

if test $# -gt 1 ; then
    obase="$2"
else
    obase=`basename "$sfst"`
    obase="${obase%.a}"
fi

##-- convert to text
evalcmd "fst-print '$sfst' > '$obase.tfst'" \
    || die "hfst-fst2txt failed"

##-- hack brackets labels?
if test -z "$brackets"; then
    runcmd perl -i -pe 's/(\s)\<(\S+)\>(\s)/$1_$2$3/sg;' "$obase.tfst" \
	   || die "bracket replacement failed"
fi

##-- hack space-only symbols
perl -i -pe 's/( +)/"_" x length($1)/eg;' "$obase.tfst"

##-- generate labels
evalcmd "echo -e '<>\\t0' > '$obase.lab'"
evalcmd "tfst-labels.sh '$obase.tfst' \
    | perl -pe 's/^\s+\$/_/;' \
    | tt-1grams.perl -freqsort \
    | tt-cut.awk '\$2' \
    | fgrep -vx '<>' \
    | awk '{print \$1 \"\\t\" NR}' \
    >> '$obase.lab'" \
	|| die "label generation failed"

##-- compile
test -n "$invert" && invertcmd="" || invertcmd="| gfsminvert -z0"
evalcmd "gfsmcompile -l '$obase.lab' '$obase.tfst' -z0 ${invertcmd} | gfsmarcsort -l -F '$obase.gfst'" \
	|| die "gfsmcompile failed"

##-- cleanup
test -n "$keep" || runcmd rm -f "$obase.tfst"

##-- report
echo "$0: created GFSM file(s) '$obase.gfst', '$obase.lab" >&2
