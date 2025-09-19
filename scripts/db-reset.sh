#!/usr/bin/env bash
# Reset the local PostgreSQL database used by TypeFlick
# -----------------------------------------------------
# 1. Drops the database (if it exists)
# 2. Re-creates it
# 3. Generates Drizzle SQL, runs migrations, then seeds

set -euo pipefail

# ────────────────────────────────────────────────────────────
# Config - change here if you tweak docker-compose.yml
DB_NAME="${POSTGRES_DB:-typeflick1}"
DB_USER="${POSTGRES_USER:-postgres}"
DB_PORT="54322"          # host-side port mapped to Postgres
PG_CONTAINER="postgres"  # service name in docker-compose.yml
NEXT_CONTAINER="nextjs"  # service that has pnpm + Drizzle scripts
# ────────────────────────────────────────────────────────────

echo "🔄  Resetting database \"$DB_NAME\" (user: $DB_USER)…"

# 1. Drop database
docker compose exec "$PG_CONTAINER" \
  psql -U "$DB_USER" -p 5432 -c "DROP DATABASE IF EXISTS ${DB_NAME};"

# 2. Re-create database
docker compose exec "$PG_CONTAINER" \
  psql -U "$DB_USER" -p 5432 -c "CREATE DATABASE ${DB_NAME};"

echo "✅  Fresh database created."

# 3. Run Drizzle generate → migrate → seed inside the Next.js container
docker compose exec "$NEXT_CONTAINER" pnpm db:migrate
docker compose exec "$NEXT_CONTAINER" pnpm db:seed

echo "🎉  Database reset, migrated and seeded!"
