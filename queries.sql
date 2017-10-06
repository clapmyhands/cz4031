-- DATA POPULATION 
CREATE TABLE Book (
    ID INT,
    YEAR INT,
    AUTHOR VARCHAR(30)
);

INSERT INTO Book VALUES 
(1, 2000, 'Kurni'),
(2, 2007, 'Michael'),
(3, 2010, 'Stefan'),
(4, 2011, 'Kurni'),
(5, 1997, 'Stefan'),
(6, 2000, 'Stefan'),
(7, 2005, 'Stefan');

CREATE TABLE Incollection (
    ID INT,
    YEAR INT,
    AUTHOR VARCHAR(30)
);

INSERT INTO Incollection VALUES 
(1, 2001, 'Michael'),
(2, 2013, 'Michael'),
(3, 2011, 'Michael'),
(4, 1980, 'Michael'),
(5, 1997, 'Michael'),
(6, 2000, 'Michael'),
(7, 2004, 'Michael');

CREATE TABLE MastersThesis (
    ID INT,
    YEAR INT,
    AUTHOR VARCHAR(30)
);

INSERT INTO MastersThesis VALUES 
(1, 2002, 'Kurni'),
(2, 2015, 'Kurni'),
(3, 2011, 'Kurni'),
(4, 1967, 'Kurni'),
(5, 1950, 'Kurni'),
(6, 2017, 'Kurni'),
(7, 2002, 'Kurni');

CREATE TABLE PhdThesis (
    ID INT,
    YEAR INT,
    AUTHOR VARCHAR(30)
);

INSERT INTO PhdThesis VALUES 
(1, 2000, 'Stefan'),
(2, 2011, 'Stefan'),
(3, 2011, 'Stefan'),
(4, 1975, 'Stefan'),
(5, 1890, 'Stefan'),
(6, 1999, 'Stefan'),
(7, 2001, 'Stefan');

CREATE TABLE Proceedings (
    ID INT,
    YEAR INT,
    MONTH VARCHAR(15),
    AUTHOR VARCHAR(30),
    CONF VARCHAR(10)
);

INSERT INTO Proceedings VALUES 
(1, 1997, 'July', 'Stefan', 'KDD'),
(2, 2012, 'September', 'Stefan', 'KDD'),
(3, 2014, 'June', 'Stefan', 'KDD'),
(4, 2014, 'October', 'Stefan', 'KDD'),
(5, 1996, 'April', 'Stefan', 'KDD'),
(6, 2015, 'May', 'Stefan', 'KDD'),
(7, 2002, 'November', 'Stefan', 'KDD');

CREATE TABLE Inproceedings (
    ID INT,
    YEAR INT,
    MONTH VARCHAR(15),
    AUTHOR VARCHAR(30),
    CONF VARCHAR(10)
);

INSERT INTO Inproceedings VALUES 
(1, 1997, 'July', 'Stefan', 'KDD'),
(2, 2012, 'March', 'Stefan', 'KDD'),
(3, 1997, 'July', 'Stefan', 'KDD'),
(4, 1980, 'July', 'Stefan', 'KDD'),
(5, 1980, 'July', 'Stefan', 'KDD'),
(6, 1980, 'February', 'Stefan', 'KDD'),
(7, 2002, 'December', 'Stefan', 'KDD');

CREATE TABLE Article (
    ID INT,
    YEAR INT,
    AUTHOR VARCHAR(30)
);

INSERT INTO Article VALUES 
(1, 1990, 'Michael'),
(2, 2013, 'Michael'),
(3, 2002, 'Kurni'),
(4, 1994, 'Kurni'),
(5, 1997, 'Stefan'),
(6, 2014, 'Stefan'),
(7, 2004, 'Hart');

SELECT * INTO TABLE Publications
FROM 
(
    (
        SELECT *
        FROM Book
    )

    UNION
    (
        SELECT *
        FROM Incollection
    )

    UNION
    (
        SELECT *
        FROM MastersThesis
    )
    
    UNION
    (
        SELECT *
        FROM PhdThesis
    )

    UNION
    (
        SELECT ID, YEAR, AUTHOR
        FROM Proceedings
    )

    UNION
    (
        SELECT ID, YEAR, AUTHOR
        FROM Inproceedings
    )

    UNION
    (
        SELECT *
        FROM Article
    )
) as publ_list;

-- QUERY 1

SELECT NAME, COUNT(*)
FROM (
    (
        SELECT 'Book' as NAME, YEAR
        FROM Book
    )
    UNION ALL
    (
        SELECT 'Incollection' as NAME, YEAR
        FROM Incollection
    )
    UNION ALL
    (
        SELECT 'MastersThesis' as NAME, YEAR
        FROM MastersThesis
    )
    UNION ALL
    (
        SELECT 'PhdThesis' as NAME, YEAR
        FROM PhdThesis
    )
    UNION ALL
    (
        SELECT 'Proceedings' as NAME, YEAR
        FROM Proceedings
    )
    UNION ALL
    (
        SELECT 'Inproceedings' as NAME, YEAR
        FROM Inproceedings
    )
    UNION ALL
    (
        SELECT 'Article' as NAME, YEAR
        FROM Article
    )
) AS publ_list
WHERE YEAR BETWEEN 2000 AND 2007
GROUP BY NAME
ORDER BY NAME;

-- QUERY 2
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

-- QUERY 3(a)
SELECT AUTHOR, ID
FROM Publications
WHERE AUTHOR = 'Kurni' AND YEAR = '2015';

-- QUERY 3(b)
SELECT AUTHOR, ID
FROM Inproceedings
WHERE AUTHOR = 'Stefan' AND YEAR = '2002' AND CONF = 'KDD';

-- QUERY 3(c)
SELECT *
FROM (
      SELECT AUTHOR, CONF, YEAR, COUNT(*) AS numberOfPapers
      FROM Inproceedings
      GROUP BY AUTHOR, CONF, YEAR
) AS resultSet
WHERE AUTHOR = 'Stefan' AND YEAR = '1980' AND CONF = 'KDD' AND numberOfPapers > 2;

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