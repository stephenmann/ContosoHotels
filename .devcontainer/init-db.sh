#!/bin/bash
set -e

# Default password if environment variable is not set
SQL_PASSWORD=${SQL_PASSWORD:-ContosoP@ssw0rd!}

# Wait for SQL Server to be ready (with timeout)
max_attempts=30
attempt=0
echo "Waiting for SQL Server to be ready..."
while [ $attempt -lt $max_attempts ]; do
  if /opt/mssql-tools/bin/sqlcmd -S db -U sa -P "$SQL_PASSWORD" -Q "SELECT 1" &>/dev/null; then
    echo "SQL Server is ready."
    break
  fi
  echo "Waiting for SQL Server to be ready... (attempt $((attempt+1))/$max_attempts)"
  sleep 2
  attempt=$((attempt+1))
done

if [ $attempt -eq $max_attempts ]; then
  echo "Error: Could not connect to SQL Server after $max_attempts attempts."
  exit 1
fi

echo "Checking if database exists..."

# Check if database exists
DB_EXISTS=$(/opt/mssql-tools/bin/sqlcmd -S db -U sa -P "$SQL_PASSWORD" -Q "SELECT COUNT(*) FROM sys.databases WHERE name='ContosoHotelsDb'" -h -1)

if [ "$DB_EXISTS" -eq "0" ]; then
  echo "Database does not exist, creating it..."
  /opt/mssql-tools/bin/sqlcmd -S db -U sa -P "$SQL_PASSWORD" -Q "CREATE DATABASE ContosoHotelsDb"
  echo "Database created, now running migrations..."
  cd /workspace
  dotnet ef database update
  echo "Migrations applied successfully!"
else
  echo "Database already exists."
fi

echo "Database initialization complete!"
