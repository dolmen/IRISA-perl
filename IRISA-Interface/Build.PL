#!/usr/bin/perl

use Module::Build;

Module::Build->new(
    module_name => 'IRISA',
    dist_author => 'Olivier Mengue <dolmen@cpan.org>',
    requires => {
	parent => '0.221',
	Moose => '1.09',
    },
)->create_build_script;
