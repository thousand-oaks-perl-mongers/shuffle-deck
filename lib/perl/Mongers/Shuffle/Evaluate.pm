package Mongers::Shuffle::Evaluate;

use Mongers::Shuffle;

use warnings;
use strict;

use List::MoreUtils qw( uniq );

use Time::HiRes qw( gettimeofday tv_interval );

my $hands_scored = {};
my $hand_count   = 0;

my $possible_combinations = 2598960;

my $ideal_ratio = {
    royal_flush    => 4 / $possible_combinations,
    straight_flush => 36 / $possible_combinations,
    four_of_a_kind => 624 / $possible_combinations,
    full_house     => 3744 / $possible_combinations,
    flush          => 5108 / $possible_combinations,
    straight       => 10200 / $possible_combinations,
    three_of_kind  => 54912 / $possible_combinations,
    two_pair       => 123552 / $possible_combinations,
    pair           => 1098240 / $possible_combinations,
    high_card      => 1302540 / $possible_combinations,
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
    my $elapsed_time = 0;

    for ( my $count = 0 ; $count < $args->{count} ; $count++ ) {
        foreach my $hand (@$hands) {
            foreach my $card (@$hand) {
                push @$deck, $card;
            }
        }

        $hands = [ [], [], [], [] ];
        my $starttime = [ gettimeofday ];
        my $deck_copy = [ @$deck ];
        #use YAML;
        #print Dump $deck_copy;
        my $shuffled_deck = Mongers::Shuffle::shuffle($deck_copy);
        #print Dump $shuffled_deck;

        $elapsed_time += tv_interval( $starttime );
        
        for ( my $rotation = 0 ; $rotation < 5 ; $rotation++ ) {
            for ( my $player = 0 ; $player < 4 ; $player++ ) {
                push @{ $hands->[$player] }, shift @$shuffled_deck;
            }
        }
        foreach my $hand (@$hands) {
            $hand_count++;
            my $hand_type = score_hand($hand);
            $hands_scored->{$hand_type}++;
        }
        $deck = [ @$shuffled_deck ];
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

    print "Elapsed Time: $elapsed_time\n";
}

sub report_stats {
    my $stats = shift;
    my $absDelta = 0;
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
        $absDelta += abs($stats->{$hand_type}->{delta}) * $stats->{$hand_type}->{expected};
    }
    print "total abs delta $absDelta\n";
}

sub score_hand {
    my $hand       = shift;
    my $hand_type = 'unknown';
    my $split_hand = [];
    foreach my $card (@$hand) {
        my ( $number, $suit ) = split( /:/, $card );
        push @$split_hand, { suit => $suit, number => $number };
    #    print "$card => [$suit | $number]\n";
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

