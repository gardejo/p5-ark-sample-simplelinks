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
    # websites exist (previous test)
    ok( $links->count_websites, 'websites exist ok (created by previous tests)' );
}

{
    # delete all websites
    $links->delete_all_websites;
    ok( ! $links->count_websites, 'no website exists ok (all websites were removed)' );
}

{
    # delete all (delete no websites)
    $links->delete_all_websites;
    ok( ! $links->count_websites, 'no website exists ok (no websites removed)' );
}

{
    # delete an existent website
    my $new_website_a = $links->add_website({
        name => 'name_a' . time,
        uri  => 'http://uri_a.example/' . time,
    });
    my $new_website_b = $links->add_website({
        name => 'name_b' . time,
        uri  => 'http://uri_b.example/' . time,
    });
    is( $links->count_websites, 2, '2 websites exist ok' );

    lives_ok {
        $new_website_a->delete;
    } 'delete an existent website ok';
    is( $links->count_websites, 1, '1 website exists ok (a was deleted)' );
    is( $new_website_a, undef, 'undef ok' );
}


done_testing();

1;
__END__
