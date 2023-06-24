# Things to remember when backing up your mac

This is a list of settings and things to remember when backing up my mac. I tend to rebuild my environments from scratch vs. restoring from a Time Machine backup. Too make that as easy as possible.

TODO: script this checklist
TODO: look at preferences porting tools
TODO: script to get default settings of interest to TODO.md

# Useful troubleshooting tools/articles

- [How to reinstall macOS - Apple Support](https://support.apple.com/en-us/HT204904)
- [Use Disk Utility to erase an Intel-based Mac - Apple Support](https://support.apple.com/en-us/HT208496)
- [How to repair a Mac disk with Disk Utility - Apple Support](https://support.apple.com/en-us/HT210898)
- [Use Apple Diagnostics to test your Mac - Apple Support](https://support.apple.com/en-us/HT202731)
- Command-Control+Shift+Option+. or `sudo sysdiagnose` will do a complete system diagnosis and output a file in /tmp/. Note: It can take 10+ minutes.

# Main Backup

1. Use [SuperDuper!](https://shirt-pocket.com/SuperDuper/SuperDuperDescription.html) to backup user files (all files and  full drive backups often don't always work especially with work controlled machines) to a disk image. Other backup options or resources
    [Features | Carbon Copy Cloner | Bombich Software](https://bombich.com/features)
    [No Excuses: 7 Free Mac Backup Apps](https://www.lifewire.com/free-mac-backup-software-2260106)
2. Confirm SuperDuper! Disk image mounts and has the files on it. Note that CloudStorage won't come over and that many files are invisibles (dot files).

2. Copy over Applications (Superduper doesn't always get them.)
3. Take screen shots of the following
    1. Menubar to get a list of bartender items and order
    2. bartender custom settings
    3. Login items
4. Use session buddy to capture currently open browser windows. See [Session Buddy – Manage Browser Tabs and Bookmarks with Ease](https://sessionbuddy.com/)

# Per App checklists

## Raycast

*Export settings*
Use the "Export Preferences & Data" command to export preferences, aliases, hotkeys, favourites, snippets, quicklinks, floating notes and other data to a "rayconfig" file. Later you can import this configuration file, using the "Import Preferences & Data" command, on the same mac or start just where you left off on a new mac.

[Raycast Manual](https://manual.raycast.com/)

## FastScripts

Run AppleScript I wrote to export all keybindings which will be manually re-added to scripts on the new computer




## Rectangle window management


## Swish window management