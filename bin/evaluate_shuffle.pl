use strict;
use warnings;

use lib '../lib/perl';

use Mongers::Shuffle::Evaluate;

Mongers::Shuffle::Evaluate::execute( { count => 10000 } );

