#!/bin/sh

test -z "$FSM_GV_ARGS" \
  && FSM_GV_ARGS="-landscape -spartan -scalebase 2"
#  && FSM_GV_ARGS="--orientation=landscape --spartan --scalebase=2"

test -n "`which tempfile 2>/dev/null`" \
  && tmpfile=`tempfile -p fsm -s .ps` \
  || tmpfile="fsmview$$.ps"

fsmdraw "$@" | dot -Tps -o$tmpfile
gv $FSM_GV_ARGS $tmpfile
