use inc::Module::Install;
name 'String-FlexMatch';
all_from 'lib/String/FlexMatch.pm';

requires 'Class::MethodMaker';

build_requires 'Test::More';
build_requires 'YAML';

use_standard_tests(without => 'pod_coverage');
auto_include;
WriteAll;
