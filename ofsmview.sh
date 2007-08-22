#!/bin/sh

OFSMDRAW=fstdraw
DOTGV=dotgv.sh

exec $OFSMDRAW "$@" | $DOTGV
