#!/bin/sh

. "`dirname $0`/fsmfuncs.sh"
DOT="dot"
DOTFLAGS="-Tps -Gcharset=latin1"

GV="gv"
#GVFLAGS="--spartan --orientation=landscape --noantialias"

PSFILE=`fsm_tempfile dotgv .ps`

##-- get GVFLAGS
if test -z "$GVFLAGS" ; then
  GV_OPT_VERSION="`$GV -version 2>/dev/null`"
  GV_OPT_V="`$GV -v 2>/dev/null`"
  
  if test -n "$GV_OPT_V" -a -n "$GV_OPT_VERSION" ; then
    if echo "$GV_OPT_VERSION" | grep Usage ; then
      GV_VERSION="$GV_OPT_V"
    else
      GV_VERSION="$GV_OPT_VERSION"
    fi
  elif test -n "$GV_OPT_V" ; then
    GV_VERSION="$GV_OPT_V"
  elif test -n "$GV_OPT_VERSION" ; then
    GV_VERSION="$GV_OPT_VERSION"
  else
    GV_VERSION="???"
  fi
  #echo "GV_VERSION=$GV_VERSION" >&2
  
  GVFLAGS_COMMON="-spartan -noantialias"
  case "$GV_VERSION" in
    *\ 3.5.*)
      GVFLAGS="-landscape $GVFLAGS_COMMON"
      ;;
    *)
      ##-- e.g. 3.6.3
      GVFLAGS="-orientation=landscape $GVFLAGS_COMMON"
      ;;
  esac
fi

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
