#!perl -T

use strict;
use warnings;
use local::lib;

use Test::More 0.87_01;

use lib 'extlib';
use lib 't/lib';

use SimpleLinks::Test::Cleanup;
use SimpleLinks::Test::Constant;

BEGIN {
    use_ok($Service_Class);
}

my $links = $Service_Class->new($Builder_Option_Of_Database);
isa_ok($links, $Service_Class);

ok( ! -f $Database_Name, sprintf('database (%s) not exists', $Database_Name) );

diag sprintf 'create database (%s)',
    $Database_Name;
my $model = $links->model;
isa_ok($model, $Model_Class);


done_testing();

1;
__END__
