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
use SimpleLinks::Test::Website::Tag;
load $Service_Class;

my $links = $Service_Class->new($Builder_Option_Of_Database);

# create tags and websites
my ( $tag_a,  $tag_b,  $tag_c,  $tag_d,
     $site_a, $site_b, $site_c, $site_d, $site_e )
        = add_website_tag_relationships($links);

# update tag of website
# ★add_tags, delete_tagsは今後実装。現在は単純ミューテーターのみとする。
$site_a->tags([$tag_b, $tag_c->id]);
$site_b->tags([]);
$site_c->tags([$tag_a->name]);  # ★今更ながらだが、slugにしよう、後で
$site_d->tags([$tag_a, $tag_c]);

# $website->tag_ids
is_deeply( [$site_a->tag_ids], [$tag_b->id, $tag_c->id],
           '$site_a->tag_ids [b,c] ok' );
is_deeply( [$site_b->tag_ids], [],
           '$site_b->tag_ids [] ok' );
is_deeply( [$site_c->tag_ids], [$tag_a->id],
           '$site_c->tag_ids [a] ok' );
is_deeply( [$site_d->tag_ids], [$tag_a->id, $tag_c->id],
           '$site_d->tag_ids [a,c] ok' );
is_deeply( [$site_e->tag_ids], [],
           '$site_e->tag_ids [] ok' );

# $website->tags
is_deeply( [map { $_->id } $site_a->tags], [$tag_b->id, $tag_c->id],
           '$site_a->tags [b,c] ok' );
is_deeply( [map { $_->id } $site_b->tags], [],
           '$site_b->tags [] ok' );
is_deeply( [map { $_->id } $site_c->tags], [$tag_a->id],
           '$site_c->tags [a] ok' );
is_deeply( [map { $_->id } $site_d->tags], [$tag_a->id, $tag_c->id],
           '$site_d->tags [a,c] ok' );
is_deeply( [map { $_->id } $site_e->tags], [],
           '$site_e->tags [] ok' );

# $tag->website_ids
is_deeply( [$tag_a->website_ids], [$site_c->id, $site_d->id],
           '$tag_a->website_ids [c,d] ok' );
is_deeply( [$tag_b->website_ids], [$site_a->id],
           '$tag_b->website_ids [a] ok' );
is_deeply( [$tag_c->website_ids], [$site_a->id, $site_d->id],
           '$tag_c->website_ids [a,d] ok' );
is_deeply( [$tag_d->website_ids], [],
           '$tag_d->website_ids [] ok' );

# $tag->websites
is_deeply( [map { $_->id } $tag_a->websites], [$site_c->id, $site_d->id],
           '$tag_a->websites [c,d] ok' );
is_deeply( [map { $_->id } $tag_b->websites], [$site_a->id],
           '$tag_b->websites [] ok' );
is_deeply( [map { $_->id } $tag_c->websites], [$site_a->id, $site_d->id],
           '$tag_c->websites [a,d] ok' );
is_deeply( [map { $_->id } $tag_d->websites], [],
           '$tag_d->websites [] ok' );

# $tag->count_websites
is( $tag_a->count_websites, 0, '$tag_a->count_websites [0] [2] ok' );
is( $tag_b->count_websites, 0, '$tag_b->count_websites [0] [1] ok' );
is( $tag_c->count_websites, 0, '$tag_c->count_websites [0] [2] ok' );
is( $tag_d->count_websites, 0, '$tag_d->count_websites [0] [0] ok' );

# $tag->count_current_websites
is( $tag_a->count_current_websites, 2, '$tag_a->count_websites [2]<[2] ok' );
is( $tag_b->count_current_websites, 1, '$tag_b->count_websites [1]<[1] ok' );
is( $tag_c->count_current_websites, 2, '$tag_c->count_websites [2]<[2] ok' );
is( $tag_d->count_current_websites, 0, '$tag_d->count_websites [0]<[0] ok' );

# $tag->count_websites (retry)
is( $tag_a->count_websites, 2, '$tag_a->count_websites [2] [2] ok' );
is( $tag_b->count_websites, 1, '$tag_b->count_websites [1] [1] ok' );
is( $tag_c->count_websites, 2, '$tag_c->count_websites [2] [2] ok' );
is( $tag_d->count_websites, 0, '$tag_d->count_websites [0] [0] ok' );


done_testing();

1;
__END__

=head1 TEST DATA

Website/tag relationship is these:

    website a : tag a
    website b : tag a b
    website c : tag   b
    website d : tag     c
    website e : (none)
    (none)    : tag     d

    tag a     : website a b
    tag b     : website   b c
    tag c     : website       d
    tag d     : (none)

            | | |
            v v v

    website a : tag   b c
    website b : (none)
    website c : tag a
    website d : tag a   c
    website e : (none)
    (none)    : tag     d

    tag a     : website     c d
    tag b     : website a
    tag c     : website a     d
    tag d     : (none)
