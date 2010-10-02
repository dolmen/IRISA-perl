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

has id_str => (
    is => 'ro',
    init_arg => undef,
    lazy => 1,
    default => sub { pack('n', $_[0]->id) }
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
    $self->registry->encode_command($self, @_);
}

1; # vim: set et sw=4 sts=4 :
