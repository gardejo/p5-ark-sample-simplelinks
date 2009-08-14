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
    SimpleLinks::Schema::Mixin::Taxonomy
    SimpleLinks::Schema::Mixin::Base
);


# ****************************************************************
# general dependencies
# ****************************************************************

use Data::Util qw(:check);
use Module::Load;


# ****************************************************************
# register
# ****************************************************************

sub register_method {
    +{
        add_tag                 => \&add_tag,
        create_tag              => \&add_tag,
        get_tag                 => \&get_tag,
        get_tag_id              => \&get_tag_id,
        tags                    => \&all_tags,
        all_tags                => \&all_tags,
        get_tags                => \&get_tags,
        get_tag_ids             => \&get_tag_ids,
        filter_tags             => \&filter_tags,
        count_tags              => \&count_tags,
        tag_ratings             => \&tag_ratings,
        tag_cloud               => \&tag_ratings,
        remove_all_tags         => \&remove_all_tags,
        delete_all_tags         => \&remove_all_tags,
        __edit_tag              => \&__edit_tag,
        __update_tag            => \&__edit_tag,
        __remove_tag            => \&__remove_tag,
        __delete_tag            => \&__remove_tag,
        __alias_columns_of_tag  => \&__alias_columns_of_tag,
        __add_website_tag       => \&__add_website_tag,
        __delete_website_tag    => \&__delete_website_tag,
    };
}


# ****************************************************************
# additional methods
# ****************************************************************

sub add_tag {
    my ($schema, $option) = @_;

    # 今のところトランザクション処理は不要

    my $tag = $schema->set(tag =>
        __PACKAGE__->SUPER::__alias_to_real
            ($option, $schema->__alias_columns_of_tag)
    );

    # 不要かも
    $tag->count_current_websites;
    $tag->update;   # tag does not need to override 'update'

    return $tag;
}

sub get_tag {
    return $_[0]->__get_row($_[1], __PACKAGE__, 'tag', $_[2]);
}

sub get_tag_id {
    return $_[0]->__get_row_id($_[1], __PACKAGE__, 'tag');
}

# all_tagsの相手となるfilter_tagsと考えればいいが、
# Refで返すんだっけ？
# 引数なしならall_tags
sub get_tags {
    return $_[0]->__get_rows($_[1], __PACKAGE__, 'tag');
}

sub get_tag_ids {
    return $_[0]->__get_row_ids($_[1], __PACKAGE__, 'tag');
}

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

# $rateを渡さないとData::Cloud->ratingで死ぬのでそれを捕捉すればよい
# $rateのデフォルト値はここでなくてSimpleLinks::Web::Model::Linksで指定
# ……と思ったが、単純に全数を指定するのが正解のような気がしたのでそう書く。
sub tag_ratings {
    my $schema = shift;

    load Data::Cloud;   # ensure_class_loaded式にload unless loadedが必要かも
    my $cloud = Data::Cloud->new;

    my @all_tags = $schema->all_tags;

    $cloud->set(
        map {
            $_->name => $_->count_websites;
        } @all_tags
    );

    return $cloud->rating( rate => scalar @all_tags );
}

sub __alias_columns_of_tag {
    my $schema = shift;

    return {
        @{ $schema->__alias_columns_of_taxonomy },
        @{ $schema->__alias_columns_of_common },
    };
}

# overrided $tag->delete
# to override $schema->delete(tag => $tag->id) by way of prevention?
sub __remove_tag {
    my ($schema_class, $tag, $table_name) = @_;

    my $schema = $tag->{model};
    my $txn = $schema->txn_scope;

    $txn->delete($table_name => $tag->id);

    my $relation_table_name = 'website_' . $table_name; # website_tag
    my $lookup_column       = $table_name . '_id';      # tag_id
    my @relations = $txn->get($relation_table_name => {
        where => [
            $lookup_column => $tag->id,
        ],
    });
    foreach my $relation (@relations) {
        $txn->delete($relation_table_name => $relation->id);
    }

    $txn->commit;

    return;
}

sub remove_all_tags {
    my $schema = shift;

    $schema->__remove_all_rows('tag');
    $schema->__remove_all_rows('website_tag');

    return;
}

sub __add_website_tag {
    my ($schema, $website_id, $tag_queries, $handler) = @_;

    $handler ||= $schema;

    foreach my $tag ( map {
        $schema->get_tag($_, $handler);
    } @$tag_queries ) {
        $handler->set(website_tag => {
            website_id  => $website_id,
            tag_id      => $tag->id,
        });
        $tag->count_current_websites($handler);
        $handler->update($tag);     # tag does not need to override 'update'
    }

    return;
}

sub __delete_website_tag {
    my ($schema, $website_id, $handler) = @_;

    $handler ||= $schema;

    my @website_tag_relations = $handler->get(website_tag => {
        where => [
            website_id => $website_id,
        ],
    });
    foreach my $website_tag_relation (@website_tag_relations) {
        $handler->delete(website_tag => $website_tag_relation->id);
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

=head2 get_tag

Returns a specified tag row from C<tag> table
on the regulation database.

=head2 get_tag_id

Returns an ID of specified tag row from C<tag> table
on the regulation database.

=head2 all_tags

Returns all tag rows from C<tagy> table
on the regulation database.

=head2 get_tags

Returns specified tag rows from C<tag> table
on the regulation database.

=head2 get_tag_ids

Returns IDs of specified tag rows from C<tag> table
on the regulation database.

=head2 filter_tags

Returns filtered tag rows from C<tag> table
on the regulation database.

=head2 count_tags

Returns number of tag rows in C<tag> table
on the regulation database.

=head2 tag_ratings

Returns ratings of tags in C<tag> table
on the regulation database.

=head2 remove_all_tags

Removes all tag rows in C<tag> table
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
