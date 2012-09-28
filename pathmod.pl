#/usr/bin/perl
# Modify all occurances of /xyz with /xyz/more_crap
# Ted Fiedler

use strict;
use warnings;
$|++;

if ( /\B\/(xyz)(?!\/more_crap)/g ) 
{
  s/$1(?!\/xyz)/xyz\/more_crap/g ;
}
