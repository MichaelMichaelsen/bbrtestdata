.open husnummer.db
CREATE TABLE husnummer (
                  UUID             CHAR(36) NOT NULL,
                  STARTPOS         INT      NOT NULL,
                  ENDPOS           INT      NOT NULL,
                  LINENO           INT      NOT NULL,
                  LISTNAME         CHAR(20) NOT NULL
                );

.print "Start importing husnummer"
.mode csv
.import ../csv/husnummer.csv husnummer
.print "Building index"
CREATE INDEX husnummer_idx ON husnummer(UUID);
