#!/usr/bin/perl
# doubles.pl
# Look for repeats in a series. Output is Series #, postion repeat was seen,
# and the repeated object.
use warnings;
use strict;
use Getopt::Long;

# Iterations allow you to put limits on a series
my $opts = GetOptions (
    "series=i" => \ my $series,
);

my %thingsIknow;

$|++;
my $count = 0;
my $iter = 1;
while (<STDIN>)
{
    chomp;
    $count++;

    if ( $thingsIknow{$_}++ ) {
        # quote stuff, if you need to
        my $q = ( $_ =~ /\s+/ ) ? qq|"| : '';
        print "${iter}:${count}:${q}$_${q}\n";
        $count = 0;
        $iter++;
        %thingsIknow = ();
    }
    elsif ( defined $series > 0 and ( $count >= $series ) ) {
        $count = 0;
        $iter++;
        %thingsIknow = ();
    }

}

exit 0;
