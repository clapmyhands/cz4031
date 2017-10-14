CREATE VIEW duplicates AS (
    SELECT ad.pub_id, a.author_name, count(1)
    FROM author a, authored ad
    WHERE a.author_id = ad.author_id
    GROUP BY ad.pub_id, a.author_name
    HAVING count(1) > 1;
)

CREATE VIEW duplicate_in_author AS (
    SELECT resultSet.pub_id, resultSet.author_id
    FROM (
        SELECT d.pub_id, ad.author_id, ROW_NUMBER() OVER (PARTITION BY d.pub_id ORDER BY ad.author_id ASC) AS pos
        FROM duplicates d, authored ad, author a
        WHERE 
            d.pub_id = ad.pub_id AND
            ad.author_id = a.author_id AND
            d.author_name = a.author_name
    ) as resultSet
    WHERE pos > 1
)

SELECT * INTO dia_table
FROM duplicate_in_author;

DELETE FROM authored ad
USING dia_table dia
WHERE ad.pub_id = dia.pub_id AND ad.author_id = dia.author_id;

DROP VIEW duplicate_in_author;
DROP VIEW duplicates;
DROP TABLE dia_table;