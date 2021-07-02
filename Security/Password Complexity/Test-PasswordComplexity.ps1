<#
.SYNOPSIS
Verify password minimum complexity requirement.

.DESCRIPTION
This function checks the input password on complexity, it wil checks the following:
        - If the password contains at least 7 characters
        - Special characters
        - numbers
        - a-z lowercase
        - A-Z uppercase

.PARAMETER password
Enter password for complexity test

.EXAMPLE
Test-PasswordComplexity -password [string] or Test-PasswordComplexity -pass [string]

.NOTES
    This script is first released by Jake Swift back in 2015 => https://gallery.technet.microsoft.com/Verify-password-complexity-c9e6f42f
    Created by  : T13nn3s
    Version     : 2.0.1 (15 February 2018)
#>
function Test-PasswordComplexity {
    param(
        # Parameter for password
        [Parameter(
            Mandatory = $true,
            HelpMessage = "Fill in the password you want to check complexity"
        )][alias("pass")]
        [string]
        $password
    ) #end param
    
    $passcheck = $Password
    $passLength = 8
    $pass = 0
   
    #checks password length
    :Checkpass Do {
        If ($Password.Length -lt $passLength) {
            Write-Host "$Password is not long enough. Minimum password length is $passlength characters" -f Red
        
        }
        Else {
            $isGood = 0
            #checks password for special characters
            write-host "Check for special characters!" -f Yellow
            If ($passcheck -match "[()!@#$%^&*]") { 
                write-host "Password contains special characters." -f Green
                $isGood++ 
            } 
            If ($passcheck -notmatch "[()!@#$%^&*]") { 
                write-host "Password does not contain any special character." -f Red 
            } 
            write-host "Verify that 0-9 is in the password!" -f Yellow
            If ($passcheck -match "[0-9]") { 
                write-host "Password contains 0-9." -f Green
                $isGood++ 
            }
            If ($passcheck -notmatch "[0-9]") { 
                write-host "Password does not contain 0-9." -f Red
            }
            write-host "Verify that a-z is in the password!" -f Yellow
            If ($passcheck -match "[a-z]") { 
                write-host "Password contains a-z." -f Green
                $isGood++ 
            }
            If ($passcheck -notmatch "[a-z]") { 
                write-host "Password contains not a-z." -f Red
            }
            write-host "Verify that A-Z is in the password!" -f Yellow
            If ($passcheck -cmatch "[A-Z]") { 
                write-host "Password contains A-Z!" -f Green
                $isGood++ 
            }
            If ($passcheck -cnotmatch "[A-Z]") { 
                write-host "Password does not contain A-Z." -f Red
            }
  
            If ($isGood -lt 3) {
                Write-Host "" 
                Write-Host "The password does not meet the minimum complexity requirements. Network security is more important than convenience!" -f Red
                
            }
            Else {
                Write-Host "$passcheck, meets the minimum complexity requirements." -f Green
                $pass++ 
    
            } #end special character check
        } #end if statement password length
    } while ($pass -eq 1) #end Do loop
} #end function
