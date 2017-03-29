#!/usr/bin/perl -w

use Getopt::Long qw(:config no_ignore_case);
use Pod::Usage;
use File::Basename qw(basename);
use Encode qw(encode decode);
use bytes;
no bytes;

##----------------------------------------------------------------------
## Globals
our $VERSION = "0.02";

##-- program vars
our $progname = basename($0);
our $verbose  = 1;

##-- encodings
our $input_encoding = 'latin1';
our $output_encoding = undef;   ##-- default: input encoding
our $escape_regops = 1;		##-- escape AT&T regex operators?
our $escape_utf8 = 1;           ##-- escape characters which are multibyte in utf-8?
our $input_words = 0;           ##-- boolean: process files or words?
our $outfile = '-';

##----------------------------------------------------------------------
## Command-line processing
GetOptions(##-- general
	   'help|h' => \$help,
	   'version|V' => \$version,
	   'verbose|v=i' => \$verbose,

	   ##-- Encoding
	   'input-encoding|ie|encoding|e=s' => \$input_encoding,
	   'output-encoding|oe=s' => \$output_encoding,
	   'escape-regops|r!' => \$escape_regops,
	   'keep-regops|regops|R' => sub { $escape_regops=0; },
	   'escape-utf8|u!' => \$escape_utf8,
	   'all-utf8|utf8|U' => sub { $input_encoding=$output_encoding='utf8'; $escape_utf8=1; },

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
## Subs: process a single string
sub process_string {
  $s_in = shift;
  chomp($s_in);
  $s_in = decode($input_encoding,$s_in) if ($input_encoding);
  $s_in =~ s/([\*\+\^\?\!\|\&\:\@\-\(\)\[\]\#])/\\$1/g if ($escape_regops);
  if ($escape_utf8) {
    $s_out = join('', map {ord($_) >= 0x80 ? "[$_]" : $_} split(//,$s_in));
  } else {
    $s_out = $s_in;
  }
  $s_out = encode($output_encoding,$s_out) if ($output_encoding);
  print OUT $s_out, "\n";
}

##----------------------------------------------------------------------
## MAIN
$output_encoding = $input_encoding if (!defined($output_encoding));
open(OUT,">$outfile") or die("$0: open failed for '$outfile': $!");
binmode(OUT,":raw");

if ($input_words) {
  process_string("$_\n") foreach (@ARGV);
} else {
  while (<>) {
    process_string($_);
  }
}

__END__
###############################################################
## pods
###############################################################

=pod

=head1 NAME

fsm-att-escape.perl - add at&t lextools escapes to input file(s)

=head1 SYNOPSIS

 fsm-att-escape.perl OPTIONS [INPUT_FILE(s)_OR_WORD(s)...]

 General Options:
   -h, -help                  # this help message
   -V, -version               # output version and exit
   -v, -verbose LEVEL         # verbosity level (default=1)

 I/O Options:
   -w,  -words                     # inputs are words, not filenames
   -ie, -input-encoding ENCODING   # input encoding (default=latin1)
   -oe, -output-encoding ENCODING  # output encoding (defualt=(same as input))
   -r,  -[no]escape-regops         # do/don't escape AT&T regex operators (default=do)
   -R,  -keep-regops               # alias for -noescape-regops
   -u,  -[no]escape-utf8           # do/don't escape multibyte utf8 characters (default=do)
   -U,  -utf8                      # alias for -ie=utf8 -oe=utf8 -escape-utf8
   -o,  -output OUTFILE            # select output file (default=stdout)

=cut

###############################################################
## OPTIONS
###############################################################
=pod

=head1 OPTIONS

=cut

###############################################################
# General Options
###############################################################
=pod

=head2 General Options

=over 4

=item -help

Display a brief help message and exit.

=item -version

Display version information and exit.

=item -verbose LEVEL

Set verbosity level to LEVEL.  Default=1.

=back

=cut


###############################################################
# Other Options
###############################################################
=pod

=head2 Other Options

=over 4

=item -someoptions ARG

Example option.

=back

=cut


###############################################################
# Bugs and Limitations
###############################################################
=pod

=head1 BUGS AND LIMITATIONS

Probably many.

=cut


###############################################################
# Footer
###############################################################
=pod

=head1 ACKNOWLEDGEMENTS

Perl by Larry Wall.

=head1 AUTHOR

Bryan Jurish E<lt>moocow@ling.uni-potsdam.deE<gt>

=head1 SEE ALSO

perl(1).

=cut

