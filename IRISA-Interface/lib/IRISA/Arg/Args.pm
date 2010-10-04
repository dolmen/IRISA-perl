use strict;

package IRISA::Arg::Args;

sub encode
{
    my $self = shift;
    my $args = shift;  # ARRAY
    my $registry = shift;
    my $type = ref $args;
    die "Invalid varg data, ARRAY ref expected" unless $type eq 'ARRAY' || $type eq 'HASH';
    # Convert HASH to ARRAY if necessary
    $args = [ @$args ] if $type eq 'HASH';
    # TODO query the Args registry
    die "Invalid varg data, even elements expected" unless ($#{$args}+2) % 1 == 0;

    my @payload;
    my $i = 0;
    while ($i < $#{$args}) {
        my ($k, $v) = @{$args}[$i..$i+1];
        push @payload, $registry->encode_arg($registry->arg($k, @_), $v);
        $i += 2;
    }

    # tag not verified
    (0x0f, join('', @payload));
}

{
    my %decode_map = {
        0x10 => sub($$) {
            my ($d, $registry) = @_;
            my $len = length($d);
            my $offset = 0;
            my @payload;
            while ($offset < $len) {
                my $arg = $registry->arg(unpack('n', substr($d, $offset+1, 2)));
                my ($sz, $value) = $registry->decode_arg($arg, substr($d, $offset+3));
                push @payload, $arg, $value;
                $offset += $sz;
            }
            ($len, \@payload);
        }
    };

    sub decode_map
    {
    }
}

1;  # vim: set et sw=4 sts=4 :
