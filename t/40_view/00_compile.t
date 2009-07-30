# use strict;
# use warnings;
use local::lib;

use Test::More 0.87_01;

use lib 'extlib';
# use lib 't/lib';

use SimpleLinks::Web;

use Ark::Test 'SimpleLinks::Web', components => [qw(
    Model::Links
    View::MT
    Controller::Root
)];

SKIP: {
    skip 'because I know no process testing Ark application', 2;

{
    my $content = get('/');
    is( $content, 'index mt', 'index view ok' );
}

{
    my $content = get('/amazing/deep/path/you/may/not/think/it');
    is( $content, '404 mt', '404 view ok' );
}

};

done_testing();

1;
__END__
