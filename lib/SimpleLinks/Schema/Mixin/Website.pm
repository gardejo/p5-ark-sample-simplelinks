package SimpleLinks::Schema::Mixin::Website;


# ****************************************************************
# pragmas
# ****************************************************************

use strict;
use warnings;


# ****************************************************************
# superclasses
# ****************************************************************

use base qw(
    SimpleLinks::Schema::Mixin::Base
);


# ****************************************************************
# general dependencies
# ****************************************************************

use Carp qw();


# ****************************************************************
# register
# ****************************************************************

sub register_method {
    +{
        websites                    => \&all_websites,
        all_websites                => \&all_websites,
        filter_websites             => \&filter_websites,
        count_websites              => \&count_websites,
        add_website                 => \&add_website,
        _alias_columns_of_website   => \&alias_columns_of_website,
        # ...
    };
}


# ****************************************************************
# additional methods
# ****************************************************************

sub all_websites {
    my $schema = shift;

    return $schema->get(website => {
        order   => {
            id  => 'ASC',
        },
    });
}

sub filter_websites {
    my ($schema, $keys) = @_;

    return $schema->lookup_multi(website => {
        @$keys,
    });
}

sub count_websites {
    my $schema = shift;

    return scalar(my @websites = $schema->all_websites);
}

sub add_website {
    my ($schema, $option) = @_;

    my $modified_option
        = __PACKAGE__->SUPER::_alias_to_real
            ($option, $schema->_alias_columns_of_website);
    ($modified_option, my $taxonomy_option)
        = $schema->SUPER::_separate_taxonomy_from
            ($modified_option, [qw(categories tags)]);

    my $website = $schema->set(website => $modified_option);

    if (keys %$taxonomy_option) {
        $schema->add_taxonomy($website->id, $taxonomy_option);
    }

    return $website;
}

sub alias_columns_of_website {
    my $schema = shift;

    return {
        @{ $schema->_alias_columns_of_taxonomy },
        @{ $schema->_alias_columns_of_common },
    };
}

# $website_row->add_categories
sub add_categories {
}

sub delete_categories {
}

sub add_tags {
}

sub add_relations {
}

sub delete_website {
}

sub delete_relations {
}

sub modify_relation {
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

SimpleLinks::Schema::Mixin::Website - 


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


=head1 LICENCE AND COPYRIGHT

Copyright (c) 2009 by MORIYA Masaki ("Gardejo"),
L<http://ttt.ermitejo.com>.

This library is free software;
you can redistribute it and/or modify it under the same terms as Perl itself.
See L<perlgpl|perlapi> and L<perlartistic|perlartistic>.
