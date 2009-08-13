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
    ok( $links->count_tags, 'tags exist ok (created by previous tests)' );
}

{
    # delete all tags
    $links->delete_all_tags;
    ok( ! $links->count_tags, 'no tag exists ok (all tags were removed)' );
}

{
    # delete all (delete no tags)
    $links->delete_all_tags;
    ok( ! $links->count_tags, 'no tag exists ok (no tags removed)' );
}

{
    # create a new tag
    my $new_tag_a = $links->add_tag({ name => 'name_a', slug => 'slug_a' });
    my $new_tag_b = $links->add_tag({ name => 'name_b', slug => 'slug_b' });
    is( $links->count_tags, 2, '2 tags exist ok' );

    # delete the tag
    lives_ok {
        $new_tag_a->delete;
    } 'delete an existent tag ok';
    is( $links->count_tags, 1, '1 tag exists ok (a was deleted)' );
    is( $new_tag_a, undef, 'undef ok' );
}


done_testing();

1;
__END__
