.open bfe.db
CREATE TABLE bfe (
                  UUID             CHAR(36) NOT NULL,
                  STARTPOS         INT      NOT NULL,
                  ENDPOS           INT      NOT NULL,
                  LINENO           INT      NOT NULL,
                  LISTNAME         CHAR(20) NOT NULL
                );

.print "Start importing bfe"
.mode csv
.import ../csv/bfe.csv bfe
.printf "Creating index"
CREATE INDEX bfe_idx ON bfe(UUID);
