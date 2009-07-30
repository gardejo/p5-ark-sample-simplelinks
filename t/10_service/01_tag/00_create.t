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
    # no tag
    my @tags     = $links->tags;
    my @all_tags = $links->all_tags;
    is( scalar @tags,       0, 'no tag ok (scalar @tags)' );
    is( scalar @all_tags,   0, 'no tag ok (scalar @all_tags)' );
    is( $links->count_tags, 0, 'no tag ok (count_tags)' );
}

my $name = 'name' . time;
my $slug = 'slug' . time;

{
    # create a new tag
    my $new_tag = $links->add_tag({
        name    => $name,
        slug    => $slug,
    });
    ok( $new_tag, 'create tag ok' );
    isa_ok( $new_tag, 'Data::Model::Row' );
    isa_ok( $new_tag, $Model_Class . '::tag' );

    # tag was created (read tags)
    my @tags     = $links->tags;
    my @all_tags = $links->all_tags;
    is( scalar @tags,       1, 'count 1 ok (scalar @tags)' );
    is( scalar @all_tags,   1, 'count 1 ok (scalar @all_tags)' );
    is( $links->count_tags, 1, 'count 1 ok (count_tags)' );

    # created tag has same column-values as query
    is( $tags[0]->id, $new_tag->id, 'id ok' );
    is( $tags[0]->name, $name, 'name ok' );
    is( $tags[0]->slug, $slug, 'slug ok' );
}

{
    # exception: same name as existent tag
    my $new_tag;
    throws_ok {
        $new_tag = $links->add_tag({
            name    => $name,
            slug    => 'slug' . time,
        });
    } qr{column taxonomy_name is not unique},
        'same name exception throwed';
    # ok( ! $new_tag, 'same name not ok' ); # unnecessary (self-evident)
}

{
    # exception: same slug as existent tag
    my $new_tag;
    throws_ok {
        $new_tag = $links->add_tag({
            name    => 'name' . time,
            slug    => $slug,
        });
    } qr{column taxonomy_slug is not unique},
        'same slug exception throwed';
    # ok( ! $new_tag, 'same slug not ok' ); # unnecessary (self-evident)
}


done_testing();

1;
__END__
