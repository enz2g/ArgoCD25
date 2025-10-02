param(
[string]$ipAddress = "127.0.0.1",
[string]$hostname = "argocd.local"
)


# Define the path to the hosts file
$hostsFilePath = "$env:SystemRoot\System32\drivers\etc\hosts"


# Construct the entry string
$newEntry = "`n$ipAddress`t$hostname"

# Check if the entry already exists to prevent duplication
if ((Get-Content $hostsFilePath | Select-String -Pattern "$ipAddress\s+$hostname") -eq $null) {
    # Add the entry to the hosts file
    Add-Content -Path $hostsFilePath -Value $newEntry

    Write-Host "Entry '$ipAddress $hostname' added to hosts file."

    # Flush DNS cache to apply changes immediately
    ipconfig /flushdns
    Write-Host "DNS cache flushed."
} else {
    Write-Host "Entry '$ipAddress $hostname' already exists in hosts file. No changes made."
}