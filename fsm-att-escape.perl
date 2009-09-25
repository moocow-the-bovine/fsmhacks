#!/usr/bin/perl -w

use Getopt::Long qw(:config no_ignore_case);
use Pod::Usage;
use File::Basename qw(basename);
use Encode qw(encode decode);
use bytes;
no bytes;

##----------------------------------------------------------------------
## Globals
our $VERSION = "0.01";

##-- program vars
our $progname     = basename($0);

##-- encodings
our $input_encoding = 'latin1';
our $output_encoding = undef;   ##-- default: input encoding
our $input_words = 0;  ##-- boolean: process files or words?
our $outfile = '-';

##----------------------------------------------------------------------
## Command-line processing
GetOptions(##-- general
	   'help|h' => \$help,
	   'version|V' => \$version,
	   'verbose|v=i' => \$verbose,

	   ##-- Encoding
	   'input-encoding|ie=s' => \$input_encoding,
	   'output-encoding|oe=s' => \$output_encoding,

	   ##-- I/O
	   'words|w!' => \$input_words,
	   'output|out|o|F=s' => \$outfile,

	  );

pod2usage({
	   -exitval=>0,
	   -verbose=>0
	  }) if ($help);

if ($version || $verbose >= 3) {
  print STDERR "$progname version $VERSION by Bryan Jurish\n";
  exit 0 if ($version);
}

##----------------------------------------------------------------------
## Encoding
$output_encoding = $input_encoding if (!defined($output_encoding));

while (defined($s_in=<>)) {
  chomp;
  $s_in = decode($input_encoding,$s_in) if ($input_encoding);
  $s_in =~ s/([\*\+\^\?\!\|\&\:\@\-\(\)\[\]\#])/\\$1/g;
  $s_in = encode($output_encoding,$s_in);
  $s_out = join('', map {bytes::length($_) > 1 ? "[$_]" : $_} split(//,$s_in));
  print $s_out;
}
