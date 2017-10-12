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

CREATE VIEW publication_author AS 
(
   SELECT pb.pub_id, pb.title, pb.pub_date, a.name
   FROM publications AS pb, authored AS aed, author AS a
   WHERE pb.pub_id = aed.pub_id AND aed.author_id = a.author_id
   ORDER BY pb.pub_id
);

CREATE VIEW confjournalpapers AS (
   SELECT *
   FROM (
      SELECT pub_id, title, year, conf AS confjournal
      FROM inproceedings
   ) AS resultSet

   UNION (
      SELECT pub_id, title, year, journal AS confjournal
      FROM article
   )
);

CREATE VIEW papers_with_authors AS (
   SELECT cjp.*, pa.name
   FROM confjournalpapers cjp, publication_author pa
   WHERE cjp.pub_id = pa.pub_id
);

CREATE VIEW proceedings_inproceedings AS (
    SELECT *
    FROM proceedings 
    UNION 
    SELECT *
    FROM inproceedings
);