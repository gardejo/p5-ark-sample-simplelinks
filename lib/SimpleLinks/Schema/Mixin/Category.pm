package SimpleLinks::Schema::Mixin::Category;


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
use List::MoreUtils qw(none);
use List::Util qw(first);


# ****************************************************************
# register
# ****************************************************************

sub register_method {
    +{
        add_category                    => \&add_category,
        create_category                 => \&add_category,
        categories                      => \&all_categories,
        all_categories                  => \&all_categories,
        count_categories                => \&count_categories,
        __edit_category                 => \&__edit_category,
        __update_category               => \&__edit_category,
        __remove_category               => \&__remove_category,
        __delete_category               => \&__remove_category,
        __alias_columns_of_category     => \&__alias_columns_of_category,
        __add_website_category          => \&__add_website_category,
    };
}


# ****************************************************************
# additional methods
# ****************************************************************

sub add_category {
    my ($schema, $option) = @_;

    my $modified_option
        = __PACKAGE__->__alias_to_real($schema, $option);
    __PACKAGE__->__check_same_column
        ($schema, 'taxonomy_name', $modified_option);
    __PACKAGE__->__check_same_column
        ($schema, 'taxonomy_slug', $modified_option);

    my $category = $schema->set(category => $modified_option);
    __PACKAGE__->__build_parent_recursively($schema, $category);

    return $category;
}

sub all_categories {
    my $schema = shift;

    return $schema->get(category => {
        order   => {
            id  => 'ASC',
        },
    });
}

sub count_categories {
    my $schema = shift;

    return scalar(my @categories = $schema->all_categories);
}

sub __build_parent_recursively {
    my ($class, $schema, $category) = @_;

    my $parent_category = $category->parent;
    if ($parent_category) {
        $parent_category->_build_children_count;
        $parent_category->_build_descendants_count;
        $parent_category->_internal_update;
        __PACKAGE__->__build_parent_recursively($schema, $parent_category);
    }

    return;
}

sub __alias_to_real {
    my ($class, $schema, $option) = @_;

    my $modified_option = $class->SUPER::__alias_to_real
                            ($option, $schema->__alias_columns_of_category);
    if (exists $modified_option->{parent}) {
        if (defined $modified_option->{parent}) {
            $modified_option->{parent_id} = $modified_option->{parent}->id;
        }
        else {
            $modified_option->{parent_id} = undef;
        }
        delete $modified_option->{parent};
    }

    return $modified_option;
}

sub __check_same_column {
    my ($class, $schema, $column, $option) = @_;

    my %is_not_same_id
        = exists $option->{id} ? (id => { '!=' => $option->{id} } )
        :                        ();
    my @category_of_same_column = $schema->get(category => {
        where   => [
            $column => $option->{$column},
            %is_not_same_id,
        ],
    });
    return unless @category_of_same_column;

    my $contestant = first {
        ( $_->parent_id || q{} ) eq ( $option->{parent_id} || q{} );
    } @category_of_same_column;
    return unless $contestant;

    require Data::Dumper;
    local $Data::Dumper::Indent = 1;
    __PACKAGE__->__throw_exception_from_category(
        sprintf('column %s is not unique', $column),
        Data::Dumper::Dumper($option),
        __PACKAGE__->__dump_contestant($contestant),
    );
}

sub __throw_exception_from_category {
    my ($class, $reason, $option, $additional_info) = @_;

    Carp::croak sprintf <<"TRACE", $reason, $option, $additional_info || q{};

    **** { SimpleLinks::Schema::Mixin::Category 's Exception ****
Reason     : %s
Attributes :
%s%s
    **** SimpleLinks::Schema::Mixin::Category 's Exception } ****
TRACE
}

sub __dump_contestant {
    my ($class, $contestant) = @_;

    return sprintf <<"TRACE", Data::Dumper::Dumper($contestant);
    **** CONTESTANT ****
%s
TRACE
}

sub __alias_columns_of_category {
    my $schema = shift;

    return {
        @{ $schema->__alias_columns_of_taxonomy },
        @{ $schema->__alias_columns_of_common },
    };
}

sub __add_website_category {
    my ($schema, $option) = @_;

    return $schema->set(website_category => $option);
}

# overrided $category->update
sub __edit_category {
    my ($schema_class, $category) = @_;

    my $schema = $schema_class->new;

    __PACKAGE__->__check_same_column
        ($schema, 'taxonomy_name', $category->get_columns);
    __PACKAGE__->__check_same_column
        ($schema, 'taxonomy_slug', $category->get_columns);
    __PACKAGE__->__check_reverse_filiation
        ($schema, $category);

    $category->_internal_update;
    __PACKAGE__->__build_parent_recursively($schema, $category);

    return $category;
}

sub __check_reverse_filiation {
    my ($class, $schema, $category) = @_;

    my $parent_id = $category->parent_id;

    return unless defined $parent_id;
    return if none {
        $_ eq $parent_id;
    } $category->child_ids;

    require Data::Dumper;
    local $Data::Dumper::Indent = 1;
    __PACKAGE__->__throw_exception_from_category(
        'category at once parent and child',
        Data::Dumper::Dumper($category),
    );
}

# overrided $category->delete
# cannot override $schema->delete(category => $category->id)!
sub __remove_category {
    my ($schema, $category) = @_;

    # to do: create method '_check_leaf_deleting'
    die 'xxx'
        if $category->is_leaf;

    my $parent_category = $category->parent;
    $category->SUPER::delete;   # can I call?
    __PACKAGE__->__build_parent_recursively($schema, $parent_category);

    return;
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

SimpleLinks::Schema::Mixin::Category - 


=head1 SYNOPSIS

    # blah blah blah


=head1 DESCRIPTION

blah blah blah


=head1 METHODS

=head2 add_category

Creates a new category row to C<category> table
on the regulation database.

Returns created C<category> row.

=head2 all_categories

Returns all category rows from C<category> table
on the regulation database.

=head2 count_categories

Returns number of category rows in C<category> table
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
