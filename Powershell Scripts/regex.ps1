# Requires -Modules Microsoft.PowerShell.Utility

param(
    [Parameter(Mandatory=$true)]
    [string]$CsvPath,
    [string]$IpColumn = 'IPAddress',
    [string]$InvalidOutput = 'InvalidIPs.csv'
)

# Import the CSV
if (!(Test-Path $CsvPath)) {
    Write-Error "CSV file not found: $CsvPath"
    exit 1
}

$rows = Import-Csv -Path $CsvPath

# Function to validate IP address
function Test-ValidIP {
    param([string]$ip)
    try {
        [System.Net.IPAddress]::Parse($ip) | Out-Null
        return $true
    } catch {
        return $false
    }
}

$invalidRows = @()
$validCount = 0
$invalidCount = 0

foreach ($row in $rows) {
    $ip = $row.$IpColumn
    if (-not (Test-ValidIP $ip)) {
        $invalidRows += $row
        $invalidCount++
    } else {
        $validCount++
    }
}

Write-Host "Total rows: $($rows.Count)"
Write-Host "Valid IPs: $validCount"
Write-Host "Invalid IPs: $invalidCount"

if ($invalidRows.Count -gt 0) {
    $invalidRows | Export-Csv -Path $InvalidOutput -NoTypeInformation
    Write-Host "Invalid IPs exported to $InvalidOutput"
} else {
    Write-Host "All IP addresses are valid."
}
