$test = "I love Minecraft"

$ip = ("255.255.255.255")
if ($ip -match '^((25[0-5]|2[0-4][0-9]|1[0-9]{2}|[0-9]?[0-9])(\.(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[0-9]?[0-9])){3})$') {
    Write-Output "Valid IPv4 address: $ip"
} else {
    Write-Output "Not a valid IPv4 address."
}