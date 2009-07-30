package SimpleLinks::Schema::Mixin::Tag;


# ****************************************************************
# pragmas
# ****************************************************************

use strict;
use warnings;


# ****************************************************************
# superclasses
# ****************************************************************

use base qw(
    SimpleLinks::Schema::Mixin::Base
);


# ****************************************************************
# general dependencies
# ****************************************************************

use Carp qw();


# ****************************************************************
# register
# ****************************************************************

sub register_method {
    +{
        tags                    => \&all_tags,
        all_tags                => \&all_tags,
        count_tags              => \&count_tags,
        add_tag                 => \&add_tag,
        __alias_columns_of_tag  => \&__alias_columns_of_tag,
        __add_website_tag       => \&__add_website_tag,
    };
}


# ****************************************************************
# additional methods
# ****************************************************************

sub all_tags {
    my $schema = shift;

    return $schema->get(tag => {
        order   => {
            id  => 'ASC',
        },
    });
}

sub count_tags {
    my $schema = shift;

    return scalar(my @tags = $schema->all_tags);
}

sub add_tag {
    my ($schema, $option) = @_;

    return $schema->set(tag =>
        __PACKAGE__->SUPER::__alias_to_real
            ($option, $schema->__alias_columns_of_tag)
    );
}

sub __alias_columns_of_tag {
    my $schema = shift;

    return {
        @{ $schema->__alias_columns_of_taxonomy },
        @{ $schema->__alias_columns_of_common },
    };
}

sub __add_website_tag {
    my ($schema, $option) = @_;

    return $schema->set(website_tag => $option);
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

SimpleLinks::Schema::Mixin::Tag - 


=head1 SYNOPSIS

    # blah blah blah


=head1 DESCRIPTION

blah blah blah


=head1 METHODS

=head2 add_tag

Creates a new tag row to C<tag> table
on the regulation database.

Returns created C<tag> row.

=head2 all_tags

Returns all tag rows from C<tagy> table
on the regulation database.

=head2 count_tags

Returns number of tag rows in C<tag> table
on the regulation database.

=head2 remove_tag

Deletes a existent tag row in C<tag> table
on the regulation database.

=head2 register_method

B<INTERNAL USE ONLY>.
For L<Data::Model::Mixin|Data::Model::Mixin> mechanism.


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
