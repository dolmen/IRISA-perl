use strict;

package IRISA::Arg::Args;

sub encode($)
{
    my $args = shift;  # ARRAY
    my $type = ref $args;
    die "Invalid data, ARRAY ref expected" unless $type eq 'ARRAY' || $type eq 'HASH';
    # Convert HASH to ARRAY if necessary
    $args = [ @$args ] if $type eq 'HASH';
    # TODO query the Args registry
}

sub decode_map
{
}

1;
