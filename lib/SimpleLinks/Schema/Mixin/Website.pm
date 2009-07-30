package SimpleLinks::Schema::Mixin::Website;


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
        websites                    => \&all_websites,
        all_websites                => \&all_websites,
        filter_websites             => \&filter_websites,
        count_websites              => \&count_websites,
        add_website                 => \&add_website,
        __alias_columns_of_website  => \&__alias_columns_of_website,
        # ...
    };
}


# ****************************************************************
# additional methods
# ****************************************************************

sub add_website {
    my ($schema, $option) = @_;

    my $modified_option
        = __PACKAGE__->SUPER::__alias_to_real
            ($option, $schema->__alias_columns_of_website);
    ($modified_option, my $taxonomy_option)
        = $schema->SUPER::__separate_taxonomy_from
            ($modified_option, [qw(categories tags)]);

    my $website = $schema->set(website => $modified_option);

    if (keys %$taxonomy_option) {
        $schema->__add_taxonomy($website->id, $taxonomy_option);
    }

    return $website;
}

sub all_websites {
    my $schema = shift;

    return $schema->get(website => {
        order   => {
            id  => 'ASC',
        },
    });
}

sub filter_websites {
    my ($schema, $keys) = @_;

    return $schema->lookup_multi(website => {
        @$keys,
    });
}

sub count_websites {
    my $schema = shift;

    return scalar(my @websites = $schema->all_websites);
}

sub __alias_columns_of_website {
    my $schema = shift;

    return {
        @{ $schema->__alias_columns_of_taxonomy },
        @{ $schema->__alias_columns_of_common },
    };
}

# $website_row->add_categories
sub __add_categories {
}

sub __delete_categories {
}

sub __add_tags {
}

sub __add_relations {
}

sub __delete_website {
}

sub __delete_relations {
}

sub __modify_relation {
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

SimpleLinks::Schema::Mixin::Website - 


=head1 SYNOPSIS

    # blah blah blah


=head1 DESCRIPTION

blah blah blah


=head1 METHODS

=head2 add_website

Creates a new website row to C<website> table
on the regulation database.

Returns created C<website> row.

=head2 all_websites

Returns all website rows from C<website> table
on the regulation database.

=head2 filter_websites

Returns filtered website rows from C<website> table
on the regulation database.

=head2 count_websites

Returns number of website rows in C<website> table
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
