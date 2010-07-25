use utf8;
use strict;
use warnings;

package IRISA::Interface::DSL;

use Irisa::Interface;

use Carp qw /croak carp/;
use vars qw($VERSION $MAIN);

# Implicit use strict for importer
$^H |= strict::bits(qw(refs subs vars));

our @EXPORT = qw/name message Int/;
our @EXPORT_OK = qw/Name Message Int/;


my @types = qw/Int Bool Date String Buffer Real Char IntTable BufferTable ArgTable/;
my %types;
{
    foreach (@types) {
        my $t = "IRISA::Arg::$_";
        $types{$_} = $t;
        $types{uc($_)} = $t;
    }
}



sub import
{
    my ($exporter, @imports) = @_;
    my ($pkg, $file, $line) = caller;

	# Set parent class
	my @isa = (__PACKAGE__);
	{
		no strict 'refs';
		*{$pkg.'::name'} = $pkg;
		*{$pkg.'::last_id'} = 0; # FIXME
		*{$pkg.'::@ISA'} = \@isa;
		*{$pkg.'::import'} = \&_import;
		*{$pkg.'::AUTOLOAD'} = \&_autoload;
	}

    unless (@imports) { # Default import
		@imports = @EXPORT;
    } else {
		# Check imports
		my %EXPORT_OK = map { ($_ => 1) } @EXPORT_OK;
		foreach (@imports) {
			unless (exists $EXPORT_OK{$_}) {
				die qq{"$_" is not exported by the $exporter module at $file line$line\n};
			}
		}
    }

	{
		no strict 'refs';
		foreach my $sym (@imports) {
			*{$pkg.'::'.$sym} = \&{$exporter.'::'.$sym};
		}
	}
}


sub _caller
{
	my @caller = caller(0);
	my $call_level = 1;
	@caller = caller($call_level) while $caller[0] eq __PACKAGE__;
	if (wantarray) {
		return @caller;
	} else {
		return $caller[0];
	}
}


sub _pkg_scalar
{
	my $var = shift;
	if (@_) {
		my $id = shift;
		no strict 'vars';
		*{$var} = $id if *{$var} <= $id;
	} else {
		*{$var};
	}
}

sub _last_arg_id
{
	my $pkg = shift;
	_pkg_scalar($pkg.'::last_arg_id', @_);
}


sub Int
{
	my $caller
	my $name = shift;
	my $id = (@_ ? $_[0] : _last_arg_id($pkg)+1);
	IRISA::Interface->arg($pkg, $name, 'Int', $id);
	_last_arg_id($pkg, $id);
}





sub _message
{
	my ($name, @args) = @_;
	my $id = $args[0];
	my $pkg = _caller;
	my $var = $pkg.'::messages';
	my $x;
	if (defined *{$var}) {
		$x = *{$var};
	} else {
		$x = *{$var} = {};
	}
	$x->{$name} = [ @args ];
	$msg_registry{$id} = "$pkg::$name";
	return ;
}

sub message_req
{
	_message(@_);
}

sub message_rsp
{
	my ($name, @args);
	_message($name.'Cmplt', @args);
}

sub Message
{
	my ($name, @args);
	_message($name, @args);
	_message($name.'Cmplt', @args);
}

sub _message_encode
{
	"Message @_";
}

sub _message_decode
{
	return {};
}

sub _message_method
{
	# my ($pkg, $message, @args) = @_;
	if (@_ == 3) {
		goto &_message_decode;
	} else {
		goto &_message_encode;
	}
}


# import() of the interface package
sub _Messages_import
{
	my $sub = 
}

# AUTOLOAD sub that is exported to the caller
# to enable an encode/decode sub for each message
sub _autoload
{
	no strict 'vars';
	my $sub = $AUTOLOAD;
	my ($pkg, $msg) = $sub =~ m/^.*::[^:]*$/;
	*$sub = \&_message_method;
	goto &$sub;
}



1; # vim:set ts=4 sw=4 sts=4:
