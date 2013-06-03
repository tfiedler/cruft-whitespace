package logroll;

use strict;
use warnings;
use Sys::Syslog;
use Carp;

our $VERSION = '0.01';

# Syslogging...
my $slog = \&do_syslog;

my %config = ();

sub new
{
    %config = @_;
    confess "Baselog not defined" unless $config{'baselog'};

    $config{'maxbytes'} = 102400 unless $config{'maxbytes'};
    $config{'maxlogs'}  = 5 unless $config{'maxlogs'};
    $config{'UID'} =  ( exists $config{'strict'} == 1 ) ? $< : $>;

    #return ( &rollit() == 0 ) ? 0 : 1;
}

sub roll
{
    my $logowner;
    my $filebytes;

    my $last = $config{'maxlogs'}; 

    if ( -f $config{'baselog'} and ! -x $config{'baselog'} )
    {
        #  0 dev      device number of filesystem
        #  1 ino      inode number
        #  2 mode     file mode  (type and permissions)
        #  3 nlink    number of (hard) links to the file
        #  4 uid      numeric user ID of file's owner
        #  5 gid      numeric group ID of file's owner
        #  6 rdev     the device identifier (special files only)
        #  7 size     total size of file, in bytes
        #  8 atime    last access time in seconds since the epoch
        #  9 mtime    last modify time in seconds since the epoch
        # 10 ctime    inode change time in seconds since the epoch (*)
        # 11 blksize  preferred block size for file system I/O
        # 12 blocks   actual number of blocks allocated
        my @info = stat($config{'baselog'});
        $logowner = $info[4];
        $filebytes = $info[7];
    }
    else
    {
        $slog->("$config{'baselog'} is NOT a regular file");
        return 1;
    }
    
    # File has not reached $maxbytes yet.
    return 0 if $config{'maxbytes'} > $filebytes;
    
    # obviously root can do anything
    if ( ! $config{'UID'} == $logowner and ! $config{'UID'} == 0 )
    {
        $slog->("uid $config{'UID'} is trying to logroll $config{'baselog'} (owner is $logowner)");
        return 1;
    }    
    
    while ( $last > 1 )
    {
       $last--;
       $slog->("renaming $config{'baselog'}");
       rename_logs($last);
    }
    
    if ( -e $config{'baselog'} ) 
    {
        rename( "$config{'baselog'}", "${config{'baselog'}}_1" ); 
        $slog->("Error renaming $config{'baselog'} -> ${config{'baselog'}}_1")
            unless -e "${config{'baselog'}}_1";
    }

    return ( touchfile() == 0 ) ? 0 : 1;
}    

sub touchfile
{
    my $BASELOG;
    unless ( open $BASELOG, ">$config{'baselog'}" )
    {
         $slog->("Unable to open $config{'baselog'}");
         return 1;
    }
    return ( close $BASELOG ) ? 0 : 1;
}

sub rename_logs
{
     my $x = shift;
     my $y = $x + 1;

     if ( -e "${config{'baselog'}}_$x" )
     {
        $slog->("renaming ${config{'baselog'}}_$x -> ${config{'baselog'}}_$y"); 

        rename("${config{'baselog'}}_$x", "${config{'baselog'}}_$y");

        my $return = ( -e "${config{'baselog'}}_$y" ) ? 0 : 1;

        $slog->("Error renaming ${config{'baselog'}}_$x -> ${config{'baselog'}}_$y")
            unless $return == 0;

        return $return;
     }
}

sub do_syslog
{
    my $message = shift;

    openlog( $0, "ndelay,pid", "local0");
    syslog("info", $message);
    closelog;
}

1;
