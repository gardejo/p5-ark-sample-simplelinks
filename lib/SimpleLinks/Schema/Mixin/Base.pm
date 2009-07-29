package SimpleLinks::Schema::Mixin::Base;


# ****************************************************************
# pragmas
# ****************************************************************

use strict;
use warnings;


# ****************************************************************
# general dependencies
# ****************************************************************

use Carp qw();


# ****************************************************************
# miscellaneous methods
# ****************************************************************

sub _alias_to_real {
    my ($schema, $option, $alias) = @_;

    my %new_option = %$option;

    while ( my ($real_column, $alias_column) = each %$alias ) {
        if (exists $new_option{$alias_column}) {
            $new_option{$real_column} = $new_option{$alias_column};
            delete $new_option{$alias_column};
        }
    }

    return \%new_option;
}

sub _separate_taxonomy_from {
    my ($schema, $option, $taxonomy_attributes) = @_;

    my %new_option = %$option;
    my %taxonomy_option;
    @taxonomy_option{@$taxonomy_attributes}
        = @new_option{@$taxonomy_attributes};
    delete @new_option{@$taxonomy_attributes};

    return \%new_option, \%taxonomy_option;
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

SimpleLinks::Schema::Mixin::Base - 


=head1 SYNOPSIS

    # blah blah blah


=head1 DESCRIPTION

blah blah blah


=head1 AUTHOR

=over 4

=item MORIYA Masaki ("Gardejo")

C<< <moriya at ermitejo dot com> >>,
L<http://ttt.ermitejo.com/>

=back


=head1 LICENCE AND COPYRIGHT

Copyright (c) 2009 by MORIYA Masaki ("Gardejo"),
L<http://ttt.ermitejo.com>.

This library is free software;
you can redistribute it and/or modify it under the same terms as Perl itself.
See L<perlgpl|perlapi> and L<perlartistic|perlartistic>.
