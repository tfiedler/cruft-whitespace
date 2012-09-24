#!/usr/bin/perl 

use strict;
use IO::Socket::INET;
use Getopt::Long;

my $opts    = GetOptions(
    "host=s"    => \my $host,
    "port=s"    => \my $port,
);


die "usage: sp -h <host|IP> [ -h <host|IP> ] -p <port> [ -p <port> ]\n" unless $host;

my $status = ( connection( $host, $port ) == 0 ) ? "Up" : "Down";
my $line = sprintf(" %-20s %-5s %-1s", $host, $port, $status);
print $line . "\n";

##############
sub connection
##############
{
        my $host     = shift;
        my $tcp_port = shift;

        return ( IO::Socket::INET->new(
            Timeout  => 2, # reasonable
            PeerAddr => $host,
            PeerPort => $tcp_port,
            Proto    => 'tcp' ) ) ? 0 : 1; 
}
