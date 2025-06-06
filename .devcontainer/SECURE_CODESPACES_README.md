# Contoso Hotels - GitHub Codespaces Setup

This document provides information about running the Contoso Hotels project in GitHub Codespaces with security best practices.

## Security-First Approach

This project uses a security-first approach for handling sensitive information:

1. **No hardcoded passwords** - Passwords are never stored in source code
2. **Secrets handling** - Uses GitHub Codespaces secrets or securely generated passwords
3. **Environment isolation** - Development credentials are isolated to each environment

## Setting Up GitHub Codespaces

For the best experience with GitHub Codespaces, we recommend:

1. Add a repository secret in GitHub called `SQL_PASSWORD` with a secure password
   - Go to your GitHub repository → Settings → Secrets and variables → Codespaces → New repository secret
   - This password will be available as an environment variable in your Codespace

2. If no secret is provided, a secure random password will be generated at startup
   - This password will be stored in the `.devcontainer/.env` file
   - Note: This file is not committed to source control

## Local Development Setup

For local development:

1. Copy `.devcontainer/.env.example` to a new file called `.env` in the root directory
2. Add a secure password in the `.env` file:
   ```
   SQL_PASSWORD=your_secure_password_here
   ```
3. Start the development container which will use this password

## Important Security Notes

- Never commit `.env` files containing real credentials to source control
- The `.gitignore` file is configured to exclude `.env` files
- For production deployments, use Azure Key Vault or another secure secret management system
- Regularly rotate development passwords, especially in shared environments

## Troubleshooting

If you encounter issues:

1. Verify that your `.env` file exists and has the proper format
2. Check if the `SQL_PASSWORD` environment variable is accessible in your container
3. For GitHub Codespaces, verify that your repository secret is correctly configured
