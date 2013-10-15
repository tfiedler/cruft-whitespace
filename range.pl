#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Long;

my $opts = GetOptions( "s" => \my $silent,
    "c" => \my $continuous,
    "limit=i" => \my $limit, );

my $cnt = 1;

while (1) {
    main();
    last unless ( $continuous or $limit );
    if ( defined $limit ) {
        last if ($cnt == $limit);
        $cnt++;
    }
}

sub main {
    my $initRange = getRand(100, 100000);

    my $low = 1;
    my $high = $initRange;
    my $rand=getRand($low, $high);
    my $seed=-1;
    my $count=1;

    while ( $seed != $rand )
    {
        $seed = getRand($low, $high);
        my $stat;
        if ( $seed < $rand ) {
            $stat='too low';
            $low=$seed+1;
        }
        elsif ( $seed > $rand ) {
            $stat='too high';
            $high=$seed-1;
        }
        elsif ( $seed = $rand ) {
            print "you guessed $rand in $count tries\n";
            if ( ! defined $silent ) { print "seed = $seed  rand = $rand \n"; }
            last;
        }
        else {
            print "bork\n";
            last;
        }

        if ( ! defined $silent ) { print "$seed is too $stat\n"; }
        $count++;
    }
}

sub getRand
{
    my $l = shift;
    my $h = shift;
    my @range=($l .. $h);
    return $range[rand(@range)];
}
