package IRISA::Interface::Command;

use Moose;
require IRISA::Arg::Args;

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

has registry => (
    is => 'ro',
    isa => 'IRISA::Interface::Registry',
    required => 1,
    weak_ref => 1,
);

has long_name => (
    is => 'ro',
    init_arg => undef,
    lazy => 1,
    default => sub { my $self = shift; $self->interface . '::' . $self->name },
);

no Moose;
__PACKAGE__->meta->make_immutable;

sub encode
{
    my $self = shift;
    my $registry = $self->registry;
    my $intf = $self->interface;
    my $args;
    if (@_ == 1 && ref($_[0]) eq 'ARRAY') {
        $args = shift;
    } else {
        $args = \@_;
    }

    my @payload;
    my $i = 0;
    while ($i < $#{$args}) {
        my ($k, $v) = @{$args}[$i..$i+1];
        push @payload, $registry->arg($k, $intf)->encode($v);
        $i += 2;
    }
    my $payload = join('', @payload);
    pack('CCnA*', length($payload), 0x40, $self->id, $payload)
}

sub decode
{
    my $self = shift;
}


1; # vim: set et sw=4 sts=4 :
