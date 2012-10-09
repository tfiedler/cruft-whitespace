#!/usr/bin/perl -w
use strict;
my (@avgs, $x);
my $seed;
my $score;
for ($x=0; $x<1000; $x++)
{
    my $low = 1;
    my $high = 1000;
    my @range=($low .. $high);
    my $rand=$range[rand(@range)];     # <---
    my $seed=int(rand($high));
    my $count=1;
    while ( $seed != $rand )
    {
        $count++;
        @range=($low .. $high);
        $seed = $range[rand(@range)];   # <---
        if ( $seed < $rand )
        {
            $low=$seed+1;
        }
        elsif ( $seed > $rand )
        {
            $high=$seed-1;
        }
    }
    push (@avgs, $count);
}
print "\n";
print "x = $x\n";
print "scores = [@avgs]\n" ;
my $total=0;
for my $i (@avgs)
{
    $total+=$i;
}
print "total = $total\n";
printf "Avg %f over %d games\n", $total/$x, $x;
