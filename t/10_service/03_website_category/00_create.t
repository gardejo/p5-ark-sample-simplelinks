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

use SimpleLinks::Test::Category;
use SimpleLinks::Test::Constant;
load $Service_Class;

my $links = $Service_Class->new($Builder_Option_Of_Database);

my ( $cat_a, $cat_b, $cat_c, $cat_d, $cat_e, $cat_f, $cat_g )
    = add_cascading_categories($links);

my $site_a = $links->add_website({
    name        => 'name_a' . time,
    uri         => 'http://site_a.example/' . time,
    categories  => [$cat_b->id],
});
my $site_b = $links->add_website({
    name        => 'name_b' . time,
    uri         => 'http://site_b.example/' . time,
    categories  => [$cat_c->name],
});
my $site_c = $links->add_website({
    name        => 'name_c' . time,
    uri         => 'http://site_c.example/' . time,
    categories  => [$cat_d->id],
});
my $site_d = $links->add_website({
    name        => 'name_d' . time,
    uri         => 'http://site_d.example/' . time,
    categories  => [$cat_e->name],
});
my $site_e = $links->add_website({
    name        => 'name_e' . time,
    uri         => 'http://site_e.example/' . time,
    categories  => [$cat_g->id],
});
my $site_f = $links->add_website({
    name        => 'name_f' . time,
    uri         => 'http://site_f.example/' . time,
});
my $site_g = $links->add_website({
    name        => 'name_g' . time,
    uri         => 'http://site_g.example/' . time,
    categories  => [$cat_b->name, $cat_g->id],
});
my $site_h = $links->add_website({
    name        => 'name_h' . time,
    uri         => 'http://site_h.example/' . time,
    categories  => [$cat_c->name, $cat_e->name],
});

# $website->category_ids
is_deeply( [$site_a->category_ids], [$cat_b->id],
           '$site_a->category_ids [a] ok' );
is_deeply( [$site_b->category_ids], [$cat_c->id],
           '$site_b->category_ids [c] ok' );
is_deeply( [$site_c->category_ids], [$cat_d->id],
           '$site_c->category_ids [d] ok' );
is_deeply( [$site_d->category_ids], [$cat_e->id],
           '$site_d->category_ids [e] ok' );
is_deeply( [$site_e->category_ids], [$cat_g->id],
           '$site_e->category_ids [g] ok' );
is_deeply( [$site_f->category_ids], [],
           '$site_f->category_ids [] ok' );
is_deeply( [$site_g->category_ids], [$cat_b->id, $cat_g->id],
           '$site_g->category_ids [b,g] ok' );
is_deeply( [$site_h->category_ids], [$cat_c->id, $cat_e->id],
           '$site_h->category_ids [c,e] ok' );

# $website->categories
is_deeply( [map { $_->id } $site_a->categories], [$cat_b->id],
           '$site_a->categories [a] ok' );
is_deeply( [map { $_->id } $site_b->categories], [$cat_c->id],
           '$site_b->categories [c] ok' );
is_deeply( [map { $_->id } $site_c->categories], [$cat_d->id],
           '$site_c->categories [d] ok' );
is_deeply( [map { $_->id } $site_d->categories], [$cat_e->id],
           '$site_d->categories [e] ok' );
is_deeply( [map { $_->id } $site_e->categories], [$cat_g->id],
           '$site_e->categories [g] ok' );
is_deeply( [map { $_->id } $site_f->categories], [],
           '$site_f->categories [] ok' );
is_deeply( [map { $_->id } $site_g->categories], [$cat_b->id, $cat_g->id],
           '$site_g->categories [b,g] ok' );
is_deeply( [map { $_->id } $site_h->categories], [$cat_c->id, $cat_e->id],
           '$site_h->categories [c,e] ok' );

# website_ids
is_deeply( [$cat_a->website_ids], [],
           '$cat_a->website_ids [] ok' );
is_deeply( [$cat_b->website_ids], [$site_a->id, $site_g->id],
           '$cat_b->website_ids [a,g] ok' );
is_deeply( [$cat_c->website_ids], [$site_b->id, $site_h->id],
           '$cat_c->website_ids [b,h] ok' );
is_deeply( [$cat_d->website_ids], [$site_c->id],
           '$cat_d->website_ids [c] ok' );
is_deeply( [$cat_e->website_ids], [$site_d->id, $site_h->id],
           '$cat_e->website_ids [d,h] ok' );
