#!/usr/bin/perl
# split_crontab.pl - Ted Fiedler
# Turns cron schedule on / off based on tags
# which are appended with a #<tag> as such
# 1 3 * * * /usr/bin/date > /tmp/date #Test
#  so by running the following:
# ./split_crontab.pl Test off
# will prepend the line with ##.
# this program does not modify crontab, but returns
# a cron file which can be read into cron.

# Due dilegence
use strict;
use warnings;

# First arg is Tag, second is action
my $TAG  = $ARGV[0]
  or die "must pass in a division.\n";
my $ACT = $ARGV[1]
  or die "must pass in an action (on or off).\n";

chomp ($TAG);
chomp ($ACT);

# Some sanity
die "Actions can only be on or off\n" unless ( ${ACT} =~ /^o(n|ff)$/ );

# Temp files etc...
my $tmp = "/tmp/temp.cron";
my $new = "./$$.cron";

my $count = 0;

if ( -f "$tmp" or -f "$new" )
{
    print "Waiting for $0 ";
    while ( $count < 2 )
    {
        print "$count ";
        sleep 10;
        $count++;
    }

    print "\n";

    if ( -f "$tmp" or -f "$new" )
    {
        print "Looks like something is wrong.\n";
        print "\t* is $0 still running?\n";
        print "\t* does $tmp exist?\n";
        print "\t* does $new exist?\n";
        print "exiting ...";
        exit 1;
    }
}

my $cronstat = ( system("crontab -l > /tmp/temp.cron") == 0 )
  ? 0 : 1;

#print "cronstat = $cronstat\n";

if ($cronstat == 0)
{
    ACT();
    print "$new";
}
else
{
    #Do not ACT
    print "Ooops something wen wrong with reading your crontab\n";
}

if ( -f "$tmp" )
{
    unlink $tmp;
}

sub ACT
{
    open my $_fh, $tmp or die "Unable to open $tmp\n";
    open my $_fh2, '+>', $new or die "Unable to open $new\n";

    select $_fh2;

    while (<$_fh>)
    {
        if  ( /#${TAG}$/i )
        {
            if ( ${ACT} eq "on" )
            {
                if ( /^##/ )
                {
                    s/^##//;
                }
            }
            elsif ( ${ACT} eq "off" )
            {
                    if ( ! /^##/ )
                    {
                        $_ = "##".$_;
                    }
            }
        }
        print ;
    }
    select (STDOUT);
    close ($_fh);
    close ($_fh2);
}
