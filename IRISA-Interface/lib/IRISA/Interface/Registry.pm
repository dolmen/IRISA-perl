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
    my ($self, $intf, $name, $id, $type) = @_;
    my $arg = IRISA::Interface::Arg->new(
        name => $name,
        interface => $intf,
        id => $id,
        type => $type,
        registry => $self,
    );
    my $args = $args_of{$$self};
    $args->{"${intf}::$name"} = $arg;
    $args->{$id} = $arg;
    # Try to add the short name, only if there is no conflict
    if (exists $args->{$name}) {
        # Conflict: short name is disabled
        delete $args->{$name};
    } else {
        # Add the short name until a conflict occur
        $args->{$name} = $arg;
    }
    $self
}

sub add_command
{
    my ($self, $intf, $name, $id) = @_;
    my $cmd = IRISA::Interface::Command->new(
        name => $name,
        interface => $intf,
        id => $id,
        registry => $self,
    );
    my $commands = $commands_of{$$self};
    $commands->{"${intf}::$name"} = $cmd;
    warn "${intf}::$name conflicts with ".$commands->{$id}->long_name if exists $commands->{$id};
    $commands->{$id} = $cmd;
    # Try to add the short name, only if there is no conflict
    if (exists $commands->{$name}) {
        # Conflict: short name is disabled
        delete $commands->{$name};
    } else {
        # Add the short name until a conflict occur
        $commands->{$name} = $cmd;
    }
    # Short interface name for standard interfaces
    if ($intf =~ /^IRISA::Interface::([a-z]{3})$/) {
        $commands->{"$1::$name"} = $cmd;
    }
    $self
}

sub arg
{
    my $self = shift;
    my $id_or_name = shift;
    my $args = $args_of{$$self};

    if (ref $id_or_name) {
        return $id_or_name if exists $args->{$id_or_name->id};
        die "Invalid object arg $id_or_name\n"
    }

    return $args->{$id_or_name} if exists $args->{$id_or_name};

    if (@_ && $id_or_name =~ /[A-za-z]\w+/) {
        $id_or_name = $_[0] . '::' . $id_or_name;
        return $args->{$id_or_name} if exists $args->{$id_or_name};
    }
    die sprintf("Unknown arg 0x%x\n", $id_or_name) if $id_or_name =~ /[1-9]/;
    die "Unknown arg $id_or_name\n"
}

sub command
{
    my $self = shift;
    my $id_or_name = shift;
    my $commands = $commands_of{$$self};

    if (ref $id_or_name) {
        return $id_or_name if exists $commands->{$id_or_name->id};
        die "Invalid object command $id_or_name\n"
    }

    return $commands->{$id_or_name} if exists $commands->{$id_or_name};

    if (@_ && $id_or_name =~ /[A-za-z]\w+/) {
        $id_or_name = $_[0] . '::' . $id_or_name;
        return $commands->{$id_or_name} if exists $commands->{$id_or_name};
    }
    die sprintf("Unknown command 0x%x\n", $id_or_name) if $id_or_name =~ /[1-9]/;
    die "Unknown command $id_or_name\n"
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


sub _load_type
{
    my $type = shift;
    no strict 'refs';
    print "# $type\n";
    return if defined *{$type.'::encode'};
    local $@;
    eval "require $type";
    die $@ if $@;
}


sub encode_arg
{
    my ($registry, $arg, $value) = @_;
    my ($type, $id) = ("IRISA::Arg::".$arg->type, $arg->id);
    _load_type($type);
    my ($prefix, $data) = $type->encode($value, $registry);
    pack('Cna*', $prefix, $id, $data);
}

# Params: ($raw_data)
# Returns: ($id, $length, $value)
sub decode_arg
{
    my ($registry, $data, @context) = @_;
    my $len = length($data);
    die "Invalid data: expected length > 3" if $len < 3;
    my ($prefix, $id) = unpack('Cn', $data);
    # TODO handle unknown arg
    my $arg = $registry->arg($id, @context);
    my $type = "IRISA::Arg::".$arg->type;
    _load_type($type);
    my $map = $type->decode_map();
    if (! exists $map->{$prefix}) {
        print "# ", unpack('H*', $data), ' ', $data, "\n";
        die sprintf('Invalid data: prefix 0x%x does not match type %s for %s', $prefix, $type, $arg->name);
    }
    my $length;
    my $dec = $map->{$prefix};
    if (ref($dec) eq '') {
        return (3, $arg, $dec);
    } elsif (ref($dec) eq 'CODE') {
        my @ret = $dec->(substr($data, 3), $registry);
        (3+$ret[0], $arg, @ret[1..$#ret])
    } else {
        die("$type: Unexpected value in decode_map for prefix $prefix");
    }
}




sub encode_message
{
    my $self = shift;
    my $cmd = shift;
    my $registry = $self;
    $cmd = $registry->command($cmd) if ref($cmd) eq '';
    my $intf = $cmd->interface;
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
        push @payload, $registry->encode_arg($registry->arg($k, $intf), $v);
        $i += 2;
    }
    my $payload = join('', @payload);
    pack('CCnA*', length($payload), 0x40, $cmd->id, $payload)
}


sub decode_message
{
    my $self = shift;
    my $data = shift;
    my $registry = $self;

    local $@;
    my $len = length $data;
    die "Invalid message length (< 4)" if $len < 4;
    my ($l, $sig, $cmd) = unpack('CCn', $data);
    die sprintf("Inconsistent byte 0 in message (got $l, expected %d)\n", $len-4) if $l != $len-4;
    warn sprintf("Invalid signature at byte 1 (got 0x%x, expected 0x40)\n", $sig) if $sig != 0x40;

    eval { $cmd = $registry->command($cmd) };
    warn "$@" if $@;

    my $offset = 4;
    my @args;
    while ($offset+3 <= $len) {
        #my $arg = $registry->arg(unpack('@1n', substr($data, $offset)));
        my ($sz, $arg, $value) = $registry->decode_arg(substr($data, $offset), $cmd);
        push @args, $arg, $value;
        $offset += $sz;
    }

    ($cmd, @args);
}


1;  # vim: set et sw=4 sts=4 :
