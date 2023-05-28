#!/bin/bash
pg_dump -s -O -h localhost -U postgres -d opensociocracy -n opensociocracy_api > ./docker-postgres/sql/api-schema.sql 
pg_dump -s -O -h localhost -U postgres -d opensociocracy -n supertokens > ./docker-postgres/sql/supertokens-schema.sql 
pg_dump --data-only  --column-inserts  -O -h localhost -U postgres -d opensociocracy --table opensociocracy_api.org_roles  > ./docker-postgres/sql/api-org-roles.sql 