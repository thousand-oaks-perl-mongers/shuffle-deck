package Mongers::Shuffle;

use warnings;
use strict;

sub shuffle {
    my ($deck) = @_;
    my $deck_copy = [ @$deck ];

    my $new_deck = [];

    while ( scalar @$deck_copy ) {
        my $deck_size = scalar(@$new_deck);
        my $putter = int(rand($deck_size));

        splice( @$new_deck, $putter, 0, shift @$deck_copy );
    }
    return $new_deck;
}

1;
