#!/bin/bash
set -e
export PGPASSWORD=$POSTGRES_PASSWORD;
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER"  --dbname "$DB_NAME" <<-EOSQL
  BEGIN;
    CREATE USER $API_USER WITH PASSWORD '$API_PASS';
    GRANT CONNECT ON DATABASE $DB_NAME TO $API_USER;
    GRANT CREATE ON DATABASE opensociocracy TO $API_USER;

    CREATE USER $SUPERTOKENS_USER WITH PASSWORD '$SUPERTOKENS_PASS';
    GRANT CONNECT ON DATABASE $DB_NAME TO $SUPERTOKENS_USER;
    GRANT CREATE ON DATABASE $DB_NAME TO $SUPERTOKENS_USER;
    
  COMMIT;

EOSQL