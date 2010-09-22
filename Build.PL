#!/usr/bin/perl

use Module::Build;

Module::Build->new(
    module_name => 'IRISA',
    dist_author => 'Olivier Mengue <dolmen@cpan.org>'
)->create_build_script;
