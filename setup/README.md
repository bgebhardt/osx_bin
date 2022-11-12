# Setting up a new Computer from scratch

Based on 8-10-2022 setup of MacBook Pro
Setting up from scratch without Migration assistant

# Initial steps to get running

Set up Apple iCloud and minimal settings

* enter iCloud account
* Set up 1Password
* Turn on internet accounts in System Preferences -> Internet Accounts
    * Started with personal google - passkey didn’t work though
* Set mouse speed and secondary click
* Set trackpad right corner secondary click and tap to click
* In system preferences items
  * Show Bluetooth menu
  * Show TimeMachine menu

Finder settings

* Show filenames
* Change default to list view
* View -> Show status bar
* Change default to list view: View Options -> Set Default

## Now set up dev environment

* Login to GitHub
* Set your git user name. see https://git-scm.com/book/en/v2/Getting-Started-First-Time-Git-Setup

$ git config --global user.name "Bryan Gebhardt"
$ git config --global user.email bryan.gebhardt@gmail.com

* TODO: Set up ssh keys for new computer

# Install applications

* Install Rosetta with `/usr/sbin/softwareupdate --install-rosetta --agree-to-license`

* Follow read me: https://github.com/bgebhardt/osx_bin
    * install Brew
    * Set up shell settings
    * run ./brew-cask-minimum.sh
    * set up the apps -- look in the file for the list to set up

## Install and set up Core Microsoft apps (now added to brew-cask-min install)

* Download and Install Microsoft Office (if not done by scripts)
* Set up Outlook with personal email account
    * Turn off alert on desktop and new message sound in prefs
