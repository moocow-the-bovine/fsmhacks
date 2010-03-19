#!/usr/bin/perl -w

use Getopt::Long qw(:config no_ignore_case);
use Pod::Usage;
use File::Basename qw(basename);
use Encode qw(encode decode);
use Gfsm;

##----------------------------------------------------------------------
## Globals
##----------------------------------------------------------------------

our $VERSION = "0.01";

##-- program vars
our $prog     = basename($0);
our $verbose  = 2;

our $input_labfile = undef;
our $input_encoding = undef;
our $output_fsmfile = '-';
our $check_labels = 1;

select(STDERR); $|=1; select(STDOUT);

##----------------------------------------------------------------------
## Command-line processing
##----------------------------------------------------------------------
GetOptions(##-- general
	   'help|h' => \$help,
	   'man|m'  => \$man,
	   'version|V' => \$version,
	   'verbose|v=i' => \$verbose,

	   ##-- misc
	   'check|c!' => \$check_labels,
	   'input-labels|il|l|input-alphabet|ia|a=s' => \$input_labfile,
	   'input-encoding|ie|e=s' => \$input_encoding,
	   'output-trie|ot|output-fsm|ofsm|of|F=s' => \$output_fsmfile,
	  );

pod2usage({-exitval=>0, -verbose=>0}) if ($help);
pod2usage({-exitval=>0, -verbose=>1}) if ($man);

if ($version) {
  print STDERR "$prog version $VERSION by Bryan Jurish\n";
  exit 0;
}

##----------------------------------------------------------------------
## Subs: messages
##----------------------------------------------------------------------

## undef = vmsg($level,@msg)
##  + print @msg to STDERR if $verbose >= $level
sub vmsg {
  my $level = shift;
  print STDERR (@_) if ($verbose >= $level);
}

##----------------------------------------------------------------------
## MAIN
##----------------------------------------------------------------------
push(@ARGV, '-') if (!@ARGV);

##-- initialize alphabet
our $abet = Gfsm::Alphabet->new();
if (defined($input_labfile)) {
  vmsg(2,"$prog: loading input labels '$input_labfile'...");
  $abet->load($input_labfile)
    or die("$prog: load failed for input labels file '$input_labfile': $!");
  vmsg(2,"loaded.\n");
}
##-- ensure epsilon
if (!defined($abet->find_key(0))) {
  $abet->get_label('<epsilon>', 0);
}

##-- get alphabet hash
our $abeth = $abet->asHash;

##-- initialize FSM
#our $fsm = Gfsm::Automaton->newTrie();
our $fsm = Gfsm::Automaton->new();
if (defined($input_fsmfile)) {
  vmsg(1,"$prog: loading input FSM '$input_fsmfile'...");
  $fsm->load($input_fsmfile)
    or die("$prog: load failed for input FSM file '$input_fsmfile': $!");
  vmsg(1,"$prog: loaded.\n");
} else {
  $fsm->semiring_type($Gfsm::SRTReal);
}

##-- ensure root state exists
$fsm->root($fsm->add_state()) if ($fsm->root == $Gfsm::noState);

##-- process corpora
our ($w,$f,$rest, @chrs,@labs,$lab);
foreach $ttfile (@ARGV) {
  vmsg(2,"$prog: processing lexf file: $ttfile ...");

  open(TT,"<$ttfile") or die("$prog: open failed for '$ttfile': $!");
  $i=-1;
  while (<TT>) {
    vmsg(2,'.') if (($i++ % 1000) == 0);
    chomp;
    next if (/^\s*$/ || /^\%%/); ##-- ignore comments & blank lines
    ($w,$f,$rest) = split(/\t/,$_,3);
    $f = 0 if (!defined($f));

    $w = decode($input_encoding,$w) if (defined($input_encoding));

    @chrs = split(//,$w);
    if (!$check_labels) {
      @labs = map {defined($_) ? $_ : $Gfsm::noLabel} @$abeth{@chrs};
    } else {
      @labs = map {
	warn("$prog: no label for input character '$chrs[$_]'") if (!defined($lab=$abeth->{$chrs[$_]}));
	defined($lab) ? $lab : $Gfsm::noLabel
      } (0..$#chrs)
    }

    $fsm->add_path(\@labs,[],$f, 0,0,1);
  }

  vmsg(2," done.\n");
}

##-- save stuff
if (defined($output_labfile)) {
  vmsg(2,"$prog: saving output labels file '$output_labfile'... ");
  $abet->save($output_labfile)
    or die("$prog: save failed for labels file '$output_labfile': $!");
  vmsg(2,"saved.\n");
}

if (defined($output_fsmfile)) {
  vmsg(2,"$prog: saving output GFSM file '$output_fsmfile'... ");
  $fsm->save($output_fsmfile)
    or die("$prog: save failed for fsm file '$output_fsmfile': $!");
  vmsg(2,"saved.\n");
}

__END__

###############################################################
## pods
###############################################################

=pod

=head1 NAME

gfsm-lexf-maketrie.perl - convert a .lexf (TEXT,COST) file to to a prefix tree acceptor

=head1 SYNOPSIS

 corpus2pta.perl OPTIONS [LEXF_FILE(s)]

 General Options:
   -help
   -version
   -verbose LEVEL

 Misc Options:
   -check , -nocheck                       # do/don't check for undefined labels (default=do)
   -input-labels   LABFILE , -il  LABFILE  # initial labels
   -output-fsm    GFSMFILE , -of GFSMFILE  # output FSM
   -output-labels  LABFILE , -ol  LABFILE  # output labels

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

Bryan Jurish E<lt>jurish@uni-potsdam.deE<gt>

=head1 SEE ALSO

perl(1), Gfsm(3pm).

=cut

