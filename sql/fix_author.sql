-- Query to delete duplicates in author and then update the authored table
-- Copy author table but without duplicates. Use the author_id with the smallest number.
WITH result AS (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY author_name ORDER BY author_id) AS row
    FROM author
)
SELECT author_id, author_name 
INTO distinct_name
FROM result
WHERE row = 1;

UPDATE authored
SET author_id = aid_updater.new_id
FROM (
    SELECT author.author_id as old_id, distinct_name.author_id as new_id
    FROM author, distinct_name
    WHERE author.author_name = distinct_name.author_name AND author.author_id != distinct_name.author_id
) AS aid_updater
WHERE authored.author_id = aid_updater.old_id;

ALTER TABLE distinct_name ADD UNIQUE (author_name);

DROP TABLE author;

ALTER TABLE distinct_name RENAME TO author;
