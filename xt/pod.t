#!perl -T

eval {
    require Test::Pod;
    Test::Pod->import;
    die if Test::Pod->VERSION < 1.40;
};

Test::More::plan( skip_all =>
    "Test::Pod 1.40 required " .
    "for testing POD"
) if $@;

all_pod_files_ok();
