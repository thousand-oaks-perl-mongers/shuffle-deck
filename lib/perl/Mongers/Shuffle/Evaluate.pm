package Mongers::Shuffle::Evaluate;

use Mongers::Shuffle;

use warnings;
use strict;

use List::MoreUtils qw( uniq );

my $hands_scored = {};
my $hand_count   = 0;

my $ideal_ratio = {
    royal_flush    => 1 / 649739,
    straight_flush => 1 / 72192,
    four_of_a_kind => 1 / 4164,
    full_house     => 1 / 693,
    flush          => 1 / 508,
    straight       => 1 / 254,
    three_of_kind  => 1 / 46.3,
    two_pair       => 1 / 20,
    pair           => 1 / 1.37,
    high_card      => 1 / .995,
    unknown        => 0,
};

my $base_deck = [];

foreach my $suit (qw ( C D H S )) {
    my $number = 1;
    while ( $number <= 13 ) {
        my $card = $number . ':' . $suit;
        push @$base_deck, $card;
        $number++;
    }
}

sub execute {
    my $args  = shift;
    my $deck  = [@$base_deck];        # Make a copy
    my $hands = [ [], [], [], [] ];

    for ( my $count = 0 ; $count < $args->{count} ; $count++ ) {
        foreach my $hand (@$hands) {
            foreach my $card (@$hand) {
                push @$deck, $card;
            }
        }

        $hands = [ [], [], [], [] ];

        my $shuffled_deck = Mongers::Shuffle::shuffle($deck);
        for ( my $rotation = 0 ; $rotation < 5 ; $rotation++ ) {
            for ( my $player = 0 ; $player < 4 ; $player++ ) {
                push @{ $hands->[$player] }, shift @$deck;
            }
        }
        foreach my $hand (@$hands) {
            $hand_count++;
            my $hand_type = score_hand($hand);
            $hands_scored->{$hand_type}++;
        }
    }

    my $stats = {};
    foreach my $hand_type ( keys %$hands_scored ) {
        my $count    = $hands_scored->{$hand_type};
        my $ratio    = $count / $hand_count;
        my $expected = $ideal_ratio->{$hand_type};
        my $delta    = ( ( $ratio - $expected ) / $expected ) * 100;

        $stats->{$hand_type} = {
            count    => $count,
            ratio    => $ratio,
            delta    => $delta,
            expected => $expected,
        };
    }

    report_stats($stats);
}

sub report_stats {
    my $stats = shift;
    foreach my $hand_type (
        qw(
        royal_flush
        straight_flush
        four_of_a_kind
        full_house
        flush
        straight
        three_of_kind
        two_pair
        pair
        high_card
        unknown
        )
      )
    {
        print $hand_type . ":\n";

        my $expected_count = int($ideal_ratio->{$hand_type}*$hand_count);
            print "\tExpected Count: " . ( $expected_count || 0 ) . "\n";
        foreach my $stat (qw( count delta ratio expected )) {
            print "\t" . $stat . ": " . ( $stats->{$hand_type}->{$stat} || 0 ) . "\n";
        }
    }
}

sub score_hand {
    my $hand       = shift;
    my $hand_type = 'unknown';
    my $split_hand = [];
    foreach my $card (@$hand) {
        my ( $number, $suit ) = split( /:/, $card );
        push @$split_hand, { suit => $suit, number => $number };
    }
    my $unique_number = scalar( uniq( map { $_->{number} } @$split_hand ) );

    # Check for hands
    # Flushes
    if ( scalar( uniq( map { $_->{suit} } @$split_hand ) ) == 1 ) {
        # it's a flush!
        my @sorted_numbers = sort { $a <=> $b } map { $_->{number} } @$split_hand;
        if ( $sorted_numbers[4] - $sorted_numbers[0] == 4 ) {
            # It's a straight
            if ( $sorted_numbers[4] == 13 ) {
                # The High Card is an Ace (Royal Flush)
                $hand_type='royal_flush';
            }
            else {
                $hand_type='straight_flush';
            }
        }
        else {
            $hand_type='flush';
        }
    }
    # Number of a kind
    elsif ( $unique_number == 5 ) {
        my @sorted_numbers =
          sort { $a <=> $b } ( map { $_->{number} } @$split_hand );
        if ( $sorted_numbers[4] - $sorted_numbers[0] == 4 ) {
            $hand_type='straight';
        }
        else {
            $hand_type='high_card';
        }
    }
    elsif ( $unique_number == 4 ) {
        $hand_type='pair';
    }
    elsif ( $unique_number == 3 ) {
        my $sorted_hand = {};
        foreach my $card (@$split_hand) {
            $sorted_hand->{ $card->{number}}++;
        }
        if ( grep { /3/ } values %$sorted_hand ) {

            #Three of a kind
            $hand_type='three_of_kind';
        }
        else {
            # Two Pair
            $hand_type='two_pair';
        }
    }
    elsif ( $unique_number == 2 ) {
        my $sorted_hand = {};
        foreach my $card (@$split_hand) {
            $sorted_hand->{ $card->{number} }++;
        }

        #Possible four of a kind or full house
        if ( grep { /4/ } values %$sorted_hand ) {

            # Four of a kind
            $hand_type='four_of_a_kind';
        }
        else {
            $hand_type = 'full_house';
        }
    }
    else {
        # Cheater! (unknown)
    }
    return $hand_type;
}

1;

