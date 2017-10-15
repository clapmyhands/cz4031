DROP VIEW IF EXISTS publication_author CASCADE;

CREATE VIEW publication_author AS 
(
   SELECT pb.pub_id, pb.title, a.author_name
   FROM publication AS pb, authored AS aed, author AS a
   WHERE pb.pub_id = aed.pub_id AND aed.author_ID = a.author_ID
   ORDER BY pb.pub_id
);

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
WHERE year BETWEEN 2000 AND 2017
GROUP BY type
ORDER BY type;
--

-- QUERY 2
DROP VIEW IF EXISTS proceedings_inproceedings CASCADE;

CREATE VIEW proceedings_inproceedings AS (
    SELECT *
    FROM proceedings 
    UNION 
    SELECT *
    FROM inproceedings
);

SELECT *
FROM (
      SELECT booktitle, extract(year from pub_date) as year, COUNT(*) AS conferences_count
      FROM (
            SELECT *
            FROM proceedings_inproceedings
            WHERE extract(month from pub_date) = 7
            ) AS julyConferences
      GROUP BY booktitle, year
      ) AS result_set
WHERE conferences_count > 200;
--

-- QUERY 3
DROP VIEW IF EXISTS publication_author CASCADE;

CREATE VIEW publication_author AS 
(
   SELECT pb.pub_id, pb.title, pb.pub_date, a.author_name
   FROM publication AS pb, authored AS aed, author AS a
   WHERE pb.pub_id = aed.pub_id AND aed.author_id = a.author_id
   ORDER BY pb.pub_id
);

-- (3a)
SELECT author_name, pub_id, title
FROM publication_author
WHERE author_name = 'Liming Chen' AND extract(year from pub_date) = 2015;

-- (3b)
SELECT author_name, pa.pub_id, pa.title
FROM publication_author pa, proceedings_inproceedings i
WHERE pa.pub_id = i.pub_id AND author_name = 'Liming Chen' AND extract(year from pa.pub_date) = 2015 AND i.booktitle = 'ICB';

-- (3c)
SELECT *
FROM (
      SELECT author_name, booktitle, EXTRACT(YEAR FROM pa.pub_date) AS year, COUNT(*) AS paper_count
      FROM proceedings_inproceedings AS i
      JOIN publication_author AS pa
      ON i.pub_id = pa.pub_id
      GROUP BY author_name, booktitle, year
   ) AS result_set
WHERE author_name = 'Liming Chen' AND year = 2009 AND paper_count > 1 AND booktitle = 'ACIVS';
--

-- QUERY 4

DROP VIEW IF EXISTS conf_journal_papers CASCADE;
DROP VIEW IF EXISTS papers_with_authors CASCADE;

CREATE VIEW conf_journal_papers AS (
   SELECT *
   FROM (
      SELECT pub_id, title, pub_date, booktitle AS confjournal
      FROM proceedings_inproceedings
   ) AS result_set
   UNION (
      SELECT pub_id, title, pub_date, journal AS confjournal
      FROM article
   )
);

CREATE VIEW papers_with_authors AS (
   SELECT cjp.*, pa.author_name
   FROM conf_journal_papers cjp, publication_author pa
   WHERE cjp.pub_id = pa.pub_id
);

-- (4a)
(
   SELECT DISTINCT author_name
   FROM papers_with_authors
   WHERE confjournal SIMILAR TO '%PVLDB%'
   GROUP BY author_name, confjournal
   HAVING COUNT(DISTINCT pub_id) > 9
) INTERSECT (
   SELECT DISTINCT author_name
   FROM papers_with_authors
   WHERE confjournal SIMILAR TO '%SIGMOD%'
   GROUP BY author_name, confjournal
   HAVING COUNT(DISTINCT pub_id) > 9
);

-- (4b)
SELECT DISTINCT pwa1.author_name 
FROM papers_with_authors pwa1
WHERE pwa1.author_name IN (
   SELECT DISTINCT author_name
   FROM papers_with_authors
   WHERE confjournal SIMILAR TO '%PVLDB%'
   GROUP BY author_name, confjournal
   HAVING COUNT(DISTINCT pub_id) > 14
) AND pwa1.author_name NOT IN (
   SELECT DISTINCT author_name
   FROM papers_with_authors
   WHERE confjournal SIMILAR TO '%KDD%'
);
--

-- QUERY 5
SELECT *
INTO yearly_count
FROM (
      SELECT extract(year from pub_date) as year, COUNT(*) as paper_count
      FROM proceedings_inproceedings
      GROUP BY year
      ) AS result_set;

