$date = "2025-13-08"  # Or any string you want to check

try {
    $IfDate = [datetime]$date
    Write-Output "yo $IfDate est une date valide"
} catch {
    Write-Output "no no no"
} 