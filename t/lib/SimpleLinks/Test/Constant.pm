package SimpleLinks::Test::Constant;


# ****************************************************************
# pragmas
# ****************************************************************

use strict;
use warnings;


# ****************************************************************
# superclasses
# ****************************************************************

use base qw(
    Exporter
);


# ****************************************************************
# general dependencies
# ****************************************************************

# use Env qw(__SimpleLinks_Test_Database_Name);
# use File::Temp qw();


# ****************************************************************
# class variables : Exporter settings
# ****************************************************************

our @EXPORT = qw(
    $Service_Class
    $Schema_Factory
    $DBMS $Model_Class $Database_Name $Builder_Option_Of_Database
);
our @EXPORT_OK = qw(
);
our %EXPORT_TAGS = (
);


# ****************************************************************
# class variables
# ****************************************************************

our $Service_Class = 'SimpleLinks::Service::Links';

our $Schema_Factory = 'Faktro::Schema::Factory';

our $DBMS = 'SQLite';

our $Model_Class = 'SimpleLinks::Schema::Table';

our $Database_Name = 'test_database.tmp';
# Cannot unlink test database on Win32 environment.
# Also cannnot unlink test dtabase created by File::Temp, on Win32 environment.
# Because test guarantee that filename of test dabase differ with time.
# our $Database_Name = $__SimpleLinks_Test_Database_Name;
# unless ($Database_Name) {
#     $Database_Name = File::Temp->new(
#         TEMPLATE => 'test_database_XXXX',
#         SUFFIX   => '.tmp',
#     )->filename;
#     $__SimpleLinks_Test_Database_Name = $Database_Name;
# }

our $Builder_Option_Of_Database = {
    schema_factory => $Schema_Factory,
    connect_info   => {
        backend     => $DBMS,
        model_class => $Model_Class,
        dsn_options => {
            dbname => $Database_Name,
        },
    },
};


# ****************************************************************
# return true
# ****************************************************************

1;
__END__


# ****************************************************************
# POD
# ****************************************************************

=head1 NAME

SimpleLinks::Test::Constant - export constants for test of SimpleLinks


=head1 SYNOPSIS

    use lib 't/lib';
    use SimpleLinks::Test::Constant;


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
