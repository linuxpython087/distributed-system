#!/usr/bin/env sh
set -e

echo "Starting app (ENV=$APP_ENV)..."

# Example: wait for a dependency (optional)
# until nc -z "$DB_HOST" "$DB_PORT"; do
#   echo "Waiting for DB..."
#   sleep 1
# done

# Example: run migrations (optional)
# python manage.py migrate

# Exec replaces the shell with uvicorn (important for signals)
exec uvicorn main:app --host 0.0.0.0 --port 8000 "$@"