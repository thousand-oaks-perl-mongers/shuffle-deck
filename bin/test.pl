use strict;
use warnings;

use lib '../lib/perl';

use Mongers::Shuffle::Evaluate;

print Mongers::Shuffle::Evaluate::score_hand( [ qw( 8:D 14:C 1:C 3:D 11:h )] ) , "\n";

