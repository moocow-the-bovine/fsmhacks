#!/bin/sh

if test -z "$@" -o "$1" = "-h"; then
  echo "Usage: eval \`$0 SYMBASE\`"
fi

sym="$1"
echo "sym=\"$sym\"; lab=\"\$sym.lab\"; scl=\"\$sym.scl\"; labscl=\"-l \\\"\$lab\\\" -S \\\"\$scl\\\"\"; iolab=\"-i \\\"\$lab\\\" -o\\\"\$lab\\\"\""
