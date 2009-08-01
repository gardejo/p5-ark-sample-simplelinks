#!perl -T

eval {
    require Test::UseAllModules;
    Test::UseAllModules->import;
};

Test::More::plan( skip_all =>
    "Test::UseAllModules required " .
    "for testing presence of all manifested modules"
) if $@;

all_uses_ok();
