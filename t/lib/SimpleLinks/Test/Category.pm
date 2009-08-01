package SimpleLinks::Test::Category;


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
# internal dependencies
# ****************************************************************

use SimpleLinks::Test::Constant;


# ****************************************************************
# class variables : Exporter settings
# ****************************************************************

our @EXPORT = qw(
    add_cascading_categories add_cascading_category
);
our @EXPORT_OK = qw(
);
our %EXPORT_TAGS = (
);


# ****************************************************************
# functions
# ****************************************************************

sub add_cascading_categories {
    my $links = shift;

    my  $category_a = add_cascading_category($links, 'a');
    my  $category_b = add_cascading_category($links, 'b');
    my  $category_c = add_cascading_category($links, 'c', {parent => $category_b});
    my  $category_d = add_cascading_category($links, 'd', {parent => $category_b});
    my  $category_e = add_cascading_category($links, 'e');
    my  $category_f = add_cascading_category($links, 'f', {parent => $category_e});
    my  $category_g = add_cascading_category($links, 'g', {parent => $category_f});

    return ( $category_a, $category_b, $category_c, $category_d,
             $category_e, $category_f, $category_g );
}

sub add_cascading_category {
    my ($links, $branch_name, $option) = @_;

    my %option = defined $option ? %$option : ();

    return $links->add_category({
        name    => 'name_' . $branch_name . time,
        slug    => 'slug_' . $branch_name . time,
        %option,
    });
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
