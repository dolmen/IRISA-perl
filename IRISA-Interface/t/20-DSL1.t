#!perl

use Test::More tests => 23;
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
is $arg->type, 'Int';


# Convert to hex, then compare
sub is_hex
{
    my ($got, $exp) = map { unpack('H*', $_) } @_[0..1];
    is $got, $exp, @_[2..$#_];
}

my $enc;

$enc = "\x00\x87\x04\x03";
#is $arg->encode(3), $enc;
is_hex $arg->encode(3), $enc, "encode char";
is_deeply [ $reg->decode_arg($enc) ], [ length($enc), $arg, 3 ], "decode char";

$enc = "\x01\x87\x04\x03\x05";
is_hex $arg->encode(0x0305), $enc, "encode short";
is_deeply [ $reg->decode_arg($enc) ], [ length($enc), $arg, 0x0305 ], "decode short";

$enc = "\x05\x87\x04";
is_hex $arg->encode(0), $enc, "encode Int 0";
is_deeply [ $reg->decode_arg($enc) ], [ length($enc), $arg, 0 ], "decode Int 0";

$enc = "\x06\x87\x03\x05Hello";
$arg = $reg->arg(0x8703);
is_hex $arg->encode("Hello"), $enc, "encode String";
is_deeply [ $reg->decode_arg($enc) ], [ length($enc), $arg, "Hello" ], "decode String";


$enc = "\x10\x87\x05\x00\x02\x00\x00\x00\x09\x00\x87\x01\x08\x06\x87\x03\x01H\x00\x00\x00\x00";
my $v = [ [ Arg1 => 8, Arg3 => 'H' ], [] ];
$arg = $reg->arg('TArg');
is_hex $arg->encode($v), $enc, 'encode ArgTable';
is_deeply [ $reg->decode_arg($enc) ], [ length($enc), $arg, $v ], "decode ArgTable";

$enc = "\x0d\@\x87\x00\x00\x87\x02\x04\x06\x87\x03\x05Hello";
my $cmd = $reg->command('Msg1');
my @params = (Arg2 => 4, Arg3 => 'Hello');
is_hex $cmd->message(@params), $enc, 'encode Msg1';
is_hex $reg->encode_message($cmd, @params), $enc;
is_hex $reg->encode_message($cmd->id, @params), $enc;
@params = ($reg->arg('Arg2'), 4, $reg->arg('Arg3'), 'Hello');
is_hex $cmd->message(@params), $enc, 'encode Msg1';
is_hex $reg->encode_message($cmd, @params), $enc;
is_hex $reg->encode_message($cmd->id, @params), $enc;
is_deeply [ $reg->decode_message($enc) ], [ $cmd, @params ];

#ok $t::DSL1::Arg1

