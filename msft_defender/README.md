# README on profiling Microsoft Defender Mac

Mainly follow the troubleshooting steps in this file

[Troubleshoot performance issues for Microsoft Defender for Endpoint on macOS | Microsoft Learn](https://learn.microsoft.com/en-us/microsoft-365/security/defender-endpoint/mac-support-perf?view=o365-worldwide)

You can exclude items (File extension, File, Folder, Process). Here's how.

[Configure and validate exclusions for Microsoft Defender for Endpoint on Mac | Microsoft Learn](https://learn.microsoft.com/en-us/microsoft-365/security/defender-endpoint/mac-exclusions?view=o365-worldwide)

Use the troubleshooting information to identify processes that might need to be excluded.

# TL;DR way to check
NOTE: python not on my machine; use python3.

Pull in real time statistics and parse it with the python script.

``` bash
mdatp diagnostic real-time-protection-statistics --output json > real_time_protection.json
cat real_time_protection.json | python3 high_cpu_parser.py  > real_time_protection.log
more real_time_protection.log
```
Get python script from:

to turn on/off stats

``` bash
mdatp config real-time-protection-statistics  --value enabled
mdatp config real-time-protection-statistics  --value default
```
disable realtime protection (not allowed by my org)

```mdatp config real-time-protection --value disabled```

# Changes on my machine
as of 12-20-2023

Turned on realtime statistics.

Highest process
820     IDriveDaemon    842     /Library/Application Support/IDriveforMac/IDriveHelperTools/IDriveDaemon.app/Contents/MacOS/IDriveDaemon

Excluded IDriveDaemon
Excluded Bert and Grover drives (folders)

# Links

[MDE for macOS (MDATP): Troubleshooting high cpu utilization by the real-time protection (wdavdaemon) – Yong Rhee’s blog](https://yongrhee.wordpress.com/2020/10/10/mde-for-macos-mdatp-troubleshooting-high-cpu-utilization-by-the-real-time-protection-wdavdaemon/)

[MDE for macOS (MDATP for macOS): List of antimalware (aka antivirus (AV)) exclusion list for 3rd party applications. – Yong Rhee’s blog](https://yongrhee.wordpress.com/2020/10/14/mde-for-macos-mdatp-for-macos-list-of-antimalware-aka-antivirus-av-exclusion-list-for-3rd-party-applications/)