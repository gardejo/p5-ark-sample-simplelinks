package SimpleLinks::CLI::Batch::Initialization;


# ****************************************************************
# pragmas
# ****************************************************************

use strict;
use warnings;


# ****************************************************************
# general dependencies
# ****************************************************************

use YAML::Any qw(Dump Load LoadFile);


# ****************************************************************
# internal dependencies
# ****************************************************************

use SimpleLinks::CLI;


# ****************************************************************
# class methods
# ****************************************************************

sub initialize {
    my ($class, $root_path, $path_untainter) = @_;

    my $config  = LoadFile($root_path . 'SimpleLinks.yml') || {};
    my $query   = $class->_read_query($root_path . $config->{datafile});
    my $dbname  = &$path_untainter($root_path . $config->{dbname});
    unlink $dbname
        if -f $dbname;
    my $service = $class->_get_service($dbname);

    # website must add after categories and tags
    foreach my $category_query (@{ $query->{categories} }) {
        $service->add_category($category_query);
    }
    foreach my $tag_query (@{ $query->{tags} }) {
        $service->add_tag($tag_query);
    }
    foreach my $website_query (@{ $query->{websites} }) {
        $service->add_website($website_query);
    }

    return;
}

sub _read_query {
    my ($class, $query_path) = @_;

    my $implementation = YAML::Any->implementation;
    my $query;

    if ( $implementation eq 'YAML::Syck' ) {
        no warnings 'once';
        local $YAML::Syck::ImplicitUnicode = 1;
        $query = LoadFile($query_path);
    }
    else {
        $query = LoadFile($query_path);
        if ( $implementation ne 'YAML::XS' ) {  # YAML::Old, YAML, YAML::Tiny
            $query = Dump($query);
            utf8::decode($query);
            $query = Load($query);
        }
    }

    return $query;
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

SimpleLinks::CLI::Batch::Initialization - 


=head1 SYNOPSIS

    # blah blah blah


=head1 DESCRIPTION

このモジュールは、コマンドラインで（バッチで）リンク集のデータベースを一括に（再）作成するためのものです。

=head1 METHODS

=head2 initialize

データベースを初期化するクラスメソッドです。

アプリケーションルートディレクトリに存在するC<SimpleLinks.yml>ファイルを設定として読み込みます。

データベースはSQLite3のファイルです。
データベースのファイル名は、C<SimpleLinks.yml>の設定にあるC<dbname>です（アプリケーションルートディレクトリからの相対パスで記述してください）。

データベースに書き込むクエリーは、C<SimpleLinks.yml>の設定にあるC<datafile>（アプリケーションからの相対パスで記述してください）のYAMLファイルに記述します。


=head1 MEMORANDUM

=head2 YAML::Any and UTF8 flag

YAML::Anyで採用されうるYAML系パーサーおよびリーダーモジュール群のそれぞれは、UTF-8フラグに関わる処理にいくつかの流派があります。

このモジュールでは、C<_read_query>メソッドでそれらの差異を吸収しています。

=over 4

=item YAML

L<宮川さんが紹介された方法|/"Miyagawa's idiom (to parse YAML file with encoding as utf8)">を使います。

=item YAML::Old

YAMLと同じです。

=item YAML::Syck

C<$YAML::Syck::ImplicitUnicode>フラグを立てます。

=item YAML::Tiny

YAMLと同じです。

=item YAML::XS

何もしません。自然体でUTF8フラグが付きます。素敵ですね。

=back


=head1 SEE ALSO

=over 4

=item Miyagawa's idiom (to parse YAML file with encoding as utf8)

L<http://subtech.g.hatena.ne.jp/miyagawa/20060813/1155447825>

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
