package SimpleLinks::Test::Cleanup;

use strict;
use warnings;

use base qw(
    Exporter
);

use English;

use SimpleLinks::Test::Constant;

our @EXPORT = qw(
    cleanup
);
our @EXPORT_OK = qw(
);
our %EXPORT_TAGS = (
);

sub cleanup {
    unlink $Database_Name
        or warn sprintf 'Cannot unlink database (%s) by (UID:%s) because: %s',
            $Database_Name,
            $UID,
            $OS_ERROR;
}

1;
__END__

=head1 NAME

SimpleLinks::Test::Cleanup - cleanup environment when end of SimpleLinks test


=head1 SYNOPSIS

    use Test::More 0.87_01;

    use lib 't/lib';
    use SimpleLinks::Test::Cleanup;

    END {
        diag 'cleanup';
        cleanup();
    }

    done_testing();


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
