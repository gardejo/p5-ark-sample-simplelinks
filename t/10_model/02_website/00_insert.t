use strict;
use warnings;
use local::lib;

use Module::Load;
use Test::More 0.87_01;

use lib 't/lib';
use lib 'extlib';

use SimpleLinks::Test::Constant;

load $Service_Class;

my $links = $Service_Class->new($Builder_Option_Of_Database);

{
    # no website
    my @websites     = $links->websites;
    my @all_websites = $links->all_websites;
    is( scalar @websites,       0, 'no website ok (scalar @websites)' );
    is( scalar @all_websites,   0, 'no website ok (scalar @all_websites)' );
    is( $links->count_websites, 0, 'no website ok (count_websites)' );
}

{
    # insert website
    my $title = 'foobar';
    my $uri   = 'http://foobar.example/';

    my $new_website = $links->add_website({
        title   => $title,
        uri     => $uri,
    });
    ok( $new_website, 'create website ok' );
    isa_ok( $new_website, 'Data::Model::Row' );
    isa_ok( $new_website, $Model_Class . '::website' );

    my @websites     = $links->websites;
    my @all_websites = $links->all_websites;
    is( scalar @websites,       1, 'count 1 ok (scalar @websites)' );
    is( scalar @all_websites,   1, 'count 1 ok (scalar @all_websites)' );
    is( $links->count_websites, 1, 'count 1 ok (count_websites)' );

    is( $websites[0]->title, $title, 'tile ok' );
    is( $websites[0]->uri,   $uri,   'uri ok' );
}

done_testing();

1;
__END__
