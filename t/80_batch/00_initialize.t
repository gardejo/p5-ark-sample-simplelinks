#!perl -T

use strict;
use warnings;
use utf8;
use local::lib;

use Test::Exception;
use Test::More;

use English;
use List::MoreUtils qw(none);
use Module::Load;
use YAML::Any;

use SimpleLinks::CLI::Batch::Initialization;

# {
#     ok( (none { $_ =~ m{YAML}xmsi } keys %INC),
#         'none YAML parsers/writters was loaded' );
# }

my $query_path
    = 'examples/app/p5-ark-sample-simplelinks/SimpleLinks.data.yml';
ok( -f $query_path, sprintf 'query file (%s) exists', $query_path );

my @implementations = YAML::Any->order;

IMPLEMENTATION:
foreach my $implementation (@implementations) {
    local @YAML::Any::_TEST_ORDER = ($implementation);
    if ($implementation ne YAML::Any->implementation) {
        diag sprintf 'module (%s) was skipped', $implementation;
        next IMPLEMENTATION;
    }

    my $query;
    lives_ok {
        $query
            = SimpleLinks::CLI::Batch::Initialization->_read_query
                ($query_path);
    } sprintf 'parse ok with implementation (%s)', $implementation;

    ok( utf8::is_utf8($query->{websites}[0]{tags}[0]), 'utf8 encoded ok' );

    # avoid redefine
    last IMPLEMENTATION
        if  $implementation eq 'YAML'       ||
            $implementation eq 'YAML::Old'  ||
            $implementation eq 'YAML::Tiny';
}

# {
#     SimpleLinks::CLI::Batch::Initialization->initialize
#                                                 ($root_path, $path_untainter);
# }


done_testing();

__END__

YAML::Node, YAMl::Type辺りが面倒。
芋蔓式アンロードは難しいので、ありもので済ませたい。
それでテスト要件足りうるのではないか。
