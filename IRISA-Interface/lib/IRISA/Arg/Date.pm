use strict;
package IRISA::Arg::Date;

sub encode($)
{
    my $v = shift;
    if (ref $v && $v->isa('DateTime')) {
	$v = $v->epoch();
    }
    return (7, pack('l>', $v);
}

sub decode_map()
{
    (
	7 => sub($) { unpack('l>', shift) }
    )
}

1;
