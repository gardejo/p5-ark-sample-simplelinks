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

my ($category_a, $category_b);
{
    # insert categories
    $category_a = $links->add_category({
        name    => 'name_a' . time,
        slug    => 'slug_a' . time,
    });
    $category_b = $links->add_category({
        name    => 'name_b' . time,
        slug    => 'slug_b' . time,
    });
}

{
    # same name
    $category_a->name($category_b->name);
    throws_ok {
        $category_a->update;
    } qr{column taxonomy_name is not unique},
        'same name exception ok';
}

{
    # same slug
    $category_a->slug($category_b->slug);
    throws_ok {
        $category_a->update;
    } qr{column taxonomy_slug is not unique},
        'same slug exception ok';
}

{
    # same name but differed parent
    my $new_category = $links->add_category({
        name   => 'name' . time,
        slug   => 'slug' . time,
        parent => $category_a,
    });
    $new_category->name($category_b->name);
    lives_ok {
        $new_category->update;
    } 'same name but differed parent ok';
}

{
    # same slug but differed parent
    my $new_category = $links->add_category({
        name    => 'name' . time,
        slug    => 'slug' . time,
        parent  => $category_a,
    });
    $new_category->slug($category_b->slug);
    lives_ok {
        $new_category->update;
    } 'same slug but differed parent ok';
}

done_testing();

1;
__END__
