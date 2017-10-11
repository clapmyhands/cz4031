-- CREATE TABLE/VIEW queries

CREATE TABLE Publication (
   pub_id INT PRIMARY KEY,
   key VARCHAR(30),
   title VARCHAR(150),
   cdate DATE,
   mdate DATE,
   year INT,
   month VARCHAR(10)
);

CREATE TABLE Book (
) INHERITS (publication);

CREATE TABLE Incollection (
) INHERITS (publication);

CREATE TABLE MastersThesis (
) INHERITS (publication);

CREATE TABLE PhdThesis (
) INHERITS (publication);

CREATE TABLE Proceedings (
   conf VARCHAR(30),
   booktitle VARCHAR(50)
) INHERITS (publication);

CREATE TABLE Inproceedings (
   conf VARCHAR(30),
   booktitle VARCHAR(50)
) INHERITS (publication);

CREATE TABLE Article (
   journal VARCHAR(30)
) INHERITS (publication);

CREATE TABLE Author 
(
   author_id INT PRIMARY KEY,
   name VARCHAR(30)
);

CREATE TABLE Authored (
   pub_id INT,
   author_id INT,
   PRIMARY KEY(pub_id, author_id)
);

CREATE VIEW PublicationAuthor AS 
(
   SELECT pb.pub_id, pb.title, pb.year, a.name
   FROM publication AS pb, Authored AS aed, Author AS a
   WHERE pb.pub_id = aed.pub_id AND aed.author_id = a.author_id
   ORDER BY pb.pub_id
);

CREATE VIEW ConfJournalPapers AS (
   SELECT *
   FROM (
      SELECT pub_id, title, year, conf AS confjournal
      FROM Inproceedings
   ) AS resultSet

   UNION (
      SELECT pub_id, title, year, journal AS confjournal
      FROM Article
   )
);

CREATE VIEW PapersWithAuthors AS (
   SELECT cjp.*, pa.name
   FROM ConfJournalPapers cjp, PublicationAuthor pa
   WHERE cjp.pub_id = pa.pub_id
);