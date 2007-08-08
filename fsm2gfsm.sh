#!/bin/sh

. `dirname $0`/fsmfuncs.sh
if test -n "$1" -a "$1" != "-" ; then
  afsm="$1"
  shift
else
  ##-- reading from a pipe: create a tempfile
  if test "$1" = "-" ; then
    afsm="$1";
    shift;
  else
    afsm="-"
  fi
  tmp=`fsm_tempfile fsm2gfsm .afsm`
  cat "$afsm" > $tmp
  afsm="$tmp"
fi

flags=`fsm2gfsm_compile_flags "$afsm"`
exec fsmprint "$afsm" | gfsmcompile $flags "$@"