* Set up OneDrive
* Set up Edge
    * Log in with Microsoft account
    * Change default browser in System Preferences -> General
    * Enable edge extensions you want in the toolbar (edge://extensions) (currently: 1Password, Session Buddy, Pocket, TabCopy, MSFT Editor)
* Set up Visual code (installed by brew-cask-minimum)
    * Login to sync with MSFT account
    * Install cmd line tools with command-P and search for "install code" (see [The Visual Studio Code command-line interface](https://code.visualstudio.com/docs/editor/command-line))

# Download key OneDrive Files

From OneDrive always sync the folders in your private file (not checked in)
*Do this before setting up apps incase they need the files.*
It seems to take a long time to download all teh files

# Set up rest of apps

* run ./mas.sh
  * There may be errors as app id's may have changed or because of authorization errors
  * After running you will have to figure out which did not install and install manually. :(
  * TODO: use mas open <id> to open each app in the appstore and manually download them.
  * Update: it is working now. It may require Rosetta 2 to be installed.
* run ./brew-cask.sh

You can run these in the background and move on to configs. Check them periodically for errors.

## Applications not installed this way

The following apps you'll have to get and install via there web installer

* [Marked 2 - Smarter tools for smarter writers](https://marked2app.com/) - I bought from developer instead of Mac App Store
* [alyssaxuu/later: Save all your Mac apps for later with one click 🖱️](https://github.com/alyssaxuu/later) - free app to save and restore open windows. Awesome!
* [BuhoCleaner: The Best Mac Cleaner Optimized for M1/M2 Macs](https://www.drbuho.com/)
* [Snail](https://snail.murusfirewall.com/) traffic shaping for MacOS
* [WiFiRadar Pro | Wireless monitoring on steroids](https://wifiradar.app/)
* [JSON Wizard | JSON, the easy way. For Mac.](https://jsonwizard.app/)
* [Premium Fonts for Mac and Windows | MacAppware](https://macappware.com/software/mac-fonts/)
* [Mac Font Manager Deluxe | MacAppware](https://macappware.com/software/mac-font-manager-deluxe/)

# Add all Scripts

Follow installation instructions here: https://github.com/bgebhardt/osx_scripts_folder
Configure all the FastScript shortcuts for the scripts.

# Configure Critical Apps and Settings
Follow the folling list of application setup instructions

Spotlight might not be done indexing so you may have to run apps from Applications

Migrate over settings files from previous mac.
TODO: how to do that without migration assistant.

Install Rosetta Intel emulation via `sudo softwareupdate --install-rosetta`
It may look like there was an error but as long as it ends with Install of "Rosetta 2 finished successfully" it should have worked.

Enable iCloud messages in Messages app preferences

Add Espson printer in Printers and Scanners

Install [Epson Printer Drivers](https://epson.com/Support/wa00607d)
* I skip this now as the software seems to cause issues.

## General

* Set CAPSLOCK to Control in System Preferences -> Keyboard -> Modifiers...

## RayCast (to replace spotlight)

* Change Spotlight shortcut in System Preferences -> Keyboard to Control-Option-Command-Space
* Start Raycast
* Got to Settings -> Advanced and click Import. Import from OneDrive.
* URL: [Raycast](https://www.raycast.com/) -- spotlight replacement; similar to Alfred

## Alfred (to replace spotlight)

* Change the spotlight short cut to Control-Option-Command-Space
* Change Alfred to command-space in General pane of Alfred settings
* Note: I switched to RayCast

## Karabiner (for EMACS style keybindings)

* Open Karabiner-Elements and allow extension in System Preferences
* In Karabiner-Elements to to Misc pane and open ~/.config/karabiner
* Copy karabiner config from OneDrive to ~/.config/karabiner

## Rectangle - For Window movement shortcuts

* Open Rectangle preferences by clicking the gear tab
* Click Import to import in shortcuts file from OneDrive

## Default Folder

* Open and set it up
* prefs: 
    * general: check all
    * folders: shortcuts for OneDrive Personal, Downloads
    * options: check and set open in iTerm2; check for updates.

## iTerm and Terminal

* switch shell to bash. I do it by changing the shell in the profile to `\bin\bash`
* in Terminal set default profile to Homebrew colors

## Typinator

* Open app
* Give access in Privacy & Security -> Accessibility
* Open settings; click Expansions tab; Set configuration to OneDrive

## FastScripts
In settings
* Open on startup
* Set editors to Visual Code
* Automatically check for updates

Set keyboard shortcuts
* The short cuts I've used can be found at https://github.com/bgebhardt/osx_scripts_folder/blob/master/fastscripts-shortcuts.csv
* There is a script in that repo that can export all shortcuts

## Bartender

* Open and set up
* Set Start on Launch
* Select "Show all hidden items if active screen is bigger than: 3000 px"
* Menubar layout: Raycast and FastScripts
* Rules: TODO

### Bartender rules

Set up rules based on screenshot in OneDrive folder.

Add a rule to show the TripMode application when the filter status is enabled.

Here's the script:
`osascript -e 'tell application "TripMode" to filter status = enabled'`

## Microsoft Outlook

* Cozy setting
* Add email accounts
* Change time scale viewed in calendar
* Reading:
  * Change to mark read after 2 seconds
  * Change swipe actions and quick actions
* Notifications & Sounds
  * Turn off new mail sound
  * Turn off new mail notifications

## Shottr

* Open and configure as directed
* [Shottr – Screenshot Annotation App For Mac](https://shottr.cc/) -- free great screen shot tool!

## OwlOCR Pro

* Open Preferences; Set to only in menu bar
* Get application from bundle bought on 03-25-2022
Award-Winning Mac Bundle is Live!
https://bundlehunt.com/my-account/downloads/all
* Links: https://owlocr.com/; https://owlocr.com/blog/posts/owlocr-5-command-line-interface

## Fig - shell integrations

* Open and configure as directed

## Parallels

* Download from site from https://my.parallels.com/desktop/downloads
* Install

## Time Machine and Time Machine Editor and Space Saver

* Set up backup disk
* Set up exclusion list

Exclude from Backups

~/Library/Application Support/Steam
~/Library/CloudStorage
~/Library/Group Containers/UBF8T346G9.Office
~/Library/Group Containers/
UBF8T346G9.OfficeOneDriveSynclntegration
~/Library/Group Containers/UBF8T346G9.OfficeOsfWebHost
~/Library/Group Containers/
UBF8T346G9.OneDriveStandaloneSuite
~/Library/Group Containers/
UBF8T346G9.OneDriveSyncClientSuite
~/Parallels/
~/Pictures/<large photos library>
~/Music

TODO: add Google Drive

* Set up Time Machine Editor (app that does scheduled TimeMachine when inactive)
  * Set "Back up: When inactive"
  * check "Create local snapshots every hour"

Space Saver can help delete local Time Machine backups. No set up required.

## Other core apps to set up

* PowerPhotos
* Velja - https://apps.apple.com/nz/app/velja/i... -- browser picker - download it from the app store and configure
* iDrive - login and set up cloud backups; set up continuous data protection
* Amphetamine - set it up to start at login
* Photos
* Music

* BetterZip
* Harmony remote software: see https://support.myharmony.com/en-us/harmony-and-macos
* PDFExpert
* Plex
* Disk Drill

* Steam
* Epic Launcher
* GOG
* Parallels

* Calibre - ebooks - see folder on one drive too
* Kindle

* CloudMounter
* GoogleDrive

## Login apps to set up

*Done*
caffeine 
popchar
Lunar -- very nice set up system
bartender -- configure it once all apps installed
Typinator 
FastScripts
Google Drive

*To do*

# Notes on other apps

Great 
[Amazing FREE Mac Apps You Aren’t Using! - YouTube](https://www.youtube.com/watch?v=FxUk8gxzHI8&list=WL&index=7&t=140s)

* Orion - https://browser.kagi.com -- safari based web browser that can run chrome, firefox, and safari extensions
* Velja - https://apps.apple.com/nz/app/velja/i... -- browser picker
* [alyssaxuu/later: Save all your Mac apps for later with one click 🖱️](https://github.com/alyssaxuu/later) -- free app to save and restore open windows. Awesome!
* [Dropover - Easier Drag & Drop on the Mac App Store](https://apps.apple.com/us/app/dropover-easier-drag-drop/id1355679052?mt=12) -- Use it to stash, gather or move any draggable content without having to open side-by-side windows.
* [ImageOptim — better Save for Web](https://imageoptim.com/mac) -- Removes bloated metadata. Saves disk space & bandwidth by compressing images without losing quality.
* [CopyClip - Clipboard History on the Mac App Store](https://apps.apple.com/us/app/copyclip-clipboard-history/id595191960?mt=12) -- free clipboard history app
* [Hidden Bar on the Mac App Store](https://apps.apple.com/us/app/hidden-bar/id1452453066?mt=12) -- hide menu bar items; free app like Bartender
* Hand Mirror - https://apps.apple.com/us/app/hand-mi... -- menubar item that will turn on your webcam to check out how you look
* [QuickShade on the Mac App Store](https://apps.apple.com/us/app/quickshade/id931571202?mt=12) -- free brightness control like Lunar or BetterDisplay which I like better
* [Operating system utilities for Mac - OnyX](https://www.titanium-software.fr/en/onyx.html) -- UI on a lot of system utilities
* [One Thing on the Mac App Store](https://apps.apple.com/us/app/one-thing/id1604176982?mt=12) -- Put one task in your menu bar

* [raycast vs alfred - Search](https://www.bing.com/search?q=raycast+vs+alfred&cvid=40c3758d7fc84f6d872e9566ddbe306c&aqs=edge.0.0j69i57j0.1896j0j1&pglt=171&FORM=ANNTA1&PC=U531)

# Brew Services

Run `brew services` to install the brew services which can register services with launchctl

More info

*  [brew(1) – The Missing Package Manager for macOS (or Linux) — Homebrew Documentation](https://docs.brew.sh/Manpage#services-subcommand)
* [Homebrew/homebrew-services: 🚀 Manage background services using the daemon manager launchctl on macOS or systemctl on Linux.](https://github.com/Homebrew/homebrew-services)
* [Starting and Stopping Background Services with Homebrew](https://thoughtbot.com/blog/starting-and-stopping-background-services-with-homebrew)

## Modify and start service sleepwatcher

I use this to mute and unmute audio when the computer goes to sleep.

For some reason the service doesn't work as a service. Still troubleshooting.

In the short term run this at the command line

sleepwatcher -V -s ~/.sleep -w ~/.wakeup

Scripts are .sleep and .wakeup

`brew services start sleepwatcher`

Currently I manually create .sleep and .wakeup in the home directory.

⚡ cat .sleep
# simple script to mute sound
osascript -e "set volume with output muted"

⚡ cat .wakeup
# simple script to unmute sound
osascript -e "set volume without output muted"

More info on sleepwatcher and Applescripts to mute/unmute

* [How to control OS X System Volume with AppleScript](https://coolaj86.com/articles/how-to-control-os-x-system-volume-with-applescript/#:~:text=On%20the%20keyboard%20you%20can%20hit%20the%20mute,volume%20without%20output%20muted%20output%20volume%201%20--100%25%22)
* [swift - Unable to mute and unmute mic using applescript - Stack Overflow](https://stackoverflow.com/questions/71421883/unable-to-mute-and-unmute-mic-using-applescript) - in the comments suggests how you can use defaults to write state for your scripts.
* [Sleepwatcher : Run Script on Sleep - tyler hoffman](http://tyhoffman.com/blog/2013/09/sleepwatcher-power-event-driven-automation/) - alternate approach to setting sleepwatcher.
  * [sleepwatcher installation script for macOS](https://gist.github.com/eu81273/3de56ccc62729aa802ef3748bdc911c0)
* [Mac OS X: Automating Tasks on Sleep » Kodiak's Korner - My Little Corner of the Net](https://www.kodiakskorner.com/log/258) - great summary for how to set up sleepwatcher LaunchAgent
  * Note: the brew sleepwatcher package doesn't include the default LaunchAgent. You have to download it from the source. [bb's Homepage](https://www.bernhard-baehr.de/)

# Synergy Setup

[Synergy - Share one mouse & keyboard across computers](https://symless.com/synergy)

* Get license from Synergy account
* Install with package or brew on Mac or chocolatey on Windows (included in both set up scripts)
* Configure as explained on there website
* Add Synergy to login items
  * [Synergy - Automatically run Synergy on start-up](https://symless.com/synergy-help/synergy-auto-start)
* configure modifier keys
  * for Mac server map Super to Ctrl and Ctrl to Super
  * see [How To Properly Map Keyboard Between Mac and PC when Share Mouses with Synergy - NEXTOFWINDOWS.COM](https://www.nextofwindows.com/how-to-properly-map-keyboard-between-mac-and-pc-when-share-mouses-with-synergy)

---

# TODO

Set up ssh-keys
https://github.com/settings/keys
https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent

* Setup default applications (example: all PDF's open in PDF Expert instead of Preview). Look to see if there's a tool or script that can do this quickly.

* Register BusyCal and BusyContacts

# Other minimum apps to install

* iClock
* Adobe Reader
* Harmony remote software: see https://support.myharmony.com/en-us/harmony-and-macos
* iDrive

Key Notifications settings to update
