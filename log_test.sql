-- GitLab and GitHub CI/CD integration setup with workload identity for Snowflake
-- Co-authored with CoCo
USE ROLE ACCOUNTADMIN;
USE DATABASE PLANT_SHOP;
USE SCHEMA PUBLIC;
USE WAREHOUSE COMPUTE_WH;
CREATE TABLE IF NOT EXISTS log AS
SELECT 'new table!' AS message, CURRENT_TIMESTAMP() as time_col;

INSERT INTO plant_shop.public.log (message, time_col) VALUES ('new entry', CURRENT_TIMESTAMP());

SELECT * FROM plant_shop.public.log;

CREATE USER IF NOT EXISTS gitlab_cicd_user
  TYPE = SERVICE
  WORKLOAD_IDENTITY = (
    TYPE = OIDC
    ISSUER = 'https://gitlab.com'
    SUBJECT = 'project_path:daimonie/snowflake-ci:ref_type:branch:ref:main'
  );

CREATE USER IF NOT EXISTS github_cicd_user
  TYPE = SERVICE
  WORKLOAD_IDENTITY = (
    TYPE = OIDC
    ISSUER = 'https://token.actions.githubusercontent.com'
    SUBJECT = 'repo:daimonie/snowflake-ci:ref:refs/heads/main'
  );

SELECT CURRENT_ACCOUNT();