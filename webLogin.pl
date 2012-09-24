#!/admin/perl/perl-5.14.0/bin/perl

use 5.010;
use strict;
use warnings;
use WWW::Mechanize;
use Test::More tests => 1;
use Getopt::Long;

my $stuff = GetOptions ( "url=s"    =>   \ my $url, 
			 "user=s"   =>   \ my $user,
			 "pass=s"   =>   \ my $pass,
			 "form=i"   =>   \ my $form,
			 "expect=s" =>   \ my $expected, );

# Adminittedly this is not elegant. 
usage('url')      unless ($url);
usage('user')     unless ($user);
usage('password') unless ($pass);
usage('form')     unless ($form);
usage('expect')   unless ($expected);

my $mech = WWW::Mechanize->new();

$mech->credentials( $user, $pass );

$mech->get( $url );

like( $mech->content(), qr/$expected/, "OK" );

sub usage
{
    my $opt = shift;
    die "you forgot option: $opt\n";
}

#./testIntegration.pl --url="http://integrate1.x.xom:9970/ixts" --user=xxx --pass=xxx --form=1 --expect="Configuration Status"
