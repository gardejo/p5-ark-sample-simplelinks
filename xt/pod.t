#!perl -T

eval {
    use Test::Pod 1.40;
};

Test::More::plan( skip_all =>
    "Test::Pod 1.40 required " .
    "for testing POD"
) if $@;

all_pod_files_ok();
