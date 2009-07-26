package SimpleLinks::Schema::Column;


# ****************************************************************
# pragmas
# ****************************************************************

use strict;
use warnings;


# ****************************************************************
# general dependencies
# ****************************************************************

use Data::Model::Schema sugar => 'simplelinks';
use DateTime;
use DateTime::Format::MySQL;    # SQLite3でも使える
use URI;


# ****************************************************************
# class variables
# ****************************************************************

our $VERSION = '0.00_00';


# ****************************************************************
# schemas
# ****************************************************************

# ================================================================
# ウェブサイト
# ================================================================

# 識別子
column_sugar 'website.id'
    => integer => {
        require     => 1,
        unsigned    => 1,
    };

# URI
column_sugar 'website.uri'
    => varchar => {
        inflate     => sub {
            URI->new($_[0]);
        },
        deflate     => sub {
            $_[0]->as_string;
        },
    };

# 題名
column_sugar 'website.title'
    => varchar => {
        require     => 1,
    };

# 管理者名（公開されていないこともあるので、NOT NULL指定にはしない）
column_sugar 'website.owner'
    => varchar => {
    };

# サイト管理者による自己紹介文
column_sugar 'website.isntroduction'
    => varchar => {
    };

# リンク集管理者（このアプリケーションの設置者）による紹介文
column_sugar 'website.comment'
    => varchar => {
    };

# ================================================================
# カテゴリー
# ================================================================

# 識別子
column_sugar 'category.id'
    => integer => {
        require     => 1,
        unsigned    => 1,
    };

# 親カテゴリー識別子
column_sugar 'category.parent'
    => integer => {
        unsigned    => 1,
    };

# ================================================================
# ウェブサイト対カテゴリー
# ================================================================

# 識別子
column_sugar 'website_category.id'
    => integer => {
        require     => 1,
        unsigned    => 1,
    };

# ================================================================
# タグ
# ================================================================

# 識別子
column_sugar 'tag.id'
    => integer => {
        require     => 1,
        unsigned    => 1,
    };

# ================================================================
# ウェブサイト対タグ
# ================================================================

# 識別子
column_sugar 'website_tag.id'
    => integer => {
        require     => 1,
        unsigned    => 1,
    };

# ================================================================
# 共通（汎用）
# ================================================================

# 作成日時
column_sugar 'common.created_on'
    => datetime => {
        require     => 1,
        _definition_of_datetime(),
    };

# 更新日時
column_sugar 'common.created_on'
    => datetime => {
        require     => 1,
        _definition_of_datetime(),
    };

sub _definition_of_datetime {
    return (
        inflate     => sub {
            DateTime::Format::MySQL
                ->parse_datetime($_[0])
                ->set_time_zone('UTC');
        },
        deflate     => sub {
            DateTime::Format::MySQL
                ->format_datetime($_[0]->set_time_zone('UTC'));
        },
        default     => sub {
            DateTime::Format::MySQL
                ->format_datetime(DateTime->now(time_zone => 'UTC'));
        },
    );
}

# ================================================================
# 分類（汎用）
# ================================================================

# URI素片（スラッグ）
column_sugar 'taxonomy.slug'
    => varchar => {
        require     => 1,
    };

# 表示名
column_sugar 'taxonomy.name'
    => varchar => {
        require     => 1,
    };

# 説明文
column_sugar 'taxonomy.description'
    => varchar => {
    };


# ****************************************************************
# return true
# ****************************************************************

1;
__END__


# ****************************************************************
# POD
# ****************************************************************

=head1 NAME

SimpleLinks::Schema::Column - 


=head1 SYNOPSIS

    blah blah blah

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
