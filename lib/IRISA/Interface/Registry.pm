package IRISA::Interface::Registry;

use strict;
use IRISA::Interface::Arg;
use IRISA::Interface::Command;

use Carp;
use Scalar::Util 'refaddr';


# The default registry used for auto registrations
my $default = __PACKAGE__->new('default');

# Attributes (in inside-out style)
my %name_of;
my %args_of;
my %commands_of;

sub new
{
    my $class = shift;

    # Object created in inside-out style (see Class::Std for explanation)
    # Our unique id for the object is stored in the scalar itself,
    # so we will just have to dereference $self to get the unique id.
    # Class::Std can not use this trick as it allows SCALARIFY
    my $self = \do{my $anon};
    # The object address is obtained by stringification of the reference
    # => SCALAR(0xcafebabe)
    # The id is a shorter byte string computed from the object address
    my $id = $$self = pack('h*', substr("$self", 9, -1));
    bless $self, $class;

    $name_of{$id} = @_ ? $_[0] : '';
    $args_of{$id} = {};
    $commands_of{$id} = {};
    $self
}

sub DESTROY
{
    my $self = shift; my $self_id = ${$self};
    delete $name_of{$self_id};
    delete $args_of{$self_id};
    delete $commands_of{$self_id};
}

sub default
{
    return $default;
}

sub name
{
    return $name_of{ ${ $_[0] } };
}

sub clear
{
    my $self = shift; my $self_id = $$self;
    $args_of{$self_id} = {};
    $commands_of{$self_id} = {};
    $self
}

sub add_arg
{
    my $self = shift; my $self_id = $$self;
    my ($intf, $name, $id, $type) = @_;
    my $arg = IRISA::Interface::Arg->new(
        name => $name,
        interface => $intf,
        id => $id,
        type => $type,
        registry => $self,
    );
    $args_of{$self_id}{$name} = $arg;
    $args_of{$self_id}{$id} = $arg;
    $self
}

sub arg
{
    my ($self, $id_or_name) = @_;
    my $args = $args_of{$$self};
    die "Unknown arg $id_or_name" unless exists $args->{$id_or_name};
    return $args->{$id_or_name}
}

sub add_command
{
    my $self = shift; my $self_id = $$self;
    my $intf = shift;
    my $name = shift;
    my $id = shift;
    my $command = IRISA::Interface::Command->new(
        name => $name,
        interface => $intf,
        id => $id,
        registry => $self,
    );
    $commands_of{$self_id}{$name} = $command;
    $commands_of{$self_id}{$id} = $command;
    $self
}

sub command
{
    my $self = shift;
    my $id_or_name = shift;
    my $commands = $commands_of{$$self};
    die "Unknown arg $id_or_name" unless exists $commands->{$id_or_name};
    $commands->{$id_or_name}
}

sub add
{
    my $self = shift;
    foreach my $intf (@_) {
        carp 'String argument expected' unless ref($intf) eq '';
        {
            no strict 'refs';
            defined(${$intf.'::name'}) or eval "require $intf";
        }
        die "$@" if $@;

        my (@args, @cmds);
        {
            no strict 'refs';
            @args = values %{$intf.'::args'};
            @cmds = values %{$intf.'::commands'};
        }

        foreach my $arg (@args) {
            $self->add_arg($intf, @$arg);
        }
        foreach my $cmd (@cmds) {
            $self->add_command($intf, @$cmd);
        }
    }
    $self
}

# Perl's module import
sub import
{
    my ($exporter, @imports) = @_;
    $default->add(@imports);
}



sub merge
{
}

# Extract
sub extract_id
{
    unpack('@1 n', $_[1]);
}

1;  # vim: set et sw=4 sts=4 :
