package SimpleLinks::Schema::Mixin::Taxonomy;


# ****************************************************************
# pragmas
# ****************************************************************

use strict;
use warnings;


# ****************************************************************
# general dependencies
# ****************************************************************

use Carp qw();
# use Data::Util qw(:check);
use Scalar::Util qw();


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
    my ($schema, $taxonomy) = @_;

    (my $table_name = Scalar::Util::blessed $taxonomy || q{})
        =~ s{ \A .+ :: }{}xms;
    my $link_entity = 'website_' . $table_name;
    my $table_id    = $table_name . '_id';

    return map {
        $_->website_id;
    } $taxonomy->{model}->get($link_entity => {
        where => [
            $table_id  => $taxonomy->id,
        ],
        order => {
            website_id => 'ASC',
        },
    });
}

sub __websites_of_taxonomy {
    my ($class, $taxonomy) = @_;

    my @website_ids = $taxonomy->website_ids;

    return [] unless @website_ids;
    return $taxonomy->{model}->__get_rows
        (\@website_ids, 'SimpleLinks::Schema::Mixin::Website', 'website');
}

sub __alias_columns_of_taxonomy {
    my $schema = shift;

    return [
        taxonomy_slug           => 'slug',
        taxonomy_name           => 'name',
        taxonomy_description    => 'description',
        taxonomy_count_websites => 'count_websites',
    ];
}

sub __add_taxonomy {
    my ($schema, $website_id, $option) = @_;

    if (defined $option->{categories}) {
        $schema->__add_website_category($website_id, $option->{categories});
    }
    if (defined $option->{tags}) {
        $schema->__add_website_tag($website_id, $option->{tags});
    }

    return;
}

sub __delete_taxonomy {
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


=head1 SEE ALSO

=over 4

=item Which is fast to replace or split?

    (my $table_name = Scalar::Util::blessed $row) =~ s{ \A .+ :: }{}xms;

vs.

    my $table_name  = (split m{::}xms, Scalar::Util::blessed $row)[-1];

See L<http://gist.github.com/158256>.

=back


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
