#!/bin/bash

interp=$(which mfsm2)
test -z "$interp" && interp=$(which fsm2)
prog=`basename "$0"`

##---------------------------------------------------------------------
## usage
print_usage() {
  cat <<EOF >&2

Usage: $prog [OPTIONS] FSMFILE.bin

Options:
  -h		# this help message
  -s SYMSPEC	# symspec file (default=FSMFILE.sym)
  -o OUTFILE	# output file (default=stdout)
  -S SCRIPT	# temporary script file (default=(temporary))
  -I INTERP	# use interpreter INTERP (default=$interp)
  -sym , -num   # do/don't use symbolic labels (default=do)
  -att , -xml   # output in att or xml mode (default=att)
  --dummy	# dummy mode (just write SCRIPT)
  --verbose	# be verbose
  --quiet	# be less verbose
  
EOF
}

##---------------------------------------------------------------------
## messages

vmsg() {
  test "$verbose" = "on" && echo "$prog: ""$@" >&2
}

die() {
  echo "$prog: ""$@" >&2
  exit 255
}


##---------------------------------------------------------------------
## Options
symnames=on
txtfmt=att
verbose=off
quiet=off
dogetopts() {
  while [ $# -gt 0 ] ; do
    opt="$1"
    shift
    case "$opt" in
      -h|-help|--help) print_usage; exit 0;;
      -o|-F) outfile="$1"; shift ;;
      -s) symspec="$1"; shift ;;
      -S) scriptfile="$1"; shift;;
      -I) interp="$1"; shift;;
      -n|-num*|--num*) symnames="off";;
      -l|-sym*|--sym*) symnames="on";;
      -x|-xml|--xml)  txtfmt="xml";;
      -a|-att|--att)  txtfmt="att";;
      -v|-verbose|--verbose) quiet="off"; verbose="on";;
      -q|-quiet|--quiet) quiet="on"; verbose="off";;
      --dummy|--no-act) dummy=1; shift;;
      *) test -z "$binfile" && binfile="$opt" ;;
    esac
  done
}
dogetopts "$@"

##---------------------------------------------------------------------
## Setup
mybase="fsm2print"
tempfiles=()

##-- interpreter
test -z "$interp" && die "no interpreter found!"

##-- input file
test -z "$binfile" && binfile="-"
binfile_in="$binfile"
if test "$binfile" = "-" ; then
  binfile=`tempfile --suffix=.fst --prefix=${mybase}`
  cat >"$binfile" || die "could not spool stdin to $binfile"
  tempfiles=("${tempfiles[@]}" $binfile)
fi
vmsg "BINFILE=$binfile ($binfile_in)"

##-- symspec
test -z "$symspec" && symspec="${binfile_in%.*}.sym"
vmsg "SYMSPEC=$symspec"

##-- output file
test -z "$outfile" && outfile="-"
test "$outfile" = "-" && outfile_cmd="" || outfile_cmd=" >$outfile"
vmsg "OUTFILE=$outfile"

##-- script file
if test -z "$scriptfile" ; then
  scriptfile=`tempfile --suffix=.fsm2 --prefix=${mybase}`
  tempfiles=("${tempfiles[@]}" $scriptfile)
fi
vmsg "SCRIPT=$scriptfile"

##-- flags
#test -n "$verbose" && vcmd="verbose on" || vmd="quiet on"

##-- write script
cat <<EOF >"$scriptfile"
quiet $quiet
verbose $verbose
continue-on-error off
load symspec $symspec
load fsm $binfile binary
text-format $txtfmt
use-symbol-names $symnames
print fsm${outfile_cmd}
quit
EOF
test -n "$dummy" && exit 0

##-- run script
vmsg "SYSTEM $interp $scriptfile"
$interp $scriptfile || die "interpreter $interp failed for $scriptfile"

##-- remove temps
#vmsg "rm temps"
rm -f "${tempfiles[@]}"
