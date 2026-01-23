$date = "2025-13-08"  # $date = Get-date

try {
    $IfDate = [datetime]$date
    Write-Output "yo $IfDate est une date valide"
} catch {
    Write-Output "no no no"
} 
