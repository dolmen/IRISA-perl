use strict;
package IRISA::Arg::Int;

our @ISA = ('IRISA::Arg');

sub encode($)
{
    my $self = shift;
    my $i = shift;
    if ($i == 0) {
	return (5, '');
    } elsif ($i < 0 || $i > 0xffff) {
	return (2, pack('N', $i));
    } elsif ($i <= 0xff) {
	return (0, pack('C', $i));
    } else {
	return (1, pack('n', $i));
    }
}

{
    my $decode_map =
    {
	0 => sub($) { (1, unpack('C', shift)) },
	1 => sub($) { (2, unpack('n', shift)) },
	2 => sub($) { (4, unpack('N', shift)) },
	5 => 0,
    };

    sub decode_map() { $decode_map }
}

1;
