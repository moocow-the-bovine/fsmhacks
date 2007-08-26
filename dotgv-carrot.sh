#!/bin/sh

DOT="dot"
DOTFLAGS="-Tps"

PS2EPSI="ps2epsi"

GV="gv"
GVFLAGS="--orientation=landscape"

PSFILE=`tempfile --prefix='dotgv' --suffix='.ps'`
EPSFILE=`basename $PSFILE .ps`.epsi

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

$DOT -o$PSFILE $DOTFLAGS 
$PS2EPSI $PSFILE $EPSFILE
gv $GVFLAGS $EPSFILE
rm -f $PSFILE $EPSFILE
