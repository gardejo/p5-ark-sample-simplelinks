use strict;
use warnings;
use local::lib;

use Module::Load;
# use Test::Exception;
use Test::More 0.87_01;
use Time::HiRes qw(time);

use lib 'extlib';
use lib 't/lib';

use SimpleLinks::Test::Constant;
load $Service_Class;

my $links = $Service_Class->new($Builder_Option_Of_Database);

# create new categories these may have parent/children
my $category_a = $links->add_category({
    name    => 'name_a' . time,
    slug    => 'slug_a' . time,
});
my $category_b = $links->add_category({
    name    => 'name_b' . time,
    slug    => 'slug_b' . time,
});
my $category_c = $links->add_category({
    name    => 'name_c' . time,
    slug    => 'slug_c' . time,
    parent  => $category_b,
});
ok( $category_c, 'create category has parent ok (c -> b)' );
my $category_d = $links->add_category({
    name    => 'name_d' . time,
    slug    => 'slug_d' . time,
    parent  => $category_b,
});
ok( $category_d, 'create category has parent ok (c,d -> b)' );
my $category_e = $links->add_category({
    name    => 'name_e' . time,
    slug    => 'slug_e' . time,
});
my $category_f = $links->add_category({
    name    => 'name_f' . time,
    slug    => 'slug_f' . time,
    parent  => $category_e,
});
ok( $category_f, 'create category has parent ok (f -> e)' );
my $category_g = $links->add_category({
    name    => 'name_g' . time,
    slug    => 'slug_g' . time,
    parent  => $category_f,
});
ok( $category_g, 'create category has ancestor ok (g -> f -> e)' );

# reload categories to update 'count' cache
# notice: must use alias (foreach $_) instead of copy (foreach my $category)
foreach (( $category_a, $category_b, $category_c, $category_d,
           $category_e, $category_f, $category_g )) {
    $_ = $links->lookup(category => $_->id);
}

# parent_id
is( $category_a->parent_id, undef,           'parent_id ok (a -> *)' );
is( $category_b->parent_id, undef,           'parent_id ok (b -> *)' );
is( $category_c->parent_id, $category_b->id, 'parent_id ok (c -> b)' );
is( $category_d->parent_id, $category_b->id, 'parent_id ok (d -> b)' );
is( $category_e->parent_id, undef,           'parent_id ok (e -> *)' );
is( $category_f->parent_id, $category_e->id, 'parent_id ok (f -> e)' );
is( $category_g->parent_id, $category_f->id, 'parent_id ok (g -> f)' );

# parent
ok( (! defined $category_a->parent),                     'parent ok (a -> *)' );
ok( (! defined $category_b->parent),                     'parent ok (b -> *)' );
is(            $category_c->parent->id, $category_b->id, 'parent ok (c -> b)' );
is(            $category_d->parent->id, $category_b->id, 'parent ok (d -> b)' );
ok( (! defined $category_e->parent),                     'parent ok (e -> *)' );
is(            $category_f->parent->id, $category_e->id, 'parent ok (f -> e)' );
is(            $category_g->parent->id, $category_f->id, 'parent ok (g -> f)' );

# is_root
ok(   $category_a->is_root, 'is_root ok     (a -> *)' );
ok(   $category_b->is_root, 'is_root ok     (b -> *)' );
ok( ! $category_c->is_root, 'is_root not ok (c -> b)' );
ok( ! $category_d->is_root, 'is_root not ok (d -> b)' );
ok(   $category_e->is_root, 'is_root ok     (e -> *)' );
ok( ! $category_f->is_root, 'is_root not ok (f -> e)' );
ok( ! $category_g->is_root, 'is_root not ok (g -> f)' );

# child_ids
is_deeply( [$category_a->child_ids],
           [],
           'child_ids ok (a <- *)' );
is_deeply( [$category_b->child_ids],
           [$category_c->id, $category_d->id],
           'child_ids ok (b <- c,d)' );
is_deeply( [$category_c->child_ids],
           [],
           'child_ids ok (c <- *)' );
is_deeply( [$category_d->child_ids],
           [],
           'child_ids ok (d <- *)' );
is_deeply( [$category_e->child_ids],
           [$category_f->id],
           'child_ids ok (e <- f <- g)' );
is_deeply( [$category_f->child_ids],
           [$category_g->id],
           'child_ids ok (f <- g)' );
is_deeply( [$category_g->child_ids],
           [],
           'child_ids ok (g <- *)' );

# children
is_deeply( [map {$_->id} $category_a->children],
           [],
           'children ok (a <- *)' );
is_deeply( [map {$_->id} $category_b->children],
           [$category_c->id, $category_d->id],
           'children ok (b <- c,d)' );
