#!perl -T


# ****************************************************************
# pragmas
# ****************************************************************

use strict;
use warnings;


# ****************************************************************
# general dependencies
# ****************************************************************

# Add application external library ({MYAPP}/extlib) to @INC.
use FindBin;
use Path::Class qw(file);
use lib file("$FindBin::Bin/../extlib")->cleanup->stringify;    # for -T mode

# This module is in application external library ({MYAPP}/extlib).
# Add local library (ex. /virtual/{USERNAME}/local/lib) to @INC.
use local::lib;

# Add application library ({MYAPP}/lib) to @INC.
use FindBin::libs;

# These modules are in local library (ex. /virtual/{USERNAME}/local/lib).
# use Inline::Files;
# use YAML::Any qw(Load);
use YAML::Any qw(LoadFile);


# ****************************************************************
# internal dependencies
# ****************************************************************

# This module is in application library ({MYAPP}/lib).
use SimpleLinks::Service::Links;


# ****************************************************************
# main routine
# ****************************************************************

my $config = LoadFile($FindBin::Bin . '/../SimpleLinks.yml') || {};
my $dbname = file($FindBin::Bin . '/../' . $config->{dbname})->cleanup
                                                             ->stringify;
unlink $dbname
    if -f $dbname;
my $links = SimpleLinks::Service::Links->new({
    schema_factory => 'Faktro::Schema::Factory',
    connect_info   => {
        backend     => 'SQLite',
        model_class => 'SimpleLinks::Schema::Table',
        dsn_options => {
            dbname => $dbname,
        },
    },
});

my $query = LoadFile($FindBin::Bin . '/../' . $config->{datafile});

foreach my $category_query (@{ $query->{categories} }) {
    $links->add_category($category_query);
}

foreach my $tag_query (@{ $query->{tags} }) {
    $links->add_tag($tag_query);
}

foreach my $website_query (@{ $query->{websites} }) {
    $links->add_website($website_query);
}
