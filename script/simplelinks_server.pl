#!/usr/local/bin/perl -T


# ****************************************************************
# pragmas
# ****************************************************************

use strict;
use warnings;


# ****************************************************************
# general dependencies
# ****************************************************************

# Add application external library ({MYAPP}/extlib) to @INC.
use FindBin;
# use Path::Class qw(file);
# use lib file("$FindBin::Bin/../extlib")->cleanup->stringify;    # for -T mode

sub untaint_lib {
    my $path = shift;

    $path =~ m{\A ( [\w/_\.\-:\\]+ ) \z}xms ? $path = $1
                    : die "invalid path";

    return $path;
};

use lib untaint_lib("$FindBin::Bin/../extlib");

# This module is in application external library ({MYAPP}/extlib).
# Add local library (ex. /virtual/{USERNAME}/local/lib) to @INC.
use local::lib;

# Add application library ({MYAPP}/lib) to @INC.
use FindBin::libs;

# These modules are in local library (ex. /virtual/{USERNAME}/local/lib).
use Getopt::Long qw(GetOptions);
use HTTP::Engine;
use HTTP::Engine::Middleware;
use YAML::Any qw(LoadFile);


# ****************************************************************
# internal dependencies
# ****************************************************************

# This module is in application library ({MYAPP}/lib).
use SimpleLinks::Web;


# ****************************************************************
# main routine
# ****************************************************************

my ($config, $debug, $port, $address) = configuration();

my $app = SimpleLinks::Web->new;
$app->log_level( $debug ? 'debug' : 'error' );
$app->config($config);
$app->setup;

my $mw = HTTP::Engine::Middleware->new;
$mw->install( 'HTTP::Engine::Middleware::Static' => {
    regexp  => qr{
        \A
        /
        (
            robots\.txt  |
            favicon\.ico |
            (?:
                css | js | images?
            )/.+
        )
        \z
    }xms,
    docroot => $app->path_to('root'),
});

HTTP::Engine->new(
    interface => {
        module => 'ServerSimple',
        args   => {
            host => $address,
            port => $port,
        },
        request_handler => $mw->handler( $app->handler ),
    },
)->run;


# ****************************************************************
# subroutines
# ****************************************************************

# Ark::Command::Interfaceを使った方が良かったなぁ……（今は-hに未対応）。
sub configuration {
    my $config = LoadFile($FindBin::Bin . '/../SimpleLinks.yml') || {};

    my $debug   = $config->{debug}   || 0;
    my $port    = $config->{port}    || 4423;
    my $address = $config->{address} || '0.0.0.0';
    my $dbname;

    GetOptions(
          'debug|d'   => \$debug,
           'port|p:i' => \$port,
        'address|a:s' => \$address,
         'dbname|n:s' => \$dbname,
    );

    $config->{dbname} = $dbname if $dbname;
    $config->{dbname} = $FindBin::Bin . '/../' . $config->{dbname};

    return ($config, $debug, $port, $address);
}


# ****************************************************************
# return true
# ****************************************************************

1;
__END__


# ****************************************************************
# POD
# ****************************************************************

=head1 NAME

simplelinks_server.pl - starter of SimpleLinks (p5-ark-sample-simplelinks) for ServerSimple


=head1 SYNOPSIS

  script/simplelinks_server.pl [options]

  Options:
   -h --help    show this help
   -d --debug   enable debug mode [default: off]
   -p --port    specify port number to listen [default: 4423]
   -a --address specify address to bind [default: 0.0.0.0]
   -n --dbname  specify path of SQLite database file to read


=head1 DESCRIPTION

In case of xrea.com and/or coreserver.jp, make directory tree like below:

  /virtual
    /{USERNAME}
      /local
        /lib      ... Local library. Deploy your favorite modules here.
    /public_html
    /{MYAPP}
      /lib        ... Application library. Deploy {MyApp} modules here.
        /{MyApp}
      /extlib     ... Application external library. Deploy local::lib here.

Loading resolution order is app-lib, local-lib, app-ext-lib, and default-libs.

=head2 Remember configure environment variables

B<CAVEAT>: Remember to configure C<.bashrc> (or C<.cshrc>, etc.) adequately!

=head2 Why not use FindBin::libs for extlib?

    use FindBin;
    use lib "$FindBin::Bin/../extlib";

is substantially same as

    use FindBin::libs qw( base=extlib );

But, perl 5.8.8 (that was installed in xrea.com and coreserver.jp)
did not include L<FindBin::libs|FindBin::libs>.

Therefore, this script add C<extlib> to C<@INC> by L<FindBin|FindBin>.


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
