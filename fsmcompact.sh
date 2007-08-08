#!/bin/sh

## wrapper for potentially missing 'fsmcompact'
if test -n "`which fsmcompact`" ; then
  exec fsmcompact "$@"
else
  exec fsmarith -i 0 "$@"
fi
