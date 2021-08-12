# KQL queries
I use this repository for useful KQL queries for personal use. Because these queries can also be useful for the community I share them through my Github repository.

## List Windows Servers
This KQL query leaves a list of Windows Servers whose logging is present in the appropriate Workspace Logging Analytics container.
```
DeviceInfo
| where OSPlatform contains "WindowsServer"
| distinct DeviceName, OSPlatform
```