is_deeply( [$cat_f->website_ids], [],
           '$cat_f->website_ids [] ok' );
is_deeply( [$cat_g->website_ids], [$site_e->id, $site_g->id],
           '$cat_g->website_ids [e,g] ok' );

# websites
is_deeply( [map { $_->id } $cat_a->websites], [],
           '$cat_a->websites [] ok' );
is_deeply( [map { $_->id } $cat_b->websites], [$site_a->id, $site_g->id],
           '$cat_b->websites [a,g] ok' );
is_deeply( [map { $_->id } $cat_c->websites], [$site_b->id, $site_h->id],
           '$cat_c->websites [b,h] ok' );
is_deeply( [map { $_->id } $cat_d->websites], [$site_c->id],
           '$cat_d->websites [c] ok' );
is_deeply( [map { $_->id } $cat_e->websites], [$site_d->id, $site_h->id],
           '$cat_e->websites [d,h] ok' );
is_deeply( [map { $_->id } $cat_f->websites], [],
           '$cat_f->websites [] ok' );
is_deeply( [map { $_->id } $cat_g->websites], [$site_e->id, $site_g->id],
           '$cat_g->websites [e,g] ok' );

# $category->count_websites
# 基本的に、状態変更を伴うアクションを跨いでオブジェクトを使い回すことは
# 有り得ないので、通常はキャッシュであるcount_websitesで良い。
# CLIなどでは注意すること。children, descendantsも古いので、
# 明示的なキャッシュ更新メソッドを叩くより、同一IDでlookupし直した方がよい。
is( $cat_a->count_websites, 0, '$cat_a->count_websites [0] [0] ok' );
is( $cat_b->count_websites, 0, '$cat_b->count_websites [0] [2] ok' );
is( $cat_c->count_websites, 0, '$cat_c->count_websites [0] [2] ok' );
is( $cat_d->count_websites, 0, '$cat_d->count_websites [0] [1] ok' );
is( $cat_e->count_websites, 0, '$cat_e->count_websites [0] [2] ok' );
is( $cat_f->count_websites, 0, '$cat_f->count_websites [0] [0] ok' );
is( $cat_g->count_websites, 0, '$cat_g->count_websites [0] [2] ok' );

# 
is( $cat_a->count_current_websites, 0, '$cat_a->count_websites [0]<[0] ok' );
is( $cat_b->count_current_websites, 2, '$cat_b->count_websites [2]<[2] ok' );
is( $cat_c->count_current_websites, 2, '$cat_c->count_websites [2]<[2] ok' );
is( $cat_d->count_current_websites, 1, '$cat_d->count_websites [1]<[1] ok' );
is( $cat_e->count_current_websites, 2, '$cat_e->count_websites [2]<[2] ok' );
is( $cat_f->count_current_websites, 0, '$cat_f->count_websites [0]<[0] ok' );
is( $cat_g->count_current_websites, 2, '$cat_g->count_websites [2]<[2] ok' );

# 
is( $cat_a->count_websites, 0, '$cat_a->count_websites [0] [0] ok' );
is( $cat_b->count_websites, 2, '$cat_b->count_websites [2] [2] ok' );
is( $cat_c->count_websites, 2, '$cat_c->count_websites [2] [2] ok' );
is( $cat_d->count_websites, 1, '$cat_d->count_websites [1] [1] ok' );
is( $cat_e->count_websites, 2, '$cat_e->count_websites [2] [2] ok' );
is( $cat_f->count_websites, 0, '$cat_f->count_websites [0] [0] ok' );
is( $cat_g->count_websites, 2, '$cat_g->count_websites [2] [2] ok' );


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

Tree of categories is these:

    あぁ、カテゴリーに紐付くウェブサイト数については、子と孫は見ないんだった。
    カテゴリーα（ウェブサイト:100, サブカテゴリー:5）などいうイメージ。

                                 self   child descendant    websites
    a (-> *) (<- *)                 0       0       0       (none)
    b (-> *) (<- c,d)               2       3       3       a, g
        c (-> b) (<- *)             2       0       0       b, h
        d (-> b) (<- *)             1       0       0       c
    e (-> *) (<- f <- g)            2       0       2       d, h
        f (-> e) (<- g)             0       2       2       (none)
            g (-> f -> e) (<- *)    2       0       0       e, g
    (none)                          -       -       -       f

Note: Cannot happen these (category does not have many parents):

    c (-> b,e)
