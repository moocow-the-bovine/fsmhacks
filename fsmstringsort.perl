#!/usr/bin/perl -w

# File: fsmstringsort.perl
# Description: sort output of lexfsmstrings
# Usage: lexfsmstrings ... | fsmstringsort.perl 

our $DEFAULT_COST=0;

our @strings = qw();
while (<>) {
  chomp;
  ($istr,$ostr_cost) = split(/\t/,$_,2);
  $istr = '' if (!defined($istr));
  if (!defined($ostr_cost)) {
    $ostr_cost = $istr;
    $istr =~ s/\<[^\>]*\>\}*$//;
  }
  if ($ostr_cost =~ /^(.*)\<(\d*\.?\d+)\>$/) {
    ($ostr,$cost) = ($1,$2);
  } else {
    ($ostr,$cost) = ($ostr_cost,0);
  }
  push(@strings,[$istr,$ostr,$cost]);
}
print
  map { join("\t", @$_[0,1], "<$_->[2]>")."\n" }
  sort { $a->[2] <=> $b->[2] || $a->[0] cmp $b->[0] || $a->[1] cmp $b->[1] }
  @strings;
