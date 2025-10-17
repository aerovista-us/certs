-- Initialize databases for AeroVista services
-- This script runs once when PostgreSQL container is first created
--
-- NOTE: To run manually, use:
--   sudo docker exec -i postgres psql -U aerovista -d aerovista < /srv/core/config/postgres/init-databases.sql
--
-- The PostgreSQL superuser is 'aerovista' (not 'postgres'). See compose-postgres.yml line 13.

-- Create databases
CREATE DATABASE n8n;
CREATE DATABASE authelia;
CREATE DATABASE grafana;
CREATE DATABASE formbricks;
CREATE DATABASE keycloak;

-- Create roles with limited privileges
CREATE ROLE n8n_user WITH LOGIN PASSWORD 'CHANGE_ME_n8n_password';
CREATE ROLE authelia_user WITH LOGIN PASSWORD 'CHANGE_ME_authelia_password';
CREATE ROLE grafana_user WITH LOGIN PASSWORD 'CHANGE_ME_grafana_password';
CREATE ROLE formbricks_user WITH LOGIN PASSWORD 'CHANGE_ME_formbricks_password';

-- Grant privileges
GRANT ALL PRIVILEGES ON DATABASE n8n TO n8n_user;
GRANT ALL PRIVILEGES ON DATABASE authelia TO authelia_user;
GRANT ALL PRIVILEGES ON DATABASE grafana TO grafana_user;
GRANT ALL PRIVILEGES ON DATABASE formbricks TO formbricks_user;

-- Grant schema permissions (required for PostgreSQL 15+)
-- This allows users to create tables in the public schema
\c authelia
GRANT ALL ON SCHEMA public TO authelia_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO authelia_user;

\c n8n
GRANT ALL ON SCHEMA public TO n8n_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO n8n_user;

\c grafana
GRANT ALL ON SCHEMA public TO grafana_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO grafana_user;

-- Create read-only role for PostgREST (API access)
CREATE ROLE web_anon NOLOGIN;
GRANT CONNECT ON DATABASE aerovista TO web_anon;

-- Enable extensions
\c aerovista
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_stat_statements";

\c n8n
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

\c authelia
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Log completion
\echo 'Database initialization complete!'

