#Requires -Version 7

[CmdletBinding()]
param (
    # Parameter for checking a
    [Parameter(
        Mandatory, ParameterSetName = 'domain',
        ValueFromPipeline = $True,
        ValueFromPipelineByPropertyName = $True,
        HelpMessage = "Specify domain name whose SPF, DMARC and DKIM record should be checked."
    )]
    [string]
    $domain,

    [Parameter(
        Mandatory, ParameterSetName = 'file',
        ValueFromPipeline = $True,
        ValueFromPipelineByPropertyName = $True,
        HelpMessage = "Specifies file name which contains a list of domain names."
    )]
    [string]
    $file,
    
    [Parameter(
        HelpMessage = "ExporttoCSV"
    )]
    [string]
    $ExportCSV
)

function CheckSpfDkimDmarc {
    param (
        $domain
    )

    foreach ($d in $domain) {
        write-host ""
        Write-Host "$d - DMARC"
        $DMARC = Resolve-DnsName -type TXT -name _dmarc.$d -ErrorAction SilentlyContinue | where-object { $_.strings -match "v=DMARC1" } | Select-Object -ExpandProperty strings
        if ($DMARC -match "p=none") {
            $DmarcComment = "$d has a valid DMARC record but the DMARC (subdomain) policy does not prevent abuse of your domain by phishers and spammers."
            $DMARC
            Write-Host "$d has a valid DMARC record but the DMARC (subdomain) policy does not prevent abuse of your domain by phishers and spammers." -ForegroundColor Yellow
        }
        elseif ($DMARC -match "p=quarantine") {
            $DmarcComment = "$d has a DMARC record and it is set to p=quarantine. To fully take advantage of DMARC, the policy should be set to p=reject."
            $DMARC
            Write-Host "$d has a DMARC record and it is set to p=quarantine. To fully take advantage of DMARC, the policy should be set to p=reject." -ForegroundColor Yellow
        }
        elseif ($DMARC -match "p=reject") {
            $DmarcComment = "$d domain has a DMARC record and your DMARC policy will prevent abuse of your domain by phishers and spammers."
            $DMARC
            Write-Host "$d domain has a DMARC record and your DMARC policy will prevent abuse of your domain by phishers and spammers." -ForegroundColor Green
        }
        elseif ($DMARC -notmatch "v=dmarc1" -or "p=") {
            $DMARC
            Write-Host "`n$d does not have a DMARC record. $d is at risk to being abused by phishers and spammers." -ForegroundColor Red
        }
    }


    Write-Host ""
    Write-Host "------------------- $d -------------------"
    Write-Host "------------------- SPF -------------------"
    $SPF = Resolve-DnsName -type TXT -name $d | where-object { $_.strings -match "v=spf1" } | Select-Object -ExpandProperty strings -ErrorAction SilentlyContinue
    if ($SPF -is [array]) {
        $SpfComment = "$d has more than one SPF-record. One SPF record for one domain. This is explicitly defined in RFC4408"
        $SPF = $SPF -join ', ';
        Write-Host $SpfComment -ForegroundColor Yellow
    }
    elseif ($SPF -notmatch "-all") {
        $SpfComment = "An SPF-record is configured but the policy is not sufficiently strict"
        $SPF
        Write-Host $SpfComment -ForegroundColor Yellow
    }
    elseif ($SPF -match "-all") {
        $SpfComment = "An SPF-record is configured and the policy is sufficiently strict."
        $SPF
        Write-Host $SpfComment -ForegroundColor Green
    }
    elseif ($SPF -match "?all") {
        $SpfComment = "Your domain has a valid SPF record but your policy is not effective enough."
        $SPF
        Write-Host $SpfComment -ForegroundColor Green
    }
    Elseif ($SPF -notmatch "v=spf1" -or "all") {
        $SpfComment = "No SPF-record configured for $d" 
        $SPF
        Write-Error $SpfComment
    }
    Write-Host ""

    Write-Host ""
    Write-Host "------------------- $d -------------------"
    Write-Host "------------------- DKIM -------------------"
    $CnameSelector1 = Resolve-DnsName -Type CNAME -Name selector1._domainkey.$d -ErrorAction SilentlyContinue
    $CnameSelector2 = Resolve-DnsName -Type CNAME -Name selector2._domainkey.$d -ErrorAction SilentlyContinue
    if ($CnameSelector1.name -like "" -and $CnameSelector2.name -like "") {
        $DkimComment = "We couldn't find a DKIM record associated with your domain."
        Write-Host $DkimComment -ForegroundColor Red
    }
    else {
        $DKIM = Resolve-DnsName -Type TXT -Name $CnameSelector1.namehost -ErrorAction SilentlyContinue | Select-Object -ExpandProperty strings -ErrorAction SilentlyContinue
        if ($DKIM -match "v=DKIM1") {
            $DkimComment = "DKIM-record is valid"
            Write-host $DkimComment -ForegroundColor Green
        }
    }

    if ($ExportCSV) {

        $Obj = New-Object System.Collections.Generic.List[System.Object]
        $results = New-Object PSObject
        $results | add-member Noteproperty "Domain" $d
        $results | add-member NoteProperty "SPF-record" $SPF
        $results | add-member Noteproperty "DMARC" $DMARC
        $results | add-member NoteProperty "SPF Comment" $SpfComment
        $results | add-member NoteProperty "Dmarc Comment" $DmarcComment
        $results | add-member NoteProperty "Dkim Comment" $DkimComment
        $results | add-member NoteProperty "DKIM" $DkimValue
        $obj.Add($results)
        $results | Export-Csv $ExportCSV -Append -NoTypeInformation -Delimiter ";"
    }
}

if ($domain) {
    CheckSpfDkimDmarc -domain $domain
}

if ($file) {
    $domains = Get-Content $file

    foreach ($domain in $domains) {
        CheckSpfDkimDmarc -domain $domain
    }

    Write-Host ""
    Write-Host "Done" -ForegroundColor Green
}
