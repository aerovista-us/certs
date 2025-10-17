# AeroVista Infrastructure SOP — PostgreSQL (Primary, Local :5432)
_Last updated: 2025-10-16_

## Purpose
Standardize how we connect to, administer, back up, and monitor the primary local PostgreSQL instance running on port **5432**.

## Scope
- Environments: NXCore (Ubuntu 24.04 LTS) local only
- Users: Engineers & services deploying to localhost
- Out of scope: Remote exposure, high availability (covered in future SOPs)

---

## 1) Access

### CLI (psql)
```bash
psql -h localhost -p 5432 -U postgres -d postgres
```

### GUI (DBeaver / pgAdmin)
- Host: `localhost`
- Port: `5432`
- Database: `<DBNAME>` (or `postgres`)
- User: `<USER>`
- SSL: Off (local only)

### App Connection String
```
postgresql://<USER>:<PASSWORD>@localhost:5432/<DBNAME>?sslmode=disable
```

---

## 2) First-Time Database Setup (Least-Privilege)
Run as superuser (e.g., `postgres`) in `psql`:

```sql
CREATE DATABASE appdb TEMPLATE template1;
CREATE ROLE appuser WITH LOGIN PASSWORD 'REPLACE_ME' NOSUPERUSER NOCREATEDB NOCREATEROLE;
GRANT CONNECT ON DATABASE appdb TO appuser;

\c appdb
CREATE SCHEMA app AUTHORIZATION appuser;
ALTER DATABASE appdb SET search_path TO app, public;

REVOKE CREATE ON SCHEMA public FROM PUBLIC;
GRANT USAGE ON SCHEMA app TO appuser;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA app TO appuser;
ALTER DEFAULT PRIVILEGES IN SCHEMA app GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO appuser;
```

**App DSN:**
```
postgresql://appuser:REPLACE_ME@localhost:5432/appdb
```

---

## 3) Backups & Restore

### One‑shot backup
```bash
sudo -u postgres pg_dump -h localhost -p 5432 -F c -d appdb -f /var/backups/appdb_$(date +%F).dump
```

### Restore to a new DB
```bash
createdb -h localhost -U postgres appdb_restore
pg_restore -h localhost -U postgres -d appdb_restore -c -F c /var/backups/appdb_YYYY-MM-DD.dump
```

### Nightly cron @ 02:30
```bash
# crontab -e (for postgres OS user)
30 2 * * * pg_dump -h localhost -p 5432 -F c -d appdb > /var/backups/appdb_$(date +\%F).dump
```

---

## 4) Health & Observability

### Service up?
```bash
pg_isready -h localhost -p 5432
```

### Connections & queries
```sql
SELECT pid, usename, datname, state, now() - query_start AS age, left(query, 120) AS query
FROM pg_stat_activity
ORDER BY state, age DESC
LIMIT 20;
```

### psql introspection shortcuts
```
\l        -- databases
\dn       -- schemas
\dt app.* -- tables in schema app
```

---

## 5) Local-Only Security

- Keep bound to localhost (default).
- Ensure `pg_hba.conf` includes:
```
host all all 127.0.0.1/32 scram-sha-256
host all all ::1/128      scram-sha-256
```
- Prefer SCRAM:  
  ```sql
  ALTER SYSTEM SET password_encryption='scram-sha-256';
  -- then restart postgres
  ```

---

## 6) Performance (Safe Defaults)
In `postgresql.conf` (or `ALTER SYSTEM`), set conservatively and iterate:
```
max_connections = 100
shared_buffers  = 25% of RAM   # e.g., 2GB on an 8GB box
work_mem        = 16MB
maintenance_work_mem = 256MB
effective_cache_size = 50-75% of RAM
```

---

## 7) Troubleshooting

- **Auth failures**
  - Verify user/password, DB name, and `pg_hba.conf`
  - Reset password: `ALTER ROLE appuser WITH PASSWORD 'NEW_ONE';`

- **App can’t connect**
  - Check listener: `ss -lntp | grep 5432`
  - Attempt `psql` using the exact DSN the app uses

- **Locks / migrations stuck**
  - `SELECT * FROM pg_locks WHERE granted=false;`
  - Inspect your migration control table (e.g., `prisma_migrations`)

---

## 8) Ownership & Change Control
- Owner: **Nexus TechWorks**
- Review cadence: Quarterly or after major Postgres upgrades
- Change process: PR to `infrastructure/sops/postgresql.md` + approval by Ops lead
