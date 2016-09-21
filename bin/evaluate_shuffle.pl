use strict;
use warnings;

use lib '../lib/perl';

use Mongers::Shuffle::Evaluate;

Mongers::Shuffle::Evaluate::execute( { count => 1300000 } );
#Mongers::Shuffle::Evaluate::execute( { count => 130 } );

