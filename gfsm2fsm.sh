#!/bin/sh

. `dirname $0`/fsmfuncs.sh
if test -n "$1" -a "$1" != "-" ; then
  gfsm="$1"
  shift
else
  ##-- reading from a pipe: create a tempfile
  if test "$1" = "-" ; then
    gfsm="$1";
    shift;
  else
    gfsm="-"
  fi
  tmp=`fsm_tempfile gfsm2fsm .gfsm`
  cat "$gfsm" > $tmp
  gfsm="$tmp"
fi

flags=`gfsm2fsm_compile_flags "$gfsm"`
exec gfsmprint "$gfsm" | fsmcompile $flags "$@"
