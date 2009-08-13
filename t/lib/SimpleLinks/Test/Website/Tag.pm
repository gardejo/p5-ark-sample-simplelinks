package SimpleLinks::Test::Website::Tag;


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


# ****************************************************************
# class variables : Exporter settings
# ****************************************************************

our @EXPORT = qw(
    add_website_tag_relationships
);
our @EXPORT_OK = qw(
);
our %EXPORT_TAGS = (
);


# ****************************************************************
# functions
# ****************************************************************

sub add_website_tag_relationships {
    my $links = shift;

    # create tags
    my $tag_a = $links->add_tag({
        name    => 'name_a' . time,
        slug    => 'slug_a' . time,
    });
    my $tag_b = $links->add_tag({
        name    => 'name_b' . time,
        slug    => 'slug_b' . time,
    });
    my $tag_c = $links->add_tag({
        name    => 'name_c' . time,
        slug    => 'slug_c' . time,
    });
    my $tag_d = $links->add_tag({
        name    => 'name_d' . time,
        slug    => 'slug_d' . time,
    });

    # create websites
    my $site_a = $links->add_website({
        name    => 'name_a' . time,
        uri     => 'http://uri_a.example/' . time,
        tags    => [$tag_a],
    });
    my $site_b = $links->add_website({
        name    => 'name_b' . time,
        uri     => 'http://uri_b.example/' . time,
        tags    => [$tag_a, $tag_b->id],
    });
    my $site_c = $links->add_website({
        name    => 'name_c' . time,
        uri     => 'http://uri_c.example/' . time,
        tags    => [$tag_b->name],
    });
    my $site_d = $links->add_website({
        name    => 'name_d' . time,
        uri     => 'http://uri_d.example/' . time,
        tags    => [$tag_c->id],
    });
    my $site_e = $links->add_website({
        name    => 'name_e' . time,
        uri     => 'http://uri_e.example/' . time,
        tags    => [],
    });

    return ( $tag_a,  $tag_b,  $tag_c,  $tag_d,
             $site_a, $site_b, $site_c, $site_d, $site_e );
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
