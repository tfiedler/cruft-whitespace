#!perl

use strict;
use warnings;
use v5.10;

#use Data::Dumper;
#print Dumper localtime(time);

#cd "~/Desktop/Notes";
# Set up the dirs if they do not exist.
my @date_stuff = localtime(time);
my $day   = $date_stuff[3];
my $month = $date_stuff[4] + 1;
my $year  = $date_stuff[5] + 1900;

if ( ! -d "$year" )
{
    mkdir $year or die "Unable to mkdir $year $!\n";
}

if ( ! -d "$year/$month" )
{
    mkdir "$year/$month" or die "Unable to mkdir $year/$month $!\n";
}

if ( ! -f "$year/$month/${day}.txt" )
{
    open my $_fh, '+>', "$year/$month/${day}.txt" or 
        die "unable to create regular file $year/$month/${day}.txt $!\n";
    close ($_fh);
}

system ("gvim $year/$month/${day}.txt");

exit 0;

# GO
