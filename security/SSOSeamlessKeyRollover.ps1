<#
.SYNOPSIS
    This script is rollovering the Kerberos decryption keys for Azure Seamless SSO.
.EXAMPLE
    PS C:\> .\SSOSeamlessKeyRollover.ps1
.NOTES
    Created by: T13nn3s
    Date: 01-06-2021
    Based on: https://feedback.azure.com/forums/169401-azure-active-directory/suggestions/33773926-automate-seamless-sso-kerberos-decryption-key-roll?tracking_code=7692a629bf86f0973236aab87ea3e996
#>

Write-Host "[*] Starting Kerberos Key rollover" -ForegroundColor Yellow
try {
    Write-Host "[*] Setting domain admin user account credentials"
    $DomainCred = Get-Credential -UserName $(whoami) -Message "Please fill in the domain admin user account."
    Write-Host "[*] Setting domain admin user account credentials.Done" -ForegroundColor Green
}
Catch {
    $error.clear()
    Write-Host "[*] Setting domain admin user account credentials.Failed" -ForegroundColor Red
    break
}

try {
    Write-Host "[*] Setting script location"
    Set-Location 'C:\Program Files\Microsoft Azure Active Directory Connect\'
    Write-Host "[+] Setting script location.Done" -ForegroundColor Green
}
Catch {
    $error.clear()
    Write-Host "[-] Setting script location.Failed" -ForegroundColor Green
    break
}
try {
    Write-Host "[*] Importing AzureADSSO.psd1"
    Import-Module .\AzureADSSO.psd1
    Write-Host "[+] Importing AzureADSSO.psd1.Done" -ForegroundColor Green
}
Catch {
    $error.clear()
    Write-Host "[-] Importing AzureADSSO.psd1.Failed" -ForegroundColor Red
    break
}

try {
    Write-Host "[*] Running New-AzureADSSOAuthenticationContext"
    New-AzureADSSOAuthenticationContext
    Write-Host "[+] New-AzureADSSOAuthenticationContext.Done" -ForegroundColor Green
}
Catch {
    $error.clear()
    Write-Host "[-] New-AzureADSSOAuthenticationContext.Failed" -ForegroundColor Red
    break
}

try {
    Write-Host "[*] Update computer password AZUREADSSOACC"
    Update-AzureADSSOForest -OnPremCredentials $DomainCred
    Write-Host "[+] Update computer password AZUREADSSOACC.Done" -ForegroundColor Green
}
Catch {
    $error.clear()
    Write-Host "[-] Update computer password AZUREADSSOACC.Failed" -ForegroundColor Red
    break
}

# Checking config
Write-Host "Outputting current config"
Get-AzureADSSOStatus | ConvertFrom-Json










