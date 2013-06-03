#!/usr/bin/perl

use strict;
use warnings;
use DBI;
use Carp;
use Storable;
use Getopt::Long;
use Digest::MD5;
use Config::INI::Reader;
use Data::Dumper;
#use YAML;

my $fetch     = \&fetch;
my $dprint    = \&debug;
my $timestamp = \&timestamp;

#Process comand line options.
my ( $config, $dbconfig, $store, $logprefix, $basedir, $debug );
my $opts = GetOptions("config=s"    => \$config,
                      "dbconfig=s"  => \$dbconfig,
                      "store"       => \$store,
                      "logprefix=s" => \$logprefix,
                      "basedir=s"   => \$basedir,
                      "verbose"     => \$debug);

carp $INC{'DBI.pm'} if $debug;

# Process table load ini file
my $inidir = ( $basedir ) ? $basedir : '../Configs';

# tkey = target key
# skey = source key
# ttable = target table
# stable = source table
# tmaporder = target map order

my %defaults;

# Relating to the Compound Primary Key
my @compoundkey;
my $compoundkey;

usage() unless $config;

my $configuration = Config::INI::Reader->read_file("$inidir/$config");
# Valid Items are keys columns defaults compoundkey and tables
# The use of compoundkey implies that there is NO unique
# key for a table - we will create one. This can be done
# one of two ways a random int. 
for ( keys %{ $configuration->{ 'compoundkey' } } )
{
    $compoundkey++;
    push @compoundkey, $_;
}

my $tkey   = ( $compoundkey ) 
             ? 'compoundkey' : $configuration->{'keys'}->{'tkey'} ;

my $skey   = ( $compoundkey ) 
             ? 'compoundkey' : $configuration->{'keys'}->{'skey'} ;

print "Target Key = $tkey\n";
print "Source Key = $skey\n";
my $ttable = $configuration->{'tables'}->{'ttable'};
my $stable = $configuration->{'tables'}->{'stable'};

# Note - This must be explicitly set to 1 in the config file...
# Be careful here if its not set lets re-set this to 0 
my $deletes = $configuration->{'configs'}->{'deletes'} || 0;

if ( ! $dbconfig )
{
    if ( $configuration->{'configs'}->{'dataconfig'} &&
         -f qq|$inidir/$configuration->{'configs'}->{'dataconfig'}| )
    {
        $dbconfig = $configuration->{'configs'}->{'dataconfig'};
    }
    else 
    {
        usage();
    }
}

# This is an INCREDIBLE hack. Im not sure how
# to get around it. See next section.
my @tmaporder = split/,/, 
    $configuration->{'columns'}->{'tmaporder'};
my @smaporder = split/,/, 
    $configuration->{'columns'}->{'smaporder'};

my $colcount = ( scalar(@tmaporder) == scalar(@smaporder) ) 
               ? scalar(@tmaporder) : -1;

# The caveat with this approach:
# @*maporder will NOT be the same order you enetered 
# into your file, perls hash ordering will
# see to that. the peril comes not so much 
# when INSERT or UPDATE happens to a table, but
# when dumping to a DBI::CSV thingy.
#for ( keys %{ $configuration->{ 'columns' } } )
#{
#    push @tmaporder, $_;
#    push @smaporder, $configuration->{'columns'}->{$_};
#    $colcount++;
#}

for ( keys %{ $configuration->{'defaults'} } )
{
    $defaults{$_} = 
        $configuration->{'defaults'}->{$_};
    $defaults{$_} =~ s/^SPACE$/ /g;
}
print Dumper %defaults;
my $dbconfiguration = 
    Config::INI::Reader->read_file("$inidir/$dbconfig");

# Set up the environment
for ( keys %{ $dbconfiguration->{'env'}} )
{
    print "$_ = ", 
        $dbconfiguration->{'env'}->{$_}, "\n" if $debug;

    $ENV{$_} = $dbconfiguration->{'env'}->{$_};
}

my $sourceDSN = $dbconfiguration->{'source'}->{'dsn'}; 
my $targetDSN = $dbconfiguration->{'target'}->{'dsn'};

