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

gfsmlookup -f "$fsmfile" `echo "$string" | gfsmlabels -l "$labfile"` \
| gfsmstrings -i "$labfile" -o "$labfile" -a

#| fsmstringsort.perl
##--
#| sort -t'<' -k2 -n
