package IRISA::Interface::Command;

use Moose;

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
    required => 0,
    weak_ref => 1,
);

no Moose;
__PACKAGE__->meta->make_immutable;

1;
