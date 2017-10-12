-- QUERY 1

SELECT type, COUNT(*)
FROM (
      (
       SELECT 'book' as type, extract(year from pub_date) as year
       FROM book
       )
      UNION ALL
      (
       SELECT 'incollection' as type, extract(year from pub_date) as year
       FROM incollection
       )
      UNION ALL
      (
       SELECT 'masters_thesis' as type, extract(year from pub_date) as year
       FROM masters_thesis
       )
      UNION ALL
      (
       SELECT 'phd_thesis' as type, extract(year from pub_date) as year
       FROM phd_thesis
       )
      UNION ALL
      (
       SELECT 'proceedings' as type, extract(year from pub_date) as year
       FROM proceedings
       )
      UNION ALL
      (
       SELECT 'inproceedings' as type, extract(year from pub_date) as year
       FROM inproceedings
       )
      UNION ALL
      (
       SELECT 'article' as type, extract(year from pub_date) as year
       FROM article
       )
      ) AS publ_list
WHERE year BETWEEN 2000 AND 2007
GROUP BY type
ORDER BY type;

-- QUERY 2
-- numberOfConferences should be > 200 instead
SELECT *
FROM (
      SELECT booktitle, extract(year from pub_date) as year, COUNT(*) AS numberOfConferences
      FROM (
            SELECT *
            FROM inproceedings
            WHERE extract(month from pub_date) = 'July'
            ) AS julyConferences
      GROUP BY booktitle, year
      ) AS result_set
WHERE numberOfConferences > 1;

-- QUERY 3
DROP VIEW IF EXISTS publication_author CASCADE;

CREATE VIEW publication_author AS 
(
   SELECT pb.pub_id, pb.title, pb.pub_date, a.name
   FROM publication AS pb, authored AS aed, author AS a
   WHERE pb.pub_id = aed.pub_id AND aed.author_id = a.author_id
   ORDER BY pb.pub_id
);

-- (3a)
SELECT name, pub_id, title
FROM publication_author
WHERE name = 'Kurni' AND extract(year from pub_date) = 2015;

-- (3b)
SELECT name, pa.pub_id, pa.title
FROM publication_author pa, inproceedings i
WHERE pa.pub_id = i.pub_id AND name = 'Stefan' AND pa.pub_date = 2012 AND i.booktitle = 'KDD';

-- (3c)
SELECT *
FROM (
      SELECT name, booktitle, pa.pub_date, COUNT(*) AS paper_count
      FROM inproceedings AS i
      JOIN publication_author AS pa
      ON i.pub_id = pa.pub_id
      GROUP BY name, booktitle, pa.pub_date
   ) AS result_set
WHERE name = 'Stefan' AND extract(year from pub_date) = 1980 AND booktitle = 'KDD' AND paper_count > 2;


-- QUERY 4
-- I assume that by 'SIGMOD papers' the question meant any publications under
-- conference/journal SIGMOD

DROP VIEW IF EXISTS confjournalpapers CASCADE;
DROP VIEW IF EXISTS papers_with_authors CASCADE;

CREATE VIEW confjournalpapers AS (
   SELECT *
   FROM (
      SELECT pub_id, title, booktitle AS confjournal
      FROM inproceedings
   ) AS result_set

   UNION (
      SELECT pub_id, title, journal AS confjournal
      FROM article
   )
);

CREATE VIEW papers_with_authors AS (
   SELECT cjp.*, pa.name
   FROM confjournalpapers cjp, publication_author pa
   WHERE cjp.pub_id = pa.pub_id
);

-- number of papers: 10 reduced to 2, 15 reduced to 3
-- (4a)
SELECT DISTINCT pwa1.name 
FROM papers_with_authors pwa1
WHERE pwa1.name IN (
   SELECT DISTINCT name
   FROM papers_with_authors
   WHERE confjournal = 'PVLDB'
   GROUP BY name, confjournal
   HAVING COUNT(DISTINCT pub_id) > 2
) INTERSECT (
   SELECT DISTINCT name
   FROM papers_with_authors
   WHERE confjournal = 'SIGMOD'
   GROUP BY name, confjournal
   HAVING COUNT(DISTINCT pub_id) > 2
);

-- (4b)
SELECT DISTINCT pwa1.name 
FROM papers_with_authors pwa1
WHERE pwa1.name IN (
   SELECT DISTINCT name
   FROM papers_with_authors
   WHERE confjournal = 'PVLDB'
   GROUP BY name, confjournal
   HAVING COUNT(DISTINCT pub_id) > 3
) AND pwa1.name NOT IN (
   SELECT DISTINCT name
   FROM papers_with_authors
   WHERE confjournal = 'KDD'
   GROUP BY name, confjournal
   HAVING COUNT(DISTINCT pub_id) = 0
);

