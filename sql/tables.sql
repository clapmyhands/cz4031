-- CREATE TABLE queries
CREATE TABLE publication (
    pub_id INT PRIMARY KEY,
    pub_key TEXT UNIQUE,
    title TEXT,
    pub_date DATE
);

CREATE TABLE book (
    pub_id INT PRIMARY KEY,
    pub_key TEXT UNIQUE,
) INHERITS publication;

CREATE TABLE incollection (
    pub_id INT PRIMARY KEY,
    pub_key TEXT UNIQUE,
) INHERITS publication;

CREATE TABLE masters_thesis (
    pub_id INT PRIMARY KEY,
    pub_key TEXT UNIQUE,
) INHERITS publication;

CREATE TABLE phd_thesis (
    pub_id INT PRIMARY KEY,
    pub_key TEXT UNIQUE,
) INHERITS publication;

CREATE TABLE proceedings (
    pub_id INT PRIMARY KEY,
    pub_key TEXT UNIQUE,
    booktitle TEXT
) INHERITS publication;

CREATE TABLE inproceedings (
    pub_id INT PRIMARY KEY,
    pub_key TEXT UNIQUE,
    booktitle TEXT
) INHERITS publication;

CREATE TABLE article (
    pub_id INT PRIMARY KEY,
    pub_key TEXT UNIQUE,
    journal TEXT
) INHERITS publication;

CREATE TABLE author (
   author_id INTEGER PRIMARY KEY,
   author_name TEXT
);

CREATE TABLE authored (
   pub_id INT,
   author_id INT,
   PRIMARY KEY(pub_id, author_id)
);
