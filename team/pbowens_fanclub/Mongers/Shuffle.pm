package Mongers::Shuffle;

use warnings;
use strict;
#use lib "$FindBin::Bin/../lib";
use Array::Shuffle 'shuffle_huge_array';

sub shuffle {
    my ($deck) = @_;

    shuffle_huge_array(@{$deck});
    return $deck;
}

1;
