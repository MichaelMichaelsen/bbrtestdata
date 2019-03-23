.open sagsdata.db
CREATE TABLE sagsdata (
                  UUID             CHAR(36) NOT NULL,
                  STARTPOS         INT      NOT NULL,
                  ENDPOS           INT      NOT NULL,
                  LINENO           INT      NOT NULL,
                  LISTNAME         CHAR(20) NOT NULL
                );

.print "Start importing sagsdata"
.mode csv
.import ../csv/sagsdata.csv sagsdata
.print "Building index"
CREATE INDEX sagsdata_idx ON sagsdata(UUID);
