package SimpleLinks::Schema::Table;


# ****************************************************************
# pragmas
# ****************************************************************

use strict;
use warnings;


# ****************************************************************
# superclasses
# ****************************************************************

use base qw(
    Data::Model
);


# ****************************************************************
# general dependencies
# ****************************************************************

use Data::Model::Schema sugar => 'simplelinks';
use DateTime;


# ****************************************************************
# internal dependencies
# ****************************************************************

use SimpleLinks::Schema::Column;


# ****************************************************************
# initializations : schemas
# ****************************************************************

# ================================================================
# ウェブサイト
# ================================================================
install_model website => schema {
    # 主キー
    key         'id';

    # カラム定義
    column      'website.id' => { auto_increment => 1 };
    column      'website.uri';
    utf8_column 'website.title';
    utf8_column 'website.owner';
    utf8_column 'website.introduction';
    utf8_column 'website.comment';
    column      'common.created_on';
    column      'common.updated_on';

    # その他
    unique      'uri';

    # 別名カラム
    alias_column common_created_on      => 'created_on';
    alias_column common_updated_on      => 'updated_on';

    # 関係(relationships)
    add_method  'category_ids' => sub {
        return map {
            $_->category_id;
        } $_[0]->{model}->get(website_category => {
            where => [
                website_id => $_[0]->id,
            ],
            order => {
                category_id => 'ASC',
            },
        });
    };

    add_method  'categories' => sub {
        return $_[0]->{model}->lookup_multi(category =>
            [($_[0]->category_ids)]
        );
    };

    add_method  'tag_ids' => sub {
        return map {
            $_->tag_id;
        } $_[0]->{model}->get(website_tag => {
            where => [
                website_id => $_[0]->id,
            ],
            order => {
                tag_id => 'ASC',
            },
        });
    };

    add_method  'tags' => sub {
        return $_[0]->{model}->lookup_multi(tag =>
            [($_[0]->tag_ids)]
        );
    };

    # 更新日時の暗黙的な更新
    add_method  'update_with_timestamp' => \&_update_with_timestamp;
};

# ================================================================
# カテゴリー
# ================================================================
install_model category => schema {
    # 主キー
    key         'id';

    # カラム定義
    column      'category.id' => { auto_increment => 1 };
    column      'category.parent_id';
    column      'taxonomy.slug';
    utf8_column 'taxonomy.name';
    utf8_column 'taxonomy.description';
    column      'common.created_on';
    column      'common.updated_on';

    # 別名カラム
    alias_column taxonomy_slug          => 'slug';
    alias_column taxonomy_name          => 'name';
    alias_column taxonomy_description   => 'description';
    alias_column common_created_on      => 'created_on';
    alias_column common_updated_on      => 'updated_on';

    # 関係(relationships)
    add_method  'parent' => sub {
        return $_[0]->{model}->get(category => {
            where => [
                id => $_[0]->parent_id,
            ],
        });
    };

    # 更新日時の暗黙的な更新
    add_method  'update_with_timestamp' => \&_update_with_timestamp;
};

# ================================================================
# ウェブサイト対カテゴリー
# ================================================================
install_model website_category => schema {
    # 主キー
    key         'id';

    # カラム定義
    column      'website_category.id' => { auto_increment => 1 };
    column      'website.id';
    column      'category.id';
    column      'common.created_on';
    column      'common.updated_on';

    # 別名カラム
    alias_column common_created_on      => 'created_on';
    alias_column common_updated_on      => 'updated_on';

    # 更新日時の暗黙的な更新
    add_method  'update_with_timestamp' => \&_update_with_timestamp;
};

# ================================================================
# タグ
# ================================================================
install_model tag => schema {
    # 主キー
    key         'id';

    # カラム定義
    column      'tag.id' => { auto_increment => 1 };
    column      'taxonomy.slug';
    utf8_column 'taxonomy.name';
    utf8_column 'taxonomy.description';
    column      'common.created_on';
    column      'common.updated_on';

    # 別名カラム
    alias_column taxonomy_slug          => 'slug';
    alias_column taxonomy_name          => 'name';
    alias_column taxonomy_description   => 'description';
    alias_column common_created_on      => 'created_on';
    alias_column common_updated_on      => 'updated_on';

    # 更新日時の暗黙的な更新
    add_method  'update_with_timestamp' => \&_update_with_timestamp;
};

