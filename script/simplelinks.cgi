#!/usr/bin/env perl


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
use lib "$FindBin::Bin/../extlib";

# This module is in application external library ({MYAPP}/extlib).
# Add local library (ex. /virtual/{USERNAME}/local/lib) to @INC.
use local::lib qq($ENV{DOCUMENT_ROOT}/../local);

# Add application library ({MYAPP}/lib) to @INC.
use FindBin::libs;

# These modules are in local library (ex. /virtual/{USERNAME}/local/lib).
use HTTP::Engine;
use YAML::Syck;


# ****************************************************************
# internal dependencies
# ****************************************************************

# this module is in application library ({MYAPP}/lib).
use SimpleLinks::Web;


# ****************************************************************
# main routine
# ****************************************************************

my $app = SimpleLinks::Web->new;

$app->config( LoadFile($FindBin::Bin . '/../SimpleLinks.yml') );
$app->setup_minimal;

HTTP::Engine->new(
    interface => {
        module          => 'CGI',
        request_handler => $app->handler,
    },
)->run;


# ****************************************************************
# return any
# ****************************************************************

__END__


# ****************************************************************
# POD
# ****************************************************************

=head1 NAME

simplelinks.cgi - starter of SimpleLinks (p5-ark-sample-simplelinks) for CGI


=head1 SYNOPSIS

    First, configure HTTPd as you think proper.
    Second, request 'http://foo.bar.example/simplelinks'.


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

=head2 Why not use FindBin::libs for extlib?

    use FindBin;
    use lib "$FindBin::Bin/../extlib";

is same as

    use FindBin::libs qw( base=extlib );

But, perl 5.8.8 did not include L<FindBin::libs|FindBin::libs>.

Therefore, this script add C<extlib> to C<@INC> by L<FindBin|FindBin>.


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
