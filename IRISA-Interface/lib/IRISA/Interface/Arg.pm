package IRISA::Interface::Arg;

use Moose;
use File::Spec;

has name => (
    is => 'ro',
    isa => 'Str',
    required => 1,
);

has interface => (
    is => 'ro',
    isa => 'Str',
    required => 0,
);

has id => (
    is => 'ro',
    isa => 'Int',
    required => 1,
);

has type => (
    is => 'ro',
    isa => 'Str',
    required => 1,
);

has registry => (
    is => 'ro',
    isa => 'IRISA::Interface::Registry',
    required => 0,
    weak_ref => 1,
);

no Moose;
__PACKAGE__->meta->make_immutable;

sub encode
{
    my ($self, @value) = (@_);
    my ($type, $id) = ($self->type, $self->id);
    _load_type($type);
    my ($prefix, $data) = $self->type->encode(@value);
    pack('Cna*', $prefix, $id, $data);
}

sub _load_type
{
    my $type = shift;
    no strict 'refs';
    defined(*{$type.'::encode'}) or eval "require $type";
}

# Params: ($raw_data)
# Returns: ($id, $length, $value)
sub decode
{
    my ($self, $d) = @_;
    my ($prefix, $id, $data) = unpack('Cna*', $d);
    _load_type($self->type);
    my $map = $self->type->decode_map();
    if (! exists $map->{$prefix}) {
        die "Invalid data: prefix does not match expected type";
    }
    my $length;
    my $dec = $map->{$prefix};
    if (ref($dec) eq '') {
        return (3, $dec);
    } elsif (ref($dec) eq 'CODE') {
        my @ret = $dec->($data);
        (3+$ret[0], @ret[1..$#ret])
    } else {
        die($self->type . ": Unexpected value in decode_map for prefix $prefix");
    }
}

sub extract_id
{
    unpack('@1 n', $_[1])
}

1;  # vim: set et ts=4 sw=4 sts=4 :
