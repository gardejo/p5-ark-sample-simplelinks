package SimpleLinks::Schema::Mixin::Common;


# ****************************************************************
# pragmas
# ****************************************************************

use strict;
use warnings;


# ****************************************************************
# general dependencies
# ****************************************************************

use Carp qw();
use DateTime;


# ****************************************************************
# register
# ****************************************************************

sub register_method {
    +{
        _update_with_timestamp      => \&update_with_timestamp,
        _alias_columns_of_common    => \&alias_columns_of_common,
    };
}


# ****************************************************************
# additional methods
# ****************************************************************

# common_updated_on以外のカラムが編集されていたらcommon_updated_onも編集する
sub update_with_timestamp {
    my ($schema, $row, $timestamp_column) = @_;

    return
        unless scalar grep {
            $_ ne $timestamp_column;
        } keys %{ $row->get_changed_columns };

    $row->$timestamp_column( DateTime->now(time_zone => 'UTC') );
    $row->update;

    return $row;
}

sub alias_columns_of_common {
    my $scalar = shift;

    return [
        common_created_on => 'created_on',
        common_updated_on => 'updated_on',
    ];
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

SimpleLinks::Schema::Mixin::Common - 


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
