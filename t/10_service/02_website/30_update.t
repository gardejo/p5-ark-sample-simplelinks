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

# create a certain website for target of comparison
my $name = 'name' . time;
my $uri  = 'http://uri.example/' . time;
my $certain_website = $links->add_website({
    name    => $name,
    uri     => $uri,
});

{
    # create a new website for comparison
    my $old_name = 'old_name' . time;
    my $new_name = 'new_name' . time;
    my $old_uri  = 'http://old.example/' . time;
    my $new_uri  = 'http://new.example/' . time;
    my $new_website = $links->add_website({
        name   => $old_name,
        uri    => $old_uri,
    });

    my $count_websites = $links->count_websites;

    # update existent website
    $new_website->name($new_name);
    $new_website->uri($new_uri);
    lives_ok {
        $new_website->update;
    } 'edit name, uri & update ok';
    ok( $new_website, 'edit website ok' );
    isa_ok( $new_website, 'Data::Model::Row' );
    isa_ok( $new_website, $Model_Class . '::website' );

    # website was updated
    my @websites = $links->websites;    # order by id
    is( $links->count_websites, $count_websites, 'count not changed' );

    # updated website has same column-values as query of update
    my $updated_website = $websites[-1];  # last id
    # my $updated_website = $links->lookup(website => $new_website->id);
    is( $updated_website->id, $new_website->id, 'id not changed' );
    is( $updated_website->name, $new_name, 'name changed' );
    is( $updated_website->uri, $new_uri, 'uri changed' );
}

{
    # same name as existent website
    my $new_website = $links->add_website({
        name   => 'name' . time,
        uri    => 'http://uri.example/' . time,
    });
    $new_website->name($name);
    lives_ok {
        $new_website->update;
    } 'same name ok';
}

{
    # exception: same uri as existent website
    my $new_website = $links->add_website({
        name   => 'name' . time,
        uri    => 'http://uri.example/' . time,
    });
    $new_website->uri($uri);
    throws_ok {
        $new_website->update;
    } qr{column uri is not unique},
        'same uri exception throwed';
}


done_testing();

1;
__END__
