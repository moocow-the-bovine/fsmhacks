#!/bin/sh

FSMDRAW=fsmdraw
DOTGV=dotgv.sh

exec $FSMDRAW "$@" | $DOTGV
