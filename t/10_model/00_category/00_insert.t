use strict;
use warnings;
use local::lib;

use Module::Load;
use Test::Exception;
use Test::More 0.87_01;
use Time::HiRes qw(time);

use lib 't/lib';
use lib 'extlib';

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

my $name = 'name' . time;
my $slug = 'slug' . time;
my $certain_category;

{
    # insert category
    $certain_category = $links->add_category({
        name    => $name,
        slug    => $slug,
    });
    ok( $certain_category, 'create category ok' );
    isa_ok( $certain_category, 'Data::Model::Row' );
    isa_ok( $certain_category, $Model_Class . '::category' );

    my @categories     = $links->categories;
    my @all_categories = $links->all_categories;
    is( scalar @categories,       1, 'count 1 ok (scalar @categoreis)' );
    is( scalar @all_categories,   1, 'count 1 ok (scalar @all_categoreis)' );
    is( $links->count_categories, 1, 'count 1 ok (count_categories)' );

    is( $categories[0]->id, $certain_category->id, 'id ok' );
    is( $categories[0]->name, $name, 'name ok' );
    is( $categories[0]->slug, $slug, 'slug ok' );
}

{
    # same name
    my $new_category;
    throws_ok {
        $new_category = $links->add_category({
            name    => $name,
            slug    => 'slug' . time,
        });
    } qr{column taxonomy_name is not unique},
        'same name exception ok';
    # ok( ! $new_category, 'same name not ok' );
}

{
    # same slug
    my $new_category;
    throws_ok {
        $new_category = $links->add_category({
            name    => 'name' . time,
            slug    => $slug,
        });
    } qr{column taxonomy_slug is not unique},
        'same slug exception ok';
    # ok( ! $new_category, 'same slug not ok' );
}

{
    # same name but differed parent
    my $new_category = $links->add_category({
        name   => $name,
        slug   => 'slug' . time,
        parent => $certain_category,
    });
    ok( $new_category, 'same name but differed parent ok' );
}

{
    # same slug but differed parent
    my $new_category = $links->add_category({
        name    => 'name' . time,
        slug    => $slug,
        parent  => $certain_category,
    });
    ok( $new_category, 'same slug but differed parent ok' );
}

done_testing();

1;
__END__
