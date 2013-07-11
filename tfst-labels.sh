#!/bin/bash

show_usage() {
    cat <<EOF >&2

Usage: $0 [OPTIONS] [ATT_FSM_FILE(s)]

Options:
  -1 , -lower	# output lower (input) labels only
  -2 , -upper   # output upper (output) labels only
  -12, -both    # output both lower and upper labels (default)

EOF
}
 

want_lo=''
want_hi=''
args=()
while test "$#" -gt 0 ; do
  a="$1"
  shift;
  case "$a" in
    -h|-help|--help)  show_usage;  exit 0 ;;
    -1|-l|-lo*|--lo*) want_lo=y;;
    -2|-u|-up*|--up*|-hi|--hi) want_hi=y;;
    -12|-both|--both) want_lo=1; want_hi=y;;
    *) args=("${args[@]}" "$a") ;;
  esac
done

if test -z "$want_lo" -a -z "$want_hi" ; then
  want_lo=y
  want_hi=y
fi

awk_lo=''
awk_hi=''
test -n "$want_lo" && awk_lo='if (NF>=3) { print $3; }'
test -n "$want_hi" && awk_hi='if (NF>=4) { print $4; }'

exec awk "{$awk_lo $awk_hi}" "${args[@]}"
