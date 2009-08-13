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
    # categories exist (previous test)
    ok( $links->count_categories, 'categories exist ok (created by previous tests)' );
}

{
    # delete all categories
    $links->delete_all_categories;
    ok( ! $links->count_categories, 'no category exists ok (all categories were removed)' );
}

{
    # delete all (delete no categories)
    $links->delete_all_categories;
    ok( ! $links->count_categories, 'no category exists ok (no categories removed)' );
}

{
    # delete an existent category
    my $new_category_a = $links->add_category({ name => 'name_a', slug => 'slug_a' });
    my $new_category_b = $links->add_category({ name => 'name_b', slug => 'slug_b' });
    is( $links->count_categories, 2, '2 categories exist ok' );

    lives_ok {
        $new_category_a->delete;
    } 'delete an existent category ok';
    is( $links->count_categories, 1, '1 tag exists ok (a was deleted)' );
    is( $new_category_a, undef, 'undef ok' );
}

{
    # exception: application internal restraint ($model->delete($talbe => $id))
    my $new_category = $links->add_category({
        name    => 'name' . time,
        slug    => 'slug' . time,
    });
    # 
    throws_ok {
        $links->delete('category' => $new_category->id);
    } qr{Can't locate object method "delete" via package "SimpleLinks::Service::Links"},
        'service object does not provide "delete" method';
    # 内部的に使用しないよう留意するだけでは危険だけれども、
    # 予防的なオーバーライドは、現時点では後回しとする。
    # throws_ok {
    #     $new_category->{model}->delete('category' => $new_category->id);
    # } qr{blah blah blah},
    #     'model object does not provide "delete" method';
}


done_testing();

1;
__END__
