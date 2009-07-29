use inc::Module::Install;

my $application_root_module = 'lib/SimpleLinks.pm';

# meta information
name                'SimpleLinks';
all_from            $application_root_module;
abstract_from       $application_root_module;
# author_from       $application_root_module;
author              'MORIYA Masaki ("Gardejo") <moriya at ermitejo dot com>';
version_from        $application_root_module;
license_from        $application_root_module;
perl_version_from   $application_root_module;

# use lib 'extlib';
no_index directory => 'extlib';
no_index directory => 'examples';

# build dependencies
build_requires      'Module::Load' => '0'; # -> perl 5.009_004
build_requires      'Module::Install' => '0.91'; # YAML::Tiny problem at Win32

# general dependencies
requires            'Any::Moose' => '0';
requires            'Ark' => '0.001000_002';
# requires          'Carp' => '0'; # -> perl 5
# requires          'Data::Dumper::Dumper => '0'; # -> perl 5.005;
requires            'Data::Model' => '0';
# requires          'Data::Model::Mixin::FindOrCreate' => '0'; # -> Data::Model
# requires          'DBD::SQLite' => '0'; # -> Data::Model
# requires          'DBI' => '0'; # -> Data::Model
requires            'DateTime' => '0';
requires            'DateTime::Format::MySQL' => '0';
# requires          'FindBin' => '0'; # -> perl 5.003_07
requires            'FindBin::libs' => '0';
requires            'List::MoreUtils' => '0'; # -> Ark -> Data::Util ???
requires            'List::Util' => '0'; # -> Ark -> Data::Util ???
# requires          'Scalar::Util' => '0'; # -> Ark
requires            'Text::MicroTemplate::Extended' => '0.01001';
requires            'URI' => '0';
requires            'local::lib' => '0';

# optional dependencies
feacures(
    'Support Markdown format for comment' => [
        -default    => 1,
        recommends( 'Text::Markdown' => '0' ),
    ],
    'Support E-mail sending' => [
        -default    => 1,
        recommends( 'Email::Send' => '0' ),
    ],
    'Support YAML format for dump' => [
        -default    => 1,
        recommends( 'YAML::Any' => '0' ),
        # recommends( 'YAML::Syck' => '0' ),
    ],
    'Support JSON format for dump' => [
        -default    => 1,
        recommends( 'JSON::Any' => '0' ),
        # recommends( 'JSON::Syck' => '0' ),
    ],
    'Support XML format for dump' => [
        -default    => 1,
        recommends( 'XML::LibXML' => '0' ), # Any XML?
    ],
);

# internal dependencies
# requires          'Faktro::Schema::Factory' => '0';

# test_requires     'File::Temp' => '0';
test_requires       'Test::Exception' => '0';
test_requires       'Test::More' => '0.87_01'; # to use done_testing()
test_requires       'Test::Warn' => '0';
# test_requires     'Time::HiRes' => '0'; # -> perl 5.007_003;

use_test_base;
tests               't/*.t t/*/*.t t/*/*/*.t';

auto_include;

WriteAll;

__END__

=head1 NAME

Makefile.PL - Makefile builder


=head1 SYNOPSIS

    $ cpan -t .
    $ make install


=head1 AUTHOR

=over 4

=item MORIYA Masaki ("Gardejo")

C<< <moriya at ermitejo dot com> >>,
L<http://ttt.ermitejo.com/>

=back


=head1 LICENCE AND COPYRIGHT

Copyright (c) 2009 by MORIYA Masaki ("Gardejo"),
L<http://ttt.ermitejo.com>.

This library is free software;
you can redistribute it and/or modify it under the same terms as Perl itself.
See L<perlgpl|perlapi> and L<perlartistic|perlartistic>.
