#!perl -T

use Test::More;
eval {
    require Test::CPAN::Meta;
    Test::CPAN::Meta->import;
    die if Test::CPAN::Meta->VERSION < 0.12;
};

Test::More::plan( skip_all =>
    "Test::CPAN::Meta 0.12 required " .
    "for testing that META.yml file matches the current specification."
) if $@;

meta_yaml_ok();
