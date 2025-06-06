# GitHub Codespaces Configuration

This file provides guidance on configuring GitHub Codespaces secrets for secure development.

## Required Secrets

To run this project in GitHub Codespaces, you should set up the following secrets:

| Secret Name | Description | Required |
|-------------|-------------|----------|
| `SQL_PASSWORD` | Password for the SQL Server database | Recommended |

## Setting Up Secrets in GitHub

1. Navigate to your GitHub repository
2. Go to Settings → Secrets and variables → Codespaces
3. Click "New repository secret"
4. Add the secret name and value
5. Click "Add secret"

## Automatic Fallback

If the `SQL_PASSWORD` secret is not provided:
- A secure random password will be generated when the Codespace starts
- This password will be stored in a temporary `.env` file within the Codespace
- The password will be used for the duration of the Codespace session

## Best Practices

- Use strong, unique passwords for development environments
- Regularly rotate development credentials
- Never hardcode sensitive information in your source code
- Use different credentials for development, testing, and production environments
