use strict;

package IRISA::Arg::ArgTable;

sub encode
{
    my $self = shift;
    my $args = shift;  # ARRAY
    my $registry = shift;
    die "Invalid varg data, ARRAY ref expected" unless ref($args) eq 'ARRAY';
    # TODO query the Args registry

    my @payload;
    my $len = 0;
    foreach my $arg (@{$args}) {
        my (undef, $data) = IRISA::Arg::Args->encode($arg, $registry);
        my $len = length $data;
        push @payload, $len, $data;
    }

    (0x10, pack('n(N/A*)*', 0+@{$args}, @payload));
}

{
    my $decode_map = {
        0x10 => sub($$) {
            my ($d, $registry) = @_;
            my $count = unpack('n', $d);
            my $arg_decode = IRISA::Arg::Args->decode_map()->{15};
            my $len = 2;
            my @payload;
            while ($count--) {
                my $len2 = unpack('N', substr($d, $len, 4));
                $len += 4;
                my (undef, $arg) = $arg_decode->(substr($d, $len, $len2), $registry);
                push @payload, $arg;
                $len += $len2;
            }
            ($len, \@payload);
        }
    };

    sub decode_map { $decode_map }
}

1;  # vim: set et sw=4 sts=4 :
