#!/bin/sh

. "`dirname $0`/fsmfuncs.sh"
DOT="dot"
DOTFLAGS="-Tps -Gcharset=latin1"

GV="gv"
GVFLAGS="--spartan --orientation=landscape"

PSFILE=`fsm_tempfile dotgv .ps`

mode="dot"
for arg in $* ; do

  case "$mode" in
    dot)
      if test "$arg" = "--" ; then
        mode="gv"
        continue
      fi
      DOTFLAGS="$DOTFLAGS $arg"
      ;;
    gv)
      if test "$arg" = "--" ; then
        mode="literal"
      fi
      GVFLAGS="$GVFLAGS $arg"
      ;;
    *)
      ;;
  esac
done

$DOT -o "$PSFILE" $DOTFLAGS
exec gv $GVFLAGS "$PSFILE"
