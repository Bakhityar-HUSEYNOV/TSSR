$date = Get-Date
Write-Output $date

$expectedYear = 2025
$expectedMonth = 7
$expectedDay = 8

if ($date.Year -eq $expectedYear -and $date.Month -eq $expectedMonth -and $date.Day -eq $expectedDay) {
    Write-Output "The date matches: $expectedYear-$expectedMonth-$expectedDay"
} else {
    Write-Output "The date does not match."
} 