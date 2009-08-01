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
    # tags exist (previous test)
    ok( $links->count_tags, 'tags exist ok (created by previous test)' );
}

{
    # delete all tags
    # diag 'tags: ', $links->count_tags;
    $links->delete_all_tags;
    # diag 'tags: ', $links->count_tags;
    ok( ! $links->count_tags, 'no tag exists ok (all tags were removed)' );
}

{
    # create a new tag
    my $new_tag_a = $links->add_tag({ name => 'name_a', slug => 'slug_a' });
    my $new_tag_b = $links->add_tag({ name => 'name_b', slug => 'slug_b' });
    my $new_tag_c = $links->add_tag({ name => 'name_c', slug => 'slug_c' });
    is( $links->count_tags, 3, '3 tags exist ok' );

    $new_tag_b->delete;
    is( $links->count_tags, 2, '2 tags exist ok (b was deleted)' );

    $new_tag_a->delete;
    is( $links->count_tags, 1, '1 tag exist ok (a was deleted)' );

    # delete 

}


done_testing();

1;
__END__
