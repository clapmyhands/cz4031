CREATE TABLE temp_publication (
    pub_id INT PRIMARY KEY,
    pub_key TEXT UNIQUE,
    title TEXT,
    pub_date DATE
);

CREATE TABLE temp_book (
    pub_id INT PRIMARY KEY,
    pub_key TEXT UNIQUE
) INHERITS (temp_publication);

CREATE TABLE temp_incollection (
    pub_id INT PRIMARY KEY,
    pub_key TEXT UNIQUE
) INHERITS (temp_publication);

CREATE TABLE temp_masters_thesis (
    pub_id INT PRIMARY KEY,
    pub_key TEXT UNIQUE
) INHERITS (temp_publication);

CREATE TABLE temp_phd_thesis (
    pub_id INT PRIMARY KEY,
    pub_key TEXT UNIQUE
) INHERITS (temp_publication);

CREATE TABLE temp_proceedings (
    pub_id INT PRIMARY KEY,
    pub_key TEXT UNIQUE,
    booktitle TEXT
) INHERITS (temp_publication);

CREATE TABLE temp_inproceedings (
    pub_id INT PRIMARY KEY,
    pub_key TEXT UNIQUE,
    booktitle TEXT
) INHERITS (temp_publication);

CREATE TABLE temp_article (
    pub_id INT PRIMARY KEY,
    pub_key TEXT UNIQUE,
    journal TEXT
) INHERITS (temp_publication);


INSERT INTO temp_inproceedings
SELECT temp.pub_id, temp.pub_key, temp.title, temp.pub_date, temp.booktitle
FROM (
    SELECT *, row_number() OVER(ORDER BY pub_id) as rnum
    FROM inproceedings
) as temp
WHERE mod(temp.rnum,2) = 0;

INSERT INTO temp_proceedings
SELECT temp.pub_id, temp.pub_key, temp.title, temp.pub_date, temp.booktitle
FROM (
    SELECT *, row_number() OVER(ORDER BY pub_id) as rnum
    FROM proceedings
) as temp
WHERE mod(temp.rnum,2) = 0;

INSERT INTO temp_article
SELECT temp.pub_id, temp.pub_key, temp.title, temp.pub_date, temp.journal
FROM (
    SELECT *, row_number() OVER(ORDER BY pub_id) as rnum
    FROM article
) as temp
WHERE mod(temp.rnum,2) = 0;

INSERT INTO temp_book
SELECT temp.pub_id, temp.pub_key, temp.title, temp.pub_date
FROM (
    SELECT *, row_number() OVER(ORDER BY pub_id) as rnum
    FROM book
) as temp
WHERE mod(temp.rnum,2) = 0;

INSERT INTO temp_incollection
SELECT temp.pub_id, temp.pub_key, temp.title, temp.pub_date
FROM (
    SELECT *, row_number() OVER(ORDER BY pub_id) as rnum
    FROM incollection
) as temp
WHERE mod(temp.rnum,2) = 0;

INSERT INTO temp_phd_thesis
SELECT temp.pub_id, temp.pub_key, temp.title, temp.pub_date
FROM (
    SELECT *, row_number() OVER(ORDER BY pub_id) as rnum
    FROM phd_thesis
) as temp
WHERE mod(temp.rnum,2) = 0;

INSERT INTO temp_masters_thesis
SELECT temp.pub_id, temp.pub_key, temp.title, temp.pub_date
FROM (
    SELECT *, row_number() OVER(ORDER BY pub_id) as rnum
    FROM masters_thesis
) as temp
WHERE mod(temp.rnum,2) = 0;


DROP TABLE IF EXISTS publication CASCADE;
DROP TABLE IF EXISTS book CASCADE;
DROP TABLE IF EXISTS incollection CASCADE;
DROP TABLE IF EXISTS masters_thesis CASCADE;
DROP TABLE IF EXISTS phd_thesis CASCADE;
DROP TABLE IF EXISTS article CASCADE;
DROP TABLE IF EXISTS proceedings CASCADE;
DROP TABLE IF EXISTS inproceedings CASCADE;

ALTER TABLE temp_publication RENAME TO publication;
ALTER TABLE temp_book RENAME TO book;
ALTER TABLE temp_incollection RENAME TO incollection;
ALTER TABLE temp_phd_thesis RENAME TO phd_thesis;
ALTER TABLE temp_masters_thesis RENAME TO masters_thesis;
ALTER TABLE temp_proceedings RENAME TO proceedings;
ALTER TABLE temp_inproceedings RENAME TO inproceedings;
ALTER TABLE temp_article RENAME TO article;