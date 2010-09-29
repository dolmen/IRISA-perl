use strict;
package IRISA::Arg::StringTable;

use parent 'IRISA::Arg';

sub encode($)
{
    my $arr = shift;
    # TODO check string length (max 255)
    (0xE, pack('n(c/a*)*', scalar(@{$arr}), @{$arr});
}

sub decode_map()
{
    {
	0xE => sub($) {
	    my ($count, @strings) = unpack('n/(c/a*)');
	}
    }
}

1;
