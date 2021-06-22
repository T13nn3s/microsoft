[CmdletBinding()]
param (
    [Parameter(
        HelpMessage = "Specify domain name whose SPF, DMARC and DKIM record should be checked."
    )]
    [string]
    $domain,

    [Parameter(
        HelpMessage = "Specifies file name which contains a list of domain names."
    )]
    [string]
    $file
)

if (!$PSBoundParameters.ContainsKey('domain') -and (!$PSBoundParameters.ContainsKey('file'))) {
    Write-warning "Please specify the -domain or -file parameters to use this script."
    return
}

if ($PSBoundParameters.ContainsKey('domain') -and ($PSBoundParameters.ContainsKey('file'))) {
    Write-warning "You cannot apply the -file or -file parameter at the same time."
    return
}

function CheckSpfDmarc {
    param (
        $domain
    )

    foreach ($d in $domain) {
        write-host ""
        Write-Host "------------------- $d -------------------"
        Write-Host "------------------- DMARC -------------------"
        $DmarcValue = (nslookup -q=txt _dmarc.$d | select-string "DMARC1") -replace "`t", ""
        $regex_dmarc = [Regex]::new("(?<=text = )(.*)(?= )")
        $DMARC = $regex_dmarc.Match($DmarcValue).Value
        if ($DMARC -match "p=none") {
            $DMARC
            Write-Host "$d has a valid DMARC record but the DMARC (subdomain) policy does not prevent abuse of your domain by phishers and spammers." -ForegroundColor Yellow
        }
        elseif ($DMARC -match "p=quarantine") {
            $DMARC
            Write-Host "$d has a DMARC record and it is set to p=quarantine. To fully take advantage of DMARC, the policy should be set to p=reject." -ForegroundColor Yellow
        }
        elseif ($DMARC -match "p=reject") {
            $DMARC
            Write-Host "$d domain has a DMARC record and your DMARC policy will prevent abuse of your domain by phishers and spammers." -ForegroundColor Green
        }
        elseif ($DMARC -notmatch "v=dmarc1" -or "p=") {
            $DMARC
            Write-Host "`n$d does not have a DMARC record. $d is at risk to being abused by phishers and spammers." -ForegroundColor Red
        }
        Write-Host ""
        Write-Host "------------------- $d -------------------"
        Write-Host "------------------- SPF -------------------"
        $SPF = (nslookup -q=txt $d | Select-String "spf1") -replace "`t", ""
        if ($SPF -notmatch "-all") {
            $SPF
            Write-Host "An SPF-record is configured but the policy is not sufficiently strict" -ForegroundColor Yellow
        }
        elseif ($SPF -match "-all") {
            $SPF
            Write-Host "An SPF-record is configured and the policy is sufficiently strict." -ForegroundColor Green
        }
        Elseif ($SPF -notmatch "v=spf1" -or "all") {
            $SPF
            Write-Host "No SPF-record configured for $d" -ForegroundColor Red
        }
        Write-Host ""

        Write-Host ""
        Write-Host "------------------- $d -------------------"
        Write-Host "------------------- DKIM -------------------"
        $DkimCname = (nslookup -q=cname selector1._domainkey.$d)
        if ($DkimCname -match "Can't find") {
            Write-Host "We couldn't find a DKIM record associated with your domain." -ForegroundColor Red
        }
        else {
            foreach ($r in $DkimCname.Split(" ")) {
                if ($r -match "onmicrosoft.com") {
                    $regex1 = [Regex]::new("(?<=canonical name = )(.*)(?=  Authoritative)")
                    $CnameValue = $regex1.Match($DkimCname).Value
                    $dkim = (nslookup -q=txt $CnameValue) -replace "`t", ""
                    $regex = [Regex]::new("(?<=text = )(.*)(?=  Authoritative)")
                    $DkimValue = $regex.Match($dkim)
                    if ($dkimvalue.Value -eq $null) {
                        Write-Host "We couldn't find a DKIM record associated with your domain."
                    }
                    else {
                        $dkimvalue.Value
                        write-host ""
                        Write-host "DKIM-record is valid" -ForegroundColor Green
                    }
                }  
            }
        }
    }
}


if ($domain) {
    CheckSpfDmarc -domain $domain
}

if ($file) {
    $domains = Get-Content $file

    foreach ($domain in $domains) {
        CheckSpfDmarc -domain $domain
    }

    Write-Host ""
    Write-Host "Done" -ForegroundColor Green   
}