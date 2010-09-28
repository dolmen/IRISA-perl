use utf8;
use strict;
use warnings;

package IRISA::Interface;

use Carp qw/croak carp/;
use Scalar::Util;



my %arg_registry = ('' => {});
my %msg_registry;

my @types = qw/Int Bool Date String Buffer Real Char IntTable BufferTable ArgTable/;
my %types;
{
    foreach (@types) {
        my $t = "IRISA::Arg::$_";
        $types{$_} = $t;
        $types{uc($_)} = $t;
    }
}



sub name
{
    my ($pkg, $file, $line) = caller;
    ${$pkg.'::name'} = $_[0];
}


sub arg
{
    my ($class, $intf, $name, $type, $id) = @_;
    $type = $types{$type};
    my $info = [ $name, $id, $type ];
    $arg_registry{$intf} = { } unless exists $arg_registry{$intf};
    $arg_registry{$intf}{$name} = $info;
    $arg_registry{$id} = $info;  # TODO handle conflicts
    return;
}


sub arg_id
{
    my $id = shift;
    if (looks_like_number($id)) {
		return $id;
	}
    if (exists $arg_registry{''}{$id}) {
		return $arg_registry{''}{$id}->[1];
	}
    #if (defined $interface && exists $arg_registry{$interface}{$id}) {
    #   return $arg_registry{$interface}{$id}->[1];
	#}
    croak "unknown ";
}

sub arg_type
{
    my $id = shift;
    $arg_registry{$id}->[1];
}

sub arg_info
{
    my ($id, $value) = @_;
    $id = arg_id($id);
    croak "unknown arg '$id'!" unless exists $arg_registry{$id};
    tie my $data, $arg_registry{id}->[1], $value;
    $id = $arg_registry{$id}->[0];
    return wantarray ? ($id, $data) : [ $id, $data ];
}

sub message
{
    
}

sub args_encode
{
    my $class = shift;
    my %args = @_;
}

sub message_encode
{
    my $class = shift;
    my $message = shift;
    my %args = @_;
}

sub message_decode
{
}

1;
