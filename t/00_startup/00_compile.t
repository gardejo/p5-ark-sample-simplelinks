#!perl -T

use strict;
use warnings;
use local::lib;

use Test::More tests => 1;

# use lib 'extlib';
# use lib 't/lib';

BEGIN {
    use_ok 'SimpleLinks';
}

diag( "Testing SimpleLinks $SimpleLinks::VERSION" );
