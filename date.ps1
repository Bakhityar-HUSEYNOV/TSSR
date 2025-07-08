$date = "2025-13-08"  # Or any string you want to check

try {
    $parsedDate = [datetime]$date
    Write-Output "The variable is a valid date."
} catch {
    Write-Output "The variable is NOT a valid date."
} 