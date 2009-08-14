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

use Carp qw();
use Data::Model::Mixin modules => [
    'FindOrCreate',
    '+SimpleLinks::Schema::Mixin::Base',
    '+SimpleLinks::Schema::Mixin::Category',
    '+SimpleLinks::Schema::Mixin::Tag',
    '+SimpleLinks::Schema::Mixin::Taxonomy',
    '+SimpleLinks::Schema::Mixin::Website',
];
use Data::Model::Schema sugar => 'simplelinks';
use List::MoreUtils qw(any);


# ****************************************************************
# internal dependencies
# ****************************************************************

use SimpleLinks::Schema::Column;


# ****************************************************************
# schemas
# ****************************************************************

# ================================================================
# ウェブサイト
# ================================================================
install_model website => schema {
    key         'id';

    column      'website.id' => { auto_increment => 1 };
    column      'website.uri';
    utf8_column 'website.name';
    utf8_column 'website.owner';
    utf8_column 'website.introduction';
    utf8_column 'website.comment';
    alias_column website_name => 'title';
    __PACKAGE__->_has_columns_of_common;

    unique      'uri';

    __PACKAGE__->_has_many_categories;
    __PACKAGE__->_has_many_tags;

    __PACKAGE__->_can_reload('website');
    __PACKAGE__->_can_alternative_update;
    __PACKAGE__->_must_rebuild_when_delete('website');
    __PACKAGE__->_must_rebuild_when_update('website');

    __PACKAGE__->_can_update_with_timestamp;
};

# ================================================================
# カテゴリー
# ================================================================
install_model category => schema {
    key         'id';

    column      'category.id' => { auto_increment => 1 };
    column      'category.parent_id';
    column      'category.count_children';
    column      'category.count_descendants';
    __PACKAGE__->_has_columns_of_taxonomy;
    __PACKAGE__->_has_columns_of_common;

    __PACKAGE__->_has_many_children;
    __PACKAGE__->_has_many_descendants;
    __PACKAGE__->_might_belong_to_parent;
    __PACKAGE__->_many_taxonomy_to_many_websites;

    __PACKAGE__->_can_reload('category');
    __PACKAGE__->_can_alternative_update;
    __PACKAGE__->_must_rebuild_when_delete('category');
    __PACKAGE__->_must_rebuild_when_update('category');

    __PACKAGE__->_can_update_with_timestamp;
};

# ================================================================
# ウェブサイト対カテゴリー
# ================================================================
install_model website_category => schema {
    key         'id';

    column      'website_category.id' => { auto_increment => 1 };
    column      'website.id';
    column      'category.id';
    __PACKAGE__->_has_columns_of_common;

    __PACKAGE__->_can_update_with_timestamp;
};

# ================================================================
# タグ
# ================================================================
install_model tag => schema {
    key         'id';

    column      'tag.id' => { auto_increment => 1 };
    __PACKAGE__->_has_columns_of_taxonomy;
    __PACKAGE__->_has_columns_of_common;

    unique      'taxonomy_name';
    unique      'taxonomy_slug';

    __PACKAGE__->_many_taxonomy_to_many_websites;

    __PACKAGE__->_can_reload('tag');
    __PACKAGE__->_must_rebuild_when_delete('tag');
    # __PACKAGE__->_must_rebuild_when_update('tag');    # does not need

    __PACKAGE__->_can_update_with_timestamp;
};

# ================================================================
# ウェブサイト対タグ
# ================================================================
install_model website_tag => schema {
    key         'id';

    column      'website_tag.id' => { auto_increment => 1 };
    column      'website.id';
    column      'tag.id';
    __PACKAGE__->_has_columns_of_common;

    __PACKAGE__->_can_update_with_timestamp;
};


# ****************************************************************
# universal columns
# ****************************************************************

sub _has_columns_of_taxonomy {
    my $schema_class = shift;

    column      'taxonomy.slug';
    utf8_column 'taxonomy.name';
    utf8_column 'taxonomy.description';
    column      'taxonomy.count_websites';

    $schema_class->_has_alias_columns_of_taxonomy;

    return;
}

sub _has_columns_of_common {
    my $schema_class = shift;

    column      'common.created_on';
    column      'common.updated_on';

    $schema_class->_has_alias_columns_of_common;

    return;
}


# ****************************************************************
# universal alias columns
# ****************************************************************

sub _has_alias_columns_of_taxonomy {
    my $schema_class = shift;

    $schema_class->_set_alias_columns
        ($schema_class->__alias_columns_of_taxonomy);

    return;
}

