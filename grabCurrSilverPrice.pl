#!/usr/bin/perl

use strict;
use warnings;

use LWP::Simple;
my $content = get("http://www.coinflation.com/silver_coin_values.html");
die "Couldn't get it!" unless defined $content;

my $cf='.0321507466';
my %coins;

$coins{'morgan silver dollar'}{'weight'} = "26.73"; # grams
$coins{'morgan silver dollar'}{'ps'} = ".90"; # grams
$coins{'peace dollar'}{'weight'} = "26.73"; # grams
$coins{'peace dollar'}{'ps'} = ".90"; # grams
$coins{'american silver eagle'}{'weight'} = "31.10"; # grams
$coins{'american silver eagle'}{'ps'} = ".999"; # grams
$coins{'washington quarter'}{'weight'} = "6.25"; # grams
$coins{'washington quarter'}{'ps'} = ".90"; # grams

if ( $content =~ /Coin value calculations use the \d\d?:\d\d (A|P)M EDT silver price for (\w+ \d\d?, \d\d\d\d): <br><b>Silver<\/b> \$(\d\d?.\d\d)\/oz/ )
{
	my $Silver = $3;
	my $date   = $2;

	print "Silver is $Silver on $date\n";
        for my $type ( keys %coins )
        {
		my $value = sprintf("%.4f", $coins{$type}{'weight'} * $cf * $Silver * $coins{$type}{'ps'});
		print "$date, $type, $value\n";
	}
}


