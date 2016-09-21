package Mongers::Shuffle;

use warnings;
use strict;

sub shuffle {
    my ($deck) = @_;
    my $deck_copy = [ @$deck ];
    my $deck_size = scalar(@$deck_copy);
#    for (my $counter = 1; $counter < 4; $counter++ ){
        my @new_deck;
        my $cut = int(rand($deck_size/6)) + int($deck_size / 3 );
        my @top_half = @$deck_copy[0..$cut];
        my @bottom_half = @$deck_copy[$cut+1..$deck_size-1];
        while (scalar(@top_half) || scalar(@bottom_half) ) {
            if (scalar(@top_half) ) {
                push @new_deck, shift @top_half;
            }
            if ( scalar(@bottom_half) ) {
                push @new_deck, shift @bottom_half;
            }
        }
        $deck_copy = \@new_deck;
#    }
    return $deck_copy;
}

1;
