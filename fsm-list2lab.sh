#!/bin/bash

show_usage() {
    cat <<EOF >&2

Usage: $0 [OPTIONS] [LABEL_FILE(s)]

Options:
  -e , -epsilon EPS	# epsilon string (default '<epsilon>')

EOF
}
 
eps='<epsilon>'
args=()
while test "$#" -gt 0 ; do
  a="$1"
  shift;
  case "$a" in
    -h|-help|--help)  show_usage;  exit 0 ;;
    -e|-eps*|--eps*)  eps="$1"; shift ;;
    *) args=("${args[@]}" "$a") ;;
  esac
done

echo -e "$eps\t0"
env -i LC_ALL=C sort -u "$@" \
 | fgrep -vx '$eps' \
 | fgrep -vx '' \
 | awk -F$'\t' '{print $1 "\t" NR};'
