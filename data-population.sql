-- DATA POPULATION 
CREATE TABLE Book (
   pub_id INT,
   title VARCHAR(50),
   year INT
);

INSERT INTO Book VALUES 
(1, 'Data Science', 2000),
(2, 'Data Analytics', 2007),
(3, 'Big Data', 2010),
(4, 'Neural Networks', 2011),
(5, 'Database Principles', 1997),
(6, 'Database Principles', 2000),
(7, 'Neural Networks', 2005);

CREATE TABLE Incollection (
   pub_id INT,
   title VARCHAR(50),
   year INT
);

INSERT INTO Incollection VALUES 
(11, 'Data Science', 2001),
(12, 'Big Data', 2013),
(13, 'Neural Networks', 2011),
(14, 'Database Principles', 1980),
(15, 'Database Principles', 1997),
(16, 'Big Data', 2000),
(17, 'Database Principles', 2004);

CREATE TABLE MastersThesis (
   pub_id INT,
   title VARCHAR(50),
   year INT
);

INSERT INTO MastersThesis VALUES 
(21, 'Data Science', 2002),
(22, 'Big Data', 2015),
(23, 'Neural Networks', 2011),
(24, 'Data Science', 1967),
(25, 'Database Principles', 1950),
(26, 'Database Principles', 2017),
(27, 'Big Data', 2002);

CREATE TABLE PhdThesis (
   pub_id INT,
   title VARCHAR(50),
   year INT
);

INSERT INTO PhdThesis VALUES 
(31, 'Big Data', 2000),
(32, 'Neural Networks', 2011),
(33, 'Database Principles', 2011),
(34, 'Neural Networks', 1975),
(35, 'Neural Networks', 1890),
(36, 'Data Science', 1999),
(37, 'Neural Networks', 2001);

CREATE TABLE Proceedings (
   pub_id INT,
   title VARCHAR(50),
   year INT,
   month VARCHAR(15),
   conf VARCHAR(10)
);

INSERT INTO Proceedings VALUES 
(41, 'Big Data', 1997, 'July', 'KDD'),
(42, 'Neural Networks', 2012, 'September', 'KDD'),
(43, 'Database Principles', 2014, 'June', 'KDD'),
(44, 'Database Principles', 2014, 'October', 'KDD'),
(45, 'Database Principles', 1996, 'April', 'KDD'),
(46, 'Big Data', 2015, 'May', 'KDD'),
(47, 'Database Principles', 2002, 'November', 'KDD');

CREATE TABLE Inproceedings (
   pub_id INT,
   title VARCHAR(50),
   year INT,
   month VARCHAR(15),
   conf VARCHAR(10)
);

INSERT INTO Inproceedings VALUES 
(51, 'Big Data', 1997, 'July', 'KDD'),
(52, 'Data Science', 2014, 'June', 'KDD'),
(53, 'Database Principles', 1997, 'July', 'KDD'),
(54, 'Principles of Database', 1980, 'July', 'KDD'),
(55, 'Neural Networks', 1980, 'July', 'KDD'),
(56, 'Database Principles', 2014, 'February', 'KDD'),
(57, 'Data Science', 2002, 'December', 'KDD'),
(58, 'Data Science', 2003, 'December', 'SIGMOD'),
(59, 'Database Principles', 2013, 'December', 'PVLDB');

CREATE TABLE Article (
   pub_id INT,
   title VARCHAR(50),
   year INT,
   journal VARCHAR(10)
);

INSERT INTO Article VALUES 
(61, 'Big Data', 1990, 'SIGMOD'),
(62, 'Neural Networks', 2013, 'PVLDB'),
(63, 'Database Principles', 2002, 'PVLDB'),
(64, 'Data Science', 1994, 'SIGMOD'),
(65, 'Data Science', 1997, 'KDD'),
(66, 'Data Science', 2014, 'SIGMOD'),
(67, 'Database Principles', 2004, 'PVLDB'),
(68, 'Database Principles', 2001, 'PVLDB');

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
    SELECT pub_id, title, year
    FROM Proceedings
    )

   UNION
   (
    SELECT pub_id, title, year
    FROM Inproceedings
    )

   UNION
   (
    SELECT pub_id, title, year
    FROM Article
    )
) as publ_list;

CREATE TABLE Author 
(
   author_id INT,
   name VARCHAR(30)
);

INSERT INTO Author VALUES 
(101, 'Michael'),
(102, 'Kurni'),
(103, 'Stefan'),
(104, 'Hart'),
(105, 'Cong Gao');

CREATE TABLE Authored (
   pub_id INT,
   author_id INT
);

INSERT INTO Authored VALUES 
(1, 101),
(2, 101),
(3, 101),
(4, 102),
(5, 103),
(6, 104),
(7, 104),
(11, 101),
(12, 101),
(13, 101),
(14, 102),
(15, 103),
(16, 104),
(17, 104),
(21, 101),
(22, 102),
(23, 103),
(24, 102),
(25, 103),
(26, 104),
(27, 104),
(51, 101),
(51, 102),
(51, 103),
(52, 101),
(52, 102),
(52, 103),
(53, 101),
(53, 102),
(53, 103),
(54, 102),
(54, 103),
(55, 103),
(56, 101),
(56, 103),
(57, 102),
(61, 101),
(61, 102),
(61, 103),
(62, 101),
(62, 102),
(62, 103),
(62, 104),
(63, 101),
(63, 102),
(63, 104),
(64, 102),
(64, 103),
(64, 104),
(65, 102),
(65, 103),
(66, 102),
(66, 103),
(66, 104),
(67, 102),
(67, 104),
(68, 104),
(68, 105);

CREATE VIEW PublicationAuthor AS 
(
   SELECT pb.pub_id, pb.title, pb.year, a.name
   FROM Publications AS pb, Authored AS aed, Author AS a
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