use utf8;
use strict;
use warnings;

package IRISA::Interface::DSL;

use IRISA::Interface;

use vars qw($VERSION $MAIN);
use Carp qw /croak carp/;

# Implicit use strict for importer
#$^H |= strict::bits(qw(refs subs vars));

our @EXPORT = qw/Class Message MessageReq Int/;
our @EXPORT_OK = qw/Class Message MessageReq Int/;


my @types = qw/Int Bool Date String Buffer Real Char IntTable BufferTable ArgTable/;
my %types;
{
    foreach (@types) {
        my $t = "IRISA::Arg::$_";
        $types{$_} = $t;
        $types{uc($_)} = $t;
    }
}

sub _Messages_import;

sub import
{
    my ($exporter, @imports) = @_;
    my ($pkg, $file, $line) = caller;

	# Strictures are forced
	strict->import;

	# Set parent class
	my @isa = qw(IRISA::Interface);
	{
		no strict 'refs';
		print "# ".__PACKAGE__."->import: $pkg\n";
		@{$pkg.'::@ISA'} = @isa;
		*{$pkg.'::import'} = \&_Messages_import;
		*{$pkg.'::AUTOLOAD'} = \&_autoload;

		${$pkg.'::name'} = $pkg;
		${$pkg.'::id'} = 0;
		${$pkg.'::last_arg_id'} = 0;
		${$pkg.'::last_msg_id'} = 0;
		%{$pkg.'::messages'} = ();
	}

    unless (@imports) { # Default import
		@imports = @EXPORT;
    } else {
		# Check imports
		my %EXPORT_OK = map { ($_ => 1) } @EXPORT_OK;
		foreach (@imports) {
			unless (exists $EXPORT_OK{$_}) {
				die qq{"$_" is not exported by the $exporter module at $file line $line\n};
			}
		}
    }

	{
		no strict 'refs';
		foreach my $sym (@imports) {
			print "# import $sym\n";
			*{$pkg.'::'.$sym} = \&{$exporter.'::'.$sym};
		}
	}
}


sub _caller
{
	my @caller = caller(0);
	my $call_level = 1;
	@caller = caller(++$call_level) while $caller[0] eq __PACKAGE__;
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
		my $value = shift;
		no strict 'refs';
		${$var} = $value if !defined(${$var}) || ${$var} <= $value;
		$value;
	} else {
		no strict 'refs';
		${$var};
	}
}

sub _base_id
{
	my $pkg = shift;
	_pkg_scalar($pkg.'::id', @_);
}

sub _last_arg_id
{
	my $pkg = shift;
	_pkg_scalar($pkg.'::last_arg_id', @_);
}

sub _last_msg_id
{
	my $pkg = shift;
	_pkg_scalar($pkg.'::last_msg_id', @_);
}


sub Class(*$)
{
	my $pkg = _caller;
	my ($name, $id) = @_;
	no strict 'refs';
	print "# Class $pkg $name $id\n";
	${$pkg.'::name'} = $name;
	_base_id($pkg, $id);
	_last_arg_id($pkg, $id);
	_last_msg_id($pkg, $id);
}

sub Int(*@)
{
	my $pkg = _caller;
	my $name = shift;
	my $id = @_ ? (_base_id($pkg)+$_[0]) : (1+_last_arg_id($pkg));
	IRISA::Interface->arg($pkg, $name, 'Int', $id);
	print "$name => $id\n";
	_last_arg_id($pkg, $id);
}





sub _message
{
	my $pkg = _caller;
	my $name = shift;
	my $id = @_ ? (_base_id($pkg)+$_[0]) : (1+_last_msg_id($pkg));
	_last_msg_id($pkg, $id);
	my $var = $pkg.'::messages';
	IRISA::Interface->message($pkg, $name, $id);
	no strict 'refs';
	${$var}->{$name} = [ @_ ];
	return ;
}

sub MessageReq(*@)
{
	my $name = shift;
	_message($name, @_);
}

sub MessageRsp(*@)
{
	my $name = shift;
	_message($name.'Cmplt', @_);
}

sub Message(*@)
{
	my $name = shift;
	my @args = @_;
	print "Message $name @args\n";
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
	my $pkg = shift;
	#my $sub = 
	print "# ${pkg}->import\n";
}

# AUTOLOAD sub that is exported to the caller
# to enable an encode/decode sub for each message
sub _autoload
{
	no strict 'vars';
	my $sub = $AUTOLOAD;
	my ($pkg, $msg) = $sub =~ m/^.*::[^:]*$/;
	print "# ${pkg}->AUTOLOAD\n";
	*$sub = \&_message_method;
	goto &$sub;
}



1; # vim:set ts=4 sw=4 sts=4:
