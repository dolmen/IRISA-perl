use strict;
package IRISA::Arg::String;

# A string, using the native encoding of the platform

sub encode
{
    my ($self, $s) = @_;
    my $l = length($s);
    return (10, '') if $l == 0;
    return (6, pack('Ca*', $l, $s)) if $l <= 0xff;
    return (12, pack('na*', $l, $s)) if $l <= 0xff;
}

{
    my $decode_map = {
        6  => sub($) {
            #my $l = ord($_[0]);
            #die "Missing data in String arg\n" if length($_[0]) < 1+$l;
            #(1+$l, substr($_[0], 1, $l))
            #(1+$l, unpack('C/a*', $_[0]))
            my @res = unpack('C X C/a*', $_[0]);
            $res[0]++;
            @res
        },
        10 => '',
        12 => sub($) {
            my $l = unpack('n', $_[0]);
            die "Missing data in String arg\n" if length($_[0]) < 1+$l;
            (2+$l, substr($_[0], 2, $l))
            #(1+$l, unpack('n/a*', $_[0]))
        }
    };

    sub decode_map() { $decode_map }
}

1;  # vim: set et sw=4 sts=4 :
