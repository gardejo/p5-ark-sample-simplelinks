package Faktro::Schema::Factory::SQLite;


# ****************************************************************
# class variables
# ****************************************************************

our $VERSION = '0.00_00';


# ****************************************************************
# MOP
# ****************************************************************

use Any::Moose;             # automatically turn on strict & warnings

extends qw(
    Faktro::Schema::Factory::DBI
);

has '+dbd' => (
    default     => 'SQLite',
);

no Any::Moose;
__PACKAGE__->meta->make_immutable;


# ****************************************************************
# initializations
# ****************************************************************

sub create_table {
    my ($self, $option) = @_;

    return
        if ! defined $self->dsn_options->{dbname}
        || -f $self->dsn_options->{dbname};

    my $dbh = DBI->connect(
        $self->dsn,
        q{},
        q{},
        { RaiseError => 1, PrintError => 1, }
    );
    # $dbh->{unicode} = 1;

    foreach my $sql ($self->_model->as_sqls) {
        $dbh->do($sql);
    }
    $dbh->disconnect;

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

Faktro::Schema::Factory::SQLite - concrete (SQLite) schema factory class for Data::Model


=head1 VERSION

0.00_00


=head1 SYNOPSIS

    blah blah blah


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
