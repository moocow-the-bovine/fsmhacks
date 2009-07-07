#!/usr/bin/perl -w

use Gfsm;

if (!@ARGV) {
  print STDERR "Usage: $0 GFSM_FILE\n";
  exit 1;
}
$gfsmfile = shift;

our $fsm = Gfsm::Automaton->new();
$fsm->load($gfsmfile)
  or die("$0: load failed for '$gfsmfile': $!");

my $sr  = Gfsm::Semiring->new($fsm->semiring_type);
my $sr1 = $sr->one;
my $sr0 = $sr->zero;
my $nq = $fsm->n_states();
foreach $q (0..($nq-1)) {
  if ($fsm->is_final($q) && ($fw=$fsm->final_weight($q)) != $sr1) {
    $qf = $fsm->add_state();
    $fsm->add_arc($q,$qf, 0,0, $fw);
    $fsm->is_final($q,0);
    $fsm->is_final($qf,1);
    $fsm->final_weight($qf,$sr1);
  }
}

$fsm->save(\*STDOUT);
