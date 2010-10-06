package IRISA::Interface::Arg;

use Moose;
use File::Spec;

has name => (
    is => 'ro',
    isa => 'Str',
    required => 1,
);

use overload '""' => sub { $_[0]->name };

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

sub encode {
    $_[0]->registry->encode_arg(@_);
}

sub decode {
    my $self = shift;
    $self->registry->decode_arg(@_);
}

1;  # vim: set et ts=4 sw=4 sts=4 :
