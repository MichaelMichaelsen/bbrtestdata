#!/usr/bin/perl
#
# lookup.pl - Lookup in the file between to byte positions
#
# SYNOPSIS
#   lookup.pl --filename=<filename> --position=<startposition>,<endposition>
#
#

use strict;
use Getopt::Long;
use Fcntl qw(:seek);
use Data::Dumper;

my $filename="../json/BBR-Total-v3_20181229200122.json";
my $position;

my $buffer;
GetOptions( "position=s"        => \$position,
            "filename=s"         => \$filename);

my ($startposition,$endposition) = split(/,/,$position);
open(my $fh, $filename) or die "Unable to open $filename";
seek($fh,$startposition,SEEK_SET);
my $bytes = $endposition - $startposition;
my $rb         = read($fh,$buffer,$bytes);
printf "%s",$buffer;
# printf "rb %d\n", $rb;
# printf "length %d\n", length($buffer);
# print Dumper($buffer);
