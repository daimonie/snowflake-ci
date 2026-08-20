-- Parameterized CI/CD log test with metadata-prefixed entries
-- Co-authored with CoCo

SET name = '<% name %>';

USE ROLE GIT_CICD;

CREATE TABLE IF NOT EXISTS log AS
SELECT 'new table!' AS message, CURRENT_TIMESTAMP() as time_col;

ALTER TABLE plant_shop.public.log MODIFY COLUMN message VARCHAR(256);

INSERT INTO plant_shop.public.log (message, time_col) VALUES ('New entry: ' || $name, CURRENT_TIMESTAMP());

SELECT * FROM plant_shop.public.log;

CREATE TABLE IF NOT EXISTS metadata AS 
    (SELECT '[A]:' AS prefix
    UNION ALL
    SELECT '[B]:' AS prefix)
;
SELECT * FROM metadata;

-- Approach: CURSOR loop over metadata via stored procedure
-- Iterates row-by-row using a FOR loop over a cursor.
-- Reference: https://docs.snowflake.com/en/developer-guide/snowflake-scripting/cursors

DECLARE
  cur CURSOR FOR SELECT prefix FROM plant_shop.public.metadata;
  current_prefix VARCHAR;
BEGIN
  FOR record IN cur DO
    current_prefix := record.prefix;
    INSERT INTO plant_shop.public.log (message, time_col)
      VALUES (:current_prefix || ' New entry: ' || $name, CURRENT_TIMESTAMP());
  END FOR;
END;

SELECT * FROM plant_shop.public.log;
 