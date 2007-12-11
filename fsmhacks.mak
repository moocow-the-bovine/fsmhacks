## -*- Mode: Makefile -*-
##
## File: *fst*/fsthacks.mak
## Author: Bryan Jurish <moocow@ling.uni-potsdam.de>
## Description: common rules for FSM stuff
##--------------------------------------------------------------

##======================================================================
## Variables
##======================================================================

##--------------------------------------------------------------
## Files: alphabets
sym     ?= symbols.sym
SYMFILE  = $(sym)
LABFILE ?= $(SYMFILE:.sym=.lab)
SCLFILE ?= $(SYMFILE:.sym=.scl)
LABSCL   = $(LABFILE) $(SCLFILE)
LABARGS ?= -l $(LABFILE) -S $(SCLFILE)
IOARGS  ?= -i $(LABFILE) -o $(LABFILE)

##--------------------------------------------------------------
## Programs
fsmcompact ?= fsmcompact.sh

##======================================================================
## Rules
##======================================================================

##--------------------------------------------------------------
## default rule
all: $(TARGETS)

##--------------------------------------------------------------
## Save all intermediate files
.SECONDARY:

##--------------------------------------------------------------
## AT&T FSM: Compilation: symbols

lab: labscl
labs: labscl
labscl: $(LABFILE) $(SCLFILE)

%.lab %.scl: %.sym
	lexmakelab $*

##----------------------------------------------------------------------
## Compilation: .lex -> .lex(+(m|M)?).afsm

%.rul.afst: %.rul $(LABSCL)
	@echo "Compiling `grep '[-=]>' $< | grep -v '#.*[-=]>' | wc -l` CS rules to $@..."
	lexrulecomp $(LABARGS) -F $@ $<

##----------------------------------------------------------------------
## AT&T FSM: Compilation: .lex -> .lex(+(m|M)?).afst

%.lex.afst: %.lex $(LABSCL)
	lexcomplex $(LABARGS) -F $@ $<

%.lex+m.afst: %.lex $(LABSCL)
	lexcomplex -m $(LABARGS) -F $@ $<

%.lex+M.afst: %.lex $(LABSCL)
	lexcomplex -M $(LABARGS) -F $@ $<

##----------------------------------------------------------------------
## AT&T FSM: Compilation: .re -> .afst

%.afst: %.re $(LABSCL)
	lexcompre $(LABARGS) -s "`cat $<`" -F $@ 

##----------------------------------------------------------------------
## AT&T FSM: Basic regexes

sigma.afst: $(LABSCL)
	lexcompre $(LABARGS) -s "[<sigma>]" -F $@

sigma-star.afst: $(LABSCL)
	lexcompre $(LABARGS) -s "[<sigma>]*" -F $@

sigma-plus.afst: $(LABSCL)
	lexcompre $(LABARGS) -s "[<sigma>]+" -F $@

##----------------------------------------------------------------------
## AT&T FSM: operations

star{%}.afst: %.afst
	fsmclosure -F $@ $<

plus{%}.afst: %.afst
	fsmclosure -p -F $@ $<

not{%}.afst: sigma-star.afst %.afst
	fsmdifference $^ -F $@

proj1{%}.afst: %.afst
	fsmproject -1 $< -F $@

proj2{%}.afst: %.afst
	fsmproject -2 $< -F $@

rme{%}.afst: %.afst
	fsmrmepsilon $< -F $@

det{%}.afst: rme{%}.afst
	fsmdeterminize $< -F $@

min{%}.afst: det{%}.afst
	fsmminimize $< -F $@

invert{%}.afst: %.afst
	fsminvert $< -F $@

compact{%}.afst: %.afst
	test -n "$(fsmcompact)" && "$(fsmcompact)" $< -F $@ || (rm -f $@ && ln $< $@)

notdom{%}.afst: %.afst sigma-star.afst
	fsmproject -1 $< \
	| fsmconcat sigma-star.afst - sigma-star.afst \
	| fsmrmepsilon | fsmdeterminize \
	| fsmdifference sigma-star.afst - \
	| fsmrmepsilon \
	| fsmdeterminize -F $@

locext{%}.afst: %.afst notdom{%}.afst
	fsmconcat $^ \
	| fsmclosure \
	| fsmconcat notdom{$*}.afst - \
	| fsmrmepsilon -F $@



##--------------------------------------------------------------
## Conversion

##-- conversion: * -> *.gfst
%.afst.gfst: %.afst
	fsm2gfsm.sh $< -F $@
%.ofst.gfst: %.ofst
	fstprint --numeric=true $< | gfsmcompile -F $@

##-- conversion: .gfst <-> *.gfsx
%.gfst.gfsx: %.gfst
	gfsmindex $< -F $@
