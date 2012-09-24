#!/usr/bin/perl 

use strict;
use warnings;
use Net::Ping;

my $down;
my $host = $ARGV[0];
my $p = Net::Ping->new("icmp");

while ( ! $down )
{
    $down++ unless $p->ping($host);
    
    sleep 10;
}

exit 0;
