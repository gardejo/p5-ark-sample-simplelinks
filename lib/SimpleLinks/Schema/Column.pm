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
use Data::Util qw(:check);
use DateTime;
use DateTime::Format::MySQL;    # SQLite3でも使用可能
use URI;


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
        require     => 1,
        inflate     => sub {
            return URI->new($_[0]);
        },
        deflate     => sub {
            my $uri = is_instance($_[0], 'URI') ? $_[0] : URI->new($_[0]);
            Carp::croak sprintf(
                'Attribute (%s) does not pass the type constraint because: ' .
                'Validation failed for %s failed with value %s',
                    'uri',
                    __PACKAGE__,
                    $uri->as_string
            ) if ! $uri->scheme || $uri->scheme !~ m{ \A http s? \z }xms;
            return $uri->as_string;
        },
    };

# 題名
column_sugar 'website.name'
    => varchar => {
        require     => 1,
    };

# サイト管理者名（公開されていないこともあるので、NOT NULL指定にはしない）
column_sugar 'website.owner'
    => varchar => {
    };

# サイト管理者による自己紹介文
column_sugar 'website.introduction'
    => varchar => {
    };

# リンク集管理者（このアプリケーションの設置者）による紹介文
column_sugar 'website.comment'
    => varchar => {
    };

# ★「必ずカテゴリに属する」という制約はadd_websiteで行う（生のsetは使わない）
# か、「カテゴリ未分類」特殊カテゴリを設ける（前者の方が楽）

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
column_sugar 'category.parent_id'
    => integer => {
        unsigned    => 1,
    };

# 子（直接の子）カテゴリー数（キャッシュ）
column_sugar 'category.count_children'
    => integer => {
        require     => 1,
        unsigned    => 1,
        default     => 0,
    };

# 子孫（全ての子・孫・曾孫……）カテゴリー数（キャッシュ）
column_sugar 'category.count_descendants'
    => integer => {
        require     => 1,
        unsigned    => 1,
        default     => 0,
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

# 所属ウェブサイト数（キャッシュ）
column_sugar 'taxonomy.count_websites'
    => integer => {
        require     => 1,
        unsigned    => 1,
        default     => 0,
    };

# ================================================================
# 共通（汎用）
# ================================================================

# 作成日時
column_sugar 'common.created_on'
    => datetime => {
        require     => 1,
        _elasticity_of_datetime(),
    };

# 更新日時
column_sugar 'common.updated_on'
    => datetime => {
        require     => 1,
        _elasticity_of_datetime(),
    };

sub _elasticity_of_datetime {
    return (
        inflate     => sub {
            return DateTime::Format::MySQL
                        ->parse_datetime($_[0])
                        ->set_time_zone('UTC');
        },
        deflate     => sub {
            return DateTime::Format::MySQL
                        ->format_datetime($_[0]->set_time_zone('UTC'));
        },
        default     => sub {
            return DateTime::Format::MySQL
                        ->format_datetime(DateTime->now(time_zone => 'UTC'));
        },
    );
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

SimpleLinks::Schema::Column - column schemas


=head1 SYNOPSIS

    package SimpleLinks::Schema::Table;

    use base qw( Data::Model );
    use Data::Model::Schema sugar => 'simplelinks';
    use SimpleLinks::Schema::Column;

    install_model website => schema {
        key         'id';

        column      'website.id' => { auto_increment => 1 };
        column      'website.uri';
        utf8_column 'website.name';
        # ....
    };


=head1 DESCRIPTION

このモジュールは、SimpleLinksアプリケーション(p5-ark-sample-simplelinks)のカラムスキーマです。

=head2 Why UTC?

日時はUTCで取り扱うこととしています。この実装は、国際化（多国語対応・地方時対応）の一環であることと同時に、時差ずれの芽を摘む意図もあります。

私見ですが、入力時にエンコード・出力時にデコードして文字化けの芽を摘む文字エンコーディングと同様に、格納および展開時にはUTC・使用時に適宜C<< $row->created_on->set_time_zone($timezone) >>する癖を付けておいた方が良いと思います。

=head2 Last updated date-time

最終更新日時を更新する際には、

    $row->any_column($any_value);
    $row->updated_on(DateTime->now(time_zone => 'UTC'));
    $row->update;

と明示的に書き込むか、

    $row->any_column($any_value);
    $row->_update_with_timestamp;

という追加メソッドを使います。

TIMESTAMP型のような値を使う洗練された方式がもしあれば、それを使うのが正解です。


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
