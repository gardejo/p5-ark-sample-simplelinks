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
use SimpleLinks::Test::Website::Category;
load $Service_Class;

my $links = $Service_Class->new($Builder_Option_Of_Database);

# create categories and websites
my ( $cat_a,  $cat_b,  $cat_c,  $cat_d,  $cat_e,  $cat_f,  $cat_g,
     $site_a, $site_b, $site_c, $site_d, $site_e, $site_f, $site_g, $site_h )
        = add_website_category_relationships($links);

# update category of website
# ★add_categories, delete_categorieは今後実装。
# 現在は単純ミューテーターのみとする。
# ★今更ながらだが、nameはslugにしよう、後で
$site_a->categories([$cat_a, $cat_b->id, $cat_c->name]);
$site_c->categories([]);
$site_d->categories([$cat_f]);
$site_f->categories([$cat_f]);
$site_g->categories([]);


# $website->category_ids
is_deeply( [$site_a->category_ids], [$cat_a->id, $cat_b->id, $cat_c->id],
           '$site_a->category_ids [a,+b,+c] ok' );
is_deeply( [$site_b->category_ids], [$cat_c->id],
           '$site_b->category_ids [c] ok' );
is_deeply( [$site_c->category_ids], [],
           '$site_c->category_ids [-d] ok' );
is_deeply( [$site_d->category_ids], [$cat_f->id],
           '$site_d->category_ids [e->f] ok' );
is_deeply( [$site_e->category_ids], [$cat_g->id],
           '$site_e->category_ids [g] ok' );
is_deeply( [$site_f->category_ids], [$cat_f->id],
           '$site_f->category_ids [+f] ok' );
is_deeply( [$site_g->category_ids], [],
           '$site_g->category_ids [-b,-g] ok' );
is_deeply( [$site_h->category_ids], [$cat_c->id, $cat_e->id],
           '$site_h->category_ids [c,e] ok' );

# $website->categories
is_deeply( [map { $_->id } $site_a->categories],
           [$cat_a->id, $cat_b->id, $cat_c->id],
           '$site_a->categories [a,+b,+c] ok' );
is_deeply( [map { $_->id } $site_b->categories], [$cat_c->id],
           '$site_b->categories [c] ok' );
is_deeply( [map { $_->id } $site_c->categories], [],
           '$site_c->categories [-d] ok' );
is_deeply( [map { $_->id } $site_d->categories], [$cat_f->id],
           '$site_d->categories [e->f] ok' );
is_deeply( [map { $_->id } $site_e->categories], [$cat_g->id],
           '$site_e->categories [g] ok' );
is_deeply( [map { $_->id } $site_f->categories], [$cat_f->id],
           '$site_f->categories [+f] ok' );
is_deeply( [map { $_->id } $site_g->categories], [],
           '$site_g->categories [-b,-g] ok' );
is_deeply( [map { $_->id } $site_h->categories], [$cat_c->id, $cat_e->id],
           '$site_h->categories [c,e] ok' );

# $category->website_ids
is_deeply( [$cat_a->website_ids], [$site_a->id],
           '$cat_a->website_ids [+a] ok' );
is_deeply( [$cat_b->website_ids], [$site_a->id],
           '$cat_b->website_ids [a,-g] ok' );
is_deeply( [$cat_c->website_ids], [$site_a->id, $site_b->id, $site_h->id],
           '$cat_c->website_ids [+a,b,h] ok' );
is_deeply( [$cat_d->website_ids], [],
           '$cat_d->website_ids [-c] ok' );
is_deeply( [$cat_e->website_ids], [$site_h->id],
           '$cat_e->website_ids [-d,h] ok' );
is_deeply( [$cat_f->website_ids], [$site_d->id, $site_f->id],
           '$cat_f->website_ids [+d,+f] ok' );
is_deeply( [$cat_g->website_ids], [$site_e->id],
           '$cat_g->website_ids [e,-g] ok' );

# $category->websites
is_deeply( [map { $_->id } $cat_a->websites], [$site_a->id],
           '$cat_a->websites [+a] ok' );
is_deeply( [map { $_->id } $cat_b->websites], [$site_a->id],
           '$cat_b->websites [a,-g] ok' );
is_deeply( [map { $_->id } $cat_c->websites],
           [$site_a->id, $site_b->id, $site_h->id],
           '$cat_c->websites [+a,b,h] ok' );
