#!/bin/sh

USAGE="$0 LABFILE STRING FSTFILE [FSMLOOKUP_ARGS]"

if [ $# -lt 3 ] ; then
  echo "Usage: $USAGE" >&2
  exit 1
fi

labs="$1"
shift
str="$1"
shift
fstfile="$1"
shift

echo gfsmlookup -f "$fstfile" \`echo "$str" \| gfsmlabels -l $labs\` "$@" >&2
gfsmlookup -f "$fstfile" `echo "$str" | gfsmlabels -l $labs` "$@"
