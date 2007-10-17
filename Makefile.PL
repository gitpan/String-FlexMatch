use inc::Module::Install;
name 'String-FlexMatch';
all_from 'lib/String/FlexMatch.pm';
perl_version '5.006';

requires 'Class::Accessor::Complex';

build_requires 'Test::More';
build_requires 'YAML';

use_standard_tests(without => 'pod_coverage');
auto_include;
WriteAll;
