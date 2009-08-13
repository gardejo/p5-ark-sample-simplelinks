#!perl -T

use strict;
use warnings;
use local::lib;

use Module::Load;
use Test::Exception;
use Test::More 0.87_01;
use Time::HiRes qw(time);

use lib 'extlib';
use lib 't/lib';

use SimpleLinks::Test::Constant;
load $Service_Class;

my $links = $Service_Class->new($Builder_Option_Of_Database);

{
    # exception: is not leaf
    my $root_category = $links->add_category({
        name    => 'root_name' . time,
        slug    => 'root_slug' . time,
    });
    my $node_category = $links->add_category({
        name    => 'node_name' . time,
        slug    => 'node_slug' . time,
        parent  => $root_category,
    });
    my $leaf_category = $links->add_category({
        name    => 'leaf_name' . time,
        slug    => 'leaf_slug' . time,
        parent  => $node_category,
    });
    $root_category->reload;
    $node_category->reload;
    my $count_categories = $links->count_categories;

    # leaf
    throws_ok {
        $root_category->delete;
    } qr{Cannot remove category because category is not a leaf},
        'Cannot remove category because category is not a leaf';
    is( $count_categories, $links->count_categories, 'same count ok' );

    # node
    throws_ok {
        $node_category->delete;
    } qr{Cannot remove category because category is not a leaf},
        'Cannot remove category because category is not a leaf';
    is( $count_categories, $links->count_categories, 'same count ok' );
}


done_testing();

1;
__END__
