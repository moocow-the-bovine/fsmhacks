#!/bin/bash

show_help() {
    cat <<EOF >&2
Usage: $0 [OPTIONS] LABFILE STRING GFSMFILE

Options:
   -u, --utf8    # assume UTF-8 alphabet
   -a, --att     # honor AT&T input escapes
   -A, --align   # output aligned arc paths

EOF
}

args=()
opts=()
labopts=()
stropts=(-a)
while [ $# -gt 0 ] ; do
    case "$1" in
	-h|-help|--help)
	    show_help
	    exit 0
	    ;;
	-u|-utf8|--utf8)
	    labopts[${#labopts[@]}]="-u"
	    stropts[${#stropts[@]}]="-u"
	    ;;
	-a|-att|--att)
	    labopts[${#labopts[@]}]="-a"
	    #stropts[${#stropts[@]}]="-a"
	    ;;
	-A|-align|--align)
	    stropts[${#stropts[@]}]="-A"
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

gfsmlookup -f "$fsmfile" `echo "$string" | gfsmlabels "${labopts[@]}" -l "$labfile"` \
| gfsmstrings "${stropts[@]}" -i "$labfile" -o "$labfile"

#| fsmstringsort.perl
##--
#| sort -t'<' -k2 -n
