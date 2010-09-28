#!perl

use Test::More tests => 5;

use IRISA::Interface::Registry qw/t::DSL1/;
#use t::DSL1;

print "# Id: ", $t::DSL1::last_arg_id, "\n";
ok "OK";

my $reg = IRISA::Interface::Registry->default;
my $arg = $reg->arg('RetCode');
is $arg->name, 'RetCode';
is $arg->id, 0x8004;
is $arg->interface, 't::DSL1';
is $arg->type, 'Int';

#ok $t::DSL1::Arg1

