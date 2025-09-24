#!/usr/bin/env bash
# Reset the Artists Collector PostgreSQL database
# ⚠️  WARNING: This will DELETE ALL ARTIST DATA from APIs!
# -----------------------------------------------------
# 1. Drops the database (if it exists)
# 2. Re-creates it  
# 3. Runs the initialization script to create tables and sample data

set -euo pipefail

# ────────────────────────────────────────────────────────────
# Config - change here if you tweak docker-compose.yml
DB_NAME="${ARTISTS_POSTGRES_DB:-artists_collector}"
DB_USER="${ARTISTS_POSTGRES_USER:-artists_user}"
DB_PASSWORD="${ARTISTS_POSTGRES_PASSWORD:-artists_password}"
DB_PORT="54323"                    # host-side port mapped to Artists Postgres
PG_CONTAINER="artists-postgres"    # service name in docker-compose.yml
ARTISTS_CONTAINER="artists-collector"  # service that manages artists data
# ────────────────────────────────────────────────────────────

echo "⚠️  WARNING: You are about to RESET the Artists database!"
echo "   This will DELETE ALL collected artist data from external APIs."
echo "   Database: $DB_NAME (user: $DB_USER)"
echo ""
read -p "Are you ABSOLUTELY sure? Type 'DELETE_ARTISTS' to confirm: " confirmation

if [ "$confirmation" != "DELETE_ARTISTS" ]; then
    echo "❌ Reset cancelled. Database preserved."
    exit 0
fi

echo "🔄 Resetting artists database \"$DB_NAME\"..."

# Check if containers are running
if ! docker compose ps "$PG_CONTAINER" | grep -q "Up"; then
    echo "❌ Container $PG_CONTAINER is not running. Start with: docker compose up -d"
    exit 1
fi

# 1. Drop database
echo "🗑️  Dropping database..."
docker compose exec "$PG_CONTAINER" \
  psql -U "$DB_USER" -d postgres -p 5432 -c "DROP DATABASE IF EXISTS ${DB_NAME} WITH (FORCE);"

# 2. Re-create database
echo "🆕 Creating fresh database..."
docker compose exec "$PG_CONTAINER" \
  psql -U "$DB_USER" -d postgres -p 5432 -c "CREATE DATABASE ${DB_NAME};"

echo "✅ Fresh artists database created."

# 3. Initialize database schema and sample data
echo "🔄 Initializing database schema and sample data..."
if docker compose ps "$ARTISTS_CONTAINER" | grep -q "Up"; then
    docker compose exec "$ARTISTS_CONTAINER" python migrations/init_db.py
else
    echo "⚠️  Artists collector container not running, skipping initialization."
    echo "   Start it with: docker compose up -d $ARTISTS_CONTAINER"
    echo "   Then run: docker compose exec $ARTISTS_CONTAINER python migrations/init_db.py"
fi

echo "🎉 Artists database reset and initialized!"
echo "   - Database: $DB_NAME"
echo "   - Port: $DB_PORT" 
echo "   - Base vide prête pour de vraies données"