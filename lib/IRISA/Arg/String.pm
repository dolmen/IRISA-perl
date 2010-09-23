use strict;
package IRISA::Arg::String;

# A string, using the native encoding of the platform

sub encode($)
{
    my $s = shift;
    my $l = length($s);
    if ($l == 0)
	return (10, '');
    (6, pack('na*', $l, ))
}

sub decode_map()
{
    {
	6  => sub($) {
	    my $l = ord($_[0]);
	    return (1+$l, substr($_[0], 1, $l));
	},
	10 => '',
    }
}

1;
