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

## Karabiner settings

1. Open the Karbiner-Elements app
2. Go to Misc section
3. Click open config directory
4. Copy config directory to back it up.

## Raycast

*Export settings*
Use the "Export Preferences & Data" command to export preferences, aliases, hotkeys, favourites, snippets, quicklinks, floating notes and other data to a "rayconfig" file. Later you can import this configuration file, using the "Import Preferences & Data" command, on the same mac or start just where you left off on a new mac.

[Raycast Manual](https://manual.raycast.com/)

## FastScripts

Run AppleScript "export fastscripts shortcuts" I wrote to export all keybindings which will be manually re-added to scripts on the new computer. It will put them all on the clipboard in csv format 

TODO: no longer seems to export all shortcuts

## Rectangle window management

Export Rectangle settings in it's preferences

## Velja
Export any custom rules and save them to OneDrive

## calibre

Copy ~/Library/Preferences/calibre directory to backup settings.

# Disabled and Retired

## Mackup
WARNING: this tool no longer works and I no longer use it.

A tool to backup and restore application configuration. Supports lots of applications.

to backup configs run `mackup backup`
to restore configs run `mackup restore`

### Install and Config
brew install mackup # Keep your Mac's application settings in sync https://github.com/lra/mackup
[lra/mackup: Keep your application settings in sync (OS X/Linux)](https://github.com/lra/mackup)

config docs: [mackup/doc at master · lra/mackup](https://github.com/lra/mackup/tree/master/doc#get-official-support-for-an-application)
sample config file: [mackup/doc/.mackup.cfg at master · lra/mackup](https://github.com/lra/mackup/blob/master/doc/.mackup.cfg)

My config is to sync to iDrive Cloud Drive. See mackup.template.cfg
Supports about 20-30 of my apps
