# Copy-Mailboxpermissions
This script checks all of the Mailbox Permissions the user has access to and makes a copy of the permissions to another user. Very useful when you want to clone the mailbox permissions of an existing user to another user. Besides, the script can also transfer all MailboxFolderPermissions. which the specified user has access to and transfers these permissions to another user.

# How to use
First, you need to load this function into your Powershell console

```powershell
Import-Module .\Copy-MailboxPermissions
```
Now you can call this function to only copy the mailbox permissions
```powershell
Copy-MailboxPermissions -SourceMailbox <username> -DestinationMailbox <username>
```
If you want also copy the MailboxFolderPermission add the additional parameter
```powershell
Copy-MailboxPermissions -SourceMailbox <username> -DestinationMailbox <username> -CopyMailboxFolderPermission
```
If you want to run this script from a non Exchange Server, you need to specify the -ComputerName parameter. The script is creating a remote powershell session to the specified host.
```powershell
Copy-MailboxPermissions -ComputerName <Hostname / IP> -SourceMailbox <username> -DestinationMailbox <username> -CopyMailboxFolderPermission
```

The script checks the type of system (can be a server or workstation), from where the script is opened, whether this is an Exchange Server or not. If it is not an Exchange Server, the script will exit and the script will return with the message that you have to apply the '-ComputerName' parameter. After the '-ComputerName' parameter has been applied, the script will open a Powershell session to the Exchange Server and will continue executing the script.

# Changelog

## [1.0.1] 30 August 2018

### Added
- try/catch on Import-PSSession.
- Some console logging with write-host on try/catch on Import-PSSession.

## [1.0] 28 August 2018
Initial script creation
