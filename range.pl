#!/usr/bin/perl
use strict;
use warnings;

my $low = 1;
my $high = 100;
my @range=($low .. $high);
my $rand=$range[rand(@range)];     # <---
my $seed=$range[rand(@range)];
my $count=1;
my $lastguess;
while ( $seed != $rand )
{
    undef @range if ( $ count > 1);
    @range=($low .. $high);
    $lastguess = $seed;
    $seed = $range[rand(@range)];   # <---
    if ( $seed < $rand )
    {
        print "You're too low - $seed (last guess = $lastguess)\n";
        $low=$seed+1;
        $count++;
    }
    elsif ( $seed > $rand )
    {
        print "you're too high - $seed (last guess = $lastguess)\n";
        $high=$seed-1;
        $count++;
    }
}

print "you got it in $count tries\n";
print "seed = $seed  rand = $rand ( last guess = $lastguess )\n";

print "\nPress enter to quit\n";
exit if <STDIN>;

