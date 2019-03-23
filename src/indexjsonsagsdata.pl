#!/usr/bin/perl
#
# indexjsonsagsdata.pl - create an index based on sagsdata id for a json file that has the following structure
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
#   indexjsonsagsdata.pl --filename=<inputfilename> --csv=<csvfilename>
#
# where
#   inputfilename   - input json filename
#   csvfilename     - output csv file
#
#  CSV file format
#
#  ID, STARTPOS, ENDPOS, LINENO, LISTNAME
#
#  ID               - the uniq id (either Id or id_lokalID for the object)
#  STARTPOS         - Start byte position of the object
#  ENDPOS           - End byte position (the separation comma)
#  LINENO           - Line number for the end of the object
#  LISTNAME         - The name of the list
#
use strict;
use warnings;
use Getopt::Long;
use Term::ProgressBar 2.00;
use JSON::SL;
use JSON;
use Fcntl qw(:seek);
use Data::Dumper;

$|=1;
my $filename = "../json/BBR-Total-v3_20181229200122.json";
my $csvfile  = "../csv/sagsdata.csv";
GetOptions( "filename=s"         => \$filename,
            "csv=s"              => \$csvfile);
my $maxlines       = 2131222117;
my $progress = Term::ProgressBar->new($maxlines);
my $p = JSON::SL->new;
open(my $fh,$filename) or die "Unable to open $filename";
open(my $csv,">$csvfile") or die "Unable to create $csvfile";

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
my $idfound    = 0;
#
# Jump to the correct list
#
while (my $buf = <$fh>) {
	  $lineno++;
    $next_update = $progress->update($lineno) if $lineno >= $next_update;
	  if ($buf =~ /\"(\w*List)\"\:/) {
			$list = $1;
      if ($list ne $oldlist) {
        $progress->message("New list ".$list);
        $oldlist = $list
      }
		}
	  #
	  # Special case for starting
	  #
	  if ($lineno == 3 ){
			$filebefore = tell();
		}
	  $fileafter = tell();
    $p->feed($buf); #parse what you can

    #fetch anything that completed the parse and matches the JSON Pointer
    while (my $obj = $p->fetch) {
        #print Dumper($obj);
        #printf "%s - %s\n",$obj->{Path},$obj->{Value};
        #printf "%s",to_json($obj->{Value}, {utf8 => 0, pretty => 1});
        my $id= "";
				if (defined $obj->{Value}{sagsdataBygning}) {
					 $id = $obj->{Value}{sagsdataBygning};
           $idfound++;
           printf $csv "%s\n", join(",",$id, $filebefore, $fileafter, $lineno,$list);
           $totalnumberofobjects++;
           $numberofobjects{$list}++;
				}
        if (defined $obj->{Value}{sagsdataEnhed}) {
           $id = $obj->{Value}{sagsdataEnhed};
           $idfound++;
           printf $csv "%s\n", join(",",$id, $filebefore, $fileafter, $lineno,$list);
           $totalnumberofobjects++;
           $numberofobjects{$list}++;
        }
        if (defined $obj->{Value}{sagsdataEtage}) {
           $id = $obj->{Value}{sagsdataEtage};
           $idfound++;
           printf $csv "%s\n", join(",",$id, $filebefore, $fileafter, $lineno,$list);
           $totalnumberofobjects++;
           $numberofobjects{$list}++;
        }
        if (defined $obj->{Value}{sagsdataGrund}) {
           $id = $obj->{Value}{sagsdataGrund};
           $idfound++;
           printf $csv "%s\n", join(",",$id, $filebefore, $fileafter, $lineno,$list);
           $totalnumberofobjects++;
           $numberofobjects{$list}++;
        }
        if (defined $obj->{Value}{sagsdataOpgang}) {
           $id = $obj->{Value}{sagsdataOpgang};
           $idfound++;
           printf $csv "%s\n", join(",",$id, $filebefore, $fileafter, $lineno,$list);
           $totalnumberofobjects++;
           $numberofobjects{$list}++;
        }
        if (defined $obj->{Value}{"sagsdataTekniskAnlæg"}) {
           $id = $obj->{Value}{"sagsdataTekniskAnlæg"};
           $idfound++;
           printf $csv "%s\n", join(",",$id, $filebefore, $fileafter, $lineno,$list);
           $totalnumberofobjects++;
           $numberofobjects{$list}++;
        }
        $filebefore = $fileafter;

    }
    #printf "(%d,%d,%d) next\n",$lineno,$filebefore, $fileafter;
}
close($csv);
open(my $statfh, ">statistik.log") or die "Unable to open statistik.log";
printf $statfh "Total number of objects: %d\n", $totalnumberofobjects;
foreach $list (keys %numberofobjects) {
  printf $statfh "%30s %d\n", $list, $numberofobjects{$list};
}
printf $statfh "sagsdata keys found %d\n",$idfound;
close($statfh)
