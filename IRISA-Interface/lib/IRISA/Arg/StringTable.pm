use strict;
package IRISA::Arg::StringTable;

use parent 'IRISA::Arg';

sub encode
{
    my ($self, $arr) = @_;
    # TODO check string length (max 255)
    (0xE, pack('n(c/a*)*', scalar(@{$arr}), @{$arr});
}

{
    my $decode_map = {
        0xE => sub($) {
            my ($count, @strings) = unpack('n/(c/a*)', $_[0]);
        }
    }

    sub decode_map() { $decode_map }
}

1;  # vim: set et sw=4 sts=4 :
