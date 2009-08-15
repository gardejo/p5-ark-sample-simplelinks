package Faktro::Schema::Factory::Base;


# ****************************************************************
# class variables
# ****************************************************************

our $VERSION = '0.00_00';


# ****************************************************************
# MOP
# ****************************************************************

use Any::Moose;             # automatically turn on strict & warnings

has 'model_class' => (
    is          => 'ro',
    isa         => 'Str',   # 未ロード時にはClassNameは型チェックエラー
    required    => 1,
);

has 'model_arguments' => (
    is          => 'ro',
    isa         => 'ArrayRef',
    default     => sub { [] },
    auto_deref  => 1,
);

has '_model' => (
    is          => 'ro',
    isa         => 'Data::Model',
    lazy_build  => 1,
);

no Any::Moose;
__PACKAGE__->meta->make_immutable;


# ****************************************************************
# builders
# ****************************************************************

sub _build__model {
    my $self = shift;

    my $model_class = $self->model_class;
    Any::Moose::load_class($model_class)
        unless Any::Moose::is_class_loaded($model_class);

    return $model_class->new($self->model_arguments);
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

Faktro::Schema::Factory::Base - abstract factory class for schema of Data::Model


=head1 VERSION

0.00_00


=head1 SYNOPSIS

    # blah blah blah


=head1 DESCRIPTION

blah blah blah

=head2 Memorandum

Abstract FactoryであるL<Faktro::Schema::Factory|Faktro::Schema::Factory>はC<new>の結果としてC<_model>を返すので、C<_model>のC<handles>指定は行わない。


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
