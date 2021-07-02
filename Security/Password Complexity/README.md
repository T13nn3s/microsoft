# Test-PasswordComplexity
Verify the password minimum complexity requirement. It wil checks the following:
- If the password contains at least 7 characters
- Special characters
- numbers
-z lowercase
- A-Z uppercase

# How to use
First, you need to load this function into your Powershell session.
```powershell
Import-Module .\Test-PasswordComplexity.ps1
```
Now you can call the function
```powershell
Test-PasswordComplexity -password [string] or Test-PasswordComplexity -pass [string]
```
# Information
It is important to use complex passwords are for network security. Complex passwords make a brute force attack difficult, but still not impossible.

# Changelog

## [2.0.1] 15 February 2018

### Fixed
- Various bugs fixed

## [2.0] 4 January 2018

### Added
- Parameter $password, you can now enter the password directly after calling the function.
- Notification to tell you exactly what the password is missing.
- Colored notifications to see at glance the type of notification.

### Changed
- function rename to Test-PasswordComplexity.

## [1.0] 20 April 2015 => Script creation by Jake Swift

### Added
- Function checkPassword.
- Create loop until password meets minimum complexity requirements.
