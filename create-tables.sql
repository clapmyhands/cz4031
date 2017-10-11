-- CREATE TABLE/VIEW queries

CREATE TABLE PubRecords (
   PUB_ID INT PRIMARY KEY,
   TITLE VARCHAR(50),
   CDATE DATE,
   MDATE DATE,
   YEAR INT,
   MONTH VARCHAR(10),
   SERIES VARCHAR(5),
   VOLUME INT, 
   CROSSREF VARCHAR(30),
   PUBLISHER VARCHAR(30),
);

CREATE TABLE Book (
) INHERITS (PubRecords);

CREATE TABLE Incollection (
) INHERITS (PubRecords);

CREATE TABLE MastersThesis (
) INHERITS (PubRecords);

CREATE TABLE PhdThesis (
) INHERITS (PubRecords);

CREATE TABLE Proceedings (
   CONF VARCHAR(30)
) INHERITS (PubRecords);

CREATE TABLE Inproceedings (
   CONF VARCHAR(30)
) INHERITS (PubRecords);

CREATE TABLE Proceedings (
   JOURNAL VARCHAR(30)
) INHERITS (PubRecords);

CREATE TABLE Author 
(
   AUTHOR_ID INT,
   NAME VARCHAR(30)
);

CREATE TABLE Authored (
   PUB_ID INT,
   AUTHOR_ID INT
);

CREATE VIEW PublicationAuthor AS 
(
   SELECT pb.PUB_ID, pb.TITLE, pb.YEAR, a.NAME
   FROM PubRecords AS pb, Authored AS aed, Author AS a
   WHERE pb.PUB_ID = aed.PUB_ID AND aed.AUTHOR_ID = a.AUTHOR_ID
   ORDER BY pb.PUB_ID
);

CREATE VIEW ConfJournalPapers AS (
   SELECT *
   FROM (
      SELECT PUB_ID, TITLE, YEAR, CONF AS CONFJOURNAL
      FROM Inproceedings
   ) AS resultSet

   UNION (
      SELECT PUB_ID, TITLE, YEAR, JOURNAL AS CONFJOURNAL
      FROM Article
   )
);

CREATE VIEW PapersWithAuthors AS (
   SELECT cjp.*, pa.NAME
   FROM ConfJournalPapers cjp, PublicationAuthor pa
   WHERE cjp.PUB_ID = pa.PUB_ID
);