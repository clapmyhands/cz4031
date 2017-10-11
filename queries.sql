-- QUERY 1

SELECT type, COUNT(*)
FROM (
      (
       SELECT 'Book' as type, year
       FROM Book
       )
      UNION ALL
      (
       SELECT 'Incollection' as type, year
       FROM Incollection
       )
      UNION ALL
      (
       SELECT 'MastersThesis' as type, year
       FROM MastersThesis
       )
      UNION ALL
      (
       SELECT 'PhdThesis' as type, year
       FROM PhdThesis
       )
      UNION ALL
      (
       SELECT 'Proceedings' as type, year
       FROM Proceedings
       )
      UNION ALL
      (
       SELECT 'Inproceedings' as type, year
       FROM Inproceedings
       )
      UNION ALL
      (
       SELECT 'Article' as type, year
       FROM Article
       )
      ) AS publ_list
WHERE year BETWEEN 2000 AND 2007
GROUP BY type
ORDER BY type;

-- QUERY 2
-- numberOfConferences should be > 200 instead
SELECT *
FROM (
      SELECT conf, year, COUNT(*) AS numberOfConferences
      FROM (
            SELECT *
            FROM Inproceedings
            WHERE month = 'July'
            ) AS julyConferences
      GROUP BY conf, year
      ) AS resultSet
WHERE numberOfConferences > 1;

-- QUERY 3
DROP VIEW IF EXISTS PublicationAuthor CASCADE;

CREATE VIEW PublicationAuthor AS 
(
   SELECT pb.pub_id, pb.title, pb.year, a.name
   FROM publication AS pb, Authored AS aed, Author AS a
   WHERE pb.pub_id = aed.pub_id AND aed.author_id = a.author_id
   ORDER BY pb.pub_id
);

-- (3a)
SELECT name, pub_id, title
FROM PublicationAuthor
WHERE name = 'Kurni' AND year = 2015;

-- (3b)
SELECT name, pa.pub_id, pa.title
FROM PublicationAuthor pa, Inproceedings i
WHERE pa.pub_id = i.pub_id AND name = 'Stefan' AND pa.year = 2012 AND i.conf = 'KDD';

-- (3c)
SELECT *
FROM (
      SELECT name, conf, pa.year, COUNT(*) AS paper_count
      FROM Inproceedings AS i
      JOIN PublicationAuthor AS pa
      ON i.pub_id = pa.pub_id
      GROUP BY name, conf, pa.year
   ) AS resultSet
WHERE name = 'Stefan' AND year = 1980 AND conf = 'KDD' AND paper_count > 2;


-- QUERY 4
-- I assume that by 'SIGMOD papers' the question meant any publications under
-- conference/journal SIGMOD

DROP VIEW IF EXISTS ConfJournalPapers CASCADE;
DROP VIEW IF EXISTS PapersWithAuthors CASCADE;

CREATE VIEW ConfJournalPapers AS (
   SELECT *
   FROM (
      SELECT pub_id, title, conf AS confjournal
      FROM Inproceedings
   ) AS resultSet

   UNION (
      SELECT pub_id, title, journal AS confjournal
      FROM Article
   )
);

CREATE VIEW PapersWithAuthors AS (
   SELECT cjp.*, pa.name
   FROM ConfJournalPapers cjp, PublicationAuthor pa
   WHERE cjp.pub_id = pa.pub_id
);

-- number of papers: 10 reduced to 2, 15 reduced to 3
-- (4a)
SELECT DISTINCT pwa1.name 
FROM PapersWithAuthors pwa1
WHERE pwa1.name IN (
   SELECT DISTINCT name
   FROM PapersWithAuthors
   WHERE confjournal = 'PVLDB'
   GROUP BY name, confjournal
   HAVING COUNT(DISTINCT pub_id) > 2
) INTERSECT (
   SELECT DISTINCT name
   FROM PapersWithAuthors
   WHERE confjournal = 'SIGMOD'
   GROUP BY name, confjournal
   HAVING COUNT(DISTINCT pub_id) > 2
);

-- (4b)
SELECT DISTINCT pwa1.name 
FROM PapersWithAuthors pwa1
WHERE pwa1.name IN (
   SELECT DISTINCT name
   FROM PapersWithAuthors
   WHERE confjournal = 'PVLDB'
   GROUP BY name, confjournal
   HAVING COUNT(DISTINCT pub_id) > 3
) AND pwa1.name NOT IN (
   SELECT DISTINCT name
   FROM PapersWithAuthors
   WHERE confjournal = 'KDD'
   GROUP BY name, confjournal
   HAVING COUNT(DISTINCT pub_id) = 0
);

