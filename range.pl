#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Long;
$|++;
my $opts = GetOptions( "s" => \my $silent,
    "c" => \my $continuous,
    "limit=i" => \my $limit, );

my $cnt = 1;

my $guessTracker = 0;

while (1) {
    my $guesses = main();
    last unless ( $continuous or $limit );
    if ( defined $limit ) {
        $guessTracker = $guessTracker + $guesses;
        if ($cnt == $limit) {
            print "Avgerage guess was ". $guessTracker / $limit . "\n";
            last;
        }
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
            if ( ! defined $silent ) {
                print "seed = $seed  rand = $rand \n";
            }
            return $count;
        }
        else {
            print "bork\n";
            return -1;
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

# Some fun ways to run this
# while (:); do ./range.pl -s -l 10; done
# while (:); do ./range.pl -c; done # but only for consuming resources...
# ./range -s -l 100000