%.gfsx.gfst: %.gfsx
	gfsmindex -u $< -F $@


##-- conversion: * -> *.ofst
%.afst.ofst: %.afst
	fsm2gfsm.sh $< -F $@
%.gfst.ofst: %.gfst
	gfsmconvert -t1 $< | gfsmprint | fstcompile - $@

##-- conversion: * -> *.afst
%.gfst.afst: %.gfst
	gfsmconvert -t1 $< | gfsmprint | fsmcompile -t > $@ || (rm -f $@; false)
%.ofst.afst: %.ofst
	fstprint --numeric=true $< | fsmcompile -t > $@ || (rm -f $@; false)

##----------------------------------------------------------------------
## Compilation: text -> *

##-- afsm
%.afst: %.tfst
	fsmcompile -t $< -F $@

%.afst: %.tfsa
	fsmcompile    $< -F $@

##-- gfsm
%.gfst: %.tfst
	gfsmcompile $< -F $@
%.gfst: %.tfsa
	gfsmcompile -a $< -F $@

##-- ofsm
%.ofst: %.tfsa
	fstcompile --acceptor=true $< $@
%.ofst: %.tfst
	fstcompile --acceptor=false $< $@

##--------------------------------------------------------------
## AT&T FSM: Decompilation: .afst -> .tfs[at]

##-- Decompilation: at&t
%.afst.tfst: %.afst
	if test `fsm-is-transducer.sh $<` = "y" ; then \
	  fsmprint $< > $@ || (rm -f $@; false) ;\
	else \
	  fsmprint $< \
	    | $(PERL) -pe 's/^(\S+)\s+(\S+)\s+(\S+)(.*)/$$1\t$$2\t$$3\t$$3\t$$4/' \
	    > $@ || (rm -f $@; false); \
	fi
%.afst.tfsa: %.afst
	if test `fsm-is-transducer.sh $<` = "y" ; then \
	  fsmproject -1 $< | fmprint > $@ || (rm -f $@; false); \
	else \
	  fsmprint $< > $@ || (rm -f $@; false) ;\
	fi


##-- Decompilation: gfsm
%.gfst.tfst: %.gfst
	if test `gfsm-is-transducer.sh $<` = "y" ; then \
	  gfsmprint $< > $@ || (rm -f $@; false) ;\
	else \
	  gfsmcomvert -t1 $< | gfsmprint > $@ || (rm -f $@; false) ;\
	fi
%.gfst.tfsa: %.gfst
	if test `gfsm-is-transducer.sh $<` = "y" ; then \
	  gfsmproject -1 $< | gfsmprint > $@ || (rm -f $@; false); \
	else \
	  gfsmprint $< > $@ || (rm -f $@; false) ;\
	fi



##-- Decompilation: ofsm
%.ofst.tfst: %.ofst
	fstprint --numeric=true $< $@

##-- text-level conversion: .tfst -> .tfsa
%.tfsa: %.tfst
	perl -n -e'chomp; @l=split; splice(@l,3,1) if (@l>2); print join("\t",@l),"\n";' \
	  < $< > $@ || (rm -f $@; false)

##----------------------------------------------------------------------
## Test: input lookup

w      ?= myword
lookup ?= myafsm

wlookup: $(lookup).afst $(LABSCL) _wlookup
_wlookup:
	@echo "-- lookup($(lookup).afst,\"$(w)\"):"
	@lexcompre $(LABARGS) -x -s "$(w)"\
	| fsmcompose - $(lookup).afst \
	| lexfsmstrings $(LABARGS) \
	| sort -t'<' -k2 -n

wglookup: $(lookup).gfst $(LABFILE) _wglookup
_wglookup:
	@echo "-- glookup($(lookup),\"$(w)\"):"
	@gfsmlookup -f $(lookup).gfst `echo "$(w)" | gfsmlabels -l $(LABFILE)` \
	| gfsmstrings -i $(LABFILE) -o $(LABFILE) \
	| perl -p -e 'chomp;' \
	  -e '($$in,$$out)=split(/\s+\:\s+/,$$_,2);' \
	  -e '$$_=join("",split(/\s+/,$$in)) . "\t" . $$out . "\n";'

##----------------------------------------------------------------------
## visualization

aview: $(fsm) $(LABFILE)
	fsmviewps.sh -i $(LABFILE) -o $(LABFILE) $(fsm)

gview: $(fsm) $(LAB)
	gfsmview.sh -i $(LABFILE) -o $(LABFILE) $(fsm)

##----------------------------------------------------------------------
## cleanup: general
no-afsm:
	rm -f *.afs[atm]
no-gfsm:
	rm -f *.gfs[atm]
no-ofsm:
	rm -f *.ofs[atm]

no-fsm: no-afsm no-gfsm no-ofsm
