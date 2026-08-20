-- Parameterized CI/CD log test with metadata-prefixed entries
-- Co-authored with CoCo

SET name = '<% name %>';

USE ROLE GIT_CICD;

CREATE TABLE IF NOT EXISTS log AS
SELECT 'new table!' AS message, CURRENT_TIMESTAMP() as time_col;


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
-- Note: Stored procedure required because snow sql -f splits on semicolons.
CREATE OR REPLACE PROCEDURE plant_shop.public.log_from_metadata(p_name VARCHAR)
RETURNS VARCHAR
LANGUAGE SQL
AS
$$
DECLARE
  cur CURSOR FOR SELECT prefix FROM plant_shop.public.metadata;
  current_prefix VARCHAR;
BEGIN
  FOR record IN cur DO
    current_prefix := record.prefix;
    INSERT INTO plant_shop.public.log (message, time_col)
      VALUES (:current_prefix || ' New entry, probably from CI: ' || :p_name, CURRENT_TIMESTAMP());
  END FOR;
  RETURN 'Done';
END;
$$;

CALL plant_shop.public.log_from_metadata($name);

SELECT * FROM plant_shop.public.log;
 