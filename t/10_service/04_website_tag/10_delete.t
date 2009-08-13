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

# delete tag and website
$tag_b->delete;
$site_d->delete;

# $website->tag_ids
is_deeply( [$site_a->tag_ids], [$tag_a->id],
           '$site_a->tag_ids [a] ok' );
is_deeply( [$site_b->tag_ids], [$tag_a->id],
           '$site_b->tag_ids [a] ok' );
is_deeply( [$site_c->tag_ids], [],
           '$site_c->tag_ids [] ok' );
is_deeply( [$site_e->tag_ids], [],
           '$site_e->tag_ids [] ok' );

# $website->tags
is_deeply( [map { $_->id } $site_a->tags], [$tag_a->id],
           '$site_a->tags [a] ok' );
is_deeply( [map { $_->id } $site_b->tags], [$tag_a->id],
           '$site_b->tags [a] ok' );
is_deeply( [map { $_->id } $site_c->tags], [],
           '$site_c->tags [] ok' );
is_deeply( [map { $_->id } $site_e->tags], [],
           '$site_e->tags [] ok' );

# $tag->website_ids
is_deeply( [$tag_a->website_ids], [$site_a->id, $site_b->id],
           '$tag_a->website_ids [a,b] ok' );
is_deeply( [$tag_c->website_ids], [],
           '$tag_c->website_ids [d] ok' );
is_deeply( [$tag_d->website_ids], [],
           '$tag_d->website_ids [] ok' );

# $tag->websites
is_deeply( [map { $_->id } $tag_a->websites], [$site_a->id, $site_b->id],
           '$tag_a->websites [a,b] ok' );
is_deeply( [map { $_->id } $tag_c->websites], [],
           '$tag_c->websites [d] ok' );
is_deeply( [map { $_->id } $tag_d->websites], [],
           '$tag_d->websites [] ok' );

# $tag->count_websites
is( $tag_a->count_websites, 0, '$tag_a->count_websites [0] [2] ok' );
is( $tag_c->count_websites, 0, '$tag_c->count_websites [0] [0] ok' );
is( $tag_d->count_websites, 0, '$tag_d->count_websites [0] [0] ok' );

# $tag->count_current_websites
is( $tag_a->count_current_websites, 2, '$tag_a->count_websites [2]<[2] ok' );
is( $tag_c->count_current_websites, 0, '$tag_c->count_websites [0]<[0] ok' );
is( $tag_d->count_current_websites, 0, '$tag_d->count_websites [0]<[0] ok' );

# $tag->count_websites (retry)
is( $tag_a->count_websites, 2, '$tag_a->count_websites [2] [2] ok' );
is( $tag_c->count_websites, 0, '$tag_c->count_websites [0] [0] ok' );
is( $tag_d->count_websites, 0, '$tag_d->count_websites [0] [0] ok' );


done_testing();

1;
__END__

# exception: duplicated categories
{
    throws_ok {
        $links->add_website({
            name        => 'name',
            uri         => 'http://website.example/',
            categories  => [$cat_a->name, $cat_a->name],
        });
    } qr{xxxx},
        'xxxx';
}

# exception: duplicated categories
{
    throws_ok {
        $links->add_website({
            name        => 'name',
            uri         => 'http://website.example/',
            categories  => [$cat_a->id, $cat_a->id],
        });
    } qr{xxxx},
        'xxxx';
}

# exception: duplicated categories
{
    throws_ok {
        $links->add_website({
            name        => 'name',
            uri         => 'http://website.example/',
            categories  => [$cat_a->id, $cat_a->name],
        });
    } qr{xxxx},
        'xxxx';
}


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

    website a : tag a
    website b : tag a
    website c : (removed)
    (removed) : tag     c
    website e : (none)
    (none)    : tag     d

    tag a     : website a b
    (removed)
    tag c     : (removed)
    tag d     : (none)
