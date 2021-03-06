use utf8;
use strict;
use warnings;

package IRISA::Interface::DSL;

use IRISA::Interface;

use vars qw($VERSION $MAIN);
use Carp qw /croak carp/;

# Implicit use strict for importer
#$^H |= strict::bits(qw(refs subs vars));



our @types = qw/Int Bool Date String Buffer Real Char IntTable BufferTable ArgTable/;
my %types = map { my $t = "IRISA::Arg::$_"; ( $_ => $t, uc($_) => $t) } @types;

our @EXPORT = (qw/Class Command/, @types);
our @EXPORT_OK = (qw/Class Command/, @types);

sub _Interface_import;

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
		@{$pkg.'::ISA'} = @isa;
		*{$pkg.'::import'} = \&_Interface_import;
		*{$pkg.'::AUTOLOAD'} = \&_Interface_AUTOLOAD;

		${$pkg.'::name'} = $pkg;
		${$pkg.'::id'} = 0;
		${$pkg.'::last_arg_id'} = 0;
		${$pkg.'::last_msg_id'} = 0;
		%{$pkg.'::args'} = ();
		%{$pkg.'::commands'} = ();
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
			if (exists $types{$sym}) {
				print "# import type $sym\n";
				my $type = $sym;
				# Creates a closure
				*{$pkg.'::'.$sym} = sub(*@) {
					__PACKAGE__->_arg($type, @_);
				};
			} else {
				print "# import $sym\n";
				*{$pkg.'::'.$sym} = \&{$exporter.'::'.$sym};
			}
		}
	}
}


sub _caller
{
	my $pkg = caller(0);
	my $call_level = 0;
	while ($pkg eq __PACKAGE__) {
		#print "_caller: $pkg ".__PACKAGE__. "\n";
		$pkg = caller(++$call_level);
	}
	#print "_caller: $pkg ".__PACKAGE__. "\n";
	if (wantarray) {
		return caller($call_level);
	} else {
		return $pkg;
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

sub _arg
{
	my $pkg = _caller;
	my $class = shift;
	my $type = shift;
	my $name = shift;
	my $id = @_ ? (_base_id($pkg)+$_[0]) : (_last_arg_id($pkg));
	_last_arg_id($pkg, 1+$id);
	print "# $type ${pkg}::$name => $id\n";
	my $info = [ $name, $id, $type ];
	{
		no strict 'refs';
		${$pkg.'::args'}{$name} = $info;
	}
}





sub _command
{
	my $pkg = _caller;
	my $name = shift;
	my $id = @_ ? (_base_id($pkg)+$_[0]) : (_last_msg_id($pkg));
	_last_msg_id($pkg, $id+1);
	print "# Command ${pkg}::$name => $id\n";
	{
		no strict 'refs';
		${$pkg.'::commands'}{$name} = [ $name, $id ];
	}
}

sub CommandReq(*@)
{
	my $name = shift;
	_command($name, @_);
}

sub CommandCmplt(*@)
{
	my $name = shift;
	_command($name.'Cmplt', @_);
}

sub Command(*@)
{
	my $name = shift;
	my @args = @_;
	_command($name, @args);
	#_command($name.'Cmplt', @args);
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
sub _Interface_import
{
	my $pkg = shift;
	print "# ${pkg}->import\n";
}

# AUTOLOAD sub that is exported to the caller
# to enable an encode/decode sub for each message
sub _Interface_AUTOLOAD
{
	no strict 'vars';
	my $sub = $AUTOLOAD;
	my ($pkg, $msg) = $sub =~ m/^(.*)::([^:]*)$/;
	print "# ${pkg}->AUTOLOAD\n";
	*$sub = \&_message_method;
	goto &$sub;
}

1;

=head1 NAME

IRISA::Interface::DSL - A DSL to ease IRISA interfaces definitions

=head1 SYNOPSIS

    package MyInterface;
    
    Class ITF => 0x8300;
    
    Int RetCode;
    String Param1 => 1;
    
    Command
    

The semantics of the keywords is the IRISA framework semantic.

Commands and Args have separate namespaces, so you can use the same name
for a Command and an Arg.

=head1 SEE ALSO

=over 4

=item *

L<irisa-h2pl>: a command-line tool that will parse a C include file and generate
a Perl module that use IRISA::Interface::DSL.

=item *

L<IRISA::Interface::Registry>: an interface is used in the context of a Registry.

=head1 AUTHOR

Olivier MenguE<eacute> C<<<dolmen@cpan.org>>>

=cut
# vim:set ts=4 sw=4 sts=4:
