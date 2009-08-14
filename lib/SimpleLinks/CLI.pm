package SimpleLinks::CLI;


# ****************************************************************
# pragmas
# ****************************************************************

use strict;
use warnings;


# ****************************************************************
# internal dependencies
# ****************************************************************

use SimpleLinks::Service::Links;


# ****************************************************************
# class methods
# ****************************************************************

sub get_service {
    my ($class, $dbname) = @_;

    return SimpleLinks::Service::Links->new({
        schema_factory => 'Faktro::Schema::Factory',
        connect_info   => {
            backend     => 'SQLite',
            model_class => 'SimpleLinks::Schema::Table',
            dsn_options => {
                dbname => $dbname,
            },
        },
    });
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

SimpleLinks::CLI - 


=head1 SYNOPSIS

    # blah blah blah


=head1 DESCRIPTION

blah blah blah


=head1 METHODS

=head2 get_service

インターフェース（Web, CLI, テストなど）に共通するサービスオブジェクトを取得します。
このクラスはCLIですが、L<SimpleLinks::Web::Model::Links|SimpleLinks::Web::Model::Links>との差分は、L<Ark::Model|Ark::Model>に関係する箇所のみです。


=head1 SEE ALSO

=over 4

=item Web interface

L<SimpleLinks::Web::Model::Links|SimpleLinks::Web::Model::Links>

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
