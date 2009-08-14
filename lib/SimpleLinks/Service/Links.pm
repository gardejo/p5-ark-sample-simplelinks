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
    isa         => 'Data::Model',   # SimpleLinks::Schema::Tableに特定しない
    lazy_build  => 1,
    # handlesはqr{}にするかも
    handles     => [qw(
        lookup lookup_multi get set txn_scope

        get_category          get_tag         get_website
        get_category_id       get_tag_id      get_website_id
        create_category       create_tag      create_website
        add_category          add_tag         add_website
        categories            tags            websites
        all_categories        all_tags        all_websites
        get_categories        get_tags        get_websites
        get_category_ids      get_tag_ids     get_website_ids
        filter_categories     filter_tags     filter_websites
        count_categories      count_tags      count_websites
        remove_all_categories remove_all_tags remove_all_websites
        delete_all_categories delete_all_tags delete_all_websites
    )],
);

has 'connect_info' => (
    is          => 'rw',
    isa         => 'HashRef',
    requied     => 1,
);

__PACKAGE__->meta->make_immutable;


# ****************************************************************
# builders
# ****************************************************************

sub _build_model {
    my $schema_factory = $_[0]->schema_factory;
    Any::Moose::load_class($schema_factory)
        unless Any::Moose::is_class_loaded($schema_factory);

    return $schema_factory->new($_[0]->connect_info);
}

no Any::Moose;


# ****************************************************************
# Data::Model handlers
# ****************************************************************

sub tag_ratings {
    return $_[0]->model->tag_ratings;
}
*tag_cloud = \&tag_ratings;


# ****************************************************************
# miscellaneous methods
# ****************************************************************

# データと直接結びつかないようなアプリケーションロジック


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


=head1 METHODS

=head2 Data::Model wrappers

=over 4

=item * lookup

=item * lookup_multi

=item * get

=item * set

=item * txn_scope

=back

B<Caveat>: This object except to support
C<< $model->delete($table => $row->id) >>,
to force you to use C<< $row->delete >> only.
Because C<$row> may have relationships (C<$model> wrapped it implicitly).

=head2 Categories

See
L<SimpleLinks::Schema::Table|SimpleLinks::Schema::Table>,
L<SimpleLinks::Schema::Column|SimpleLinks::Schema::Column>,
L<SimpleLinks::Schema::Mixin::Category|SimpleLinks::Schema::Mixin::Category>,
and
L<SimpleLinks::Schema::Mixin::Taxonomy|SimpleLinks::Schema::Mixin::Taxonomy>.

=over 4

=item * categories

=item * all_categoreis

=item * count_categories

=item * add_category

=item * create_category

=item * remove_all_categories

=item * delete_all_categories

=back

=head2 Tags

See
L<SimpleLinks::Schema::Table|SimpleLinks::Schema::Table>,
L<SimpleLinks::Schema::Column|SimpleLinks::Schema::Column>,
L<SimpleLinks::Schema::Mixin::Tag|SimpleLinks::Schema::Mixin::Tag>,
and
L<SimpleLinks::Schema::Mixin::Taxonomy|SimpleLinks::Schema::Mixin::Taxonomy>.

=over 4

=item * tags

=item * all_tags

=item * count_tags

=item * add_tag

=item * create_tag

=item * tag_ratings

=item * tag_cloud

=item * remove_all_tags

=item * delete_all_tags

=back

=head2 Websites

See
L<SimpleLinks::Schema::Table|SimpleLinks::Schema::Table>,
L<SimpleLinks::Schema::Column|SimpleLinks::Schema::Column>,
L<SimpleLinks::Schema::Mixin::Website|SimpleLinks::Schema::Mixin::Website>,
and
L<SimpleLinks::Schema::Mixin::Taxonomy|SimpleLinks::Schema::Mixin::Taxonomy>.

=over 4

=item * websites

=item * all_websites

=item * count_websites

=item * add_website

=item * create_website

=item * remove_all_websites

=item * delete_all_websites

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
