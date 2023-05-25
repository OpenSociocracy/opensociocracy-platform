#!/bin/bash
pg_dump -s -O -h localhost -U postgres -d opensociocracy -n opensociocracy_api > ./docker-postgres/sql/api-schema.sql 
pg_dump -s -O -h localhost -U postgres -d opensociocracy -n supertokens > ./docker-postgres/sql/supertokens-schema.sql 
# pg_dump -h localhost -U postgres -d izzup -n ultri_auth > ./misc/database/ulri_auth_schema.sql 
# pg_dump -h localhost -U postgres -d izzup > ./misc/database/izzup_all.sql