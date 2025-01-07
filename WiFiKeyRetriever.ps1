<#
.SYNOPSIS
    Lists all available Wi-Fi profiles and retrieves the saved Wi-Fi password for a selected network.

.DESCRIPTION
    This script uses `netsh wlan` commands to list Wi-Fi profiles and retrieve the password
    for a chosen profile.

.NOTES
    Requires administrative privileges to access Wi-Fi passwords.

.EXAMPLE
    .\WiFiKeyRetriever.ps1
    Displays a list of profiles and prompts to select one to retrieve its password.

.AUTHOR
    Sam (ident)

.TWITTER
    https://twitter.com/1d3nt

.GITHUB
    https://github.com/1d3nt

.EMAIL
    ident@simplecoders.com

.VBFORUMS
    https://www.vbforums.com/member.php?113656-ident

.ORCID
    https://orcid.org/0009-0007-1363-3308
#>

# Get the list of Wi-Fi profiles
Write-Host "Retrieving saved Wi-Fi profiles..." -ForegroundColor Cyan
$profilesOutput = netsh wlan show profiles

# Parse the profile names from the output
$profileNames = ($profilesOutput | Select-String -Pattern "All User Profile\s+:\s+(.*)" | ForEach-Object { $_.Matches.Groups[1].Value }).Trim()

# Check if any profiles exist
if (-not $profileNames) {
    Write-Host "No saved Wi-Fi profiles found on this machine." -ForegroundColor Red
    return
}

# Display the profiles and prompt the user to select one
Write-Host "`nAvailable Wi-Fi Profiles:" -ForegroundColor Yellow
$profileNames | ForEach-Object { Write-Host "- $_" }

$selectedProfile = Read-Host "`nEnter the Wi-Fi profile name from the list above"

# Validate the user's selection
if (-not $profileNames -contains $selectedProfile) {
    Write-Host "Invalid profile name. Please ensure the name matches exactly." -ForegroundColor Red
    return
}

# Retrieve the details for the selected profile
$profileDetails = netsh wlan show profile name="$selectedProfile" key=clear

# Extract and display the Wi-Fi password
$passwordMatch = $profileDetails | Select-String -Pattern "Key Content\s+:\s+(.*)"

if ($passwordMatch) {
    $password = $passwordMatch.Matches.Groups[1].Value
    Write-Host "`nWi-Fi Password for '$selectedProfile': $password" -ForegroundColor Green
} else {
    Write-Host "`nNo password found for profile '$selectedProfile'. It might be an open network." -ForegroundColor Yellow
}
