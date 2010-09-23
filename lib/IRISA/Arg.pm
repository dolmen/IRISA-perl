use strict;

package IRISA::Arg;

sub encode
{
    my ($id, $type, @value) = (@_);
    eval "require $type";
    my ($prefix, $data) = do {
        no strict 'refs';
        &{$type.'::encode'}(@value)
    };
    pack('Cn', $prefix, $id).$data;
}

# Returns ($id, $length, $value)
sub decode
{
    my ($d, $type) = (@_); # TODO extract the type from the Arg registry
    my ($prefix, $id, $data) = unpack('Cna*', $d);
    my $map = do {
        no strict 'refs';
        &{$type.'::decode_map'}()
    };
    if (! exists $map->{$prefix}) {
        die "Invalid data: prefix does not match expected type";
    }
    my $length;
    my $dec = $map->{$prefix};
    if (ref($dec) eq '') {
        return ($id, 0, $dec);
    } elsif (ref($dec) eq 'CODE') {
        return ($id, $dec->($data));
    }
}

1;  # vim: set et ts=4 sw=4 sts=4 :
