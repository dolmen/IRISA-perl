#!perl

use Test::More tests => 9;

use IRISA::Interface::Registry qw/t::DSL1/;
#use t::DSL1;

print "# Id: ", $t::DSL1::last_arg_id, "\n";
ok "OK";

my $reg = IRISA::Interface::Registry->default;
my $arg = $reg->arg('RetCode');
is $arg->name, 'RetCode';
is $arg->id, 0x8004;
is $arg->interface, 't::DSL1';
is $arg->type, 'IRISA::Arg::Int';

my $enc;

$enc = "\x00\x80\x04\x03";
is $arg->encode(3), $enc;
is_deeply [ $arg->decode($enc) ], [ length($enc), 3 ];

$enc = "\x01\x80\x04\x03\x05";
is $arg->encode(0x0305), $enc;
is_deeply [ $arg->decode($enc) ], [ length($enc), 0x0305 ];

$enc = "\x05\x80\x04";
is $arg->encode(0), $enc;
is_deeply [ $arg->decode($enc) ], [ length($enc), 0 ];

#ok $t::DSL1::Arg1

