#!/bin/bash

show_help() {
  echo "Usage: $0 [-u|--utf8] LABFILE STRING GFSMFILE" >&2
}

args=()
opts=()
utf8=()
while [ $# -gt 0 ] ; do
    case "$1" in
	-h|-help|--help)
	    show_help
	    exit 0
	    ;;
	-u|-utf8|--utf8)
	    utf8=(--utf8)
	    ;;
	*)
	    if [ ${#args[@]} -lt 3 ]; then
		args[${#args[@]}]="$1"
	    else
		opts[${#opts[@]}]="$1"
	    fi
	    ;;
    esac
    shift
done

if [ ${#args[@]} -lt 3 ] ; then
    show_help
    exit 0
fi

labfile="${args[0]}"
[ \! -e "$labfile" -a -e "$labfile.lab" ] && labfile="$labfile.lab" 

string="${args[1]}"
fsmfile="${args[2]}"

gfsmlookup -f "$fsmfile" `echo "$string" | gfsmlabels "${utf8[@]}" -l "$labfile"` \
| gfsmstrings "${utf8[@]}" -i "$labfile" -o "$labfile" -a

#| fsmstringsort.perl
##--
#| sort -t'<' -k2 -n