my $sourceuser = $dbconfiguration->{'source'}->{'username'};
my $sourcepwd  = $dbconfiguration->{'source'}->{'password'};

my $targetuser = $dbconfiguration->{'target'}->{'username'};
my $targetpwd  = $dbconfiguration->{'target'}->{'password'};

print Dumper @compoundkey if $compoundkey and $debug;

## start the log
my $LOG_DIR = 'Logs';
my $LOG = ( $logprefix ) ? 
    $logprefix . "_$config-" . $timestamp->('log') : 
    "$config-" . $timestamp->('log');

open my $LF, '>', "$LOG_DIR/$LOG" or
    croak "unable to open $LOG_DIR/$LOG: $!\n";

# Start an exceptions file as well
open my $EF, '>', "$LOG_DIR/$LOG.err" or
    croak "unable to open $LOG_DIR/$LOG.err: $!\n";

print $LF scalar(localtime), "\n\n";

## End of ini file processing

$dprint->(qq{\@tmaporder = @tmaporder});
$dprint->(qq{\@smaporder = @smaporder});

print $LF "remote table => $ttable\nremote key => $tkey\n";
print $LF "local table => $stable\nlocal key => $skey\n";

# recylce $config for logfile naming 
# minus the .ini
$config =~ s!\..*!! ;

# Hold the errors for reporting...
my @ERRS;

$dprint->(qq{initializing DB connections});


## Obviously provide your own DB connections...
# Source
my $Source_h = DBI->connect($sourceDSN, $sourceuser, $sourcepwd);
$Source_h->{ChopBlanks} = "true";
$Source_h->{RaiseError} = 0;
$Source_h->{PrintError} = 1;


# Target
my $Target_h = DBI->connect($targetDSN, $targetuser, $targetpwd);
$Target_h->{ChopBlanks} = "true";
$Target_h->{RaiseError} = 0;
$Target_h->{PrintError} = 1;

if ($targetDSN =~ /^DBI:CSV:$/i )
{
    my $first = shift @tmaporder;
    my $line = "$first char(100)";

    for my $item (@tmaporder) 
    {
        $line .= ",$item char(100)";
    }

    $Target_h->{'f_dir'}        = "$LOG_DIR";
    $Target_h->{'csv_sep_char'} = ',';
    $Target_h->{'csv_eol'}      = "\n";
    $Target_h->{'file'}         = $ttable;
    $Target_h->{'col_names'}    = [@tmaporder];

    unlink("$LOG_DIR/$ttable") if ( -f "$LOG_DIR/$ttable" );

    my $csv_create = qq|create TABLE $ttable ($line)|;

    my $create_sth = 
        $Target_h->prepare($csv_create) or 
        croak "Unable to prepare ( $csv_create )", $Target_h->errstr, "\n";

    $create_sth->execute;
}
## End of DB setup ##


# The quere to select our data from the jobs field
# This querys the SQL server Jobs table
my $rfieldlist = join",", @tmaporder;
my $rquery = qq{select $rfieldlist from $ttable};

# This is for the local query only
my $lfieldlist = join",", @smaporder;
my $lquery = qq{select $lfieldlist from $stable};

$dprint->(qq{Remote query = $rquery});
$dprint->(qq{Local query = $lquery});

# prepare and execute our sql query on the 
# local DB
$dprint->(qq{prepare});
my $Source_sth = 
    $Source_h->prepare($lquery) or 
    errpt('FATAL', $Source_h->errstr(), 'NA', $lquery);

$Source_sth->execute() or 
    errpt ( 'FATAL', $Source_h->errstr(), 'NA', $lquery );

# prepare and execute our sql query on the 
# remote DB
$dprint->(qq{execute});
my $Target_sth = 
    $Target_h->prepare($rquery) or 
    errpt('FATAL', $Target_h->errstr(), 'NA', $rquery);

$Target_sth->execute() or 
    errpt ( 'FATAL', $Target_h->errstr(), 'NA', $rquery );

my %RemoteDB;
my %LocalDB;

