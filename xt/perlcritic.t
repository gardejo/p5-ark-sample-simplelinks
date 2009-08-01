#!perl -T

eval {
    require Perl::Critic;
    Perl::Critic->import;
    die if Perl::Critic->VERSION < 1.094;   # for equivalent_modules

    require Test::Perl::Critic;
    # 'use Any::Moose' and 'use Ark' are same as 'use strict' and 'use warnings'
    Test::Perl::Critic->import(
        -profile => 'xt/perlcriticrc',
    );
};

Test::More::plan( skip_all =>
    "Perl::Critic 1.094 and Test::Perl::Critic required " .
    "for testing PBP compliance"
) if $@;

all_critic_ok();
