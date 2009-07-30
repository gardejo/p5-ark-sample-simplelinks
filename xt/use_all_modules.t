#!perl -T

eval {
    use Test::UseAllModules;
};

Test::More::plan( skip_all =>
    "Test::UseAllModules required " .
    "for testing presence of all manifested modules"
) if $@;

BEGIN {
    all_uses_ok();
}
