use strict;
use warnings;

use inc::Module::Install;

my $application_root_module = 'lib/SimpleLinks.pm';

# ================================================================
# meta information
# ================================================================
name_from       $application_root_module;
abstract_from   $application_root_module;
all_from        $application_root_module;
version_from    $application_root_module;
author          'MORIYA Masaki ("Gardejo") <moriya at ermitejo dot com>';
license_from    $application_root_module;
resources (
    repository  => 'git://github.com/gardejo/p5-ark-sample-simplelinks.git',
    bugtracker  => 'http://github.com/gardejo/p5-ark-sample-simplelinks/issues',
    homepage    => 'http://blog.eorzea.asia/2009/07/post_35.html',
);
# use lib 'extlib';
no_index directory => 'examples';
no_index directory => 'extlib';

# ================================================================
# build dependencies
# ================================================================
build_requires  'Module::Install'       => '0.80';  # YAML::Tiny problem
build_requires  'Module::Load'          => '0';     # > perl 5.009_004

# ================================================================
# general dependencies
# ================================================================
perl_version_from $application_root_module;
# requires      'Any::Moose'            => '0';     # > Ark > HTTP::Engine
  requires      'Ark'                   => '0.001000_002'; # from GitHub
# requires      'Carp'                  => '0';     # > perl 5
# requires      'Data::Dumper'          => '0';     # > perl 5.005;
  requires      'Data::Model'           => '0.00003';
# requires      'Data::Model::Mixin::FindOrCreate' => '0'; # > Data::Model
# requires      'DBD::SQLite'           => '0';     # > Data::Model
# requires      'DBI'                   => '0';     # > Data::Model
# requires      'DateTime'              => '0';     # > HTTP::Engine::Middleware
# requires      'Encode'                => '1.9801'; # > perl 5.008_001
# requires      'English'               => '0';     # > perl 5
  requires      'DateTime::Format::MySQL' => '0';
# requires      'Exception::Class'      => '0';     # > E::C::TryCatch
  requires      'Exception::Class::TryCatch' => '0';
# requires      'Filter::Util::Call'    => '0';     # (requires implicitly)
# requires      'FindBin'               => '0';     # > perl 5.003_07
# requires      'FindBin::libs'         => '0';     # > Ark
# requires      'Getopt::Long'          => '0';     # > Ark
# requires      'HTML::Shakan'          => '0';     # soon!
# requires      'HTTP::Engine'          => '0';     # > Ark
# requires      'HTTP::Engine::Middleware' => '0';  # > Ark
  requires      'List::Compare'         => '0';
  requires      'List::MoreUtils'       => '0.22';
# requires      'List::MoreUtils'       => '0.22';  # > HTML::Shakan
#                   note: 0.23 has any bugs. 0.24 was dropped from CPAN.
#                         0.25 is an as yet unstable release.
# requires      'List::Util'            => '0';     # > perl 5.06_00
# requires      'Mouse'                 => '0';     # > Ark
# requires      'MouseX::Types'         => '0';     # > Ark > HTTP::Engine
# requires      'Path::Class'           => '0.16';  # > Ark
# requires      'Scalar::Util'          => '1.19';  # > Ark > HTTP::Engine
# requires      'Storable'              => '0';     # > perl 5.007_003
# requires      'Taint::Util'           => '0';     # (is not in use)
  requires      'Text::MicroTemplate::Extended' => '0.01001';
# requires      'URI'                   => '0';     # > Ark
  requires      'local::lib'            => '0';

# Note: I want replace code with Scalar::Util as with Data::Util
#       because it interest me in is_number() as alternate looks_like_number().

# ================================================================
# optional dependencies
# ================================================================
features(
    'Support E-mail sending' => [
        -default    => 0,
        recommends( 'Email::Send'       => '0' ),
    ],
    'Support JSON format for dump' => [
        -default    => 0,
        recommends( 'JSON::Any'         => '0' ),
    ],
    'Support Markdown format for comment' => [
        -default    => 0,
        recommends( 'Text::Markdown'    => '0' ),
    ],
    'Support tag cloud' => [
        -default    => 0,
        recommends( 'Data::Cloud'       => '0' ),
    ],
    'Support XML format for dump' => [
        -default    => 0,
        recommends( 'XML::LibXML'       => '0' ),   # Any XML?
    ],
    'Support YAML format for dump' => [
        -default    => 0,
        recommends( 'YAML::Any'         => '0' ),
    ],
    'Support initialization by batch script' => [
        -default    => 0,
      # recommends( 'Class::Inspector'  => '0' ),   # > HTML::Shakan > FV::L
        recommends( 'YAML::Any'         => '0' ),
    ],
);

# ================================================================
# internal dependencies
# ================================================================
# requires      'Faktro::Schema::Factory' => '0';

# ================================================================
# dependencies for tests
# ================================================================
# test_requires 'File::Temp'            => '0';
# test_requires 'Test::Exception'       => '0';         # > Data::Model
  test_requires 'Test::More'            => '0.87_01';   # to use done_testing()
  test_requires 'Test::Warn'            => '0';
# test_requires 'Time::HiRes'           => '0';         # > perl 5.007_003;

# Ark::Test

# ================================================================
# dependencies for author tests
# plan skip_all => 'xxxx required for testing xxxx' if ...
# ================================================================
# test_requires 'Test::NoTabs'          => '0';
# test_requires 'Test::Output'          => '0';
# test_requires 'Test::Perl'            => '0';                                 
# test_requires 'Perl::Critic'          => '1.094';     # for equivalent_modules
# test_requires 'Test::Pod'             => '0';
# test_requires 'Test::Pod::Coverage'   => '0';
# test_requires 'Test::Spelling'        => '0';
# test_requires 'Test::Synopsis'        => '0';
# test_requires 'Test::UseAllModules'   => '0';

# ================================================================
# tests
# ================================================================
use_test_base;
tests           't/*.t t/*/*.t t/*/*/*.t';
author_tests    'xt';

# ================================================================
# installation
# ================================================================
auto_include;
auto_install;

# ================================================================
# META.yml writter
# ================================================================
WriteAll;

__END__


# ****************************************************************
# POD
# ****************************************************************

=head1 NAME

Makefile.PL - Makefile builder


=head1 SYNOPSIS

    $ cpan -t .
    $ cpan -i .


=head1 AUTHOR

=over 4

=item MORIYA Masaki ("Gardejo")

C<< <moriya at ermitejo dot com> >>,
L<http://ttt.ermitejo.com/>

=back


=head1 LICENSE AND COPYRIGHT

Copyright (c) 2009 by MORIYA Masaki ("Gardejo"),
L<http://ttt.ermitejo.com>.

This library is free software;
you can redistribute it and/or modify it under the same terms as Perl itself.
See L<perlgpl|perlapi> and L<perlartistic|perlartistic>.
