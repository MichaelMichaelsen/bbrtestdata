#!/usr/bin/perl
#
# processbfe.pl - fetch the json pieces and glue them together
#
# SYNOPSIS
# ========
#
#   processbfe.pl --bfenummer==<keyfile> --position=<filename>
#
# where
#   bfenummer       - uuid to be found
#   position        - filename for the result of the query
#
use strict;
use warnings;
use Getopt::Long;
use Term::ProgressBar 2.00;
use JSON::SL;
use JSON;
use Data::Dumper;
use Fcntl qw(:seek);
use DBI;

my $uuidfile  = "../csv/bfenummer.csv";
my $position  = "../csv/position2.csv";

GetOptions( "uuidfile=s"         => \$uuidfile,
            "position=s"         => \$position);

open(my $uuidfh    , $uuidfile   ) or die "Unable to open $uuidfile";
open(my $positionfh, ">$position") or die "Unable to create $position";

my $driver   = "SQLite";
my $uuiddsn  = "DBI:$driver:dbname=bfe.db";
my $userid   = "";
my $password = "";
my $dbh      = DBI->connect($uuiddsn, $userid, $password, { RaiseError => 1 }) or die $DBI::errstr;
my $table    = "bfe";

while (my $uuid=<$uuidfh>) {
  chomp($uuid);
  findposition($dbh,$table,$uuid,$positionfh );
}
close($uuidfh);
close($positionfh);
$dbh->disconnect();
#
# findposition
#
sub findposition {
  my $dbh     = shift;
  my $table   = shift;
  my $key     = shift;
  my $fh      = shift;

  # printf "findobject: %s\n",$tablename;
  my $stmt = qq(select * from $table where UUID="$key");
  # printf   "DB %s\n",$stmt;
  my $sth  = $dbh->prepare( $stmt );

  my $rv   = $sth->execute() or die $DBI::errstr;
  if($rv < 0) {
    return undef;
  }
  while(my @row = $sth->fetchrow_array()) {
     my $startpostion = $row[1];
     my $endposition  = $row[2];
     my $listname     = $row[4];
     printf $fh "%s,%d,%d,%s\n",$key,$startpostion,$endposition,$listname;
  }
}
