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

use Carp qw();
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
        tags                    => \&all_tags,
        all_tags                => \&all_tags,
        get_tags                => \&get_tags,
        filter_tags             => \&filter_tags,
        count_tags              => \&count_tags,
        tag_ratings             => \&tag_ratings,
        tag_cloud               => \&tag_ratings,
        remove_all_tags         => \&remove_all_tags,
        delete_all_tags         => \&remove_all_tags,
        __alias_columns_of_tag  => \&__alias_columns_of_tag,
        __add_website_tag       => \&__add_website_tag,
    };
}


# ****************************************************************
# additional methods
# ****************************************************************

sub add_tag {
    my ($schema, $option) = @_;

    my $tag = $schema->set(tag =>
        __PACKAGE__->SUPER::__alias_to_real
            ($option, $schema->__alias_columns_of_tag)
    );

    # 不要かも
    $tag->count_current_websites;
    $tag->update;

    return $tag;
}

sub get_tag {
    return $_[0]->__get_row($_[1], __PACKAGE__, 'tag');
}

# all_tagsの相手となるfilter_tagsと考えればいいが、
# Refで返すんだっけ？
# 引数なしならall_tags
sub get_tags {
    return $_[0]->__get_rows($_[1], __PACKAGE__, 'tag');
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

sub remove_all_tags {
    my $schema = shift;

    $schema->__remove_all_rows('tag');
    $schema->__remove_all_rows('website_tag');

    return;
}

sub __add_website_tag {
    my ($schema, $website_id, $tag_queries) = @_;

    foreach my $tag ( map {
        $schema->get_tag($_, __PACKAGE__, 'tag');
    } @$tag_queries ) {
        $schema->set(website_tag => {
            website_id  => $website_id,
            tag_id      => $tag->id,
        });
        $tag->count_current_websites;
        $tag->update;
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

=head2 all_tags

Returns all tag rows from C<tagy> table
on the regulation database.

=head2 get_tags

Returns specified tag rows from C<tag> table
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
