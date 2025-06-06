#!/bin/bash
# This script runs before the devcontainer is created
# It generates a secure random password for the SQL Server if one doesn't exist

# Determine if we're running locally or in Codespaces
CODESPACES=${CODESPACES:-false}
WORKSPACE_ROOT=${CODESPACES_WORKSPACE_ROOT:-"$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"}

# Ensure working directory is set correctly
cd "$(dirname "${BASH_SOURCE[0]}")"

# Define environment file paths with absolute paths
ENV_FILE="$WORKSPACE_ROOT/.env"
DEV_ENV_FILE="$WORKSPACE_ROOT/.devcontainer/.env"

# Debug information
echo "Running pre-create script from: $(pwd)"
echo "WORKSPACE_ROOT: $WORKSPACE_ROOT"
echo "CODESPACES: $CODESPACES"

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
    
    # Create environment files in both locations to ensure Docker Compose can find them
    echo "# This file is generated for Codespaces - do not commit" > "$ENV_FILE"
    echo "SQL_PASSWORD=$SQL_PASSWORD" >> "$ENV_FILE"
    echo "Created .env file in workspace root: $ENV_FILE"
    
    # Ensure .devcontainer directory exists
    mkdir -p "$(dirname "$DEV_ENV_FILE")"
    
    echo "# This file is generated for Codespaces - do not commit" > "$DEV_ENV_FILE"
    echo "SQL_PASSWORD=$SQL_PASSWORD" >> "$DEV_ENV_FILE"
    echo "Created .env file in .devcontainer: $DEV_ENV_FILE"
    
    # Set permissions to ensure files are readable
    chmod 644 "$ENV_FILE"
    chmod 644 "$DEV_ENV_FILE"
    
    echo "Environment setup complete for Codespaces"
else
    # We're running locally
    echo "Setting up local development environment..."
    
    # Check if root .env exists
    if [ ! -f "$ENV_FILE" ]; then
        # Create .env file with a warning
        echo "# Environment variables for Contoso Hotels development" > "$ENV_FILE"
        echo "# This file should NOT be committed to source control" >> "$ENV_FILE"
        echo "" >> "$ENV_FILE"
        echo "# SQL Server password" >> "$ENV_FILE"
        echo "SQL_PASSWORD=$(generate_secure_password)" >> "$ENV_FILE"
        
        echo "Created .env file with secure SQL password in: $ENV_FILE"
    else
        echo "Using existing .env file: $ENV_FILE"
    fi
    
    # Check if .devcontainer/.env exists
    if [ ! -f "$DEV_ENV_FILE" ]; then
        # Create .env file in .devcontainer as well for Docker Compose
        mkdir -p "$(dirname "$DEV_ENV_FILE")"
        echo "# Environment variables for Contoso Hotels development" > "$DEV_ENV_FILE"
        echo "# This file should NOT be committed to source control" >> "$DEV_ENV_FILE"
        echo "" >> "$DEV_ENV_FILE"
        
        # Extract SQL_PASSWORD from root .env file if it exists
        if [ -f "$ENV_FILE" ]; then
            SQL_PASSWORD=$(grep SQL_PASSWORD "$ENV_FILE" | cut -d= -f2)
            echo "SQL_PASSWORD=$SQL_PASSWORD" >> "$DEV_ENV_FILE"
        else
            echo "SQL_PASSWORD=$(generate_secure_password)" >> "$DEV_ENV_FILE"
        fi
        
        echo "Created .devcontainer/.env file: $DEV_ENV_FILE"
    else
        echo "Using existing .devcontainer/.env file: $DEV_ENV_FILE"
    fi
    
    echo "Local environment setup complete"
fi

# Output success message
echo "Pre-create initialization complete"

# Final verification
echo "Verifying environment files exist:"
if [ -f "$ENV_FILE" ]; then
    echo "✅ Root .env file exists: $ENV_FILE"
else
    echo "❌ Root .env file is missing: $ENV_FILE"
fi

if [ -f "$DEV_ENV_FILE" ]; then
    echo "✅ .devcontainer/.env file exists: $DEV_ENV_FILE"
else
    echo "❌ .devcontainer/.env file is missing: $DEV_ENV_FILE"
fi
