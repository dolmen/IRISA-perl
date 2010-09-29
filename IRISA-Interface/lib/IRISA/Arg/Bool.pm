use strict;
package IRISA::Arg::Bool;

sub encode($)
{
    return (3 + ! ! $_[0], '');
}

sub decode_map()
{
    # The key is the prefix, the value is the decode sub
    {
	3 => 0,
	4 => 1,
    }
}

1;
