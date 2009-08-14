package SimpleLinks::Web::Controller::Root;


# ****************************************************************
# general dependencies
# ****************************************************************

use Exception::Class::TryCatch;


# ****************************************************************
# MOP
# ****************************************************************

use Ark 'Controller';       # automatically turn on strict & warnings

has '+namespace' => (
    default => '',
);

# with Localizable

__PACKAGE__->meta->make_immutable;


# ****************************************************************
# actions
# ****************************************************************

# default 404 handler
sub default : Path Args {
    my ($self, $c) = @_;

    $c->res->status(404);
    $c->view('MT')->template('errors/404');
}

sub index : Path Args(0) {
    my ($self, $c) = @_;

    try eval {
        # test
        my $model   = $c->model('Links');
        my $website = $model->lookup( website => 1 );

        use YAML::Any;
        use Encode;
        $c->res->header(content_type => 'text/plain; charset=UTF-8');
        $c->res->body(Encode::decode_utf8(Dump $website));

        # $c->res->body('Ark Default Index');
    };
    if (catch my $exception) {
        $c->res->status(500);
        $c->view('MT')->template('errors/500');
    }
}

sub end : Private {
    my ($self, $c) = @_;

    unless ($c->res->body or $c->res->status =~ m{ \A 3\d\d }xms) {
        $c->forward( $c->view('MT') );
    }
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

SimpleLinks::Web::Controller::Root - 


=head1 SYNOPSIS

    # blah blah blah


=head1 DESCRIPTION

blah blah blah


=head1 ACTIONS

=head2 default

Ark default handler (404 Not found).

=head2 index

Index page (C</>).

=head2 end

End action. Renders content with any template.


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
