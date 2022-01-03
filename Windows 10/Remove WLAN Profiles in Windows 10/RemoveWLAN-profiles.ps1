<#
.SYNOPSIS
    This script removes all the wireless profiles and preserves the specific networks you want to keep.

.DESCRIPTION
    Windows saves the WLAN-profiles in XML-files placed in the ProgramData\Microsoft\WlanSvc\Profiles\Interfaces folder. Each Wi-fi adapter indetifies itself with a GUID.
    This script is based on the script wich Ed Wilson from the 'The Scripting Guys' has placed on their blog. It seems That script no longer worked under windows 10
    regarding this question on the technet gallary: https://gallery.technet.microsoft.com/scriptcenter/site/requests/WiFi-removal-script-not-working-on-Windows-10-device-44a09e21.
    I have made some changes to the script to get it working again for Windows 10.

.NOTES
    Created by: T13nn3s
    Version: 1.0 (1 august 2018)
    
.LINK
    Blog page: https://blogs.technet.microsoft.com/heyscriptingguy/2013/06/16/weekend-scripter-use-powershell-to-manage-auto-connect-wireless-networks/
    Script request: https://gallery.technet.microsoft.com/scriptcenter/site/requests/WiFi-removal-script-not-working-on-Windows-10-device-44a09e21
#>
$GUID = (Get-NetAdapter -Name 'wi-fi').interfaceGUID
$path = "C:\ProgramData\Microsoft\Wlansvc\Profiles\Interfaces\$guid"
$network1 = "Mred"
$network2 = "NOKIA Lumia 920_3303"
#$network3 = "" if you want to edit second network

Set-Location $path
Get-ChildItem -Path $path -Recurse |
Foreach-Object {
    [xml]$c = Get-Content -Path $_.FullName
    foreach ($xml in $c) {
        If (($xml.WLANProfile.name -contains $network1) -or ($xml.WLANProfile.name -contains $network2)) {
            #do nothing
        }
        Else {
            Remove-Item $_.Name
        }
    }
}

