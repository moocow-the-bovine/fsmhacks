#!/bin/sh

FORCE="yes"

for f in `find . -maxdepth 1 -type f -not -name '*~' -not -name '.*' -not -name 'zzz*'` ; do
  b=`basename $f`
  echo -n "$b: "
  if [ -n "$FORCE" -a "$FORCE" != "no" ] ; then
    echo -n "force-removing, "
    rm -f ~/local/bin/$b
  fi
  if [ -e ~/local/bin/$b ] ; then
    echo "exists: skipping"
  else
    echo "linking"
    ln -s $PWD/$b ~/local/bin
  fi
done

