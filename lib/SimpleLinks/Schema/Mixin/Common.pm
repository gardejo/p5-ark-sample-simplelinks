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
use Data::Util qw(:check);
use DateTime;


# ****************************************************************
# register
# ****************************************************************

sub register_method {
    +{
        __get_row                   => \&__get_row,
        __get_rows                  => \&__get_rows,
        __update_with_timestamp     => \&__update_with_timestamp,
        __alias_columns_of_common   => \&__alias_columns_of_common,
        __remove_all_rows           => \&__remove_all_rows,
        __delete_all_rows           => \&__remove_all_rows,
        __all_ids                   => \&__all_ids,
    };
}


# ****************************************************************
# additional methods
# ****************************************************************


# オブジェクトならそのまま、整数ならキーを、その他なら名前で検索
sub __get_row {
    my ($schema, $query, $class, $table) = @_;

    if ( is_instance($query, $class) ) {
        return $query;
    }
    elsif ( is_integer($query) ) {
        return $schema->lookup( $table => $query );
    }
    else {
        my $name = __PACKAGE__->__get_name_column_name($class);
        my @rows = $schema->get( $table => { where => [ $name => $query ] } );
        die 'more than one row selected'
            if scalar @rows > 1;
        return $rows[0];
    }
}

# 上記の複数版で、異種リストは不可（頭しか見ない）
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

sub __get_name_column_name {
    my ($invocant, $class) = @_;

    return $class->isa('SimpleLinks::Schema::Mixin::Taxonomy')
        ? 'taxonomy_name'
        : 'name';
}


# common_updated_on以外のカラムが編集されていたらcommon_updated_onも編集する
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

    # $schema->deleteをフックしているわけではない（フックは$row->delete）ので
    # 問題なく行ける。例えばcategoryのleaf以外の削除も可能。……のはず。

    # テストはcreate, read, update, deleteの順番ではなくて、
    # create, delete, read, updateの順番に実施するのが自然そう。
    # テスト間での依存（前のテストでcreateしたrowをreadしてupdateしてdelete）
    # は首が回らなくなりそうなので、都度削除するくらいの方が楽ではなかろうか。

    # 意図はDELETE FROM tableなので、DELETE (列挙...) FROM tableを発行していると
    # 過剰処理になってしまうため、後で発行SQLを調べる
    foreach my $id (@{ $schema->__all_ids($table) }) {
        $schema->delete($table => $id);
    }

    return;
}

sub __all_ids {
    my ($schema, $table) = @_;

    return [ map { $_->id } ( $schema->get($table => {} ) ) ];
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




=head1 METHODS

=head2 register_method

B<INTERNAL USE ONLY>.
For L<Data::Model::Mixin|Data::Model::Mixin> mechanism.


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