is_deeply( [map {$_->id} $category_c->children],
           [],
           'children ok (c <- *)' );
is_deeply( [map {$_->id} $category_d->children],
           [],
           'children ok (d <- *)' );
is_deeply( [map {$_->id} $category_e->children],
           [$category_f->id],
           'children ok (e <- f <- g)' );
is_deeply( [map {$_->id} $category_f->children],
           [$category_g->id],
           'children ok (f <- g)' );
is_deeply( [map {$_->id} $category_g->children],
           [],
           'children ok (g <- *)' );

# count_children
is( $category_a->count_children, 0, 'count_children ok (a <- *)'      );
is( $category_b->count_children, 2, 'count_children ok (b <- c,d)'    );
is( $category_c->count_children, 0, 'count_children ok (c <- *)'      );
is( $category_d->count_children, 0, 'count_children ok (d <- *)'      );
is( $category_e->count_children, 1, 'count_children ok (e <- f <- g)' );
is( $category_f->count_children, 1, 'count_children ok (f <- g)'      );
is( $category_g->count_children, 0, 'count_children ok (g <- *)'      );

# is_leaf
ok(   $category_a->is_leaf, 'is_leaf ok     (a <- *)'      );
ok( ! $category_b->is_leaf, 'is_leaf not ok (b <- c,d)'    );
ok(   $category_c->is_leaf, 'is_leaf ok     (c <- *)'      );
ok(   $category_d->is_leaf, 'is_leaf ok     (d <- *)'      );
ok( ! $category_e->is_leaf, 'is_leaf not ok (e <- f <- g)' );
ok( ! $category_f->is_leaf, 'is_leaf not ok (f <- g)'      );
ok(   $category_g->is_leaf, 'is_leaf ok     (g <- *)'      );

# descendant_ids
is_deeply( [$category_a->descendant_ids],
           [],
           'descendant_ids ok (a <- *)' );
is_deeply( [$category_b->descendant_ids],
           [$category_c->id, $category_d->id],
           'descendant_ids ok (b <- c,d)' );
is_deeply( [$category_c->descendant_ids],
           [],
           'descendant_ids ok (c <- *)' );
is_deeply( [$category_d->descendant_ids],
           [],
           'descendant_ids ok (d <- *)' );
is_deeply( [$category_e->descendant_ids],
           [$category_f->id, $category_g->id],
           'descendant_ids ok (e <- f <- g)' );
is_deeply( [$category_f->descendant_ids],
           [$category_g->id],
           'descendant_ids ok (f <- g)' );
is_deeply( [$category_g->descendant_ids],
           [],
           'descendant_ids ok (g <- *)' );

# descendants
is_deeply( [map {$_->id} $category_a->descendants],
           [],
           'descendants ok (a <- *)' );
is_deeply( [map {$_->id} $category_b->descendants],
           [$category_c->id, $category_d->id],
           'descendants ok (b <- c,d)' );
is_deeply( [map {$_->id} $category_c->descendants],
           [],
           'descendants ok (c <- *)' );
is_deeply( [map {$_->id} $category_d->descendants],
           [],
           'descendants ok (d <- *)' );
is_deeply( [map {$_->id} $category_e->descendants],
           [$category_f->id, $category_g->id],
           'descendants ok (e <- f <- g)' );
is_deeply( [map {$_->id} $category_f->descendants],
           [$category_g->id],
           'descendants ok (f <- g)' );
is_deeply( [map {$_->id} $category_g->descendants],
           [],
           'descendants ok (g <- *)' );

# count_descendants
is( $category_a->count_descendants, 0, 'count_descendants ok (a <- *)'      );
is( $category_b->count_descendants, 2, 'count_descendants ok (b <- c,d)'    );
is( $category_c->count_descendants, 0, 'count_descendants ok (c <- *)'      );
is( $category_d->count_descendants, 0, 'count_descendants ok (d <- *)'      );
is( $category_e->count_descendants, 2, 'count_descendants ok (e <- f <- g)' );
is( $category_f->count_descendants, 1, 'count_descendants ok (f <- g)'      );
is( $category_g->count_descendants, 0, 'count_descendants ok (g <- *)'      );


done_testing();

1;
__END__

=head1 TEST DATA

Tree of categories is these:

    a (-> *) (<- *)
    b (-> *) (<- c,d)
        c (-> b) (<- *)
        d (-> b) (<- *)
    e (-> *) (<- f <- g)
        f (-> e) (<- g)
            g (-> f -> e) (<- *)

Note: Cannot happen these (category does not have many parents):

    c (-> b,e)
