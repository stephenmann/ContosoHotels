#!/bin/bash
# This script runs before the devcontainer is created
# It generates a secure random password for the SQL Server if one doesn't exist

# Determine if we're running locally or in Codespaces
CODESPACES=${CODESPACES:-false}
WORKSPACE_ROOT=${CODESPACES_WORKSPACE_ROOT:-"$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"}

# Check if .env file exists in the workspace root
ENV_FILE="$WORKSPACE_ROOT/.env"
DEV_ENV_FILE="$WORKSPACE_ROOT/.devcontainer/.env"

# Function to generate a secure random password
generate_secure_password() {
    # Generate a 16-character random password with special characters
    # This is only for development use
    if command -v openssl >/dev/null 2>&1; then
        openssl rand -base64 12 | tr -dc 'a-zA-Z0-9!#$%&()*+,-./:;<=>?@[\]^_`{|}~' | head -c 16
    else
        < /dev/urandom tr -dc 'a-zA-Z0-9!#$%&()*+,-./:;<=>?@[\]^_`{|}~' | head -c 16
    fi
}

# Generate the password if needed
if [ "$CODESPACES" = "true" ]; then
    # We're in GitHub Codespaces
    echo "Setting up environment for GitHub Codespaces..."
    
    # Check if SQL_PASSWORD is already set as a Codespace secret
    if [ -z "$SQL_PASSWORD" ]; then
        # Generate a password and set it as an environment variable
        SQL_PASSWORD=$(generate_secure_password)
        echo "Generated a secure SQL password for this Codespace session"
    else
        echo "Using SQL_PASSWORD from Codespace secrets"
    fi
    
    # Create a temporary .env file for this Codespace instance
    echo "# This file is generated for Codespaces - do not commit" > "$DEV_ENV_FILE"
    echo "SQL_PASSWORD=$SQL_PASSWORD" >> "$DEV_ENV_FILE"
    
    echo "Environment setup complete for Codespaces"
else
    # We're running locally
    echo "Setting up local development environment..."
    
    # Check if .env exists
    if [ ! -f "$ENV_FILE" ]; then
        # Create .env file with a warning
        echo "# Environment variables for Contoso Hotels development" > "$ENV_FILE"
        echo "# This file should NOT be committed to source control" >> "$ENV_FILE"
        echo "" >> "$ENV_FILE"
        echo "# SQL Server password" >> "$ENV_FILE"
        echo "SQL_PASSWORD=$(generate_secure_password)" >> "$ENV_FILE"
        
        echo "Created .env file with secure SQL password"
    else
        echo "Using existing .env file"
    fi
    
    echo "Local environment setup complete"
fi

# Output success message
echo "Pre-create initialization complete"
