package SimpleLinks::Web::View::MT;


# ****************************************************************
# MOP
# ****************************************************************

use Ark 'View::MT';         # automatically turn on strict & warnings

has '+options' => (
    default => sub {
        my $self = shift;

        my $context   = sub { $self->context };
        my $stash     = sub { $self->context->stash };
        # my $user      = sub { $self->context->user };
        # my $localizer = sub { $self->context->stash->{localizer} };

        return {
            tag_start  => '[%',
            tag_end    => '%]',
            line_start => '%',
            template_args => {
                c           => $context,
                stash       => $stash,
                s           => $stash,
                # user        => $user,
                # u           => $user,
                # localizer   => $localizer,
                # l           => $localizer,
            },
        };
    },
);

no Ark;
__PACKAGE__->meta->make_immutable;


# ****************************************************************
# miscellaneous methods
# ****************************************************************



# ****************************************************************
# return true
# ****************************************************************

1;
__END__


# ****************************************************************
# POD
# ****************************************************************

=head1 NAME

SimpleLinks::Web::View::MT - 


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