-- QUERY 5
SELECT * INTO yearly_count
FROM (
      SELECT extract(year from pub_date) as year, COUNT(*) as paper_count
      FROM inproceedings
      GROUP BY year
      ) AS result_set;


SELECT *
FROM (
      (
       SELECT '1970-1979' AS year_range, paper_count
       FROM yearly_count
       WHERE extract(year from pub_date) BETWEEN 1970 AND 1979
       )

      UNION
      (
       SELECT '1980-1989' AS year_range, paper_count
       FROM yearly_count
       WHERE extract(year from pub_date) BETWEEN 1980 AND 1989
       )

      UNION
      (
       SELECT '1990-1999' AS year_range, paper_count
       FROM yearly_count
       WHERE extract(year from pub_date) BETWEEN 1990 AND 1999
       )

      UNION
      (
       SELECT '2000-2009' AS year_range, paper_count
       FROM yearly_count
       WHERE extract(year from pub_date) BETWEEN 2000 AND 2009
       )

      UNION
      (
       SELECT '2010-2019' AS year_range, paper_count
       FROM yearly_count
       WHERE extract(year from pub_date) BETWEEN 2010 AND 2019
       )
      ) as result_set
ORDER BY year_range;

DROP TABLE yearly_count;

-- QUERY 6
DROP VIEW IF EXISTS data_conferences CASCADE;
DROP VIEW IF EXISTS collaborators CASCADE;
DROP VIEW IF EXISTS collaborators_count CASCADE;

CREATE VIEW data_conferences AS 
(
   SELECT *
   FROM papers_with_authors
   WHERE title SIMILAR TO '%[dD]ata%'
);

CREATE VIEW collaborators AS
(
   SELECT dc1.name, dc2.name as collaborator
   FROM data_conferences dc1
   JOIN data_conferences dc2 ON dc1.pub_id = dc2.pub_id AND NOT dc1.name = dc2.name
);

CREATE VIEW collaborators_count AS
(
   SELECT name, COUNT(DISTINCT collaborator) as collab_count
   FROM collaborators
   GROUP BY name
   ORDER BY collab_count DESC
);

SELECT name
FROM collaborators_count
WHERE collab_count = (SELECT MAX(collab_count) FROM collaborators_count)
ORDER BY name;

-- QUERY 7
DROP VIEW IF EXISTS data_conferences_5year CASCADE;

CREATE VIEW data_conferences_5year AS (
    SELECT *
    FROM papers_with_authors
    WHERE title SIMILAR TO '%[dD]ata%' AND extract(year from pub_date) BETWEEN 2013 AND 2017
);

SELECT name, COUNT(DISTINCT pub_id) AS pub_count
FROM data_conferences_5year
GROUP BY name
ORDER BY pub_count DESC
LIMIT 10;

-- QUERY 8
DROP VIEW IF EXISTS valid_conferences CASCADE;

CREATE VIEW valid_conferences AS (
    SELECT booktitle, extract(year from pub_date) as year, COUNT(*) AS pub_count
    FROM inproceedings
    WHERE booktitle in (
        SELECT DISTINCT booktitle 
        FROM inproceedings 
        WHERE extract(month from pub_date) = 'June'
    )
    GROUP BY booktitle, year
);

SELECT DISTINCT booktitle
FROM valid_conferences
WHERE pub_count > 100

-- QUERY 9
-- (9a)
DROP VIEW IF EXISTS diligent_authors CASCADE;

CREATE VIEW diligent_authors AS (
   SELECT name, extract(year from pub_date) as year
   FROM publication_author
   WHERE extract(year from pub_date) BETWEEN 1988 AND 2017 AND name SIMILAR TO '% H[a-z\.]*'
   GROUP BY name, year
   HAVING COUNT(*) = 30
);

SELECT DISTINCT name
FROM diligent_authors;

-- (9b)
SELECT name, COUNT(*)
FROM publication_author
GROUP BY name
ORDER BY pub_date DESC

-- QUERY 10
-- For each year, find the author with the most publication published and the number of publications by that author.
DROP VIEW IF EXISTS yearly_author_pub_count CASCADE;

CREATE VIEW yearly_author_pub_count AS (
    SELECT extract(year from pub_date) as year, name, COUNT(*) AS pub_count
    FROM publication_author
    GROUP BY year, name
    ORDER BY year, COUNT(*) DESC
);

WITH result AS (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY year ORDER BY pub_count DESC) AS row
    FROM yearly_author_pub_count
)
SELECT year, name, pub_count
FROM result
WHERE row = 1;

