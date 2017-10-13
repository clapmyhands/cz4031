CREATE INDEX book_date ON book(pub_date);
CREATE INDEX article_date ON article(pub_date);
CREATE INDEX incollection_date ON incollection(pub_date);
CREATE INDEX masters_thesis_date ON masters_thesis(pub_date);
CREATE INDEX phd_thesis_date ON phd_thesis(pub_date);
CREATE INDEX proceedings_date ON proceedings(pub_date);
CREATE INDEX inproceedings_date ON inproceedings(pub_date);

CREATE INDEX author_name ON author(author_name);

CREATE INDEX proceedings_conference ON proceedings(booktitle);
CREATE INDEX inproceedings_conference ON inproceedings(booktitle);
CREATE INDEX article_journal ON article USING HASH(journal);
