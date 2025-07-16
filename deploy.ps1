# PowerShell script for installing and configuring Tailscale with logging

$LogDir = "logs"
$LogFile = "$LogDir\tailscale_install.log"

function Write-Green($msg) { Write-Host $msg -ForegroundColor Green }
function Write-Red($msg) { Write-Host $msg -ForegroundColor Red }
function Write-Yellow($msg) { Write-Host $msg -ForegroundColor Yellow }
function Log($msg) { $msg | Out-File -Append -FilePath $LogFile }

# Check for Administrator privileges
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
    [Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Yellow "This script must be run as Administrator."
    New-Item -ItemType Directory -Force -Path $LogDir | Out-Null
    Log "DEBUG: Not ran as Administrator"
    exit 1
}

# Ensure log directory exists
New-Item -ItemType Directory -Force -Path $LogDir | Out-Null

# Check for curl
if (-not (Get-Command curl.exe -ErrorAction SilentlyContinue)) {
    Write-Yellow "curl not found, attempting to install curl..."
    Log "DEBUG: curl not found, attempting to install curl..."

    try {
        Invoke-Expression "winget install --id curl --silent"
        Write-Green "Installed curl successfully, proceeding..."
        Log "DEBUG: Installed curl successfully"
    } catch {
        Write-Red "Failed to install curl, check the logs for errors."
        Log "ERROR: Failed to install curl"
        exit 1
    }
} else {
    Write-Green "curl is already installed."
    Log "DEBUG: curl already installed"
}

# Check if Tailscale is installed
$tailscaleInstalled = Get-Command tailscale.exe -ErrorAction SilentlyContinue

if ($tailscaleInstalled) {
    Write-Green "Tailscale is already installed"
    Log "DEBUG: Tailscale is already installed"
} else {
    Write-Yellow "Tailscale is not installed, installing now..."
    Log "DEBUG: Tailscale is not installed, installing now..."

    try {
        Invoke-WebRequest https://pkgs.tailscale.com/stable/tailscale-setup-latest.exe -Outfile tailscale-setup-latest.exe >> $LogFile 2>&1
        Start-Process -FilePath .\tailscale-setup-latest.exe -ArgumentList "/quiet" -Wait -NoNewWindow    
        Write-Green "Installed Tailscale"
        Log "DEBUG: Installed Tailscale"
    } catch {
        Write-Red "Failed to install Tailscale, check the logs for details."
        Log "ERROR: Failed to install Tailscale"
        exit 1
    }
    if (Get-Command .\tailscale-setup-latest.exe -ErrorAction SilentlyContinue) {
        Write-Green "Tailscale installed successfully"
        Log "DEBUG: Tailscale installed successfully"
        Remove-Item -Path .\tailscale-setup-latest.exe -Force
    } else {
        Write-Red "Tailscale installation failed"
        Log "ERROR: Tailscale installation failed"
        Remove-Item -Path .\tailscale-setup-latest.exe -Force
        exit 1
}

# Check if Tailscale is logged in
$statusOutput = & tailscale status 2>&1
if ($statusOutput -match "Logged out") {
    Write-Yellow "Tailscale is logged out, attempting to authenticate..."
    Log "DEBUG: Tailscale is logged out, attempting to authenticate..."
} else {
    Write-Green "Tailscale is already authenticated, no need to log in again"
    Log "DEBUG: Tailscale is already authenticated"
    exit 0
    }

}

# Authenticate using auth key from top_secret file
$authKeyPath = ".\top_secret"
if (Test-Path $authKeyPath) {
    Write-Yellow "Secret auth key found, using it to authenticate Tailscale..."
    Log "DEBUG: Secret auth key found, attempting to authenticate Tailscale..."

    $TAILSCALE_AUTH_KEY = (Get-Content $authKeyPath -Raw).Trim()
    Log "Using auth key: $TAILSCALE_AUTH_KEY"

    try {
         tailscale up --authkey $TAILSCALE_AUTH_KEY >> $LogFile 2>&1
        if ($LASTEXITCODE -eq 0) {
            $ip = (& tailscale ip -4).Trim()
            Write-Green "Tailscale authenticated successfully"
            Write-Green "Tailscale is now running, your IP address is: $ip"
            Log "DEBUG: Tailscale authenticated successfully"
            Log "Tailscale is now running, your IP address is: $ip"
        } else {
            throw "tailscale up failed"
        }
    } catch {
        Write-Red "Failed to authenticate Tailscale, check the logs for details."
        Log "ERROR: Failed to authenticate Tailscale"
        exit 1
    }
} else {
    Write-Red "No secret auth key found. Please create a file called 'top_secret'."
    Log "ERROR: No secret auth key found"
    exit 1
}
