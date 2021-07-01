#Requires -Version 7
#$ErrorActionPreference = "SilentlyContinue"
function DomainHealthChecker {
    [CmdletBinding()]
    param (
        # Check a single domain
        [Parameter(
            Mandatory, ParameterSetName = 'domain',
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True,
            HelpMessage = "Specify domain name whose SPF, DMARC and DKIM record should be checked.",
            Position = 1)]
        [string]$Name,

        # Check domains from a file
        [Parameter(
            Mandatory, ParameterSetName = 'file',
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True,
            HelpMessage = "Specifies file name which contains a list of domain names.",
            Position = 2)]
        [System.IO.FileInfo]$File,

        # DNS Server to use
        [Parameter(Mandatory = $false,
            Position = 3)]
        [string]$Server = "1.1.1.1"
    )

    begin {

        class SpfDkimDmarc {
            [string]$Name
            [string]$SPFRecord
            [string]$SpfAdvisory
            [string]$DmarcRecord
            [string]$DmarcAdvisory
            [string]$DkimRecord
            [string]$DkimAdvisory
        
            # Constructor: Created the object with the SPF, DMARC and DKIM values
            SpfDkimDmarc (
                [string]$d, 
                [string]$SPF,
                [string]$SpfAdvisory,
                [string]$DMARC,
                [string]$DmarcAdvisory,
                [string]$DKIM,
                [string]$DkimAdvisory
            ) {
                $this.Name = $d
                $this.SPFRecord = $SPF
                $this.SpfAdvisory = $SpfAdvisory
                $this.DmarcRecord = $DMARC
                $this.DmarcAdvisory = $DmarcAdvisory
                $this.DkimRecord = $DKIM
                $this.DkimAdvisory = $DkimAdvisory
            }
        }
    }

    process {
        if ($file) {
            if (-not(Test-Path $file)) {
                Write-error "$($file) does not exist"
                return
            }
        }

        function StartDomainHealthCheck($domain) {

            # Check SPF-record
            $SPF = Resolve-DnsName -type TXT -name $Domain -server $Server -ErrorAction SilentlyContinue | where-object { $_.strings -match "v=spf1" } | Select-Object -ExpandProperty strings
            $SPFCount = ($SPF | Measure-Object).Count
            if ($SPFCount -eq 0) {
                $SpfAdvisory = "No SPF-record found"
            }
            elseif ($SPF -is [array]) {
                $SpfAdvisory = "Domain has more than one SPF-record. One SPF record for one domain. This is explicitly defined in RFC4408"
            }
            elseif ($SPF -notmatch "-all") {
                $SpfAdvisory = "An SPF-record is configured but the policy is not sufficiently strict"
            }
            elseif ($SPF -match "-all") {
                $SpfAdvisory = "An SPF-record is configured and the policy is sufficiently strict."
            }
            elseif ($SPF -match "^?all") {
                $SpfAdvisory = "Your domain has a valid SPF record but your policy is not effective enough."
            }
            Elseif ($SPF -notmatch "v=spf1" -or "all") {
                $SpfAdvisory = "No SPF-record configured."
            }

            # Check DKIM-record
            $DKIM = $null
            $CnameSelector1 = Resolve-DnsName -Type CNAME -Name selector1._domainkey.$Domain -server $Server -ErrorAction SilentlyContinue
            if ($CnameSelector1.NameHost -notcontains "domainkey") {
                $DkimAdvisory = "We couldn't find a DKIM record associated with your domain."
            }
            else {
                $DKIM = Resolve-DnsName -Type TXT -Name $CnameSelector1.namehost -server $Server | Select-Object -ExpandProperty strings
                if ($DKIM -like "") {
                    $DkimAdvisory = "We couldn't find a DKIM record associated with your domain."
                }
                elseif ($DKIM -match "v=DKIM1") {
                    $DkimAdvisory = "DKIM-record is valid."
                } 
            }
        
            # Check DMARC-record
            $DMARC = Resolve-DnsName -type TXT -name _dmarc.$Domain -Server $Server -ErrorAction SilentlyContinue | where-object { $_.strings -match "v=DMARC1" } | Select-Object -ExpandProperty strings
            if ($DMARC -like "") {
                $DmarcAdvisory = "Does not have a DMARC record. This domain is at risk to being abused by phishers and spammers."
            }
            elseif ($DMARC -match "p=quarantine") {
                $DmarcAdvisory = "Domain has a DMARC record and it is set to p=quarantine. To fully take advantage of DMARC, the policy should be set to p=reject."
            }
            elseif ($DMARC -match "p=reject") {
                $DmarcAdvisory = "Domain has a DMARC record and your DMARC policy will prevent abuse of your domain by phishers and spammers."
            }
            elseif ($DMARC -match "p=none") {
                $DmarcAdvisory = "Domain has a valid DMARC record but the DMARC (subdomain) policy does not prevent abuse of your domain by phishers and spammers."
            }

            $ReturnValues = [SpfDkimDmarc]::New($Domain, $SPF, $SpfAdvisory, $DMARC, $DmarcAdvisory, $DKIM, $DkimAdvisory)
            $ReturnValues
        }

        if ($file) {
            foreach ($Domain in (Get-Content -Path $file)) {
                StartDomainHealthCheck -Domain $Domain
            }
        }
        if ($Name) {
            foreach ($Domain in $Name) {
                StartDomainHealthCheck -Domain $Name
            }
        }      
    }
    end {}
}
