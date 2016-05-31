#!/bin/bash

##==============================================================
## Globals
hfst=""
dummy=""
keep=""
xbrackets="y"

##==============================================================
## Subs
show_usage() {
    cat <<EOF >&2

Usage: $0 [OPTIONS] HFST

Options:
   -h     , -help         # this help message
   -o     , -out BASE     # set output basename (default=\${HFST%.hfst*})
   -d     , -dummy        # just print commands
   -[no]b , -[no]brackets # do/don't translate bracketed symbols in lab files? (default=do)
   -[no]k , -[no]keep     # keep temporary tfst? (default=don't)

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
      "-d"|"-dummy"|"-dry-run") dummy=y ;;
      "-k"|"-keep") keep=y ;;
      "-nok"|"-nokeep") keep="" ;;
      "-b"|"-brackets"|"-xb"|"-xlate-brackets") xbrackets=y; ;;
      "-nob"|"-nobrackets"|"-noxb"|"-noxlate-brackets") xbrackets=""; ;;
#      "-t"|"-tags"|"-xt"|"-xlate-tags") xtags=y; ;;
#      "-not"|"-notags"|"-noxt"|"-noxlate-tags") xtags=""; ;;
#      "-f"|"-feat"|"-features"|"-xf"|"-xlate-features") xfeat=y; ;;
#      "-nof"|"-nofeat"|"-nofeatures"|"-noxf"|"-noxlate-features") xfeat=""; ;;
      "-"*)
	  die "unknown option '$1'"
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
if test -n "$xbrackets"; then
    runcmd perl -i -pe 's/(?<=\s)\[(\S+)\](?=\s)/<$1>/sg;' "$obase.tfst" \
	   || die "bracket-label hack failed"
fi


##-- generate labels
evalcmd "echo -e '@0@\\t0' > '$obase.lab'"
evalcmd "tfst-labels.sh '$obase.tfst' \
    | tt-1grams.perl -freqsort \
    | tt-cut.awk '\$2' \
    | fgrep -vx '@0@' \
    | awk '{print \$1 \"\\t\" NR}' \
    >> '$obase.lab'" \
    || die "label generation failed"

##-- compile
evalcmd "gfsmcompile -l '$obase.lab' '$obase.tfst' -z0 | gfsmarcsort -l -F '$obase.gfst'" \
    || die "gfsmcompile failed"

##-- cleanup
test -n "$keep" || runcmd rm -f "$obase.tfst"

##-- report
echo "$0: created GFSM file(s) '$obase.gfst', '$obase.lab" >&2
