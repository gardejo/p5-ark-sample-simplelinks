#!perl -T

use FindBin;

eval {
    use Test::NoTabs;
};

Test::More::plan( skip_all =>
    "Test::NoTabs required " .
    "for testing presence of tabs"
) if $@;

# inc/ModuleInstall/* will die.
# all_perl_files_ok();

# WTF? cannnot read.
all_perl_files_ok("$FindBin::Bin/../lib");
