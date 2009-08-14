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

use List::Compare;


# ****************************************************************
# register
# ****************************************************************

sub register_method {
    +{
        add_website                 => \&add_website,
        create_website              => \&add_website,
        get_website                 => \&get_website,
        get_website_id              => \&get_website_id,
        websites                    => \&all_websites,
        all_websites                => \&all_websites,
        get_websites                => \&get_websites,
        get_website_ids             => \&get_website_ids,
        filter_websites             => \&filter_websites,
        count_websites              => \&count_websites,
        remove_all_websites         => \&remove_all_websites,
        delete_all_websites         => \&remove_all_websites,
        __edit_website              => \&__edit_website,
        __update_website            => \&__edit_website,
        __remove_website            => \&__remove_website,
        __delete_website            => \&__remove_website,
        __modify_categories         => \&__modify_categories,
        __modify_tags               => \&__modify_tags,
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

    my $txn = $schema->txn_scope;

    my $website = $txn->set(website => $modified_option);
    if (keys %$taxonomy_option) {
        $schema->__add_taxonomy($website->id, $taxonomy_option, $txn);
    }

    $txn->commit;

    return $website;
}

sub get_website {
    return $_[0]->__get_row($_[1], __PACKAGE__, 'website');
}

sub get_website_id {
    return $_[0]->__get_row_id($_[1], __PACKAGE__, 'website');
}

sub all_websites {
    my $schema = shift;

    return $schema->get(website => {
        order   => {
            id  => 'ASC',
        },
    });
}

# all_websitesの相手となるfilter_websitesと考えればいいが、
# Refで返すんだっけ？
sub get_websites {
    return $_[0]->__get_rows($_[1], __PACKAGE__, 'website');
}

sub get_website_ids {
    return $_[0]->__get_row_ids($_[1], __PACKAGE__, 'website');
}

sub filter_websites {
    my ($schema, $keys) = @_;

    return $schema->lookup_multi(website => $keys);
}

sub count_websites {
    my $schema = shift;

    return scalar(my @websites = $schema->all_websites);
}

sub __alias_columns_of_website {
    my $schema = shift;

    return {
        name => 'title',
        @{ $schema->__alias_columns_of_common },
    };
}

# overrided $website->update
sub __edit_website {
    my ($schema_class, $website) = @_;

    my $schema = $website->{model};    # $schema_class->new
    my $txn = $schema->txn_scope;

    # Note: same uri was restricted by Data::Model's unique
    $website->_internal_update($txn);

    $txn->commit;

    return $website;
}

# overrided $website->delete
# to override $schema->delete(website => $website->id) by way of prevention?
sub __remove_website {
    my ($schema_class, $website, $table_name) = @_;

    my $schema = $website->{model};
    my $txn = $schema->txn_scope;

    $txn->delete($table_name => $website->id);
    $schema->__delete_taxonomy($website->id, $txn);

    $txn->commit;

    return;
}

sub remove_all_websites {
    my $schema = shift;

    $schema->__remove_all_rows('website');
    $schema->__remove_all_rows('website_category');
    $schema->__remove_all_rows('website_tag');

    return;
}

# setter
sub __modify_categories {
    my ($schema_class, $website, $new_categories) = @_;

    my $schema = $website->{model};

    my $new_category_ids = [];
    foreach my $new_category (@$new_categories) {
        push @$new_category_ids,
            $schema->__get_row_id(
                $new_category,
                'SimpleLinks::Schema::Mixin::Category',
                'category',
            );
    }

    my @old_category_ids = map {
        $_->category_id;
    } ( $schema->get(website_category => {
        where => [
            website_id => $website->id,
        ],
        order   => {
            id  => 'ASC',
        },
    }) );
    my $comparison = List::Compare->new(\@old_category_ids, $new_category_ids);

    foreach my $deleting_category_id ($comparison->get_unique) {
        my $relation = $schema->get(website_category => {
            where => [
                website_id  => $website->id,
                category_id => $deleting_category_id,
            ],
        });
        $relation->next->delete;
    }

    my $txn = $schema->txn_scope;

    foreach my $adding_category_id ($comparison->get_complement) {
        $txn->set(website_category => {
            website_id  => $website->id,
            category_id => $adding_category_id,
        });
    }

    $txn->commit;

    # same to getter（※未テスト！）
    return [
        $schema->get(website_tag => {
            where => [
                website_id => $website->id,
            ],
        })
    ];
}

# setter
sub __modify_tags {
    my ($schema_class, $website, $new_tags) = @_;

    my $schema = $website->{model};

    my $new_tag_ids = [];
    foreach my $new_tag (@$new_tags) {
        push @$new_tag_ids,
            $schema->__get_row_id(
                $new_tag,
                'SimpleLinks::Schema::Mixin::Tag',
                'tag',
            );
    }

    my @old_tag_ids = map {
        $_->tag_id;
    } ( $schema->get(website_tag => {
        where => [
            website_id => $website->id,
        ],
        order   => {
            id  => 'ASC',
        },
    }) );
    my $comparison = List::Compare->new(\@old_tag_ids, $new_tag_ids);

    foreach my $deleting_tag_id ($comparison->get_unique) {
        my $relation = $schema->get(website_tag => {
            where => [
                website_id => $website->id,
                tag_id     => $deleting_tag_id,
            ],
        });
        $relation->next->delete;
    }

    my $txn = $schema->txn_scope;

    foreach my $adding_tag_id ($comparison->get_complement) {
        $txn->set(website_tag => {
            website_id => $website->id,
            tag_id     => $adding_tag_id,
        });
    }

    $txn->commit;

    # same to getter（※未テスト！）
    return [
        $schema->get(website_tag => {
            where => [
                website_id => $website->id,
            ],
        })
    ];
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

=head2 get_website

Returns a specified website row from C<website> table
on the regulation database.

=head2 get_website_id

Returns an ID of specified website row from C<website> table
on the regulation database.

=head2 all_websites

Returns all website rows from C<website> table
on the regulation database.

=head2 get_websites

Returns specified website rows from C<website> table
on the regulation database.

=head2 get_website_ids

Returns IDs of specified website rows from C<website> table
on the regulation database.

=head2 filter_websites

Returns filtered website rows from C<website> table
on the regulation database.

=head2 count_websites

Returns number of website rows in C<website> table
on the regulation database.

=head2 remove_all_websites

Removes all website rows in C<website> table
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
