use utf8;
use strict;
use warnings;

package IRISA::Interface;

use Carp qw/croak carp/;

my %arg_registry;
my %msg_registry;

sub name
{
    my ($pkg, $file, $line) = caller;
	*{$pkg.'::name'} = $_[0];
}


sub arg
{
    my ($pkg, $file, $line) = caller;
	my $int = *{$pkg.'::name'}; # Interface name
    my ($class, $name, $type, $id) = @_;
    $type = $types{$type};
    my $info = [ $name, $id, $type ];
    $arg_registry{$int}{$name} = $info;
	$arg_registry{$id} = $info;
    return unless $int;
    $arg_registry{$int} = { } unless exists $arg_registry{$int};
    $arg_registry{$int}{$name} = $info;
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


1;
