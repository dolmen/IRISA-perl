#!perl

use Test::More tests => 12;

use IRISA::Interface::Registry qw/t::DSL1/;
#use t::DSL1;


print "# Id: ", $t::DSL1::last_arg_id, "\n";
ok "OK";

my $reg = IRISA::Interface::Registry->default;
my $arg = $reg->arg('RetCode');
is $arg->name, 'RetCode';
is $arg->id, 0x8704;
is $arg->interface, 't::DSL1';
is $arg->type, 'IRISA::Arg::Int';


# Convert to hex, then compare
sub is_hex
{
    my ($got, $exp) = map { unpack('H*', $_) } @_[0..1];
    is $got, $exp, @_[2..$#_];
}

my $enc;

$enc = "\x00\x87\x04\x03";
#is $arg->encode(3), $enc;
is_hex $arg->encode(3), $enc;
is_deeply [ $arg->decode($enc) ], [ length($enc), 3 ];

$enc = "\x01\x87\x04\x03\x05";
is_hex $arg->encode(0x0305), $enc;
is_deeply [ $arg->decode($enc) ], [ length($enc), 0x0305 ];

$enc = "\x05\x87\x04";
is_hex $arg->encode(0), $enc;
is_deeply [ $arg->decode($enc) ], [ length($enc), 0 ];

$enc = "\x0d\@\x87\x00\x00\x87\x02\x04\x06\x87\x03\x05Hello";
my $cmd = $reg->command('Msg1');
is_hex $cmd->encode(Arg2 => 4, Arg3 => 'Hello'), $enc;

#ok $t::DSL1::Arg1

