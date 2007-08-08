#!/bin/sh

## wrapper for potentially missing 'fsmcompact'
if test -n "`which fsmcompact`" ; then
  exec fsmcompact "$@"
else
  ##-- fsmcompact missing: dummy
  exec fsmarith -i 0 "$@"
fi
