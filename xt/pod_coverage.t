#!perl -T

eval {
    require Test::Pod::Coverage;
    Test::Pod::Coverage->import;
    die if Test::Pod::Coverage->VERSION < 1.08;
};

Test::More::plan( skip_all =>
    "Test::Pod::Coverage 1.08 required " .
    "for testing POD coverage"
) if $@;

all_pod_coverage_ok('lib');

# note: Devel::Cover and Attribute::Protected and Test::Pod::Coverage
#       are incompatible?