is_deeply( [map { $_->id } $cat_d->websites], [],
           '$cat_d->websites [-c] ok' );
is_deeply( [map { $_->id } $cat_e->websites], [$site_h->id],
           '$cat_e->websites [-d,h] ok' );
is_deeply( [map { $_->id } $cat_f->websites], [$site_d->id, $site_f->id],
           '$cat_f->websites [+d,+f] ok' );
is_deeply( [map { $_->id } $cat_g->websites], [$site_e->id],
           '$cat_g->websites [e,-g] ok' );

# $category->count_websites
# 基本的に、状態変更を伴うアクションを跨いでオブジェクトを使い回すことは
# 有り得ないので、通常はキャッシュであるcount_websitesで良い。
# CLIなどでは注意すること。children, descendantsも古いので、
# 明示的なキャッシュ更新メソッドを叩くより、$category->reloadした方がよい。
is( $cat_a->count_websites, 0, '$cat_a->count_websites [0] [0->1] ok' );
is( $cat_b->count_websites, 0, '$cat_b->count_websites [0] [2->1] ok' );
is( $cat_c->count_websites, 0, '$cat_c->count_websites [0] [2->3] ok' );
is( $cat_d->count_websites, 0, '$cat_d->count_websites [0] [1->0] ok' );
is( $cat_e->count_websites, 0, '$cat_e->count_websites [0] [2->1] ok' );
is( $cat_f->count_websites, 0, '$cat_f->count_websites [0] [0->2] ok' );
is( $cat_g->count_websites, 0, '$cat_g->count_websites [0] [2->1] ok' );

# $category->count_current_websites
is( $cat_a->count_current_websites, 1, '$cat_a->count_websites [1]<[0->1] ok' );
is( $cat_b->count_current_websites, 1, '$cat_b->count_websites [1]<[2->1] ok' );
is( $cat_c->count_current_websites, 3, '$cat_c->count_websites [3]<[2->3] ok' );
is( $cat_d->count_current_websites, 0, '$cat_d->count_websites [0]<[1->0] ok' );
is( $cat_e->count_current_websites, 1, '$cat_e->count_websites [1]<[2->1] ok' );
is( $cat_f->count_current_websites, 2, '$cat_f->count_websites [2]<[0->2] ok' );
is( $cat_g->count_current_websites, 1, '$cat_g->count_websites [1]<[2->1] ok' );

# $category->count_websites (retry)
is( $cat_a->count_websites, 1, '$cat_a->count_websites [0->1] [1] ok' );
is( $cat_b->count_websites, 1, '$cat_b->count_websites [2->1] [1] ok' );
is( $cat_c->count_websites, 3, '$cat_c->count_websites [2->3] [3] ok' );
is( $cat_d->count_websites, 0, '$cat_d->count_websites [1->0] [0] ok' );
is( $cat_e->count_websites, 1, '$cat_e->count_websites [2->1] [1] ok' );
is( $cat_f->count_websites, 2, '$cat_f->count_websites [0->2] [2] ok' );
is( $cat_g->count_websites, 1, '$cat_g->count_websites [2->1] [1] ok' );


done_testing();

1;
__END__

=head1 TEST DATA

Website/category relationship is these:

                                 self   child descendant    websites
    a (-> *) (<- *)                 0       0       0!      (none)
    b (-> *) (<- c,d)               2       3       3       a, g
        c (-> b) (<- *)             2       0       0!      b, h
        d (-> b) (<- *)             1       0       0!      c
    e (-> *) (<- f <- g)            2       0       2       d, h
        f (-> e) (<- g)             0       2       2       (none)
            g (-> f -> e) (<- *)    2       0       0!      e, g
    (none)                          -       -       -       f

            | | |
            v v v

                                 self   child descendant    websites
    a (-> *) (<- *)                 0       0       0!      <add a>
    b (-> *) (<- c,d)               2       3       3       a, <delete g>
        c (-> b) (<- *)             2       0       0!      b, h, <add a>
        d (-> b) (<- *)             1       0       0!      <delete c>
    e (-> *) (<- f <- g)            2       0       2       <delete d>, h
        f (-> e) (<- g)             0       2       2       <add d, f>
            g (-> f -> e) (<- *)    2       0       0!      e, <delete g>
