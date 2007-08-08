#!/bin/sh

. `dirname $0/fsmfuncs.sh`
if test -n "$1" -a "$1" != "-" ; then
  afsm="$1"
  shift
  flags=`fsm2gfsm_compile_flags "$afsm"`
else
  ##-- reading from a pipe: expect that gfsm flags are given on command-line
  ( echo "$0: WARNING: cannot auto-determine (acceptor|transducer) status for STDIN" >&2 )
  if test "$1" = "-" ; then
    afsm="$1";
    shift;
  else
    afsm="-"
  fi
  flags=""
fi

exec fsmprint "$afsm" | gfsmcompile $flags "$@"
