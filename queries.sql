-- QUERY 1

SELECT TYPE, COUNT(*)
FROM (
      (
       SELECT 'Book' as TYPE, YEAR
       FROM Book
       )
      UNION ALL
      (
       SELECT 'Incollection' as TYPE, YEAR
       FROM Incollection
       )
      UNION ALL
      (
       SELECT 'MastersThesis' as TYPE, YEAR
       FROM MastersThesis
       )
      UNION ALL
      (
       SELECT 'PhdThesis' as TYPE, YEAR
       FROM PhdThesis
       )
      UNION ALL
      (
       SELECT 'Proceedings' as TYPE, YEAR
       FROM Proceedings
       )
      UNION ALL
      (
       SELECT 'Inproceedings' as TYPE, YEAR
       FROM Inproceedings
       )
      UNION ALL
      (
       SELECT 'Article' as TYPE, YEAR
       FROM Article
       )
      ) AS publ_list
WHERE YEAR BETWEEN 2000 AND 2007
GROUP BY TYPE
ORDER BY TYPE;

-- QUERY 2
-- numberOfConferences should be > 200 instead
SELECT *
FROM (
      SELECT CONF, YEAR, COUNT(*) AS numberOfConferences
      FROM (
            SELECT *
            FROM Inproceedings
            WHERE MONTH = 'July'
            ) AS julyConferences
      GROUP BY CONF, YEAR
      ) AS resultSet
WHERE numberOfConferences > 1;

-- QUERY 3
DROP VIEW IF EXISTS PublicationAuthor CASCADE;

CREATE VIEW PublicationAuthor AS 
(
   SELECT pb.PUB_ID, pb.TITLE, pb.YEAR, a.NAME
   FROM Publications AS pb, Authored AS aed, Author AS a
   WHERE pb.PUB_ID = aed.PUB_ID AND aed.AUTHOR_ID = a.AUTHOR_ID
   ORDER BY pb.PUB_ID
);

-- (3a)
SELECT NAME, PUB_ID, TITLE
FROM PublicationAuthor
WHERE NAME = 'Kurni' AND YEAR = 2015;

-- (3b)
SELECT NAME, pa.PUB_ID, pa.TITLE
FROM PublicationAuthor pa, Inproceedings i
WHERE pa.PUB_ID = i.PUB_ID AND NAME = 'Stefan' AND pa.YEAR = 2012 AND i.CONF = 'KDD';

-- (3c)
SELECT *
FROM (
      SELECT NAME, CONF, pa.YEAR, COUNT(*) AS numberOfPapers
      FROM Inproceedings AS i
      JOIN PublicationAuthor AS pa
      ON i.PUB_ID = pa.PUB_ID
      GROUP BY NAME, CONF, pa.YEAR
   ) AS resultSet
WHERE NAME = 'Stefan' AND YEAR = 1980 AND CONF = 'KDD' AND numberOfPapers > 2;


-- QUERY 4
-- I assume that by 'SIGMOD papers' the question meant any publications under
-- conference/journal SIGMOD

DROP VIEW IF EXISTS ConfJournalPapers CASCADE;
DROP VIEW IF EXISTS PapersWithAuthors CASCADE;

CREATE VIEW ConfJournalPapers AS (
   SELECT *
   FROM (
      SELECT PUB_ID, TITLE, CONF AS CONFJOURNAL
      FROM Inproceedings
   ) AS resultSet

   UNION (
      SELECT PUB_ID, TITLE, JOURNAL AS CONFJOURNAL
      FROM Article
   )
);

CREATE VIEW PapersWithAuthors AS (
   SELECT cjp.*, pa.NAME
   FROM ConfJournalPapers cjp, PublicationAuthor pa
   WHERE cjp.PUB_ID = pa.PUB_ID
);

-- number of papers: 10 reduced to 2, 15 reduced to 3
-- (4a)
SELECT DISTINCT pwa1.NAME 
FROM PapersWithAuthors pwa1
WHERE pwa1.NAME IN (
   SELECT DISTINCT NAME
   FROM PapersWithAuthors
   WHERE CONFJOURNAL = 'PVLDB'
   GROUP BY NAME, CONFJOURNAL
   HAVING COUNT(DISTINCT PUB_ID) > 2
) INTERSECT (
   SELECT DISTINCT NAME
   FROM PapersWithAuthors
   WHERE CONFJOURNAL = 'SIGMOD'
   GROUP BY NAME, CONFJOURNAL
   HAVING COUNT(DISTINCT PUB_ID) > 2
);

-- (4b)
SELECT DISTINCT pwa1.NAME 
FROM PapersWithAuthors pwa1
WHERE pwa1.NAME IN (
   SELECT DISTINCT NAME
   FROM PapersWithAuthors
   WHERE CONFJOURNAL = 'PVLDB'
   GROUP BY NAME, CONFJOURNAL
   HAVING COUNT(DISTINCT PUB_ID) > 3
) AND pwa1.NAME NOT IN (
   SELECT DISTINCT NAME
   FROM PapersWithAuthors
   WHERE CONFJOURNAL = 'KDD'
   GROUP BY NAME, CONFJOURNAL
   HAVING COUNT(DISTINCT PUB_ID) = 0
);

