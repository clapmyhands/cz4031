-- CREATE TABLE/VIEW queries

CREATE TABLE book (
    pub_id INT PRIMARY KEY,
    pub_key TEXT UNIQUE,
    title TEXT,
    pub_date DATE
);

CREATE TABLE incollection (
   pub_id INT PRIMARY KEY,
   pub_key TEXT UNIQUE,
   title TEXT,
   pub_date DATE
);

CREATE TABLE masters_thesis (
   pub_id INT PRIMARY KEY,
   pub_key TEXT UNIQUE,
   title TEXT,
   pub_date DATE
);

CREATE TABLE phd_thesis (
   pub_id INT PRIMARY KEY,
   pub_key TEXT UNIQUE,
   title TEXT,
   pub_date DATE
);

CREATE TABLE proceedings (
   pub_id INT PRIMARY KEY,
   pub_key TEXT UNIQUE,
   title TEXT,
   pub_date DATE,
   booktitle TEXT
);

CREATE TABLE inproceedings (
   pub_id INT PRIMARY KEY,
   pub_key TEXT UNIQUE,
   title TEXT,
   pub_date DATE,
   booktitle TEXT
);

CREATE TABLE Article (
   pub_id INT PRIMARY KEY,
   pub_key TEXT UNIQUE,
   title TEXT,
   pub_date DATE,
   journal TEXT
);

CREATE TABLE author (
   author_id INTEGER PRIMARY KEY,
   author_name TEXT
);

CREATE TABLE authored (
   pub_id INT,
   author_id INT,
   PRIMARY KEY(pub_id, author_id)
);

CREATE VIEW publication_author AS 
(
   SELECT pb.pub_id, pb.title, a.author_name
   FROM publication AS pb, authored AS aed, author AS a
   WHERE pb.pub_id = aed.pub_id AND aed.author_ID = a.author_ID
   ORDER BY pb.pub_id
);

/*
CREATE VIEW conf_journal_papers AS (
   SELECT *
   FROM (
      SELECT pub_id, title, YEAR, CONF AS conf_journal
      FROM inproceedings
   ) AS resultSet

   UNION (
      SELECT pub_id, title, YEAR, journal AS conf_journal
      FROM article
   )
);

CREATE VIEW papers_without_authors AS (
   SELECT cjp.*, pa.name
   FROM conf_journal_papers cjp, publication_author pa
   WHERE cjp.pub_id = pa.pub_id
);