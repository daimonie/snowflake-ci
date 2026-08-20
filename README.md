# snowflake-ci

## Creating the workspace

First setup requires the authentication secret and API integration:
```sql
-- Create a basic authentication secret for GitLab or Github integration
-- Co-authored with CoCo

-- Create a secret with basic authentication credentials for GitLab
-- Replace the placeholder values with your actual GitLab credentials
USE ROLE ACCOUNTADMIN;
USE DATABASE PLANT_SHOP;
USE SCHEMA PUBLIC;
CREATE SECRET gitlab_auth_secret
    TYPE = PASSWORD
    USERNAME = '<<username>>'
    PASSWORD = '<<github token>>'
    COMMENT = 'GitLab authentication secret for repository integration';

CREATE OR REPLACE API INTEGRATION my_git_api_integration
  API_PROVIDER = git_https_api
  API_ALLOWED_PREFIXES = ('https://github.com/daimonie')
  ALLOWED_AUTHENTICATION_SECRETS = (gitlab_auth_secret)
  ENABLED = TRUE;
```

After that, create a workspace from the git repo in the snowsight UI (see https://docs.snowflake.com/en/user-guide/ui-snowsight/workspaces-git#label-create-a-git-workspace ).

Make sure that the PAT being used from snowflake <> Gitlab/Github has write access on code contents, or it will silently fail.

## CI integration
For this, we're looking at the [Snowflake CI/CD component for gitlab](https://docs.snowflake.com/en/developer-guide/snowflake-cli/cicd/gitlab-component). 

First, we create a user for gitlab to use in CI/CD:
```sql

CREATE USER gitlab_cicd_user
  TYPE = SERVICE
  WORKLOAD_IDENTITY = (
    TYPE = OIDC
    ISSUER = 'https://gitlab.com'
    SUBJECT = 'project_path:<<gitlab user/repo>>:ref_type:branch:ref:main'
  );
```