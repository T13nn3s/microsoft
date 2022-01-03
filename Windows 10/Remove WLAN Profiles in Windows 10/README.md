# Remove-WLAN-Profiles-in-Windows-10
Windows saves the WLAN-profiles in XML-files placed in the ProgramData\Microsoft\WlanSvc\Profiles\Interfaces folder. Each Wi-fi adapter identifies itself with a GUID. This script is based on the script wich Ed Wilson from the 'The Scripting Guys' has placed on their blog. It seems That the script no longer worked under windows 10 regarding this question on the TechNet gallery: https://gallery.technet.microsoft.com/scriptcenter/site/requests/WiFi-removal-script-not-working-on-Windows-10-device-44a09e21. I have made some changes to the script to get it working again for Windows 10.

# How to use
**NOTE:** To effect the changes a restart is required.
**NOTE:** In case of 'Permission Denied' error, run the script with Administrator rights.

Replace the variables ```$network1``` and ```$network2``` the name of the WLAN-profiles you want to preserve. After that, you can run the script. If you want to run this script on a regular basis from the Task Scheduler, check this page: blogs.technet.com/b/heyscriptingguy/archive/2012/08/11/weekend-scripter-use-the-windows-task-scheduler-to-run-a-windows-powershell-script.aspx
