#!perl -T

eval {
    use Perl::Critic 1.094;             # for equivalent_modules
    use Test::Perl::Critic;
};

Test::More::plan( skip_all =>
    "Perl::Critic 1.094 and Test::Perl::Critic required " .
    "for testing PBP compliance"
) if $@;

# 'use Any::Moose' and 'use Ark' are same as 'use strict' and 'use warnings'
Test::Perl::Critic->import(
    -profile => 'xt/perlcriticrc',
);

Test::Perl::Critic::all_critic_ok();
