package SimpleLinks::Web::Model::Links;


# ****************************************************************
# MOP
# ****************************************************************

use Ark 'Model::Adaptor';   # automatically turn on strict & warnings

__PACKAGE__->config(
    class    => 'SimpleLinks::Service::Links',
    args     => {
        schema_factory => 'Faktro::Schema::Factory',
        connect_info   => {
            backend     => 'SQLite',
            model_class => 'SimpleLinks::Schema::Table',
            dsn_options => {
                dbname => SimpleLinks::Web->config->{dbname},
            },
        },
    },
);


# ****************************************************************
# return true
# ****************************************************************

1;
__END__


# ****************************************************************
# POD
# ****************************************************************

=head1 NAME

SimpleLinks::Web::Model::Links - 


=head1 SYNOPSIS

    # blah blah blah


=head1 DESCRIPTION

blah blah blah


=head1 SEE ALSO

=over 4

=item Command line interface (CLI)

L<< SimpleLinks::CLI->get_service|SimpleLinks::CLI/"get_service" >>

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
