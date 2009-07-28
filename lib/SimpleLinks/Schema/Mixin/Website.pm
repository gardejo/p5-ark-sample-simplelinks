package SimpleLinks::Schema::Mixin::Website;


# ****************************************************************
# pragmas
# ****************************************************************

use strict;
use warnings;


# ****************************************************************
# general dependencies
# ****************************************************************

use Carp qw();


# ****************************************************************
# register
# ****************************************************************

sub register_method {
    +{
        add_website => \&add_website,
        # ...
    };
}


# ****************************************************************
# additional methods
# ****************************************************************

sub add_website {
    my ($model, $option) = @_;

    my @taxonomy_attributes = qw(category_ids tag_ids);
    my %taxonomy_option;
    @taxonomy_option{@taxonomy_attributes} = @{$option}{@taxonomy_attributes};
    delete @{$option}{@taxonomy_attributes};

    my $row = $model->set($option);
    if (keys %taxonomy_option) {
        $model->add_taxonomy(\%taxonomy_option);
    }

    return $row;
}

sub add_taxonomy {
}

sub delete_taxonomy {
}

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
