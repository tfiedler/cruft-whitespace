#!/usr/bin/perl

use strict;
use warnings;
use Getopt::Long;
use File::Copy;

my $dir;
my $opts = GetOptions( "dir=s" => \$dir, );

my @files;

PROCESSDIR: {
    print "dir = $dir\n";
    opendir my $DH, $dir or die "$dir must be a directory: $!\n";

    @files = grep { /.*/ && -f "$dir/$_" } readdir($DH);
}

for my $file ( @files )
{   

    if ( $file =~ /[A-Z]/ )
    {   
        my $lc = lc($file);

        if ( -f "$dir/$lc" )
        {   
            print "not converting $dir/$file to $dir/$lc\n";
            next;
        }

        move("$dir/$file", "$dir/$lc") or
            warn "Unable to move $dir/$file to $dir/$lc: $!\n";
    }
}
