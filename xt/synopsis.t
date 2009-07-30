#!perl -T

eval {
    use Test::Synopsis 0.06;
};

Test::More::plan( skip_all =>
    "Test::Synopsis 0.06 required " .
    "for testing POD synopsis"
) if $@;

all_synopsis_ok('lib');
