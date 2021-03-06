package SimpleLinks::Schema::Mixin::Taxonomy;


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
# register
# ****************************************************************

sub register_method {
    +{
        __add_taxonomy              => \&__add_taxonomy,
        __delete_taxonomy           => \&__delete_taxonomy,
        _website_ids                => \&__website_ids_of_taxonomy,
        _websites                   => \&__websites_of_taxonomy,
        __alias_columns_of_taxonomy => \&__alias_columns_of_taxonomy,
    };
}


# ****************************************************************
# additional methods
# ****************************************************************

sub __website_ids_of_taxonomy {
    my ($schema_class, $taxonomy, $handler) = @_;

    my $schema = $taxonomy->{model};
    my $table_name = $schema->__get_table_name($taxonomy);

    $handler ||= $schema;
    my $link_entity = 'website_' . $table_name;
    my $table_id    = $table_name . '_id';

    return map {
        $_->website_id;
    } $handler->get($link_entity => {
        where => [
            $table_id  => $taxonomy->id,
        ],
        order => {
            website_id => 'ASC',
        },
    });
}

sub __websites_of_taxonomy {
    my ($schema_class, $taxonomy) = @_;

    my @website_ids = $taxonomy->website_ids;

    return [] unless @website_ids;
    return $taxonomy->{model}->__get_rows
        (\@website_ids, 'SimpleLinks::Schema::Mixin::Website', 'website');
}

sub __alias_columns_of_taxonomy {
    my $schema_class = shift;

    return [
        taxonomy_slug           => 'slug',
        taxonomy_name           => 'name',
        taxonomy_description    => 'description',
        taxonomy_count_websites => 'count_websites',
    ];
}

sub __add_taxonomy {
    my ($schema, $website_id, $option, $txn) = @_;

    if (defined $option->{categories}) {
        $schema->__add_website_category
                    ($website_id, $option->{categories}, $txn);
    }
    if (defined $option->{tags}) {
        $schema->__add_website_tag
                    ($website_id, $option->{tags}, $txn);
    }

    return;
}

sub __delete_taxonomy {
    my ($schema, $website_id, $txn) = @_;

    $schema->__delete_website_category
                ($website_id, $txn);
    $schema->__delete_website_tag
                ($website_id, $txn);

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

SimpleLinks::Schema::Mixin::Taxonomy - 


=head1 SYNOPSIS

    # blah blah blah


=head1 DESCRIPTION

blah blah blah


=head1 METHODS

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
