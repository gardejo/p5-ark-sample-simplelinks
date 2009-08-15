package Faktro::Schema::Factory;


# ****************************************************************
# class variables
# ****************************************************************

our $VERSION = '0.00_00';


# ****************************************************************
# MOP
# ****************************************************************

use Any::Moose;             # automatically turn on strict & warnings

has 'backend' => (
    is          => 'ro',
    isa         => 'Str',
    required    => 1,
);

around 'new' => sub {
    my ($next, $class, @options) = @_;

    my $abstract_factory = $class->$next(@options);
    my $concrete_factory_class
        = __PACKAGE__ . '::' . $abstract_factory->backend;
    Any::Moose::load_class($concrete_factory_class)
        unless Any::Moose::is_class_loaded($concrete_factory_class);

    return $concrete_factory_class->new(@options)->_model;
};

no Any::Moose;


# ****************************************************************
# return true
# ****************************************************************

1;
__END__


# ****************************************************************
# POD
# ****************************************************************

=head1 NAME

Faktro::Schema::Factory - abstract factory class for schema of Data::Model


=head1 VERSION

0.00_00


=head1 SYNOPSIS

    # blah blah blah


=head1 DESCRIPTION

blah blah blah

=head2 Memorandum

C<< around 'new' >>を稼働させるため、C<< __PACKAGE__->meta->make_immutable >>は使わない。


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
