#!/bin/sh

info=`fsminfo -v "$@"`

exec echo "$info" \
 | egrep '^(class|semiring|transducer|\#)[[:space:]]'

# | egrep '^(class|semiring|transducer|initial|\#|connected|acyclic|costless|costs non-negative|deterministic)[[:space:]]'