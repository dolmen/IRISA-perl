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
    foreach my $arg (@{$args}) {
        my (undef, $data) = IRISA::Arg::Args->encode($arg, $registry);
        push @payload, $data;
    }

    (0x10, pack('n/(N/a*)*', @payload));
}

{
    my $decode_map = {
        0x10 => sub($$) {
            my ($d, $registry) = @_;
            my $arg_decode = IRISA::Arg::Args->decode_map()->{15};
            my @payload = unpack('n/(N/a*)*', $d);
            my $len = 2;
            @payload = map {
                $len += 4 + length($_);
                print "# ", unpack('H*', $_), "\n";
                my (undef, $arg) = $arg_decode->($_, $registry);
                $arg
            } @payload;

=begin comment

            my $count = unpack('n', $d);
            my $len = 2;
            my @payload;
            while ($count--) {
                my $len2 = unpack('N', substr($d, $len, 4));
                $len += 4;
                my (undef, $arg) = $arg_decode->(substr($d, $len, $len2), $registry);
                push @payload, $arg;
                $len += $len2;
            }

=end comment

=cut

            ($len, \@payload);
        }
    };

    sub decode_map { $decode_map }
}

1;  # vim: set et sw=4 sts=4 :
