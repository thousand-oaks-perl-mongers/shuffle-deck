package Mongers::Shuffle;

#use v5.20;
use warnings;
use strict;

use List::Util;

sub shuffle {
    my ($deck) = @_;
    my $deck_copy = [ @$deck ];

    my @new_deck = List::Util::shuffle(@$deck_copy);

    return \@new_deck;
}

1;