SELECT *
FROM (
      (
       SELECT '1970-1979' AS year_range, SUM(paper_count) as decade_paper_count
       FROM yearly_count
       WHERE year BETWEEN 1970 AND 1979
       GROUP BY year_range
       )

      UNION
      (
       SELECT '1980-1989' AS year_range, SUM(paper_count) as decade_paper_count
       FROM yearly_count
       WHERE year BETWEEN 1980 AND 1989
       GROUP BY year_range
       )

      UNION
      (
       SELECT '1990-1999' AS year_range, SUM(paper_count) as decade_paper_count
       FROM yearly_count
       WHERE year BETWEEN 1990 AND 1999
       GROUP BY year_range
       )

      UNION
      (
       SELECT '2000-2009' AS year_range, SUM(paper_count) as decade_paper_count
       FROM yearly_count
       WHERE year BETWEEN 2000 AND 2009
       GROUP BY year_range
       )

      UNION
      (
       SELECT '2010-2019' AS year_range, SUM(paper_count) as decade_paper_count
       FROM yearly_count
       WHERE year BETWEEN 2010 AND 2019
       GROUP BY year_range
       )
) as result_set
ORDER BY year_range;

DROP TABLE yearly_count;
--

-- QUERY 6
DROP VIEW IF EXISTS data_conferences CASCADE;
DROP VIEW IF EXISTS collaborators CASCADE;
DROP VIEW IF EXISTS collaborators_count CASCADE;

CREATE VIEW data_conferences AS 
(
   SELECT *
   FROM papers_with_authors
   WHERE confjournal SIMILAR TO '%[dD]ata%'
);

CREATE VIEW collaborators AS
(
   SELECT dc1.author_name, dc2.author_name as collaborator
   FROM data_conferences dc1
   JOIN data_conferences dc2 ON dc1.pub_id = dc2.pub_id AND NOT dc1.author_name = dc2.author_name
);

CREATE VIEW collaborators_count AS
(
   SELECT author_name, COUNT(DISTINCT collaborator) as collab_count
   FROM collaborators
   GROUP BY author_name
   ORDER BY collab_count DESC
);

SELECT author_name, collab_count
FROM collaborators_count
WHERE collab_count = (SELECT MAX(collab_count) FROM collaborators_count)
ORDER BY author_name;
--

-- QUERY 7
DROP VIEW IF EXISTS data_conferences_5year CASCADE;

CREATE VIEW data_conferences_5year AS (
    SELECT *
    FROM papers_with_authors
    WHERE title SIMILAR TO '%[dD]ata%' AND extract(year from pub_date) BETWEEN 2013 AND 2017
);

SELECT author_name, COUNT(DISTINCT pub_id) AS pub_count
FROM data_conferences_5year
GROUP BY author_name
ORDER BY pub_count DESC
LIMIT 10;
--

-- QUERY 8
DROP VIEW IF EXISTS valid_conferences CASCADE;

CREATE VIEW valid_conferences AS (
    SELECT booktitle, extract(year from pub_date) as year, COUNT(*) AS pub_count
    FROM inproceedings
    WHERE booktitle in (
        SELECT DISTINCT booktitle 
        FROM inproceedings
        WHERE extract(month from pub_date) = 6
    )
    GROUP BY booktitle, year
);

SELECT DISTINCT booktitle, year, pub_count
FROM valid_conferences
WHERE pub_count > 100
ORDER BY pub_count;

-- QUERY 9

-- (9a)
SELECT *
INTO h_family
FROM publication_author pa
WHERE pa.author_name SIMILAR TO '% H(\.|[a-z]+)';

SELECT author_name, extract(year from pub_date) as year
INTO author_year_1988_2017
FROM h_family
GROUP BY author_name, year
HAVING
    extract(year from pub_date) <= 2017 AND
    extract(year from pub_date) >= 1988;

SELECT author_name
FROM author_year_1988_2017
GROUP BY author_name
HAVING
    MAX(year)=2017 AND
    MIN(year)=1988 AND
    count(year)=30;

DROP TABLE h_family;
DROP TABLE author_year_1988_2017;

-- (9b)
SELECT author_name
INTO early_author
FROM publication_author pa
WHERE pa.pub_date IN (
    SELECT MIN(pub_date)
    FROM publication_author
)
GROUP BY author_name;

SELECT ea.author_id, ea.author_name, count(*) as pub_count
FROM authored ad, (
    SELECT a.*
    FROM author a, early_author ea
    WHERE a.author_name = ea.author_name
) as ea
WHERE ad.author_id = ea.author_id
GROUP BY ea.author_id, ea.author_name;

DROP TABLE IF EXISTS early_author;
--

-- QUERY 10
-- For each year, find the author with the most publication published and the number of publications by that author.
DROP VIEW IF EXISTS yearly_author_pub_count CASCADE;

CREATE VIEW yearly_author_pub_count AS (
    SELECT extract(year from pub_date) as year, author_name, COUNT(*) AS pub_count
    FROM publication_author
    GROUP BY year, author_name
    ORDER BY year, COUNT(*) DESC
);

WITH result AS (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY year ORDER BY pub_count DESC) AS row
    FROM yearly_author_pub_count
)
SELECT year, author_name, pub_count
FROM result
WHERE row = 1;
