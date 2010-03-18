#!/usr/bin/perl -w

while (<>) {
  chomp;
  @f = split(/\s+/,$_);
  next if ($#f >= 3 && $f[2]==0 && $f[3]!=0);
  print $_, "\n";
}
