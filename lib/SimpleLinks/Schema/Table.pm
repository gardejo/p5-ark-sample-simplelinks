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

use Data::Model::Mixin modules => [
    'FindOrCreate',
    '+SimpleLinks::Schema::Mixin::Category',
    '+SimpleLinks::Schema::Mixin::Common',
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
    __PACKAGE__->_columns_of_common;

    unique      'uri';

    __PACKAGE__->_website_has_many_categories;
    __PACKAGE__->_website_has_many_tags;

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
    __PACKAGE__->_columns_of_taxonomy;
    __PACKAGE__->_columns_of_common;

    __PACKAGE__->_category_has_many_children;
    __PACKAGE__->_category_has_many_descendants;
    __PACKAGE__->_category_might_belong_to_parent;
    __PACKAGE__->_many_taxonomy_to_many_websites;

    __PACKAGE__->_can_alternative_update;
    __PACKAGE__->_must_update_with_rebuild;

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
    __PACKAGE__->_columns_of_common;

    __PACKAGE__->_can_update_with_timestamp;
};

# ================================================================
# タグ
# ================================================================
install_model tag => schema {
    key         'id';

    column      'tag.id' => { auto_increment => 1 };
    __PACKAGE__->_columns_of_taxonomy;
    __PACKAGE__->_columns_of_common;

    unique      'taxonomy_name';
    unique      'taxonomy_slug';

    __PACKAGE__->_many_taxonomy_to_many_websites;

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
    __PACKAGE__->_columns_of_common;

    __PACKAGE__->_can_update_with_timestamp;
};


# ****************************************************************
# universal columns
# ****************************************************************

sub _columns_of_taxonomy {
    my $schema = shift;

    column      'taxonomy.slug';
    utf8_column 'taxonomy.name';
    utf8_column 'taxonomy.description';
    column      'taxonomy.count_websites';

    $schema->_alias_columns_of_taxonomy;

    return;
}

sub _columns_of_common {
    my $schema = shift;

    column      'common.created_on';
    column      'common.updated_on';

    $schema->_alias_columns_of_common;

    return;
}


# ****************************************************************
# universal alias columns
# ****************************************************************

sub _alias_columns_of_taxonomy {
    my $schema = shift;

    $schema->_set_alias_columns($schema->__alias_columns_of_taxonomy);

    return;
}

sub _alias_columns_of_common {
    my $schema = shift;

    $schema->_set_alias_columns($schema->__alias_columns_of_common);

    return;
}

sub _set_alias_columns {
    my ($schema, $alias_columns) = @_;

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

sub _website_has_many_categories {
    my $schema = shift;

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
        return $_[0]->{model}->lookup_multi(category => [
            $_[0]->category_ids
        ]);
    };

    return;
}

sub _website_has_many_tags {
    my $schema = shift;

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
        return $_[0]->{model}->lookup_multi(tag => [
            $_[0]->tag_ids
        ]);
    };

    return;
}

sub _category_has_many_children {
    my $schema = shift;

    add_method child_ids => sub {
        return map {
            $_->id;
        } $_[0]->children;
    };

    add_method children => sub {
        return $_[0]->{model}->get(category => {
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
            ( scalar( my @children = $_[0]->children ) );
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

sub _category_has_many_descendants {
    my $schema = shift;

    add_method descendant_ids => sub {
        return map {
            $_->id;
        } $_[0]->descendants;
    };

    add_method descendants => sub {
        my $row = shift;

        my @descendants;
        foreach my $immediate_child ($row->children) {
            push @descendants,
                $immediate_child, $immediate_child->descendants;
        }

        return @descendants;
    };

    add_method _build_descendants_count => sub {
        return $_[0]->count_descendants
            ( scalar( my @descendants = $_[0]->descendants ) );
    };

    return;
}

sub _category_might_belong_to_parent {
    my $schema = shift;

    add_method parent => sub {
        my $parent_id = $_[0]->parent_id;
        return unless defined $parent_id;
        return $_[0]->{model}->lookup(category =>
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

sub _must_update_with_rebuild {
    my $schema = shift;

    add_method update => sub {
        $schema->__edit_category($_[0]);
    };

    return;
}

sub _can_alternative_update {
    my $schema = shift;

    add_method _internal_update => sub {
        my $row = shift;
        $row->{model}->update($row, @_);
    };

    return;
}

sub _many_taxonomy_to_many_websites {
    my $class = shift;

    add_method website_ids => sub {
        $class->_website_ids($_[0]);
    };

    add_method websites => sub {
        # contextでArrayRefかArrayかを変える？
        @{ $class->_websites($_[0]) };
    };

    add_method count_current_websites => sub {
        $_[0]->count_websites(scalar $_[0]->website_ids);
    };

    return;
}


# ****************************************************************
# miscellaneous methods
# ****************************************************************

sub _can_update_with_timestamp {
    my $schema = shift;

    add_method _update_with_timestamp => sub {
        $schema->__update_with_timestamp($_[0], 'common_updated_on');
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

=head2 Relationship

C<belongs_to>, C<has_many>, C<might_have>, C<has_one>, C<many_to_many>は、単なる命名規則に過ぎません。

なお、それらのリレーション実現メソッドは、本クラスに実装しなければなりません。。
これは、メソッドを生やす行オブジェクトを特定するC<add_method>関数内の、C<caller>による実装に準拠する必要があるためです。


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
