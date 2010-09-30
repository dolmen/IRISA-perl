use strict;
package IRISA::Arg::Bool;

sub encode
{
    return (3 + ! ! $_[1], '');
}

{
    # The key is the prefix, the value is the decode sub
    my $decode_map = {
        3 => 0,
        4 => 1,
    };

    sub decode_map() { $decode_map }
}

1; # vim: set et sw=4 sts=4 :
