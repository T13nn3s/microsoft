<#
.SYNOPSIS
    Powershell Script for converting Exchange Legacy DN to X500 Address.
.DESCRIPTION
    When you send email messages to an internal user in Microsoft 365 you can receive a IMCEAEX-NDR. This issue occurs because the 
    value for the LegacyExchangeDN attribute changed. The auto-complete cache in Outlook and/or OWA route the mail messages internally.
    If this route is no longer exists you can receive this error. 

    To solve this, convert the LegacyExchangeDN to an X500-address and add this address as an alias to the users mailbox.
.EXAMPLE
    ConvertTo-X500 -LegacyDN "IMCEAEX-_O=MMS_OU=EXCHANGE+20ADMINISTRATIVE+20GROUP+20+28FYDIBOHF23SPDLT+29_CN=RECIPIENTS_CN=User6ed4e168-addd-4b03-95f5-b9c9a421957358d@mgd.domain.com"
.NOTES
    Created by  : T13nn3s
    Version     : 1.1.0 (1 september 2018)

    Changelog:
    v.1.1.0 (1 september 2018)
    - Adding pipeline support
    - Parameter 'LegacyDN' supports now a array input
    - Write the output back to the pipeline

    v1.0 (19 april 2018)
    - Initial script creation.
.LINK
    More information about IMCEAEX-NDR: https://support.microsoft.com/en-us/help/2807779/
#>

function ConvertTo-X500 {
    [CmdletBinding()]
    param (
        # Specify LegacyExchangeDN
        [Parameter(
            Mandatory = $True,
            HelpMessage = "Specify Legacy DN wich needs to converted to X500.",
            ValueFromPipeline = $True,
            ValueFromPipelinebyPropertyName = $True
        )][alias("DN", "LD", "Legacy")]
        [string[]]
        $LegacyDN
    ) # End param
    
    foreach ($X500 in $LegacyDN) {
        # Convert From Legacy DN to X500
        $X500 = $X500.Replace("_", "/")
        $X500 = $X500.Replace("+20", " ")
        $X500 = $X500.Replace("IMCEAEX-", "")
        $X500 = $X500.Replace("+28", "(")
        $X500 = $X500.Replace("+29", ")")
        $X500 = $X500.Replace("2E", ".")
        $X500 = $X500.Replace("5F", "_")
        $x500 = $x500.Split("@")[0]
    }
    # Return value to pipeline
    New-Object PSObject -Property @{
        X500 = "X500:" + $x500
    }    
} # End function