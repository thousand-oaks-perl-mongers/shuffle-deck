package Mongers::Shuffle;

use warnings;
use strict;

sub shuffle {
    my ($deck) = @_;

    my @order = sort {rand(1000)>500} (0..(scalar(@$deck)-1));
    my $deck_copy =  [ @$deck[@order] ];


#	my %deckHash = map {$_ => 1} @$deck_copy;
# 	my $new_deck = [keys %deckHash];
    

    return $deck_copy;
}

1;
