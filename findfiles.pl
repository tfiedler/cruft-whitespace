#!/admin/perl/perl-5.14.0/bin/perl 

use strict;
use warnings;
use Getopt::Long;
usee Digest::MD5 qw(md5);

my ( $infile, $silent, $text );

my $opts = GetOptions( "c=s" => \$infile, 
                       "s"   => \$silent, 
                       "t"   => \$text,);

if ( $infile and -f $infile )
{
    open my $FH, $infile or die "Unable to open $infile\n";
    while ( <$FH> )
    {
        my ( $sum, $file ) = split /\s+/;
        my $message = "UNKNOWN"; 
        if ( -f $file )
        {
            my $newsum = getsum($file);
            $message = ( "$newsum" eq "$sum" ) ? 'OK' : 'FAILED';
        }
        elsif ( -d $file )
        {
             $message = "$file is a directory";
        }
        print "$file $message\n" 
            unless ( $silent and $message =~ /^OK$/ );
    }
} 
else
{
    for my $file ( @ARGV )
    {
        next unless (-f $file );
        print getsum($file) . "  $file\n";
    }
}

sub getsum
{
    my $file = shift;
    my $sum = Digest::MD5->new;
    open my $FH, $file or die "Unable to open $file: $!\n";
    binmode($FH) unless $text;
    $sum->addfile($FH);
    my $digest = $sum->hexdigest;
    return $digest;
}
