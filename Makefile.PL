use inc::Module::Install;
name 'SimpleLinks-Web';
all_from 'lib/SimpleLinks/Web.pm';

requires 'Ark';

tests 't/*.t';

build_requires 'Test::More';
use_test_base;
auto_include;
WriteAll;
