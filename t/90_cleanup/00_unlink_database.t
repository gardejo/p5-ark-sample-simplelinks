use strict;
use warnings;
use local::lib;

use Test::More 0.87_01;

use lib 'extlib';
use lib 't/lib';

use SimpleLinks::Test::Cleanup;
use SimpleLinks::Test::Constant;

plan(tests => 1);

END {
    ok(-f $Database_Name, 'database file exists');
    diag sprintf 'try to unlink database (%s)',
        $Database_Name;
    eval {
        cleanup();
    };
    # Because "Permission denied" error may happen on Win32, I don't this test:
    # ok(! -f $Database_Name, 'database file was unlinked');
}

1;
__END__
