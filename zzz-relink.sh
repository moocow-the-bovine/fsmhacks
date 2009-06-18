#!/bin/sh

FORCE="yes"
BINDIR="$HOME/local/bin"
DUMMY="no"
THISDIR="`readlink -f $PWD`"

runcmd() {
  if test "$DUMMY" = "yes"; then
    echo -n " [DUMMY: " "$@" "] " 1>&2
  else
    "$@"
  fi
}

for f in `find . -maxdepth 1 -type f -not -name '*~' -not -name '.*' -not -name 'zzz*'` ; do
  b=`basename $f`
  echo -n "$b: "
  if [ -n "$FORCE" -a "$FORCE" != "no" ] ; then
    echo -n "force-removing, "
    runcmd rm -f "$BINDIR/$b"
  elif [ -e "$BINDIR/$b" ] ; then
   echo "exists: skipping"
    continue
  fi
  echo -n "linking"
  runcmd ln -s "$THISDIR/$b" "$BINDIR/"
  echo
done

