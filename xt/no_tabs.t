#!perl -T

use FindBin;

eval {
    require Test::NoTabs;
    Test::NoTabs->import;
};

Test::More::plan( skip_all =>
    "Test::NoTabs required " .
    "for testing presence of tabs"
) if $@;

# inc/ModuleInstall/* will die.
# all_perl_files_ok();

# cannnot read /lib/* (?)
all_perl_files_ok("$FindBin::Bin/../lib");
