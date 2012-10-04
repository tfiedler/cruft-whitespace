#!/usr/bin/perl

use strict;
use warnings;

system("clear");

my $first = int(rand(10));
my $second = int(rand(10));

print "What is your name? ";
my $name=<STDIN>;

print "hello, $name.\n"; 
