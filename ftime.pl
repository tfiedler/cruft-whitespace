#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;

my $DH; # Dir Handle
my $dir = $ARGV[0];
my @files;

PROCESSDIR: {
    opendir $DH, $dir or die "$dir must be a directory: $!\n";

    @files = grep { /.*/ && -f "$dir/$_" } readdir($DH);
}

my $format = "%-40s %30s %30s %30s";
my $header = sprintf("$format", 'File', 'atime', 'mtime', 'ctime');
my $line = '-' x length($header);

print "$header\n$line\n";

for my $file ( @files )
{
     my @stat = stat("$dir/$file");

     my $out = sprintf("$format", $file, convert($stat[8]) , convert($stat[9]) , convert($stat[10]));

     print "$out\n";
}
print "$line\n";
print "DIRECTORY: $dir\n";
    
sub convert { my $in = shift; return scalar(localtime($in)) }
