#!/usr/bin/perl
#
# generate.pl - generate the json file based on the main json input file and the position file
#
# SYNOPSIS
# ========
#
#   genereate.pl --filename==<filename> --position=<filename> --jsonfile=<filename> --uuid=<filename>
#
# where
#   filename        - the main file download file
#   position        - intput with the positions
#   newuuid         - list of found uuid
#   jsonfile        - the output file
#
#
# The main structure
# {
#    [{},{},{},..{}],
#    [{},{},{},..{}],
#    [{},{},{},..{}],
#    ...
#    [{},{},{},..{}]
# }
#
# Position file format
# key,start,end,list
#
use strict;
use warnings;
use Getopt::Long;
use Term::ProgressBar 2.00;
use Fcntl qw(:seek);

my $filename = "../json/BBR-Total-v3_20181229200122.json";
my $position = "../csv/newposition.csv";
my $jsonfile = "../json/bbr-v1.3  .json";
my $newuuid  = "../csv/newuuid.csv";

GetOptions( "filename=s"        => \$filename,
            "position=s"        => \$position,
            "jsonfile=s"        => \$jsonfile,
            "newuuid=s"         => \$newuuid);

open(my $fh,   $filename)                     or die "Unable to open $filename";
open(my $posfh,"sort -t, -k4 $position|")     or die "Unable to open $position";
open(my $jsonfh,">$jsonfile")                 or die "Unable to create $jsonfile";
open(my $newuuidfh,">$newuuid")               or die "Unable to create $newuuid";

my %jsonstruct;
my %lists;
while (my $line=<$posfh>) {
  chomp($line);
  my ($key,$startposition,$endposition,$list) = split(/,/,$line);
  my $json = getjson($fh,$startposition,$endposition);
  finduuid($newuuidfh, $json);
  push(@{$jsonstruct{$list}},$json);
  $lists{$list}++;
}
generatejson($jsonfh);
# for my $list (sort keys %jsonstruct) {
#   printf "%s %d\n",$list, scalar @{$jsonstruct{$list}}
# }
sub generatejson {
  my $fh = shift;
  printf $fh "{\n";
  my $numeroflists = scalar keys %lists;
  my $listno       = 0;
  for my $list (sort keys %jsonstruct) {
    $listno++;
    printf $fh "\"%s\": [\n",$list;
    printf $fh "%s\n",join(",\n",@{$jsonstruct{$list}});
    #
    # no commas for the last list
    #
    if ($listno < $numeroflists) {
      printf $fh "],\n"
    } else {
      printf $fh "]\n"
    }
  }
  printf $fh "}\n";
}
#
# finduuid - locate the uuid in the input
#
sub finduuid{
  my $fh    = shift;
  my $input = shift;
  my @lines = split(/\n/,$input);
  for my $line (@lines) {
    if ($line =~ /([a-fA-F0-9]{8}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{12})/) {
      printf $fh "%s\n",$1
    }
  }
}
#
# getjson
#
sub getjson{
  my $fh    = shift;
  my $start = shift;
  my $end   = shift;
  # printf "getjson(%d,%d)\n", $start,$end;

  my $buffer;
  seek($fh,$start,SEEK_SET);
  my $bytes = $end - $start;
  my $rb    = read($fh,$buffer,$bytes);
  #
  # Remove the trailing comma
  #
  $buffer =~ s/,$//;
  # printf "getjson: %s",$buffer;

  return $buffer;
}
