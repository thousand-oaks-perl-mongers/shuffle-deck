package Mongers::Shuffle;

use warnings;
use strict;
#use lib "$FindBin::Bin/../lib";
use Array::Shuffle 'shuffle_huge_array';

sub shuffle {
    my ($deck) = @_;
    my $deck_copy = [ @$deck ];

    shuffle_huge_array(@{$deck_copy});
    return $deck_copy;
}

1;
