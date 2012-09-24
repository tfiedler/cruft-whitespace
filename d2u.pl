#!/usr/bin/perl

use strict;
use warnings;

my $fn = $ARGV[0] || die "Unable to open file: $!\n";
&crlf($fn);

sub crlf
{
    my $file = shift;

    my $IFH;

    my @dump_ = split/\//, $file;
    my $filename = $dump_[$#dump_];

    open $IFH, "$file" or warn "unable to open $file for reading: $!\n";

    while (<$IFH>)
    {
        $_ =~ s/\r\n/\n/;
        print $_;
    }

    close ($IFH);

    return 0;
}
