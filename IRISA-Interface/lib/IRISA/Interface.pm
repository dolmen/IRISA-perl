use utf8;
use strict;
use warnings;

package IRISA::Interface;

use Carp qw/croak carp/;
use Scalar::Util;



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
    my ($class) = shift;
    no strict 'refs';
    ${$class.'::name'}
}


1;
