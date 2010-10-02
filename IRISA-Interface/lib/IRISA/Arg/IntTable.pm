use strict;
package IRISA::Arg::IntTable;

sub encode
{
    my ($self, $arr) = @_;
    return (0xd, pack('n/N*', @{$arr}))
}

{
    my $decode_map = {
        0xd => sub($) {
            my $d = shift;
            #my $count = unpack('n', $d);
            #return (2+4*$count, [ unpack('l>*', substr($d, 2, 4*$count)) ] )
            my @arr = unpack('n/N*', $d);
            return (2+4*@arr, \@arr);
        },
    };

    sub decode_map() { $decode_map }
}

1; # vim:set et ts=4 sw=4 sts=4 :
