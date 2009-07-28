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
use Scalar::Util qw();


# ****************************************************************
# register
# ****************************************************************

sub register_method {
    +{
        _website_ids           => \&website_ids,
        _websites              => \&websites,
        __build_websites_count => \&_build_websites_count,
    };
}


# ****************************************************************
# additional methods
# ****************************************************************

sub website_ids {
    my ($schema, $row) = @_;

    (my $table_name = Scalar::Util::blessed $row) =~ s{ \A .+ :: }{}xms;

    my $link_entity = 'website_' . $table_name;
    my $table_id    = $table_name . '_id';

    return map {
        $_->website_id;
    } $row->{model}->get($link_entity => {
        where => [
            $table_id  => $row->id,
        ],
        order => {
            website_id => 'ASC',
        },
    });
}

sub websites {
    my ($schema, $row) = @_;

    my @website_ids = $row->website_ids($row);
    return unless @website_ids;

    return $row->{model}->lookup_multi(website => [
        @website_ids,
    ]);
}

sub _build_websites_count {
    my ($schema, $row) = @_;

    my @websites = $row->websites($row);   # force list context

    return $row->count_websites(scalar @websites);
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
