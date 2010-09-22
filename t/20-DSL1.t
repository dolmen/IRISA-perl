#!perl

use Test::More tests => 1;

use t::DSL1;

print "Id: ", $t::DSL1::last_arg_id, "\n";

ok "OK";
#ok $t::DSL1::Arg1

