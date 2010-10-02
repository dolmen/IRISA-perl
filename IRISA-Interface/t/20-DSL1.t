#!perl

use Test::More tests => 21;
use Test::NoWarnings;

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
is_hex $arg->encode(0x0305), $enc, "encode short";
is_deeply [ $arg->decode($enc) ], [ length($enc), 0x0305 ], "decode short";

$enc = "\x05\x87\x04";
is_hex $arg->encode(0), $enc, "encode Int 0";
is_deeply [ $arg->decode($enc) ], [ length($enc), 0 ], "decode Int 0";

$enc = "\x06\x87\x03\x05Hello";
$arg = $reg->arg(0x8703);
is_hex $arg->encode("Hello"), $enc, "encode String";
is_deeply [ $arg->decode($enc) ], [ length($enc), "Hello" ], "decode String";

$enc = "\x0d\@\x87\x00\x00\x87\x02\x04\x06\x87\x03\x05Hello";
my $cmd = $reg->command('Msg1');
my @params = (Arg2 => 4, Arg3 => 'Hello');
is_hex $cmd->encode(@params), $enc, 'encode Msg1';
is_hex $reg->encode_command($cmd, @params), $enc;
is_hex $reg->encode_command($cmd->id, @params), $enc;
@params = ($reg->arg('Arg2'), 4, $reg->arg('Arg3'), 'Hello');
is_hex $cmd->encode(@params), $enc, 'encode Msg1';
is_hex $reg->encode_command($cmd, @params), $enc;
is_hex $reg->encode_command($cmd->id, @params), $enc;
is_deeply [ $reg->decode_command($enc) ], [ $cmd, @params ];

#ok $t::DSL1::Arg1

