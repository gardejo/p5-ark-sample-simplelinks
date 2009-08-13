package SimpleLinks::Schema::Mixin::Base;


# ****************************************************************
# pragmas
# ****************************************************************

use strict;
use warnings;


# ****************************************************************
# general dependencies
# ****************************************************************

use Carp qw();
use Data::Util qw(:check);
use DateTime;
use Scalar::Util qw();
use Storable qw(dclone);


# ****************************************************************
# register
# ****************************************************************

sub register_method {
    +{
        __get_row                   => \&__get_row,
        __get_rows                  => \&__get_rows,
        __get_row_id                => \&__get_row_id,
        __get_row_ids               => \&__get_row_ids,
        __update_with_timestamp     => \&__update_with_timestamp,
        __alias_columns_of_common   => \&__alias_columns_of_common,
        __remove_all_rows           => \&__remove_all_rows,
        __delete_all_rows           => \&__remove_all_rows,
        __all_ids                   => \&__all_ids,
    };
}


# ****************************************************************
# miscellaneous methods
# ****************************************************************

sub __get_table_name {
    my ($schema, $row) = @_;

    (my $table_name = Scalar::Util::blessed $row || q{})
        =~ s{ \A .+ :: }{}xms;

    return $table_name;
}

# �I�u�W�F�N�g�Ȃ炻�̂܂܁A�����Ȃ�L�[���A���̑��Ȃ疼�O�Ō���
sub __get_row {
    my ($schema, $query, $class, $table) = @_;

    if ( is_instance($query, 'Data::Model::Row') ) {
        # return $query;
        return dclone($query);
    }
    elsif ( is_integer($query) ) {
        return $schema->lookup( $table => $query );
    }
    else {
        my $name = __PACKAGE__->__get_name_column_name($class);
        my @rows = $schema->get( $table => { where => [ $name => $query ] } );
        die sprintf 'row (%s) not found from table (%s)',
            $query, $table
                unless @rows;
        die 'more than one (%d) row selected from table (%s)',
            scalar (@rows), $table
                if scalar @rows > 1;
        return $rows[0];
    }
}

# ��L�̕����łŁA�َ탊�X�g�͕s�i���������Ȃ��j
sub __get_rows {
    my ($schema, $queries, $class, $table) = @_;

    if ( is_instance($queries->[0], $class) ) {
        return $queries;
    }
    elsif ( is_integer($queries->[0]) ) {
        return [ $schema->lookup_multi( $table => $queries ) ];
    }
    else {
        my $name = __PACKAGE__->__get_name_column_name($class);
        my @rows;
        foreach my $query (@$queries) {
            push @rows,
                $schema->get( $table => { where => [ $name => $query ] } );
        }
        return \@rows;
    }
}

sub __get_row_id {
    my ($schema, $query, $class, $table) = @_;

    if ( is_instance($query, 'Data::Model::Row') ) {
        return $query->id;
    }
    elsif ( is_integer($query) ) {
        return $query;
    }
    else {
        my $name = __PACKAGE__->__get_name_column_name($class);
        my @rows = $schema->get( $table => { where => [ $name => $query ] } );
        die sprintf 'row (%s) not found from table (%s)',
            $query, $table
                unless @rows;
        die 'more than one (%d) row selected from table (%s)',
            scalar (@rows), $table
                if scalar @rows > 1;
        return $rows[0]->id;
    }
}

# ��L�̕����łŁA�َ탊�X�g�͕s�i���������Ȃ��j
sub __get_row_ids {
    my ($schema, $queries, $class, $table) = @_;

    if ( is_instance($queries->[0], $class) ) {
        return [ map {
            $_->id;
        } @$queries ];
    }
    elsif ( is_integer($queries->[0]) ) {
        return $queries;
    }
    else {
        my $name = __PACKAGE__->__get_name_column_name($class);
        my @row_ids;
        foreach my $query (@$queries) {
            push @row_ids,
                $schema->get( $table => { where => [ $name => $query ] } )
                       ->id;
        }
        return \@row_ids;
    }
}

sub __get_name_column_name {
    my ($invocant, $class) = @_;

    return $class->isa('SimpleLinks::Schema::Mixin::Taxonomy')
        ? 'taxonomy_name'
        : 'name';
}


# common_updated_on�ȊO�̃J�������ҏW����Ă�����common_updated_on���ҏW����
sub __update_with_timestamp {
    my ($schema, $row, $timestamp_column) = @_;

    return
        unless scalar grep {
            $_ ne $timestamp_column;
        } keys %{ $row->get_changed_columns };

    $row->$timestamp_column( DateTime->now(time_zone => 'UTC') );
    $row->update;

    return $row;
}

sub __alias_columns_of_common {
    my $schema = shift;

    return [
        common_created_on => 'created_on',
        common_updated_on => 'updated_on',
    ];
}

sub __remove_all_rows {
    my ($schema, $table) = @_;

    # $schema->delete���t�b�N���Ă���킯�ł͂Ȃ��i�t�b�N��$row->delete�j�̂�
    # ���Ȃ��s����B�Ⴆ��category��leaf�ȊO�̍폜���\�B�c�c�̂͂��B

    # �e�X�g��create, read, update, delete�̏��Ԃł͂Ȃ��āA
    # create, delete, read, update�̏��ԂɎ��{����̂����R�����B
    # �e�X�g�Ԃł̈ˑ��i�O�̃e�X�g��create����row��read����update����delete�j
    # �͎񂪉��Ȃ��Ȃ肻���Ȃ̂ŁA�s�x�폜���邭�炢�̕����y�ł͂Ȃ��낤���B

    # �Ӑ}��DELETE FROM table�Ȃ̂ŁADELETE (��...) FROM table�𔭍s���Ă����
    # �ߏ菈���ɂȂ��Ă��܂����߁A��Ŕ��sSQL�𒲂ׂ�
    foreach my $id (@{ $schema->__all_ids($table) }) {
        $schema->delete($table => $id);
    }

    return;
}

sub __all_ids {
    my ($schema, $table) = @_;

    return [ map { $_->id } ( $schema->get($table => {} ) ) ];
}

sub __alias_to_real {
    my ($invocant, $option, $alias) = @_;

    my %new_option = %$option;

    while ( my ($real_column, $alias_column) = each %$alias ) {
        if (exists $new_option{$alias_column}) {
            $new_option{$real_column} = $new_option{$alias_column};
            delete $new_option{$alias_column};
        }
    }

    return \%new_option;
}

sub __separate_taxonomy_from {
    my ($invocant, $option, $taxonomy_attributes) = @_;

    my %new_option = %$option;
    my %taxonomy_option;
    @taxonomy_option{@$taxonomy_attributes}
        = @new_option{@$taxonomy_attributes};
    delete @new_option{@$taxonomy_attributes};

    return \%new_option, \%taxonomy_option;
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

SimpleLinks::Schema::Mixin::Base - 


=head1 SYNOPSIS

    # blah blah blah


=head1 DESCRIPTION

blah blah blah


=head1 METHODS

=head2 register_method

B<INTERNAL USE ONLY>.
For L<Data::Model::Mixin|Data::Model::Mixin> mechanism.


=head1 SEE ALSO

=over 4

=item Which is fast to replace or split?

    (my $table_name = Scalar::Util::blessed $row) =~ s{ \A .+ :: }{}xms;

vs.

    my $table_name  = (split m{::}xms, Scalar::Util::blessed $row)[-1];

See L<http://gist.github.com/158256>.

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
