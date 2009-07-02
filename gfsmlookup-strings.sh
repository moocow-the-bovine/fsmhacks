#!/bin/sh

if [ $# -lt 3 ] ; then
  echo "Usage: $0 LABFILE STRING GFSMFILE"
  exit 1
fi

labfile="$1"
shift
string="$1"
shift
fsmfile="$1"
shift

labs=`echo "$string" | gfsmlabels -l "$labfile"`
gfsmlookup -f "$gfsmfile" "$labs" \
| gfsmstrings -l "$symbase.lab" -a \
| fsmstringsort.perl

#| sort -t'<' -k2 -n
