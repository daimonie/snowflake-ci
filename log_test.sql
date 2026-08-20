

SET name = '<% name %>';

USE ROLE GIT_CICD;

CREATE TABLE IF NOT EXISTS log AS
SELECT 'new table!' AS message, CURRENT_TIMESTAMP() as time_col;

ALTER TABLE plant_shop.public.log MODIFY COLUMN message VARCHAR(256);

INSERT INTO plant_shop.public.log (message, time_col) VALUES ('New entry: ' || $name, CURRENT_TIMESTAMP());

SELECT * FROM plant_shop.public.log;
