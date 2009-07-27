package SimpleLinks::Web::Controller::Root;


# ****************************************************************
# MOP
# ****************************************************************

use Ark 'Controller';       # automatically turn on strict & warnings

has '+namespace' => (
    default => '',
);


# ****************************************************************
# actions
# ****************************************************************

# default 404 handler
sub default :Path :Args {
    my ($self, $c) = @_;

    $c->res->status(404);
    $c->res->body('404 Not Found');
}

sub index :Path :Args(0) {
    my ($self, $c) = @_;

    my $model   = $c->model('Links');
    my $website = $model->lookup( website => 1 );

    # test
    use YAML::Syck;
    use Encode;
    $c->res->header(content_type => 'text/plain');
    $c->res->body(Encode::decode_utf8(Dump $website));

    # $c->res->body('Ark Default Index');
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

SimpleLinks::Web::Model::Links - 


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
