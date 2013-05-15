#!/bin/bash

## filename=`fsm_tempfile PREFIX SUFFIX`
fsm_tempfile() {
  if test -n "`which tempfile 2>/dev/null`" ; then
   tempfile --prefix="$1" --suffix="$2"
  else
    echo "/tmp/$1_$$$2"
  fi
}

test -n "$drawcmd" || drawcmd=gfsmdraw
test -n "$dotcmd" || dotcmd=dot
test -n "$dotenc" || dotenc="latin1"

test -n "$psviewer"  || psviewer='gv -spartan'
test -n "$pdfviewer"  || pdfviewer=xpdf
test -n "$pngviewer" || pngviewer=`which eog`
 test -n "$pngviewer" || pngviewer=`which geeqie`
 test -n "$pngviewer" || pngviewer=`which xloadimage`
test -n "$svgviewer" || svgviewer=`which sensible-browser`
test -n "$dotviewer"  || dotviewer=dotty

drawargs=()
dotfilter=(egrep -v '^[ ]*(rotate|size|orientation)[ ]*=')
dotfmt=ps
dotargs=()
viewcmd=($psviewer -noantialias)
viewargs=()
aaargs=()

argmode="draw"

for a in "$@" ; do
  case "$a" in
    ##-- dot + view mode
    -ps|-gv)
      dotfmt="ps"
      viewcmd=($psviewer)
      ;;
    -pdf|-xpdf)
      dotfmt="pdf"
      viewcmd=($pdfviewer)
      ;;
    -png)
      dotfmt="png"
      viewcmd=($pngviewer)
      ;;
    -svg)
      dotfmt="svg"
      viewcmd=($svgviewer)
      ;;
    -dotty)
      dotfmt="dot"
      viewcmd=($dotviewer)
      ;;
    -dot)
      dotfmt="dot"
      viewcmd=(cat)
      ;;

    ##-- viewer
    -viewer=*|-view=*|-v=*|-gv=*)
      viewcmd=(${a#*=})
      ;;

    ##-- encoding
    -e=*)
      dotenc="${a#-e=}"
      ;;

    ##-- antialiasing
    -aa|-antialias)
      aaargs=(-antialias)
      ;;
    -noaa|-noantialias)
      aaargs=(-noantialias)
      ;;

    ##-- dot-arguments
    -do=*)
      dotargs[${#dotargs[@]}]="${a#-do=}"
      ;;

    ##-- viewer-arguments
    -vo=*)
      viewargs[${#viewargs[@]}]="${a#-vo=}"
      ;;

    ##-- draw / dot / viewer arguments with --
    --)
      if test "$argmode" = "draw" ; then
       argmode="dot"
      else
       argmode="view"
      fi
      ;;

    *)
      #echo "[$argmode] arg=$a" >&2
      if test "$argmode" = "draw" ; then
	drawargs[${#drawargs[@]}]="$a"
      elif test "$argmode" = "dot" ; then
        dotargs[${#dotargs[@]}]="$a"
      else
        viewargs[${#viewargs[@]}]="$a"
      fi
      ;;
  esac
done

test -n "$dotfile" || dotfile=`fsm_tempfile gfsmview .dot`
fmtfile="${dotfile}.${dotfmt}"

test "$dotfmt" = "ps" && viewargs=("${viewargs[@]}" "${aaargs[@]}")

system() {
  #echo "$0: $@" >&2
  "$@"
}

system "$drawcmd" "${drawargs[@]}" | system "${dotfilter[@]}" > "$dotfile" \
 && system "$dotcmd" "${dotargs[@]}" -Gcharset="$dotenc" -T"$dotfmt" -o"$fmtfile" "$dotfile" \
 && system "${viewcmd[@]}" "${viewargs[@]}" "$fmtfile" \
 && system rm -f "$dotfile" "$fmtfile"

