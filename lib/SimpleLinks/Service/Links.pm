package SimpleLinks::Service::Links;


# ****************************************************************
# MOP
# ****************************************************************

use Any::Moose;             # automatically turn on strict & warnings

has 'schema_factory' => (
    is          => 'rw',
    isa         => 'Str',
    required    => 1,
);

has 'model' => (
    is          => 'rw',
    isa         => 'Str',
    lazy_build  => 1,
    handles     => [qw(
        lookup lookup_multi get set txn_scope

        categories all_categories count_categories
        tags       all_tags       count_tags
        websites   all_websites   count_websites

        add_category create_category
        add_tag      create_tag
        add_website  create_website
    )],
    # Except 'delete', to force programmer to use $row->delete only
    # ( to did not use $schema->delete($table => $row->id) ).
);

has 'connect_info' => (
    is          => 'rw',
    isa         => 'HashRef',
    requied     => 1,
);

sub _build_model {
    my $schema_factory = $_[0]->schema_factory;
    Any::Moose::load_class($schema_factory)
        unless Any::Moose::is_class_loaded($schema_factory);

    return $schema_factory->new($_[0]->connect_info);
}

no Any::Moose;
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

SimpleLinks::Service::Links - 


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
