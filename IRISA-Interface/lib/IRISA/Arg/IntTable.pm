use strict;
package IRISA::Arg::IntTable;

sub encode
{
    my ($self, $arr) = @_;
    return (0xd, pack('nN*', (scalar @{$arr}), @{$arr}))
}

{
    my $decode_map = {
        0xd => sub($) {
            my $d = shift;
            my $count = unpack('n', $d);
            return (2+4*$count, [ unpack('l>*', substr($d, 2, 4*$count)) ] )
        },
    };

    sub decode_map() { $decode_map }
}

1; # vim:set et ts=4 sw=4 sts=4 :
