#!perl -T

use strict;
use warnings;
use local::lib;

use Module::Load;
use Test::Exception;
use Test::More 0.87_01;

use lib 'extlib';
use lib 't/lib';

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
    # create a new website
    my $name = 'foobar';
    my $uri  = 'http://foobar.example/';
    my $new_website = $links->add_website({
        name    => $name,
        uri     => $uri,
    });
    ok( $new_website, 'create website ok' );
    isa_ok( $new_website, 'Data::Model::Row' );
    isa_ok( $new_website, $Model_Class . '::website' );

    # website was created (read websites)
    my @websites     = $links->websites;
    my @all_websites = $links->all_websites;
    is( scalar @websites,       1, 'count 1 ok (scalar @websites)' );
    is( scalar @all_websites,   1, 'count 1 ok (scalar @all_websites)' );
    is( $links->count_websites, 1, 'count 1 ok (count_websites)' );

    # created website has same column-values as query
    is( $websites[0]->name, $name, 'name ok' );
    # diag $uri;
    isa_ok( $websites[0]->uri, 'URI');
    is( $websites[0]->uri->as_string,  $uri, 'uri ok' );
}

# exception: duplicated URIs


# exception: duplicated not an URI
# あぁ、良く考えたらMoose/MouseのX::Types::URIも通しているね。http, https限定にするか。
{
    throws_ok {
        $links->add_website({
            name        => 'name',
            uri         => 'this is not an URI',
        });
    } qr{Attribute \(uri\) does not pass the type constraint because: Validation failed for SimpleLinks::Schema::Column failed with value this%20is%20not%20an%20URI},
        'not a http(s) ok';
}

done_testing();

1;
__END__
