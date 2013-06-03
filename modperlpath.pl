#!/usr/bin/perl

use strict;
use warnings;

my $DH; # Dir Handle
my $dir = $ARGV[0] or die "no directory passed\n";
my @files;

# auto close DIR when it is 
# longer in scope.
PROCESSDIR: {
    opendir $DH, $dir or die "$dir must be a directory: $!\n";

    @files = grep { /.*/ && -f "$dir/$_" } readdir($DH);
}

my $line = 'perl -i.bak -p -e \'$_ =~ /^#!\/usr\/local\/bin\/perl$/ && $. == 1 && s/local\///\'';

# we only want files that use perl in /usr/local/bin or add your
# own path here incase of things like /opt/perl/bin/perl etc...
my $badpath = qq|/usr/local/bin/perl|;

# Pre-Compile the regexs
my $wanted = qr|^#!\Q$badpath\E$|;
# you may optionally want to change this to skip certain suffixes
my $unwanted = qr#(orig|bak|old|\d+)$#i;

for my $file ( @files) 
{
    chomp $file;
     
    # Skip all files that end in old, OLD, or end in digits ( ie date coded backups )
    next if $file =~ $unwanted;

    open my $FH, "$dir/$file" or die "Unable to open $file for reading: $!\n";
    while ( <$FH> )
    {
     chomp $_;
        
        # If line 1
        if ( $. == 1 )
        {
            if ( $_ =~ $wanted )
            {
                # sluff off a trailing / if it exists....
                $dir =~ s/\/$//;
                print qq|$line ${dir}/${file}\n|;
            }
            # stop after line 1 
            last;
        }
    }
} 

__END__
