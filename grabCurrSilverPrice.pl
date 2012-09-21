#!/usr/bin/perl

use strict;
use warnings;

use LWP::Simple;
my $content = get("http://www.coinflation.com/silver_coin_values.html");
die "Couldn't get it!" unless defined $content;

my $cf='.0321507466';
my %coins;

$coins{'franklin half dollar'}{'weight'} = "12.5"; # grams
$coins{'franklin half dollar'}{'ps'} = ".90"; 
$coins{'franklin half dollar'}{'quantity'} = "0"; 
$coins{'morgan silver dollar'}{'weight'} = "26.73"; # grams
$coins{'morgan silver dollar'}{'ps'} = ".90"; 
$coins{'morgan silver dollar'}{'quantity'} = 1;
$coins{'peace dollar'}{'weight'} = "26.73"; # grams
$coins{'peace dollar'}{'ps'} = ".90"; 
$coins{'peace dollar'}{'quantity'} = 1;
$coins{'american silver eagle'}{'weight'} = "31.10"; # grams
$coins{'american silver eagle'}{'ps'} = ".999"; 
$coins{'american silver eagle'}{'quantity'} = 3;
$coins{'washington quarter'}{'weight'} = "6.25"; # grams
$coins{'washington quarter'}{'ps'} = ".90"; 
$coins{'washington quarter'}{'quantity'} = 2;
$coins{'liberty half dollar'}{'weight'} = '12.5'; # grams
$coins{'liberty half dollar'}{'ps'} = ".90";
$coins{'liberty half dollar'}{'quantity'} = 1;
$coins{'queens diamond jubilee'}{'quantity'} = 1;
$coins{'queens diamond jubilee'}{'ps'} = ".999";
$coins{'queens diamond jubilee'}{'weight'} = "7.96";

my $valuation = 0;

#if ( $content =~ /Coin value calculations use the \d+:\d+ (A|P)M EDT silver price for (\w+ \d+, \d\d\d\d): <br><b>Silver<\/b> \$(\d+.\d+)\/oz/ )
if ( $content =~ /silver price for (\w+ \d+, \d\d\d\d): <br><b>Silver<\/b> \$(\d+.\d+)\/oz/ )
{
	my $Silver = $2;
	my $date   = $1;
         
        my $topline = sprintf("%-25s %24s", "Silver: \$${Silver}", $date);
        print "\n$topline\n"; 
	#print "Silver: \$${Silver}\t$date\n";
        print "=" x 50 . "\n";
        my $header = sprintf("%-22s %-4s%8s %8s", "Coin", "Quan", "Value", "Total");
        print "$header\n";
        print "=" x 50 . "\n";
        for my $type ( keys %coins )
        {
		my $value = sprintf("%.4f", $coins{$type}{'weight'} * $cf * $Silver * $coins{$type}{'ps'});
                my $worth = sprintf("%.2f", $coins{$type}{'quantity'} * $value);
                $valuation = $valuation + $worth;
                my $line = sprintf("%-22s %-4s%8s %8s", $type, $coins{$type}{'quantity'}, $value, $worth);
		#print "$type, $value, $worth\n";
		print "$line\n";
	}
        print "=" x 50 . "\n";
}
my $bottomline = sprintf("%-20s %.2f", "Total worth:", $valuation);
print "$bottomline\n";
print "=" x 50 . "\n";




