#!/usr/bin/perl

use warnings;
use strict;
use Module::Build;

Module::Build->new(
    module_name        => 'String::FlexMatch',
    license            => 'perl',
    create_makefile_pl => 'traditional',
    requires           => {
        'perl'               => '5.6.1',
        'Class::MethodMaker' => 1.11,
        'YAML'               => 0.35,
        'Test::More'         => 0.47,
    },
)->create_build_script;
