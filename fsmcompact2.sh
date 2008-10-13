#!/bin/sh

show_usage() {
    echo "Usage: $0 [OPTIONS] FSMFILE" 1>&2
    echo "Options:" 1>&2
    echo " -l         : encode/decode labels (as for fsmencode(1))" 1>&2
    echo " -c         : encode/decode costs  (as for fsmencode(1))" 1>&2
    echo " -k KEYFILE : use KEYFILE for encoding (default=temp file)" 1>&2
    echo " -F OUTFILE : send output to OUTFILE" 1>&2
    echo " -v         : be verbose" 1>&2
}

encopts=()
outopts=()
keyfile=""
infile="-"
verbose=""
while test "$#" -gt 0 ; do
 if getopts "h?lck:F:v" name "$@" ; then
  case "$name" in
    F)
      outopts[${outopts[*]}]="-F$OPTARG"
      ;;
    k)
      keyfile="$OPTARG"
      ;;
    [lc])
      encopts[${encopts[*]}]="-${name}"
      ;;
    v)
      verbose=1
      ;;
    *)
      show_usage
      exit 1
      ;;
  esac
  while test "$OPTIND" -gt "1"; do
    shift
    let "OPTIND=$OPTIND-1"
  done
 else
  #echo "arg: OPTIND=$OPTIND; args=($*)"
  #args[${#args[*]}]="$1"
  infile="$1"
  shift
  OPTIND=1
 fi
done

if test -z "${encopts[*]}"; then
  encopts=("-l" "-c")
fi

if test -z "$keyfile"; then
  keyfile="`tempfile -p fsmkey -s .afst`"
  rm -f "$keyfile"
fi

if test -n "$verbose"; then
  #echo "$0: input file       : '${infile}'"  1>&2
  #echo "$0: key file         : '${keyfile}'" 1>&2
  #echo "$0: fsmencode options: '${encopts[@]}'" 1>&2
  #echo "$0: output options   : '${outopts[@]}'" 1>&2
  #echo "$0: running command:" 1>&2
  echo "fsmencode ${encopts[@]} $infile $keyfile | fsmrmepsilon | fsmdeterminize | fsmminimize | fsmencode -d ${encopts[@]} - $keyfile ${outopts[@]}" 1>&2
fi

fsmencode "${encopts[@]}" "$infile" "$keyfile" \
 | fsmrmepsilon | fsmdeterminize | fsmminimize \
 | fsmencode -d "${encopts[@]}" - "$keyfile" "${outopts[@]}"
