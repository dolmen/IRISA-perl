package t::DSL1;
use IRISA::Interface::DSL;

Class DSL1 => 0x8700;

Int Arg1 => 1;
Int Arg2 => 2;
String Arg3;

Int RetCode;

Command Msg1;
Command 'Msg2';

1;
