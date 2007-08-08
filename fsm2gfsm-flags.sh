#!/bin/sh

if [ "`fsminfo '$1' | grep '^transducer' | cut -f2`" != "y" ]; then
  echo "-a";
fi

