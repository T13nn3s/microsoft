# Convert-LegacyExchangeDN-to-X500
When you send email messages to an internal user in Microsoft 365 you can receive an IMCEAEX-NDR. This issue occurs because the value for the LegacyExchangeDN attribute changed. The auto-complete cache in Outlook and/or OWA route the mail messages internally. If this route is no longer exists you can receive this error.
To solve this problem, convert the LegacyExchangeDN to an X500-address and add this address as an alias to the user's mailbox in ECP.

# How to use
First, you need to load this function into your active Powershell console.
```powershell
Import-Module ConvertTo-X500
```
Call the function ConvertTo-X500
```powershell 
ConvertTo-X500 -LegacyDN "IMCEAEX-_O=MMS_OU=EXCHANGE+20ADMINISTRATIVE+20GROUP+20+28FYDIBOHF23SPDLT+29_CN=RECIPIENTS_CN=User6ed4e168-addd-4b03-95f5-b9c9a421957358d@mgd.domain.com"
```

# Changelog

## [1.1.0] 1 september 2018

### Added
- Adding pipeline support
- Parameter 'LegacyDN' supports now a array input
- Write the output back to the pipeline

## [1.0] 19 april 2018
- Initial script creation.



