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
use List::Util qw(first);


# ****************************************************************
# register
# ****************************************************************

sub register_method {
    +{
        categories                      => \&all_categories,
        all_categories                  => \&all_categories,
        count_categories                => \&count_categories,
        add_category                    => \&add_category,
        create_category                 => \&add_category,
        edit_category                   => \&edit_category,
        update_category                 => \&edit_category,
        remove_category                 => \&remove_category,
        delete_category                 => \&remove_category,
        _alias_columns_of_category      => \&alias_columns_of_category,
        _add_website_category           => \&add_website_category,
    };
}


# ****************************************************************
# additional methods
# ****************************************************************

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

sub add_category {
    my ($schema, $option) = @_;

    my $modified_option
        = __PACKAGE__->_alias_to_real($schema, $option);
    __PACKAGE__->_check_same_column
        ($schema, 'taxonomy_name', $modified_option);
    __PACKAGE__->_check_same_column
        ($schema, 'taxonomy_slug', $modified_option);

    my $category = $schema->set(category => $modified_option);
    __PACKAGE__->_build_parent_recursively($schema, $category);

    return $category;
}

sub _build_parent_recursively {
    my ($class, $schema, $category) = @_;

    my $parent_category = $category->parent;
    if ($parent_category) {
        $parent_category->_build_children_count;
        $parent_category->_build_descendants_count;
        $parent_category->update;   # SUPER::update ??
        __PACKAGE__->_build_parent_recursively($schema, $parent_category);
    }

    return;
}

sub _alias_to_real {
    my ($class, $schema, $option) = @_;

    my $modified_option = $class->SUPER::_alias_to_real
                            ($option, $schema->_alias_columns_of_category);
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

sub _check_same_column {
    my ($class, $schema, $column, $option) = @_;

    my @category_of_same_column = $schema->get(category => {
        where   => [
            $column => $option->{$column},
        ],
    });
    return unless @category_of_same_column;

    my $contestant = first {
        ( $_->parent_id || q{} ) eq ( $option->{parent_id} || q{} );
    } @category_of_same_column;
    return unless $contestant;

    require Data::Dumper;
    local $Data::Dumper::Indent = 1;
    __PACKAGE__->_throw_exception_from_category(
        sprintf('column %s is not unique', $column),
        Data::Dumper::Dumper($option),
        __PACKAGE__->_dump_contestant($contestant),
    );
}

sub _throw_exception_from_category {
    my ($schema, $reason, $option, $additional_info) = @_;

    Carp::croak sprintf <<"TRACE", $reason, $option, $additional_info;

    **** { SimpleLinks::Schema::Mixin::Category 's Exception ****
Reason     : %s
Attributes :
%s%s
    **** SimpleLinks::Schema::Mixin::Category 's Exception } ****
TRACE
}

sub _dump_contestant {
    my ($class, $contestant) = @_;

    return sprintf <<"TRACE", Data::Dumper::Dumper($contestant);
    **** CONTESTANT ****
%s
TRACE
}

sub alias_columns_of_category {
    my $schema = shift;

    return {
        @{ $schema->_alias_columns_of_taxonomy },
        @{ $schema->_alias_columns_of_common },
    };
}

sub add_website_category {
    my ($schema, $option) = @_;

    return $schema->set(website_category => $option);
}

# override $category->update ?
sub edit_category {
    my ($schema, $category) = @_;

    __PACKAGE__->_check_same_column
        ($schema, 'taxonomy_name', $category);
    __PACKAGE__->_check_same_column
        ($schema, 'taxonomy_slug', $category);

    # to do: create method '_check_reverse_filiation'
    die 'xxx'
        # to do: create method 'is_child_of'
        if grep {
            $category->parent->id eq $_->id
        } $category->children;

    $category->SUPER::update;   # can I call?
    __PACKAGE__->_build_parent_recursively($schema, $category);

    return $category;
}

# cannot override $schema->delete(category => $category->id)!
# override $category->delete ?
sub remove_category {
    my ($schema, $category) = @_;

    # to do: create method '_check_leaf_deleting'
    die 'xxx'
        if $category->is_leaf;

    my $parent_category = $category->parent;
    $category->SUPER::delete;   # can I call?
    __PACKAGE__->_build_parent_recursively($schema, $parent_category);

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
