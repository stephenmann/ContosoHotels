# PowerShell script to start SQL Server in Docker for local development

# Load environment variables from .env file if it exists
if (Test-Path -Path "./load-env.ps1") {
    . ./load-env.ps1
}

# Define a default password if none is provided
$SQL_PASSWORD = if ($env:SQL_PASSWORD) { $env:SQL_PASSWORD } else { "DefaultP@ssw0rd" }

Write-Host "Starting SQL Server container for Contoso Hotels development..." -ForegroundColor Green

# Check if the container already exists
$containerExists = docker ps -a --filter "name=contoso-sql" --format "{{.Names}}"

if ($containerExists -eq "contoso-sql") {
    # Check if it's running
    $containerRunning = docker ps --filter "name=contoso-sql" --format "{{.Names}}"
    
    if ($containerRunning -eq "contoso-sql") {
        Write-Host "SQL Server container is already running." -ForegroundColor Yellow
    } else {
        Write-Host "Starting existing SQL Server container..." -ForegroundColor Cyan
        docker start contoso-sql
    }
} else {
    Write-Host "Creating new SQL Server container..." -ForegroundColor Cyan
    docker run -e "ACCEPT_EULA=Y" -e "SA_PASSWORD=$SQL_PASSWORD" -e "MSSQL_PID=Express" `
        --name contoso-sql -p 1433:1433 -d mcr.microsoft.com/mssql/server:2019-latest
}

Write-Host "`nSQL Server is now available at:" -ForegroundColor Green
Write-Host "Server: localhost,1433" -ForegroundColor White
Write-Host "User: sa" -ForegroundColor White
Write-Host "Password: $SQL_PASSWORD" -ForegroundColor White
Write-Host "Database: ContosoHotelsDb (will be created by Entity Framework)" -ForegroundColor White

Write-Host "`nUse the following connection string in appsettings.Development.json:" -ForegroundColor Green
Write-Host "Server=localhost,1433;Database=ContosoHotelsDb;User Id=sa;Password=$SQL_PASSWORD;TrustServerCertificate=True;MultipleActiveResultSets=true" -ForegroundColor White

Write-Host "`nTo update the database structure, run:" -ForegroundColor Green
Write-Host 'dotnet ef database update' -ForegroundColor White

Write-Host "`nPress any key to exit..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
