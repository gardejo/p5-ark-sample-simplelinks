#!perl -T

use strict;
use warnings;
use utf8;
use local::lib;

use Module::Load;
use Storable qw(dclone);
use Test::Exception;
use Test::More 0.87_01;
use Time::HiRes qw(time);

use lib 'extlib';
use lib 't/lib';

use SimpleLinks::Test::Constant;
load $Service_Class;

my $links = $Service_Class->new($Builder_Option_Of_Database);

{
    # no category
    my @categories     = $links->categories;
    my @all_categories = $links->all_categories;
    is( scalar @categories,       0, 'no category ok (scalar @categoreis)' );
    is( scalar @all_categories,   0, 'no category ok (scalar @all_categoreis)' );
    is( $links->count_categories, 0, 'no category ok (count_categories)' );
}

my $name = '名称' . time;   # utf8_column
my $slug = 'slug' . time;
my $certain_category;

{
    # create a new category
    $certain_category = $links->add_category({
        name    => $name,
        slug    => $slug,
    });
    ok( $certain_category, 'create category ok' );
    isa_ok( $certain_category, 'Data::Model::Row' );
    isa_ok( $certain_category, $Model_Class . '::category' );

    # category was created (read categories)
    my @categories     = $links->categories;
    my @all_categories = $links->all_categories;
    is( scalar @categories,       1, 'count 1 ok (scalar @categoreis)' );
    is( scalar @all_categories,   1, 'count 1 ok (scalar @all_categoreis)' );
    is( $links->count_categories, 1, 'count 1 ok (count_categories)' );

    # created category has same column-values as query
    is( $categories[0]->id, $certain_category->id, 'id ok' );
    is( $categories[0]->name, $name, 'name ok' );
    is( $categories[0]->slug, $slug, 'slug ok' );
    is( $categories[0]->count_websites, 0, 'websites count ok' ); # w/c行き？
}

{
    # reload
    my $before_reload = dclone($certain_category);
    my $before_count  = $links->count_categories;

    $certain_category->reload;
    # (parent_id) not exists vs. undef
    # is_deeply( $before_reload, $certain_category, 'reload ok' );
    is( $before_reload->id,   $certain_category->id,   'reloaded id ok' );
    is( $before_reload->name, $certain_category->name, 'reloaded name ok' );
    is( $before_reload->slug, $certain_category->slug, 'reloaded slug ok' );
    is( $before_count, $links->count_categories, 'same count ok' );
}

# todo: to create with other columns (owner, introduction, comment),
#       except "parent_id".

{
    # exception: same name as existent category
    my $new_category;
    throws_ok {
        $new_category = $links->add_category({
            name    => $name,
            slug    => 'slug' . time,
        });
    } qr{column taxonomy_name is not unique},
        'same name exception throwed';
    # ok( ! $new_category, 'same name not ok' ); # unnecessary (self-evident)
}

{
    # exception: same slug as existent category
    my $new_category;
    throws_ok {
        $new_category = $links->add_category({
            name    => 'name' . time,
            slug    => $slug,
        });
    } qr{column taxonomy_slug is not unique},
        'same slug exception throwed';
    # ok( ! $new_category, 'same slug not ok' ); # unnecessary (self-evident)
}

{
    # same name but differed parent
    my $new_category = $links->add_category({
        name   => $name,
        slug   => 'slug' . time,
        parent => $certain_category,
    });
    ok( $new_category, 'create same name but differed parent ok' );
}

{
    # same slug but differed parent
    my $new_category = $links->add_category({
        name    => 'name' . time,
        slug    => $slug,
        parent  => $certain_category,
    });
    ok( $new_category, 'create same slug but differed parent ok' );
}

# todo: to catch "category at once parent and child" exception


done_testing();

1;
__END__
