package Mongers::Shuffle;

use warnings;
use strict;

sub shuffle {
    my ($deck) = @_;
    my $deck_copy = [ @$deck ];

    # print "START INCOMING DECK\n";
    # print join ",", @$deck_copy;
    # print "\n-----\n\n-----\n";
    # print join ",", @$deck;
    # print "\nEND INCOMING DECK\n\n";



    my %deckHash = map {$_ => 1} @$deck_copy;
    my $new_deck = [keys %deckHash];

    # print "START OUTGOING DECK\n";
    # print join ",", @$new_deck;
    # print "\nEND OUTGOING DECK\n\n";

    return $new_deck;
}

1;
