#!/bin/sh

if [ $# -lt 3 ] ; then
  echo "Usage: $0 SYMBASE REGEX FSMFILE [LEXCOMPRE_ARGS]"
  exit 1
fi

symbase="$1"
shift
regex="$1"
shift
fsmfile="$1"
shift

lexcompre \
  -l "$symbase.lab" -S "$symbase.scl" \
  -s "$regex" \
  "$@" \
| fsmcompose - "$fsmfile" \
| lexfsmstrings -l "$symbase.lab" -S "$symbase.scl" \
| fsmstringsort.perl

#| sort -t'<' -k2 -n
