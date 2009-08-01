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

eval {
    load Data::Cloud;
};
plan( skip_all =>
    "Data::Cloud required " .
    "for testing tag cloud"
) if $@;

use SimpleLinks::Test::Constant;
load $Service_Class;

my $links = $Service_Class->new($Builder_Option_Of_Database);

{
    # delete all websites, tags
    $links->delete_all_websites;
    $links->delete_all_tags;
    ok( ! $links->count_tags, 'no tag exists ok (all tags were removed)' );
}

{
    # set tags
    $links->add_tag({ name => 'tag_a', slug => 'tag_slug_a' });
    $links->add_tag({ name => 'tag_b', slug => 'tag_slug_b' });
    $links->add_tag({ name => 'tag_c', slug => 'tag_slug_c' });
}

# これより前のファイルで、website/tagのリレーションをテストしておくこと。

# うーん、lookupの都合上、name : $idの方がよさそう。
# count = 0の人は配列から除きたい
# tag cloud用の大きさ（<li class="tag_cloud_item" style="font-size: XX%">）
# も返すかも。
# 標準偏差を使う？　中央値を使う？　まさか先頭と末尾の平均を基準とした
# 増減分割合を使う（かなり微妙）。

{
    # set websites
    $links->add_website({
        name => 'website_a',
        uri  => 'http://website_a.example/',
        tags => [qw(tag_a            )],
    });
    is_deeply( $links->tag_ratings,
               [ { name => 'tag_a', count => 1, rank => 3 },
                 { name => 'tag_b', count => 0, rank => 2 },
                 { name => 'tag_c', count => 0, rank => 1 }, ],
               'a(1=3), b(0=2), c(0=1) :  ok' );
}

# use YAML::Syck; die Dump $links->tag_ratings;

{
    $links->add_website({
        name => 'website_b',
        uri  => 'http://website_b.example/',
        tags => [qw(tag_a            )],
    });
    is_deeply( $links->tag_ratings,
               [ { name => 'tag_a', count => 2, rank => 3 },
                 { name => 'tag_b', count => 0, rank => 2 },
                 { name => 'tag_c', count => 0, rank => 1 }, ],
               'a(2=3), b(0=2), c(0=1) :  ok' );
}

{
    $links->add_website({
        name => 'website_c',
        uri  => 'http://website_c.example/',
        tags => [qw(            tag_c)],
    });
    is_deeply( $links->tag_ratings,
               [ { name => 'tag_a', count => 2, rank => 3 },
                 { name => 'tag_c', count => 1, rank => 2 },
                 { name => 'tag_b', count => 0, rank => 1 }, ],
               'a(2=3), b(0=1), c(1=2) :  ok' );
}

{
    $links->add_website({
        name => 'website_d',
        uri  => 'http://website_d.example/',
        tags => [qw(      tag_b tag_c)],
    });
    is_deeply( $links->tag_ratings,
               [ { name => 'tag_a', count => 2, rank => 3 },
                 { name => 'tag_c', count => 2, rank => 2 },
                 { name => 'tag_b', count => 1, rank => 1 }, ],
               'a(2=3), b(2=2), c(1=1) :  ok' );
}

{
    $links->add_website({
        name => 'website_e',
        uri  => 'http://website_e.example/',
        tags => [qw(      tag_b tag_c)],
    });
    is_deeply( $links->tag_ratings,
               [ { name => 'tag_c', count => 3, rank => 3 },
                 { name => 'tag_a', count => 2, rank => 2 },
                 { name => 'tag_b', count => 2, rank => 1 }, ],
               'a(2=2), b(3=3), c(2=1) :  ok' );
}


done_testing();

1;
__END__