# ================================================================
# ウェブサイト対タグ
# ================================================================
install_model website_tag => schema {
    # 主キー
    key         'id';

    # カラム定義
    column      'website_tag.id' => { auto_increment => 1 };
    column      'website.id';
    column      'tag.id';
    column      'common.created_on';
    column      'common.updated_on';

    # 別名カラム
    alias_column common_created_on      => 'created_on';
    alias_column common_updated_on      => 'updated_on';

    # 更新日時の暗黙的な更新
    add_method  'update_with_timestamp' => \&_update_with_timestamp;
};


# ****************************************************************
# miscellaneous methods
# ****************************************************************

# common_updated_on以外のカラムが編集されていたらcommon_updated_onも編集する
sub _update_with_timestamp {
    my $row = shift;

    return
        unless scalar grep {
            $_ ne 'common_updated_on';
        } keys %{ $row->get_changed_columns };

    $row->updated_on( DateTime->now(time_zone => 'UTC') );
    $row->update;

    return $row;
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

SimpleLinks::Schema::Table - table schemas


=head1 SYNOPSIS

=head2 Directly (from CLI)

    use Faktro::Schema::Factory;

    use Encode;
    use YAML::Syck;

    my $model = Faktro::Schema::Factory->new(
        backend     => 'SQLite',
        model_class => 'SimpleLinks::Schema::Table',
        dsn_options => {
            dbname => '/virtual/eorzea/db/simplelinks.db',
        },
    );
    my $website = $model->lookup( website => 1 );
    print Encode::decode_utf8( Dump $website );

    1;
    __END__

=head2 Indirectry (via Ark)

    package SimpleLinks::Web::Model::Links;

    use Ark 'Model::Adaptor';

    __PACKAGE__->config(
        class => 'Faktro::Schema::Factory',
        args  => {
            backend     => 'SQLite',
            model_class => 'SimpleLinks::Schema::Table',
            dsn_options => {
                dbname => SimpleLinks::Web->config->{dbname},
            },
        },
        deref => 1,
    );

    1;
    __END__

    package SimpleLinks::Web::Controller::Root;

    use Encode;
    use YAML::Syck;

    use Ark 'Controller';

    has '+namespace' => (
        default => q{},
    );

    sub index : Path Args(0) {
        my ($self, $c) = @_;

        my $model   = $c->model('Links');
        my $website = $model->lookup( website => 1 );

        # $c->res->header(content_type => 'text/plain');
        $c->res->body(Encode::decode_utf8(Dump $website));
    }

    # ...

    1;
    __END__


=head1 DESCRIPTION

このモジュールは、SimpleLinksアプリケーション(p5-ark-sample-simplelinks)のテーブルスキーマです。

L<SYNOPSIS|/SYNOPSIS>では、L<Data::Model|Data::Model>の`base_driver`やDBのテーブル生成などを、ラッパークラスのL<Faktro::Schema::SQLite|Faktro::Schema::SQLite>で行っています。勿論、L<Data::ModelのSYNOPSIS|Data::Model/SYNOPSIS>の通りに、テーブルスキーマである本モジュール自体に処理を実装しても構いません。

=head2 Memorandum

=head3 auto update

C<< $row->update >>の替わりにC<< $row->update_with_timestamp >>を使うことにより、暗黙的に更新日時を設定出来ます。

C<< $row->update >>を上書きして、以下のように暗黙的に更新日時を設定することも不可能ではありませんが、C<< $row->{model}->update >>のようにカプセル化をうっちゃっているので、今回は採用しませんでした。

    add_method  'update' => sub {
        my $row = shift;

        $row->updated_on(DateTime->now);

        return $row->{model}->update($row, @_);
    };


=head3 alias_colun

C<< $model->set >>時にはC<< alias_column >>されたエイリアスでの格納は不可能（？）。


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