-- QUERY 5
SELECT * INTO YearlyCount
FROM (
      SELECT YEAR, COUNT(*) as numberOfPapers
      FROM Inproceedings
      GROUP BY YEAR
      ) AS resultSet;


SELECT *
FROM (
      (
       SELECT '1970-1979' AS YEAR_RANGE, numberOfPapers
       FROM YearlyCount
       WHERE YEAR BETWEEN 1970 AND 1979
       )

      UNION
      (
       SELECT '1980-1989' AS YEAR_RANGE, numberOfPapers
       FROM YearlyCount
       WHERE YEAR BETWEEN 1980 AND 1989
       )

      UNION
      (
       SELECT '1990-1999' AS YEAR_RANGE, numberOfPapers
       FROM YearlyCount
       WHERE YEAR BETWEEN 1990 AND 1999
       )

      UNION
      (
       SELECT '2000-2009' AS YEAR_RANGE, numberOfPapers
       FROM YearlyCount
       WHERE YEAR BETWEEN 2000 AND 2009
       )

      UNION
      (
       SELECT '2010-2019' AS YEAR_RANGE, numberOfPapers
       FROM YearlyCount
       WHERE YEAR BETWEEN 2010 AND 2019
       )
      ) as resultSet
ORDER BY YEAR_RANGE;

DROP TABLE YearlyCount;

-- QUERY 6
DROP VIEW IF EXISTS dataConferences CASCADE;
DROP VIEW IF EXISTS collaborators CASCADE;
DROP VIEW IF EXISTS collaboratorsCount CASCADE;

CREATE VIEW dataConferences AS 
(
   SELECT *
   FROM PapersWithAuthors
   WHERE TITLE SIMILAR TO '%[dD]ata%'
);

CREATE VIEW collaborators AS
(
   SELECT dc1.NAME, dc2.NAME as collaborator
   FROM dataConferences dc1
   JOIN dataConferences dc2 ON dc1.PUB_ID = dc2.PUB_ID AND NOT dc1.NAME = dc2.NAME
);

CREATE VIEW collaboratorsCount AS
(
   SELECT NAME, COUNT(DISTINCT collaborator) as collabCount
   FROM collaborators
   GROUP BY NAME
   ORDER BY collabCount DESC
);

SELECT NAME
FROM collaboratorsCount
WHERE collabCount = (SELECT MAX(collabCount) FROM collaboratorsCount)
ORDER BY NAME;

-- QUERY 7
DROP VIEW IF EXISTS dataConferences5Years CASCADE;

CREATE VIEW dataConferences5Years AS (
    SELECT *
    FROM PapersWithAuthors
    WHERE TITLE SIMILAR TO '%[dD]ata%' AND YEAR BETWEEN 2013 AND 2017
);

SELECT NAME, COUNT(DISTINCT PUB_ID) AS pubCount
FROM dataConferences5Years
GROUP BY NAME
ORDER BY pubCount DESC
LIMIT 10;

-- QUERY 8
DROP VIEW IF EXISTS validConferences CASCADE;

CREATE VIEW validConferences AS (
    SELECT CONF, YEAR, COUNT(*) AS pubCount
    FROM Inproceedings
    WHERE CONF in (
        SELECT DISTINCT CONF 
        FROM Inproceedings 
        WHERE MONTH = 'June'
    )
    GROUP BY CONF, YEAR
);

SELECT DISTINCT CONF
FROM validConferences
WHERE pubCount > 100

-- QUERY 9
-- (9a)
DROP VIEW IF EXISTS diligentAuthors CASCADE;

CREATE VIEW diligentAuthors AS (
   SELECT NAME, YEAR
   FROM PublicationAuthor
   WHERE YEAR BETWEEN 1988 AND 2017 AND NAME SIMILAR TO '% H%'
   GROUP BY NAME, YEAR
   HAVING COUNT(*) = 30
);

SELECT DISTINCT NAME
FROM diligentAuthors;

-- (9b)
SELECT NAME, COUNT(*)
FROM PublicationAuthor
GROUP BY NAME
ORDER BY M_DATE DESC

-- QUERY 10
-- For each year, find the author with the most publication published and the number of publications by that author.
DROP VIEW IF EXISTS yearlyAuthorPubCount CASCADE;

CREATE VIEW yearlyAuthorPubCount AS (
    SELECT YEAR, NAME, COUNT(*) AS pubCount
    FROM PublicationAuthor
    GROUP BY YEAR, NAME
    ORDER BY YEAR, COUNT(*) DESC
);

WITH result AS (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY YEAR ORDER BY pubCount DESC) AS row
    FROM yearlyAuthorPubCount
)
SELECT YEAR, NAME, pubCount
FROM result
WHERE row = 1;

