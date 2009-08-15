package Faktro::Schema::Factory::DBI;


# ****************************************************************
# class variables
# ****************************************************************

our $VERSION = '0.00_00';


# ****************************************************************
# general dependencies
# ****************************************************************

use Data::Model::Driver::DBI;


# ****************************************************************
# MOP
# ****************************************************************

use Any::Moose;             # automatically turn on strict & warnings

extends qw(
    Faktro::Schema::Factory::Base
);

has 'dbi_driver' => (
    is          => 'ro',
    isa         => 'Data::Model::Driver::DBI',
    lazy_build  => 1,
);

has 'dbd' => (
    is          => 'ro',
    isa         => 'Str',
    required    => 1,
);

has 'dsn' => (
    is          => 'ro',
    isa         => 'Str',
    lazy_build  => 1,
);

has 'dbi_connect_options' => (
    is          => 'ro',
    isa         => 'HashRef',
    builder     => '_build_dbi_connect_options',
);

has 'dsn_options' => (
    is          => 'ro',
    isa         => 'HashRef',
    default     => sub { {} },
);

no Any::Moose;
__PACKAGE__->meta->make_immutable;


# ****************************************************************
# builders
# ****************************************************************

sub _build_dbi_driver {
    return Data::Model::Driver::DBI->new(
        dsn             => $_[0]->dsn,
        connect_options => $_[0]->dbi_connect_options,
    );
}

sub _build_dbi_connect_options {
    return {};
}

sub _build_dsn {
    my @dsn_options;
    while (my ($key, $value) = each %{ $_[0]->dsn_options }) {
        push @dsn_options, $key . '=' . (defined $value ? $value : q{});
    }
    return sprintf(
        'dbi:%s:%s',
        $_[0]->dbd,
        (
            join ';', @dsn_options,
        ),
    );
}


# ****************************************************************
# initializations
# ****************************************************************

sub BUILD {
    my $self = shift;

    $self->_model->set_base_driver($self->dbi_driver);
    $self->create_table;

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

Faktro::Schema::Factory::DBI - abstract DBI factory class for schema of Data::Model


=head1 VERSION

0.00_00


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


=head1 LICENSE AND COPYRIGHT

Copyright (c) 2009 by MORIYA Masaki ("Gardejo"),
L<http://ttt.ermitejo.com>.

This library is free software;
you can redistribute it and/or modify it under the same terms as Perl itself.
See L<perlgpl|perlapi> and L<perlartistic|perlartistic>.
