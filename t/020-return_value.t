use strict;
use warnings;
use Test::More tests => 27;

BEGIN {
    use Data::Printer::Config;
    no warnings 'redefine';
    *Data::Printer::Config::load_rc_file = sub { {} };
};

use Data::Printer colored => 0;

eval { require Capture::Tiny; 1; }
    or plan skip_all => 'Capture::Tiny not found';

my $string = 'All your base are belong to us.';
my $return = 1;
my ($stdout, $stderr) = Capture::Tiny::capture( sub {
    $return = p $string, return_value => 'void';
});

is $stdout, '', 'STDOUT should be empty after p() (scalar, scalar)';
is $stderr, qq("$string"\n), 'pass-through STDERR (scalar, scalar)';
is $return, undef, 'pass-through return (scalar scalar)';

##############
### hashes ###
##############
my %foo = ( answer => 42, question => 24 );

my $expected = <<'EOT';
{
    answer     42,
    question   24
}
EOT

my (%return_list, $return_scalar);

($stdout, $stderr) = Capture::Tiny::capture( sub {
    %return_list = p %foo;
});

is $stdout, '', 'STDOUT should be empty after p() (hash, list)';
is $stderr, $expected, 'pass-through STDERR (hash, list)';

is_deeply \%return_list, \%foo, 'pass-through return (hash list)';

($stdout, $stderr) = Capture::Tiny::capture( sub {
    $return_scalar = p %foo;
});

is $stdout, '', 'STDOUT should be empty after p() (hash, scalar)';
is $stderr, $expected, 'pass-through STDERR (hash, scalar)';

is $return_scalar, scalar %foo, 'pass-through return (hash scalar)';


##############
### arrays ###
##############

my @return_list;
my @foo = qw(foo bar);
$expected = <<'EOT';
[
    [0] "foo",
    [1] "bar"
]
EOT

($stdout, $stderr) = Capture::Tiny::capture( sub {
    @return_list = p @foo;
});

is $stdout, '', 'STDOUT should be empty after p() (array, list)';
is $stderr, $expected, 'pass-through STDERR (array, list)';

is_deeply \@return_list, \@foo, 'pass-through return (array list)';

($stdout, $stderr) = Capture::Tiny::capture( sub {
    $return_scalar = p @foo;
});

is $stdout, '', 'STDOUT should be empty after p() (array, scalar)';
is $stderr, $expected, 'pass-through STDERR (array, scalar)';

is $return_scalar, 2, 'pass-through return (array scalar)';


##############
### scalar ###
##############

my $foo = 'how much wood would a woodchuck chuck if a woodchuck could chuck wood?';
$expected = qq{"$foo"$/};

($stdout, $stderr) = Capture::Tiny::capture( sub {
    @return_list = p $foo;
});

is $stdout, '', 'STDOUT should be empty after p() (scalar, list)';
is $stderr, $expected, 'pass-through STDERR (scalar, list)';

is_deeply \@return_list, [ $foo ], 'pass-through return (scalar list)';

($stdout, $stderr) = Capture::Tiny::capture( sub {
    $return_scalar = p $foo;
});

is $stdout, '', 'STDOUT should be empty after p() (scalar, scalar)';
is $stderr, $expected, 'pass-through STDERR (scalar, scalar)';

is $return_scalar, $foo, 'pass-through return (scalar scalar)';


#######################
### method chaining ###
#######################

package Foo;
sub new  { bless {}, shift }
sub bar  { $_[0]->{meep}++; $_[0] }
sub baz  { $_[0]->{meep}++; $_[0] }
sub biff { $_[0]->{meep}++; $_[0] }

package main;

$expected =<<'EOT';
Foo  {
    public methods (4): bar, baz, biff, new
    private methods (0)
    internals: {
        meep   2
    }
}
EOT

$foo = Foo->new;

($stdout, $stderr) = Capture::Tiny::capture( sub {
    (Data::Printer::p $foo->bar->baz)->biff;
});

is $stdout, '', 'STDOUT should be empty after p() (object, direct)';
is $stderr, $expected, 'pass-through STDERR (object, direct)';

is $foo->{meep}, 3, 'pass-through return (object, direct)';

# once again, but this time in indirect object notation

$foo = Foo->new;

($stdout, $stderr) = Capture::Tiny::capture( sub {
    $foo->bar->baz->Data::Printer::p->biff;
});

is $stdout, '', 'STDOUT should be empty after p() (object, indirect)';
is $stderr, $expected, 'pass-through STDERR (object, indirect)';

is $foo->{meep}, 3, 'pass-through return (object, indirect)';