sub _has_alias_columns_of_common {
    my $schema_class = shift;

    $schema_class->_set_alias_columns
        ($schema_class->__alias_columns_of_common);

    return;
}

sub _set_alias_columns {
    my ($schema_class, $alias_columns) = @_;

    while(
        my ($real_column, $alias_column) = (splice @$alias_columns, 0, 2)
    ) {
        alias_column $real_column => $alias_column;
    }

    return;
}


# ****************************************************************
# relationships
# ****************************************************************

sub _has_many_categories {
    my $schema_class = shift;

    add_method category_ids => sub {
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

    add_method categories => sub {
        my ($row, $categories) = @_;

        if ($categories) {  # setter
            my $website_category_relations
                = __PACKAGE__->__modify_categories($row, $categories);
            return
                unless $website_category_relations;
            my @categories = $row->{model}->get(category => {
                where => [
                    id => {
                        IN => [ map {
                            $_->category_id;
                        } @$website_category_relations ],
                    },
                ],
            });
            return \@categories;
        }
        else {              # getter
            return $row->{model}->lookup_multi(category => [
                $row->category_ids,
            ]);
        }
    };

    return;
}

sub _has_many_tags {
    my $schema_class = shift;

    add_method tag_ids => sub {
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

    add_method tags => sub {
        my ($row, $tags) = @_;

        if ($tags) {    # setter
            my $website_tag_relations
                = __PACKAGE__->__modify_tags($row, $tags);
            return
                unless $website_tag_relations;
            my @tags = $row->{model}->get(tag => {
                where => [
                    id => {
                        IN => [ map {
                            $_->tag_id;
                        } @$website_tag_relations ],
                    },
                ],
            });
            return \@tags;
        }
        else {          # getter
            return $row->{model}->lookup_multi(tag => [
                $row->tag_ids,
            ]);
        }
    };

    return;
}

sub _has_many_children {
    my $schema_class = shift;

    add_method child_ids => sub {
        return map {
            $_->id;
        } $_[0]->children($_[1]);
    };

    add_method children => sub {
        my ($row, $handler) = @_;

        $handler ||= $row->{model};

        return $handler->get(category => {
            where => [
                parent_id => $_[0]->id,
            ],
            order => {
                id        => 'ASC',
            },
        });
    };

    add_method _build_children_count => sub {
        return $_[0]->count_children
            ( scalar( my @children = $_[0]->children($_[1]) ) );
    };

    add_method is_leaf => sub {
        return not $_[0]->count_children;
    };

    add_method is_child_of => sub {
        my ($category, $parent_candidate) = @_;

        return any {
            $category->id eq $_;
        } $parent_candidate->child_ids;
    };

    return;
}

sub _has_many_descendants {
    my $schema_class = shift;

    add_method descendant_ids => sub {
        return map {
            $_->id;
        } $_[0]->descendants;
    };

    add_method descendants => sub {
        my ($row, $txn) = @_;

        my @descendants;
        foreach my $immediate_child ($row->children($txn)) {
            push @descendants,
                $immediate_child, $immediate_child->descendants($txn);
        }

        return @descendants;
    };

    add_method _build_descendants_count => sub {
        return $_[0]->count_descendants
            ( scalar( my @descendants = $_[0]->descendants($_[1]) ) );
    };

    return;
}

sub _might_belong_to_parent {
    my $schema_class = shift;

    add_method parent => sub {
        my ($row, $handler) = @_;

        $handler ||= $row->{model};
        my $parent_id = $row->parent_id;

        return unless defined $parent_id;
        return $handler->lookup(category =>
            $parent_id
        );
    };

    add_method is_root => sub {
        return not defined $_[0]->parent_id;
    };

    add_method is_parent_of => sub {
        my ($category, $child_candidate) = @_;

        return any {
            $_->id eq $child_candidate->parent_id;
        } $category->children;
    };

    return;
}

sub _must_rebuild_when_update {
    my ($schema_class, $table_name) = @_;

    my $method = '__edit_' . $table_name;

    add_method update => sub {
        $schema_class->$method($_[0], $_[1]);
    };

    return;
}

sub _must_rebuild_when_delete {
    my ($schema_class, $table_name) = @_;

    my $method = '__remove_' . $table_name;

    add_method delete => sub {
        $schema_class->$method($_[0], $table_name, $_[1]);
        undef $_[0];
    };

    return;
}

sub _many_taxonomy_to_many_websites {
    my $schema_class = shift;

    add_method website_ids => sub {
        $schema_class->_website_ids($_[0], $_[1]);
    };

    add_method websites => sub {
        # contextでArrayRefかArrayかを変える？
        @{ $schema_class->_websites($_[0]) };
    };

    add_method count_current_websites => sub {
        $_[0]->count_websites(scalar $_[0]->website_ids($_[1]));
    };

    return;
}


# ****************************************************************
# miscellaneous methods
# ****************************************************************

sub _can_reload {
    my ($schema_class, $table_name) = @_;

    add_method reload => sub {
        my $reloaded_row = $_[0]->{model}->lookup($table_name => $_[0]->id);
        Carp::croak "Cannot reload $_[0]"
            unless $reloaded_row;
        $_[0] = $reloaded_row;
    };

    return;
}

sub _can_alternative_update {
    my $schema_class = shift;

    add_method _internal_update => sub {
        my ($row, $handler) = @_;

        $handler ||= $row->{model};
        $handler->update($row);
    };

    return;
}

sub _can_update_with_timestamp {
    my $schema_class = shift;

    add_method _update_with_timestamp => sub {
        $schema_class->__update_with_timestamp($_[0], 'common_updated_on');
    };
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

    # **** Directly (from CLI) ****

    package SimpleLinks::CLI::Foobar;

    use Encode;
    use FindBin;
    use YAML::Any;

    use lib 'extlib';
    use Faktro::Schema::Factory;

    my $model = Faktro::Schema::Factory->new(
        backend     => 'SQLite',
        model_class => 'SimpleLinks::Schema::Table',
        dsn_options => {
            dbname => $FindBin::Bin . '/../SimpleLinks.db',
        },
    );
    my $website = $model->lookup( website => 1 );
    print Encode::decode_utf8( Dump $website );


    # **** Indirectry (via Ark) ****

    # ---- Ark model ----

    package SimpleLinks::Web::Model::Links;

    use Ark 'Model::Adaptor';   # automatically turn on strict & warnings

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

    # ---- Ark controller ----

    package SimpleLinks::Web::Controller::Root;

    use Encode;
    use YAML::Any;

    use Ark 'Controller';       # automatically turn on strict & warnings

    has '+namespace' => (
        default => q{},
    );

    sub index : Path Args(0) {
        my ($self, $c) = @_;

        my $model   = $c->model('Links');
        my $website = $model->lookup( website => 1 );

        $c->res->header( content_type => 'text/plain' );
        $c->res->body( Encode::decode_utf8(Dump $website) );
    }


=head1 DESCRIPTION

このモジュールは、SimpleLinksアプリケーション(p5-ark-sample-simplelinks)のテーブルスキーマです。

L<SYNOPSIS|/SYNOPSIS>では、L<Data::Model|Data::Model>のC<base_driver>やDBのテーブル生成などを、ラッパークラスのL<Faktro::Schema::SQLite|Faktro::Schema::SQLite>で行っています。勿論、L<Data::ModelのSYNOPSIS|Data::Model/SYNOPSIS>の通りに、テーブルスキーマである本モジュール自体に処理を実装しても構いません。


=head1 MEMORANDUM

=head2 Auto update

C<< $row->update >>の替わりにC<< $row->update_with_timestamp >>を使うことにより、暗黙的に更新日時を設定出来ます。

C<< $row->update >>を上書きして、以下のように暗黙的に更新日時を設定することも不可能ではありませんが、今回は採用しませんでした。

    add_method update => sub {
        my $row = shift;

        $row->updated_on(DateTime->now);

        return $row->{model}->update($row, @_);
    };


=head2 Alias coluns

C<< $model->set >>時にはC<< alias_column >>されたエイリアスでの格納は不可能（？）。

=head2 Relationships

このクラスでは、手動で関係(relationships)を定義しています。

なお、このクラスのクラスメソッドに散見されるC<belongs_to>, C<has_many>, C<might_have>, C<has_one>, C<many_to_many>は、単なる命名規則に過ぎません。

これらのリレーション実現メソッドは、本クラスに実装しなければなりません。。
これは、メソッドを生やす行オブジェクトを特定するC<add_method>関数内の、C<caller>による実装に準拠する必要があるためです。

L<Data::Model|Data::Model>のリレーション対応版が出来た場合には、当然ながらこれらの手動定義は破棄して書き直します。

=head2 Test::Synopsis

L<SYNOPSYS|/"SYNOPSIS">セクションの子セクション（C<=head2 Directly (from CLI)>など）は作れないので留意します。


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
