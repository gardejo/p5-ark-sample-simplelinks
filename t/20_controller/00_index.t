use strict;
use warnings;
use local::lib;

use Module::Load;
use Test::More 0.87_01;

use lib 't/lib';
use lib 'extlib';

use SimpleLinks::Test::Constant;

ok(1, 'dummy');

done_testing();

1;
__END__
