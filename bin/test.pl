use strict;
use warnings;

use lib '../lib/perl';

use Mongers::Shuffle::Evaluate;

print Mongers::Shuffle::Evaluate::score_hand( [ qw( 10:C 9:C 11:C 12:C 13:C )] ) , "\n";

