#!/usr/bin/perl
# "grep" through a log file for a field and report the occurrences of that field.
# I got bored.
# because you can use awk '{print $<field #>}' <file> | uniq -c
# which is probably the best way.
# Ted Fiedler <Fiedlert@gmail.com>

use strict;
use warnings;
use 5.010;
use Getopt::Long;
use Data::Dumper;

my $p = \&pad;
my $p2 = $p->(2);
my $p4 = $p->(4);

my $OPTS = GetOptions (
    "file=s"    => \my $file,
    "key=s"     => \ my $key,
    "results=i" => \ my $results,
    "sample"  => \ my $sample,
    "usage"     => \ my $usage, );


if ( $usage ) { usage(); exit 0; }

my %hash;

if ( -f "$file" )
{
    open my $_f, "$file" or die "unable to open $file: $!\n";
    $results = ( ! $results ) ? 10 : $results;
    if ( $sample )
    {
        while (<$_f>)
        {
            if ( $. <= $results ) {print}
            else {last}
        }
    }

    if ( $key =~ /^.+$/)
    {
        while (<$_f>)
        {
            my @inspect = split /\s+/;
            #print Dumper @inspect;
            if ( defined $inspect[$key] )
            {
                #say "I saw $inspect[$key] at location $key";
                $hash{$inspect[$key]}++;
            }
            else
            {
                #say "null at location $key";
                $hash{'_null_'}++;
            }
        }
    }

    #else {
    #    say "WizBang!"
    #}
}


#print Dumper %hash;

my $count=0;
foreach my $key ( sort { $hash{$b} <=> $hash{$a} } ( keys %hash ) )
{
    say "$hash{$key} $key";
    last if ( $count++ > $results );
}

#########
sub usage
#########
{
    say "$0 - \"grep\" through a log file and enumerate the occurrences of a given field.";
    say $p2 . "options";
    say $p4 . "--file    -> log file to search";
    say $p4 . "--key     -> field to report upon";
    say $p4 . "--results -> # of results to return";
    say $p4 . "--sample  -> return sample data (default is 10 or --results)";
    say $p4 . "--usage   -> if you have to ask...";
}

#######
sub pad
#######
{
    return  " " x shift
}
