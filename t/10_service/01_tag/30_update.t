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

# create a certain category for target of comparison
my $name = 'name' . time;
my $slug = 'slug' . time;
my $certain_category = $links->add_category({
    name    => $name,
    slug    => $slug,
});

{
    # create a new category for comparison
    my $old_name = 'old_name' . time;
    my $new_name = 'new_name' . time;
    my $old_slug = 'old_slug' . time;
    my $new_slug = 'new_slug' . time;
    my $new_category = $links->add_category({
        name   => $old_name,
        slug   => $old_slug,
    });
    my $count_categories = $links->count_categories;

    # update existent category
    $new_category->name($new_name);
    $new_category->slug($new_slug);
    lives_ok {
        $new_category->update;
    } 'edit name, slug & update ok';
    ok( $new_category, 'edit category ok' );
    isa_ok( $new_category, 'Data::Model::Row' );
    isa_ok( $new_category, $Model_Class . '::category' );

    # category was updated
    my @categories = $links->categories;    # order by id
    is( $links->count_categories, $count_categories, 'count not changed' );

    # updated category has same column-values as query of update
    my $updated_category = $categories[-1];  # last id
    # my $updated_category = $links->lookup(category => $new_category->id);
    is( $updated_category->id, $new_category->id, 'id not changed' );
    is( $updated_category->name, $new_name, 'name changed' );
    is( $updated_category->slug, $new_slug, 'slug changed' );
}

{
    # exception: same name as existent category
    my $new_category = $links->add_category({
        name   => 'name' . time,
        slug   => 'slug' . time,
    });
    $new_category->name($name);
    throws_ok {
        $new_category->update;
    } qr{column taxonomy_name is not unique},
        'same name exception throwed';
}

{
    # exception: same slug as existent category
    my $new_category = $links->add_category({
        name   => 'name' . time,
        slug   => 'slug' . time,
    });
    $new_category->slug($slug);
    throws_ok {
        $new_category->update;
    } qr{column taxonomy_slug is not unique},
        'same slug exception throwed';
}

{
    # same name but differed parent
    my $new_category = $links->add_category({
        name   => 'name' . time,
        slug   => 'slug' . time,
        parent => $certain_category,
    });
    $new_category->name($name);
    lives_ok {
        $new_category->update;
    } 'edit same name but differed parent ok';
}

{
    # same slug but differed parent
    my $new_category = $links->add_category({
        name    => 'name' . time,
        slug    => 'slug' . time,
        parent  => $certain_category,
    });
    $new_category->slug($slug);
    lives_ok {
        $new_category->update;
    } 'edit same slug but differed parent ok';
}


done_testing();

1;
__END__