-- QUERY 5
SELECT * INTO YearlyCount
FROM (
      SELECT year, COUNT(*) as paper_count
      FROM Inproceedings
      GROUP BY year
      ) AS resultSet;


SELECT *
FROM (
      (
       SELECT '1970-1979' AS year_range, paper_count
       FROM YearlyCount
       WHERE year BETWEEN 1970 AND 1979
       )

      UNION
      (
       SELECT '1980-1989' AS year_range, paper_count
       FROM YearlyCount
       WHERE year BETWEEN 1980 AND 1989
       )

      UNION
      (
       SELECT '1990-1999' AS year_range, paper_count
       FROM YearlyCount
       WHERE year BETWEEN 1990 AND 1999
       )

      UNION
      (
       SELECT '2000-2009' AS year_range, paper_count
       FROM YearlyCount
       WHERE year BETWEEN 2000 AND 2009
       )

      UNION
      (
       SELECT '2010-2019' AS year_range, paper_count
       FROM YearlyCount
       WHERE year BETWEEN 2010 AND 2019
       )
      ) as resultSet
ORDER BY year_range;

DROP TABLE YearlyCount;

-- QUERY 6
DROP VIEW IF EXISTS dataConferences CASCADE;
DROP VIEW IF EXISTS collaborators CASCADE;
DROP VIEW IF EXISTS collaboratorsCount CASCADE;

CREATE VIEW dataConferences AS 
(
   SELECT *
   FROM PapersWithAuthors
   WHERE title SIMILAR TO '%[dD]ata%'
);

CREATE VIEW collaborators AS
(
   SELECT dc1.name, dc2.name as collaborator
   FROM dataConferences dc1
   JOIN dataConferences dc2 ON dc1.pub_id = dc2.pub_id AND NOT dc1.name = dc2.name
);

CREATE VIEW collaboratorsCount AS
(
   SELECT name, COUNT(DISTINCT collaborator) as collabCount
   FROM collaborators
   GROUP BY name
   ORDER BY collabCount DESC
);

SELECT name
FROM collaboratorsCount
WHERE collabCount = (SELECT MAX(collabCount) FROM collaboratorsCount)
ORDER BY name;

-- QUERY 7
DROP VIEW IF EXISTS dataConferences5Years CASCADE;

CREATE VIEW dataConferences5Years AS (
    SELECT *
    FROM PapersWithAuthors
    WHERE title SIMILAR TO '%[dD]ata%' AND year BETWEEN 2013 AND 2017
);

SELECT name, COUNT(DISTINCT pub_id) AS pubCount
FROM dataConferences5Years
GROUP BY name
ORDER BY pubCount DESC
LIMIT 10;

-- QUERY 8
DROP VIEW IF EXISTS validConferences CASCADE;

CREATE VIEW validConferences AS (
    SELECT conf, year, COUNT(*) AS pubCount
    FROM Inproceedings
    WHERE conf in (
        SELECT DISTINCT conf 
        FROM Inproceedings 
        WHERE month = 'June'
    )
    GROUP BY conf, year
);

SELECT DISTINCT conf
FROM validConferences
WHERE pubCount > 100

-- QUERY 9
-- (9a)
DROP VIEW IF EXISTS diligentAuthors CASCADE;

CREATE VIEW diligentAuthors AS (
   SELECT name, year
   FROM PublicationAuthor
   WHERE year BETWEEN 1988 AND 2017 AND name SIMILAR TO '% H%'
   GROUP BY name, year
   HAVING COUNT(*) = 30
);

SELECT DISTINCT name
FROM diligentAuthors;

-- (9b)
SELECT name, COUNT(*)
FROM PublicationAuthor
GROUP BY name
ORDER BY M_DATE DESC

-- QUERY 10
-- For each year, find the author with the most publication published and the number of publications by that author.
DROP VIEW IF EXISTS yearlyAuthorPubCount CASCADE;

CREATE VIEW yearlyAuthorPubCount AS (
    SELECT year, name, COUNT(*) AS pubCount
    FROM PublicationAuthor
    GROUP BY year, name
    ORDER BY year, COUNT(*) DESC
);

WITH result AS (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY year ORDER BY pubCount DESC) AS row
    FROM yearlyAuthorPubCount
)
SELECT year, name, pubCount
FROM result
WHERE row = 1;

