#!/bin/bash
set -e

echo "Starting database initialization..."

# Ensure we have the SQL password
if [ -z "$SQL_PASSWORD" ]; then
    echo "SQL_PASSWORD environment variable is not set."
    echo "Checking for generated password file..."
    
    if [ -f "/workspace/.devcontainer/.env" ]; then
        echo "Found .devcontainer/.env file, sourcing it..."
        source /workspace/.devcontainer/.env
    fi
    
    # Final check if we have a password
    if [ -z "$SQL_PASSWORD" ]; then
        echo "ERROR: Could not find a SQL password."
        echo "Please ensure one of the following:"
        echo "1. You have set up the SQL_PASSWORD in your .env file"
        echo "2. The .env file is properly loaded by the container"
        echo "3. For GitHub Codespaces, set SQL_PASSWORD as a secret"
        echo "4. The pre-create.sh script was run successfully"
        exit 1
    fi
fi

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
