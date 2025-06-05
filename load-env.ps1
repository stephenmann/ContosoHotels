# PowerShell script to load environment variables from .env file

# Check if .env file exists
if (Test-Path -Path ".env") {
    Write-Host "Loading environment variables from .env file..." -ForegroundColor Cyan
    
    # Read the .env file line by line
    Get-Content ".env" | ForEach-Object {
        # Skip comments and empty lines
        if (-not ($_ -match "^\s*#") -and $_ -match "\S") {
            # Split by the first equals sign
            $name, $value = $_ -split '=', 2
            
            # Trim whitespace
            $name = $name.Trim()
            $value = $value.Trim()
            
            # Set environment variable for current process
            [Environment]::SetEnvironmentVariable($name, $value, "Process")
            Write-Host "  Set $name environment variable" -ForegroundColor Green
        }
    }
} else {
    Write-Host "Warning: .env file not found. Please copy .env.example to .env and set your values." -ForegroundColor Yellow
}

# Output current SQL_PASSWORD status
if ([Environment]::GetEnvironmentVariable("SQL_PASSWORD", "Process")) {
    Write-Host "SQL_PASSWORD is set in the environment" -ForegroundColor Green
} else {
    Write-Host "SQL_PASSWORD is not set in the environment" -ForegroundColor Red
    Write-Host "Please set SQL_PASSWORD in your .env file or directly in your environment" -ForegroundColor Yellow
}
