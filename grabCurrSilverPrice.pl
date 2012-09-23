#!/usr/bin/perl

use strict;
use warnings;

use LWP::Simple;

# Expecting name, quantity, % silver, weight in grams, face value, origin country, target country
my $incsv = $ARGV[0]; 

my %coins;

if ( -f "$incsv" )
{
	open my $_fh, $incsv 
		or die "unable to open $incsv for reading: $!\n";
	while (<$_fh>)
	{
		next if $. == 1;
		my ($coin, @data) = split /,/;
		$coin =~ s/"//g;
		$coins{$coin}{'quantity'} = $data[0];
		$coins{$coin}{'ps'} = $data[1];
		$coins{$coin}{'weight'} = $data[2];
		$coins{$coin}{'fv'} = $data[3];
		$coins{$coin}{'origin'} = $data[4];
		$coins{$coin}{'target'} = $data[5];
	}

	close ($_fh);
}
else
{
	print "usage: $0 <csv file>\n";
}

my $content = get("http://www.coinflation.com/silver_coin_values.html");
die "Couldn't get it!" unless defined $content;

my $cf='.0321507466';

my $valuation = 0;
my $facevalue = 0;

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
		$facevalue = $facevalue + 
			( ConvertTo($coins{$type}{'origin'},$coins{$type}{'target'}) * $coins{$type}{'fv'} );

                my $line = sprintf("%-22s %-4s%8s %8s", $type, $coins{$type}{'quantity'}, $value, $worth);
		#print "$type, $value, $worth\n";
		print "$line\n";
	}
        print "=" x 50 . "\n";
}
my $bottomline = sprintf("%-15s %.2f %15s %.2f", "Total worth:", $valuation, "Face value:", $facevalue);
print "$bottomline\n";
print "=" x 50 . "\n";

sub ConvertTo
{
	my $ORIGIN = shift;
	my $TARGET = shift;

        return 1 if $ORIGIN = $TARGET;

	my $URL = "http://themoneyconverter.com/${ORIGIN}/${TARGET}.aspx";

	my $get = get($URL);
	die "Couldn't get it!" unless defined $get;

	my $toUSD;
	if ( $get =~ /Latest Exchange Rates: 1 \w+ \w+ = (\d\.\d+) United States Dollar/ )
	{
        	$toUSD = $1;
	}
	return $toUSD;
}
