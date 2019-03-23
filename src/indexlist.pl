#!/usr/bin/perl
#
# indexlist.pl - create an file with the byte positions for each list
#
# {
#   "List1" : [
#       {object1},
#       {object2},
#       ...
#       {objectN}
#      ],
#   "List2" : [
#       {object1},
#       {object2},
#       ...
#       {objectN}
#      ],
#      ...
#   "ListN" : [
#       {object1},
#       {object2},
#       ...
#       {objectN}
#      ]
#}
#
#
# SYNOPSIS
# ========
#
#   indexlist.pl --filename=<inputfilename>
#
# where
#   inputfilename   - input json filename
#   csvfilename     - output csv file
#
#
# The script creates 3 files:
#
use strict;
use warnings;
use Getopt::Long;
use Term::ProgressBar 2.00;
use JSON::SL;
use JSON;
use Data::Dumper;

$|=1;
my $filename = "../json/BBR-Total-v3_20181229200122.json";
my $csvfile  = "../csv/list.csv";
GetOptions( "filename=s"         => \$filename);
my $maxlines       = 2131222117;
my $progress = Term::ProgressBar->new($maxlines);
my $p = JSON::SL->new;
open(my $fh,$filename              ) or die "Unable to open $filename";
open(my $csvfh,       ">$csvfile")   or die "Unable to create $csvfile";

#look for everthing past the first level (i.e. everything in the array)
$p->set_jsonpointer(["/^/^"]);

my $lineno     = 0;
my $filebefore = 0;
my $fileafter  = 0;
my $list       = "";
my $oldlist    = "";
my $next_update= 0;
my $totalnumberofobjects
               = 0;
my %numberofobjects;
my %ids;
while (my $buf = <$fh>) {
  $lineno++;
  $next_update = $progress->update($lineno) if $lineno >= $next_update;
  if ($buf =~ /\"(\w*List)\"\:/) {
    $list = $1;
    if ($list ne $oldlist) {
      $progress->message("New list ".$list);
      $oldlist = $list;
      printf $csvfh "%s,%d,%d\n", $list, tell($fh), $lineno;
    }
  }
  #
  # Special case for starting
  #
  if ($lineno == 3 ){
    printf $csvfh "%s,%d,%d\n", $list,tell($fh), $lineno;
  }

}
printf "Number of lines %d\n", $lineno;
close($csvfh);
