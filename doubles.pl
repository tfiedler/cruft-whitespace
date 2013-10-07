#!/usr/bin/perl
# doubles.pl
# Look for repeats in a series. Output is Series #, postion repeat was seen,
# and the repeated object.
use warnings;
use strict;
use Getopt::Long;

# Iterations allow you to put limits on a series
my $opts = GetOptions (
    "iterations=i" => \ my $iterations,
);

my %thingsIknow;

$|++;
my $count = 1;
my $major_iters = 1;
while (<STDIN>)
{
    chomp;

    if ( $thingsIknow{$_}++ ) {
        # quote stuff, if you need to
        my $q = ( $_ =~ /\s+/ ) ? qq|"| : '';
        print "${major_iters}:${count}:${q}$_${q}\n";
        #unless ( $count == defined $iterations ) { print "${major_iters}:${count}:${q}$_${q}\n"; }
        $count = 1;
        $major_iters++;
        %thingsIknow = ();
    }
    elsif ( ( defined $iterations > 0 && $count >= $iterations ) ) {
        $count = 1;
        $major_iters++;
    }

    $count++;

}

exit 0
