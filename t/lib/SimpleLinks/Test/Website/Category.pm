package SimpleLinks::Test::Website::Category;


# ****************************************************************
# pragmas
# ****************************************************************

use strict;
use warnings;


# ****************************************************************
# superclasses
# ****************************************************************

use base qw(
    Exporter
);


# ****************************************************************
# general dependencies
# ****************************************************************

use Time::HiRes qw(time);


# ****************************************************************
# internal dependencies
# ****************************************************************

use SimpleLinks::Test::Constant;
use SimpleLinks::Test::Category;


# ****************************************************************
# class variables : Exporter settings
# ****************************************************************

our @EXPORT = qw(
    add_website_category_relationships
);
our @EXPORT_OK = qw(
);
our %EXPORT_TAGS = (
);


# ****************************************************************
# functions
# ****************************************************************

sub add_website_category_relationships {
    my $links = shift;

    # create categories
    my ($cat_a, $cat_b, $cat_c, $cat_d, $cat_e, $cat_f, $cat_g )
        = add_cascading_categories($links);

    # create websites
    my $site_a = $links->add_website({
        name        => 'name_a' . time,
        uri         => 'http://site_a.example/' . time,
        categories  => [$cat_b],
    });
    my $site_b = $links->add_website({
        name        => 'name_b' . time,
        uri         => 'http://site_b.example/' . time,
        categories  => [$cat_c->id],
    });
    my $site_c = $links->add_website({
        name        => 'name_c' . time,
        uri         => 'http://site_c.example/' . time,
        categories  => [$cat_d->name],
    });
    my $site_d = $links->add_website({
        name        => 'name_d' . time,
        uri         => 'http://site_d.example/' . time,
        categories  => [$cat_e],
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
        categories  => [$cat_b->name, $cat_g],
    });
    my $site_h = $links->add_website({
        name        => 'name_h' . time,
        uri         => 'http://site_h.example/' . time,
        categories  => [$cat_c->id, $cat_e],
    });

    return (
        $cat_a,  $cat_b,  $cat_c,  $cat_d,  $cat_e,  $cat_f,  $cat_g,
        $site_a, $site_b, $site_c, $site_d, $site_e, $site_f, $site_g, $site_h
    );
}



# ****************************************************************
# return true
# ****************************************************************

1;
__END__


# ****************************************************************
# POD
# ****************************************************************

=head1 NAME

SimpleLinks::Test::Cleanup - cleanup environment when end of SimpleLinks test


=head1 SYNOPSIS

    use Test::More 0.87_01;

    use lib 't/lib';
    use SimpleLinks::Test::Cleanup;

    END {
        diag 'cleanup';
        cleanup();
    }

    done_testing();


=head1 AUTHOR

=over 4

=item MORIYA Masaki ("Gardejo")

C<< <moriya at ermitejo dot com> >>,
L<http://ttt.ermitejo.com/>

=back


=head1 LICENSE AND COPYRIGHT

Copyright (c) 2009 by MORIYA Masaki ("Gardejo"),
L<http://ttt.ermitejo.com>.

This library is free software;
you can redistribute it and/or modify it under the same terms as Perl itself.
See L<perlgpl|perlapi> and L<perlartistic|perlartistic>.
