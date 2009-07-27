package SimpleLinks::Web;


# ****************************************************************
# class variables
# ****************************************************************

our $VERSION = '0.01';


# ****************************************************************
# MOP
# ****************************************************************

use Ark;                    # automatically turn on strict & warnings

__PACKAGE__->config(
    dbname          => undef,
    # dbname          => $FindBin . '/',
    # pod_namespace => 'Ark::Manual',
    # site_title    => 'Ark 0.1 Documentation (DRAFT)',
);

__PACKAGE__->meta->make_immutable;


# ****************************************************************
# return true
# ****************************************************************

1;
__END__


# ****************************************************************
# POD
# ****************************************************************

=head1 NAME

SimpleLinks::Web - 


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


=head1 LICENCE AND COPYRIGHT

Copyright (c) 2009 by MORIYA Masaki ("Gardejo"),
L<http://ttt.ermitejo.com>.

This library is free software;
you can redistribute it and/or modify it under the same terms as Perl itself.
See L<perlgpl|perlapi> and L<perlartistic|perlartistic>.
