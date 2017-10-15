
DROP INDEX IF EXISTS book_date;
DROP INDEX IF EXISTS article_date;
DROP INDEX IF EXISTS incollection_date;
DROP INDEX IF EXISTS masters_thesis_date;
DROP INDEX IF EXISTS phd_thesis_date;
DROP INDEX IF EXISTS proceedings_date;
DROP INDEX IF EXISTS inproceedings_date;

DROP INDEX IF EXISTS proceedings_conference;
DROP INDEX IF EXISTS inproceedings_conference;
DROP INDEX IF EXISTS article_journal;


/*
CREATE INDEX book_date ON book(pub_date);
CREATE INDEX article_date ON article(pub_date);
CREATE INDEX incollection_date ON incollection(pub_date);
CREATE INDEX masters_thesis_date ON masters_thesis(pub_date);
CREATE INDEX phd_thesis_date ON phd_thesis(pub_date);
CREATE INDEX proceedings_date ON proceedings(pub_date);
CREATE INDEX inproceedings_date ON inproceedings(pub_date);

CREATE INDEX proceedings_conference ON proceedings(booktitle);
CREATE INDEX inproceedings_conference ON inproceedings(booktitle);
CREATE INDEX article_journal ON article(journal);
*/

--Query 3
DROP VIEW IF EXISTS publication_author CASCADE;

CREATE VIEW publication_author AS 
(
   SELECT pb.pub_id, pb.title, pb.pub_date, a.author_name
   FROM publication AS pb, authored AS aed, author AS a
   WHERE pb.pub_id = aed.pub_id AND aed.author_id = a.author_id
   ORDER BY pb.pub_id
);

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

-- Query 5
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