# hashes to hold the initial db slurp
my %rdb;
my %ldb;
my $counter = 0;

$dprint->(qq{Binding row data locally});

# Bind columns to hashes
# this is faster and more efficient
# than alternatives.
for ( @smaporder )
{
  $counter++;
	$ldb{$_} = undef;
	$Source_sth->bind_col( $counter, \$ldb{$_} );
}

$dprint->(qq{local counter = $counter});
$dprint->(qq{Binding row data remotely});

$counter = 0;
for ( @tmaporder )
{
    $counter++;
    $rdb{$_} = undef;
    $Target_sth->bind_col( $counter, \$rdb{$_} );
}

$dprint->(qq{remote counter = $counter});

# Fetch the data and hold in these  hashes
$dprint->(qq{Fetching remote data});
%RemoteDB = $fetch->($Target_sth, \%rdb, $tkey);
$dprint->(qq{fetching local data});
%LocalDB  = $fetch->($Source_sth, \%ldb, $skey);

store [\%RemoteDB, %rdb, \%LocalDB, \%ldb],  "$LOG_DIR/$LOG.loc"
    if $store;

my @rinsert_keys;
my @rinspect_keys;
my @rdelete_keys;

# Populate arrays with keys
#
# @rinsert_keys are keys that exist locally
# and DO NOT exist remotely. These will always
# be inserts
for ( keys %LocalDB )
{
    push @rinsert_keys, $_ if ( ! exists $RemoteDB{$_} );
}

# @rinspect_keys represent rows of data
# where the keys are the same remotely
# and locally - this is a dumping 
# ground which we will further inspect
# the data later on
for ( keys %LocalDB )
{
    push @rinspect_keys, $_ if ( exists $RemoteDB{$_} );
}

# @rdelete_keys represent rows of data where
# the key exists remotely but not locally
# these just get deleted.
for ( keys %RemoteDB )
{
    push @rdelete_keys, $_ if ( ! exists $LocalDB{$_} ); 
}

