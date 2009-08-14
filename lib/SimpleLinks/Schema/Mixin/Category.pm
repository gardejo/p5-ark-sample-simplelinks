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
    SimpleLinks::Schema::Mixin::Taxonomy
    SimpleLinks::Schema::Mixin::Base
);


# ****************************************************************
# general dependencies
# ****************************************************************

use Carp qw(croak);
use Data::Util qw(:check);
use List::MoreUtils qw(none);
use List::Util qw(first);


# ****************************************************************
# register
# ****************************************************************

sub register_method {
    +{
        add_category                    => \&add_category,
        create_category                 => \&add_category,
        get_category                    => \&get_category,
        get_category_id                 => \&get_category_id,
        categories                      => \&all_categories,
        all_categories                  => \&all_categories,
        get_categories                  => \&get_categories,
        get_category_ids                => \&get_category_ids,
        filter_categories               => \&filter_categories,
        count_categories                => \&count_categories,
        remove_all_categories           => \&remove_all_categories,
        delete_all_categories           => \&remove_all_categories,
        __edit_category                 => \&__edit_category,
        __update_category               => \&__edit_category,
        __remove_category               => \&__remove_category,
        __delete_category               => \&__remove_category,
        __alias_columns_of_category     => \&__alias_columns_of_category,
        __add_website_category          => \&__add_website_category,
        __delete_website_category       => \&__delete_website_category,
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

    my $txn = $schema->txn_scope;

    my $category = $txn->set(category => $modified_option);
    __PACKAGE__->__build_parent_recursively($category, $txn);

    # 不要かも
    $category->count_current_websites($txn);
    $category->update($txn);    # overrided internal update

    $txn->commit;

    return $category;
}

sub get_category {
    return $_[0]->__get_row($_[1], __PACKAGE__, 'category', $_[2]);
}

sub get_category_id {
    return $_[0]->__get_row_id($_[1], __PACKAGE__, 'category');
}

sub all_categories {
    my $schema = shift;

    return $schema->get(category => {
        order   => {
            id  => 'ASC',
        },
    });
}

# all_categoriesの相手となるfilter_categoriesと考えればいいが、
# Refで返すんだっけ？
# 引数なしならall_cats
sub get_categories {
    return $_[0]->__get_rows($_[1], __PACKAGE__, 'category');
}

sub get_category_ids {
    return $_[0]->__get_row_ids($_[1], __PACKAGE__, 'category');
}

sub count_categories {
    my $schema = shift;

    return scalar(my @categories = $schema->all_categories);
}

sub __build_parent_recursively {
    my ($schema_class, $category, $txn) = @_;

    my $parent_category = $category->parent($txn);
    if ($parent_category) {
        $parent_category->_build_children_count($txn);
        $parent_category->_build_descendants_count($txn);
        $parent_category->_internal_update($txn);
        __PACKAGE__->__build_parent_recursively($parent_category, $txn);
    }

    return;
}

sub __alias_to_real {
    my ($class, $schema, $option) = @_;

    my $modified_option = $class->SUPER::__alias_to_real
                            ($option, $schema->__alias_columns_of_category);

    if (exists $modified_option->{parent}) {
        if (defined $modified_option->{parent}) {
            $modified_option->{parent_id}
                = $schema->get_category_id($modified_option->{parent});
        }
        else {
            $modified_option->{parent_id} = undef;
        }
        delete $modified_option->{parent};
    }

    return $modified_option;
}

sub __check_same_column {
    my ($class, $schema, $column, $option, $handler) = @_;

    $handler ||= $schema;

    my %is_not_same_id
        = exists $option->{id} ? (id => { '!=' => $option->{id} } )
        :                        ();
    my @category_of_same_column = $handler->get(category => {
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

    croak sprintf <<"TRACE", $reason, $option, $additional_info || q{};

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

# overrided $category->update
sub __edit_category {
    my ($schema_class, $category, $txn) = @_;

    my $schema = $category->{model};

    __PACKAGE__->__check_same_column
        ($schema, 'taxonomy_name', $category->get_columns, $txn);
    __PACKAGE__->__check_same_column
        ($schema, 'taxonomy_slug', $category->get_columns, $txn);
    __PACKAGE__->__check_reverse_filiation
        ($schema, $category, $txn);

    $category->_internal_update($txn);
    __PACKAGE__->__build_parent_recursively($category, $txn);

    return $category;
}

sub __check_reverse_filiation {
    my ($class, $schema, $category, $txn) = @_;

    my $parent_id = $category->parent_id;

    return unless defined $parent_id;

    my @child_ids = $category->child_ids($txn);
    return unless @child_ids;
    return if none {
        $_ eq $parent_id;
    } @child_ids;

    require Data::Dumper;
    local $Data::Dumper::Indent = 1;
    __PACKAGE__->__throw_exception_from_category(
        'category at once parent and child',
        Data::Dumper::Dumper($category),
    );
}

# overrided $category->delete
# to override $schema->delete(category => $category->id) by way of prevention?
sub __remove_category {
    my ($schema_class, $category, $table_name) = @_;

    croak "Cannot remove category because category is not a leaf"
        unless $category->is_leaf;

    my $schema = $category->{model};
    my $txn = $schema->txn_scope;

    $txn->delete($table_name => $category->id);
    __PACKAGE__->__build_parent_recursively($category, $txn);

    my $relation_table_name = 'website_' . $table_name; # website_category
    my $lookup_column       = $table_name . '_id';      # category_id
    my @relations = $txn->get($relation_table_name => {
        where => [
            $lookup_column => $category->id,
        ],
    });
    foreach my $relation (@relations) {
        $txn->delete($relation_table_name => $relation->id);
    }

    $txn->commit;

    return;
}

sub remove_all_categories {
    my $schema = shift;

    $schema->__remove_all_rows('category');
    $schema->__remove_all_rows('website_category');

    return;
}

sub __add_website_category {
    my ($schema, $website_id, $category_queries, $handler) = @_;

    $handler ||= $schema;

    foreach my $category ( map {
        $schema->get_category($_, $handler);
    } @$category_queries ) {
        $handler->set(website_category => {
            website_id  => $website_id,
            category_id => $category->id,
        });
        $category->count_current_websites($handler);
        $category->update($handler);    # overrided internal update
    }

    return;
}

sub __delete_website_category {
    my ($schema, $website_id, $handler) = @_;

    $handler ||= $schema;

    my @website_category_relations = $handler->get(website_category => {
        where => [
            website_id => $website_id,
        ],
    });
    foreach my $website_category_relation (@website_category_relations) {
        $handler->delete(website_category => $website_category_relation->id);
    }

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

=head2 get_category

Returns a specified category row from C<category> table
on the regulation database.

=head2 get_category_id

Returns an ID of specified category row from C<category> table
on the regulation database.

=head2 all_categories

Returns all category rows from C<category> table
on the regulation database.

=head2 get_categories

Returns specified category rows from C<category> table
on the regulation database.

=head2 get_category_ids

Returns IDs of specified category rows from C<category> table
on the regulation database.

=head2 filter_categories

Returns filtered category rows from C<category> table
on the regulation database.

=head2 count_categories

Returns number of category rows in C<category> table
on the regulation database.

=head2 remove_all_categories

Removes all category rows in C<category> table
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
