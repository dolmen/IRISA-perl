package IRISA::Interface::brk;
use IRISA::Interface;

name 'brk';
class 'BRK', 0x100;
version ;

Int Error => 1;
String ProgName => 3;
Bool 
Buffer
StringTable IconBitmap => 15;
BufferTable

Message Register => 1,
    [ qw{ProgName Description IconBitmap?} ],
    [ qw{Error} ];