# Insert Routines
print $LF "\nINFO: +++ There are ", scalar(@rinsert_keys), " to insert\n";
for my $keys (@rinsert_keys)
{
    my @VALUES;
    
    for my $count ( 0 .. $#smaporder )
    {
        push @VALUES, $LocalDB{$keys}{$smaporder[$count]};
    }

    my $values = join',',@VALUES;

    my $query = "INSERT into $ttable ($rfieldlist) VALUES ($values)";

    print $LF "INSERT: $keys QUERY: $query\n";
    
    my $Target_sth = $Target_h->prepare($query) or 
        errpt("INSERT", $Target_h->errstr(), $keys, $query);

    $Target_sth->execute() or errpt("INSERT", $Target_h->errstr(), $keys, $query);
}      

# Inspect/Update Routines
print $LF "\nINFO: +++ There are ", scalar(@rinspect_keys), " to INSPECT\n";
for my $keys (@rinspect_keys)
{
    my @UPDATESET;
    my @WHERE;
    my $UPDATE;

    # Inspect the actual column data, if its different push it onto 
    # @UPDATESET array for later processing
    for my $count ( 0 .. $#smaporder )
    {
        unless( $LocalDB{$keys}{$smaporder[$count]} eq $RemoteDB{$keys}{$tmaporder[$count]} )
        {
            print $LF "INSPECT $keys: Local $smaporder[$count] = $LocalDB{$keys}{$smaporder[$count]}\n";
            print $LF "INSPECT $keys: Remote $tmaporder[$count] = $RemoteDB{$keys}{$tmaporder[$count]}\n";
            push @UPDATESET, "$tmaporder[$count] = $LocalDB{$keys}{$smaporder[$count]}";
        }
    }

    $UPDATE = join', ', @UPDATESET;

    # If there is anything here, goto work...
    if ( scalar(@UPDATESET) > 0 )
    { 
        my $WHERE_CLAUSE = ( $compoundkey ) ? join' AND ', map { qq|$_ = $RemoteDB{$keys}{$_}| } @compoundkey
                                        : qq|$tkey = $RemoteDB{$keys}{$tkey}|;

    	my $query = "UPDATE $ttable SET $UPDATE WHERE $WHERE_CLAUSE";

        print $LF "UPDATE: $keys QUERY=$query\n";

        my $Target_sth = $Target_h->prepare($query) or 
	      errpt ("UPDATE", $Target_h->errstr(), $keys, $query); 

        $Target_sth->execute() or errpt ("UPDATE", $Target_h->errstr(), $keys, $query);
    }
    elsif ( $debug )
    {
        print $LF "INSPECT: $keys Nothing to do\n";
    }

}

# Delete Routines
print $LF "\nINFO: +++ There are ", scalar(@rdelete_keys), " to delete\n";
for my $keys ( @rdelete_keys )
{
    print "Deletes = $deletes\n";
    print $LF "No deletes done on $ttable\n" if $deletes == 0;

    last if $deletes == 0; 

    my $WHERE_CLAUSE = ( $compoundkey ) ? join' AND ', map { qq|$_ = $RemoteDB{$keys}{$_}| } @compoundkey
                                    : qq|$tkey = $RemoteDB{$keys}{$tkey}|;

    my $query = "DELETE FROM $ttable WHERE $WHERE_CLAUSE";
    print $LF "DELETE: $keys\nDELETE: $query\n";
    my $Target_sth=$Target_h->prepare($query) or errpt("DELETE", $Target_h->errstr(), $keys, $query);
    $Target_sth->execute() or errpt("DELETE", $Target_h->errstr(), $keys, $query);
}

print $EF "$_\n" for @ERRS;

END {
    $Target_h->disconnect;
    $Source_h->disconnect;
}


#### Local Subs ####

sub fetch
{
    my $sth    = shift || croak;
    my $dbhash = shift || croak;
    my $key    = shift || croak;

    my %DB;

    while ( $sth->fetchrow_hashref )
    {
        if ( $compoundkey )
        {
            $key = undef;

            my $keydigest = Digest::MD5->new;
            
            for my $item (@compoundkey)
            {
                $keydigest->add( $Source_h->quote( $dbhash->{$item} || undef ) ) ;
            }

            my $digest = $keydigest->hexdigest;
            
            # Ensure that ALL data is properly quoted
            # using the dbi->quote method
            $DB{$digest}{$_} 
     	        = $Target_h->quote( $dbhash->{$_} || $defaults{$_}) for keys %$dbhash 
        }
        else
        {

            # Ensure that ALL data is properly quoted
            # using the dbi->quote method
            $DB{$dbhash->{$key}}{$_} 
     	        = $Target_h->quote( $dbhash->{$_}||$defaults{$_} ) for keys %$dbhash 
        }
    }

    return %DB or 
        errpt ( 'FATAL', 'Unable to return data from fetch', 'NA', 'NA' ); 
}

sub debug
{
    carp "@_\n" if $debug
}

sub errpt
{
    my $TYPE   = shift;
    my $DB_ERR = shift;
    my $KEY    = shift;
    my $QUERY  = shift;

    my $ERR    = "$TYPE key $KEY: $DB_ERR";

    push @ERRS, $ERR;

    print $LF "$TYPE FAILURE: key = $KEY $DB_ERR\n$QUERY\n";

    return 0 unless ($TYPE eq 'FATAL');

    return 1;

}

sub timestamp
{
    $_ = shift || "timestamp";
    my ( $sec, $min, $hour,
    $mday, $mon, $year,
    $wday, $yday ) = localtime();
    
    $mon++;
    $year += 1900;
    
    my $log = sprintf "%4i%02i%02i%04i", $year,$mon,$mday, $$;
    my $timestamp = sprintf "%4i-%02i-%02i %02i:%02i:%02i  ",
        $year, $mon, $mday, $hour, $min, $sec;
    
    my $return = ( $_ eq "timestamp" ) ? $timestamp : $log;
    
    return $return;
}

sub usage 
{
    croak qq|usage: $0 --config=config.ini OPTIONAL: ---dbconfig=dbconfig.ini -basedir="Configs" --logprefix=test -s -d \n|;
}

