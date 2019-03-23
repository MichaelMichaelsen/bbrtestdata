#!/usr/bin/perl
#
# finduuid.pl - lookup the uuid in the index file and then search for the entiry in the json file
#
# SYNOPSIS
# ========
#
#   finduuid.pl --db==<databasefile> --uuid=<uuid> --table=<table> --filename=<jsonfile>
#
# where
#   db        - database with the index uuid
#   uuid      - one uuid
#   filename  - the big json file
#
use strict;
use warnings;
use Getopt::Long;
use Data::Dumper;
use Fcntl qw(:seek);
use DBI;

my $db       = "bbr.db";
my $uuid     = "00111d35-d6e3-83d7-251c66622944";
my $table    = "bbr";
my $filename = "BBR.json";

GetOptions( "db=s"         => \$db,
            "table=s"      => \$table,
            "uuid=s"        => \$uuid,
            "filename=s"   => \$filename);

open(my $fh, $filename   ) or die "Unable to open $filename";

my $driver   = "SQLite";
my $uuiddsn  = "DBI:$driver:dbname=$db";
my $userid   = "";
my $password = "";
my $dbh      = DBI->connect($uuiddsn, $userid, $password, { RaiseError => 1 }) or die $DBI::errstr;

findposition($dbh,$table,$uuid,$positionfh );

$dbh->disconnect();
close($fh);
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
