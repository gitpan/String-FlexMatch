use inc::Module::Install;
name 'String-FlexMatch';
all_from 'lib/String/FlexMatch.pm';
perl_version '5.006';

requires 'Class::Accessor::Complex';

build_requires 'Test::More' => '0.70';
build_requires 'YAML'       => '0.65';

use_standard_tests(without => 'pod_coverage');
auto_include;
WriteAll;
