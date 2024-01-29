# Setting up a new Computer from scratch

Based on 8-10-2022 setup of MacBook Pro
Setting up from scratch without Migration assistant

# Initial steps to get running

Set up Apple iCloud and minimal settings

* follow initial set up flow from Apple
  * enter iCloud account
* Set up 1Password
* Turn on internet accounts in System Preferences -> Internet Accounts
    * Started with personal google - passkey didn’t work though
* Set mouse speed and secondary click
* Set trackpad right corner secondary click and tap to click
* In Control Center preferences in System Preferences items
  * Show Bluetooth menu
  * Show TimeMachine menu 

Finder settings

* Show filename extensions
* Change default to list view
* View -> Show status bar
* Change default to list view: View Options -> Set Default

## Now set up dev environment

* Change terminal default profile to Homebrew
* Change default shell to bash: `chsh -s /bin/bash`
* go to brew.sh and follow instructions to install homebrew
* Install github cls `/opt/homebrew/bin/brew install gh` see [cli/cli: GitHub’s official command line tool](https://github.com/cli/cli#installation)
* Login to git with `/opt/homebrew/bin/gh auth login`

* Set your git user name. see https://git-scm.com/book/en/v2/Getting-Started-First-Time-Git-Setup

$ git config --global user.name "Bryan Gebhardt"
$ git config --global user.email bryan.gebhardt@gmail.com

## Download bin from github
/opt/homebrew/bin/gh repo clone bgebhardt/osx_bin
follow the rest of the instructions on this page: https://github.com/bgebhardt/osx_bin

* TODO: Set up ssh keys for new computer

### Optional - change brew cache location
The brew cache can take up space so I move it to an external drive always installed in my laptop.
Add this to the .bash_profile in the home directory. I don't check this in because this volume doesn't exist on my other computers.

```
# the default homebrew cache location
# brew --cache
#/Users/bryan/Library/Caches/Homebrew
export HOMEBREW_CACHE="/Volumes/Bert/Caches/Homebrew"
echo "setting brew cache location to $HOMEBREW_CACHE"
```

# Install applications

* Install Rosetta with `/usr/sbin/softwareupdate --install-rosetta --agree-to-license`

* Follow read me: https://github.com/bgebhardt/osx_bin
    * install Brew (see https://brew.sh)
    * Set up shell settings
    * run ~/bin/setup/brew-cask-minimum.sh
    * set up the apps -- look in the file for the list to set up

## Install and set up Core Microsoft apps (now added to brew-cask-min install)

* WORK ONLY: Download Company Portal app from app store and set up work requirements. http://aka.ms/mdm
  * logout to force required password change
  * update Defender virus & threat protection
  * reenable linking mac keyboards and mouse in Displays preference
  * Set up exchange in System Preferences
  * Set up work email in Outlook

* Download and Install Microsoft Office (if not done by scripts)
* Open Outlook and login with credentials
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
It seems to take a long time to download all the files

# Set up iDrive

* Configure iDrive
* Select a previous computer to link iDrive to or start as new device
* Turn on cloud sync - personal Obsidian vault is there

# Set up rest of apps (including cli apps)

* run ./mas.sh
  * There may be errors as app id's may have changed or because of authorization errors
  * After running you will have to figure out which did not install and install manually. :(
  * TODO: use mas open <id> to open each app in the appstore and manually download them.
  * Update: it is working now. It may require Rosetta 2 to be installed.
* run ./brew-cask.sh
* run ./brew.sh

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
* Clock - no cask; same software maker [seense | The Clock for macOS](https://seense.com/the_clock/)
* Quick expose - no cask; same software maker [Quick Exposé: A New Way to Use Mission Control and App Exposé on macOS • MacPlus Software](https://oteifyapp.com/quick-expose/)


# Add all Scripts

Follow installation instructions here: https://github.com/bgebhardt/osx_scripts_folder
Configure all the FastScript shortcuts for the scripts.

# Configure Critical Apps and Settings
Follow the following list of application setup instructions

Spotlight might not be done indexing so you may have to run apps from Applications

Migrate over settings files from previous mac.
TODO: how to do that without migration assistant.

Install Rosetta Intel emulation via `sudo softwareupdate --install-rosetta`
It may look like there was an error but as long as it ends with Install of "Rosetta 2 finished successfully" it should have worked.

Enable iCloud messages in Messages app preferences

Add Espson printer in Printers and Scanners

Install [Epson Printer Drivers](https://epson.com/Support/wa00607d)
* I skip this now as the software seems to cause issues.

## Mackup
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

## General

* Set CAPSLOCK to Control in System Preferences -> Keyboard -> Modifiers...

## Dock
Set app switcher to show on all monitors. Useful if laptop is monitor to the right of main monitor.

``` shell
defaults write com.apple.Dock appswitcher-all-displays -bool true
killall Dock
```

to reverse

``` shell
defaults write com.apple.Dock appswitcher-all-displays -bool false
killall Dock
```

From [Show macOS app switcher across all monitors · GitHub](https://gist.github.com/jthodge/c4ba15a78fb29671dfa072fe279355f0)

## RayCast (to replace spotlight)

* Change Spotlight shortcut in System Preferences -> Keyboard to Control-Option-Command-Space
* Start Raycast
* Go to Settings -> Advanced and click Import. Import from OneDrive or ~/bin/setup/configs
* Get password from 1Password
* URL: [Raycast](https://www.raycast.com/) -- spotlight replacement; similar to Alfred

### OneDrive web search links

These two links will open personal and work OneDrive searches for the word passed in via Raycast.

* personal: https://onedrive.live.com/?id=root&qt=search&q={Query}&scope=drive
* work: https://microsoft-my.sharepoint-df.com/personal/{your-work-onedrive-location}/_layouts/15/onedrive.aspx?q={Query}&view=7&searchScope=all

## Alfred (to replace spotlight)

* Change the spotlight short cut to Control-Option-Command-Space
* Change Alfred to command-space in General pane of Alfred settings
* Note: I switched to RayCast

## Karabiner (for EMACS style keybindings)

* Open Karabiner-Elements and allow extension in System Preferences
* In Karabiner-Elements to to Misc pane and open ~/.config/karabiner
* Copy karabiner config from OneDrive or bin/setup/configs to ~/.config/karabiner

## iDrive

iDrive cloud sync is needed for my Obsidian vault

## Obsidian Note taking setup

Enable core plugins
My vaults are in iDrive and OneDrive. Set up those to applications first.


## Rectangle - For Window movement shortcuts

* Open Rectangle preferences by clicking the gear tab
* Click Import to import in shortcuts file from OneDrive or bin/setup/configs 

## Default Folder

* Open and set it up
* prefs: 
    * general: check all
    * folders: shortcuts for OneDrive Personal, Downloads
    * options: check and set open in iTerm2; check for updates.

## iTerm and Terminal

* switch shell to bash. I do it by changing the shell in the profile to `\bin\bash`
* in Terminal set default profile to Homebrew colors

## Warp terminal

sign in and start using

## Typinator

* Open app
* Give access in Privacy & Security -> Accessibility
* Open settings; click Expansions tab; Set configuration to iDrive Cloud Drive folder

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

## Microsoft Edge

* Login to both work and personal accounts creating a profile for each
* Enable Extensions you want visible
* Select Moonlight Glow from Appearance on Personal Profile

## Shottr

* Open and configure as directed
* [Shottr – Screenshot Annotation App For Mac](https://shottr.cc/) -- free great screen shot tool!

## OwlOCR Pro

* use mas to install version 6.
* in Pro preferences click restore from v5
* set single screen capture to clipboard shortcut to cmd-shift-1
* Open Preferences; Set to only in menu bar
* Set up the CLI - Links: https://owlocr.com/; https://owlocr.com/blog/posts/owlocr-5-command-line-interface

Old way
* Get application from bundle bought on 03-25-2022
Award-Winning Mac Bundle is Live!
https://bundlehunt.com/my-account/downloads/all


## Better Display

* Auto launch on login
* TODO: Figure out other settings.

## Hookmark

Activate with this Licence key. Open link in browser.

https://hook.cogsciapps.com/activate?info=d02975c273a42a6fa031c5e10e067ac856e8e3c3aee14a7020c528550ec991a879b576eec4638cc493b36c0915fdb3abb25fbe38760bb2a40a684adfcdf39d2f5d7653002625147ccafce1ec68aa2ff8ad643fe7b96ab0012680a3c0eb8bd87b867abc06fc2029bc30bf91691addafb0452473fd0f473e66196b0c8ca38af513eb195ad1b6151f6cbced0ee45cc0ad30660e0b43196ba0ecfc016b6a07c33a1d1083629b7d3d8d3fc2cbd6932a54f4f7ae803131589219a8fd784ae64cbe826eb14341e4173e892077f16e44a8a0a3947a8d8dd8b26f4228d5c6c7e96330d86b2e9d2aa1f14d42d0d9eef2d6bfee8052dbf714e53ffc2a257deda11b120bd007

* Follow set up instructions
* Set Copy Link to Control-Command-C
* Set Copy Markdown Link to Control-Command-S
* Activate iCloud sync to sync links
* Import in link data if you have a recent backup
* Set up custom apps

Update Office apps in scripts tab. Change Get Address for each app as follows.


"cur doc link v2.applescript" scripts return encoded URLs which are suitable for sharing in email, etc.
Here's one example
```applescript
-- gets a url to the front window of Microsoft Word.
-- can choose a link that will download if pasted into browser or a link format that opens in the Mac office app (set gMacAppLink).
-- when pasting the link into a Microsft app it should resolve to a clickable link that opens in web.

-- inspired by Hookmark's excel scripts 
-- Links with fixes for Office apps
-- [Using Hookmark in Microsoft OneDrive with Microsoft Office Apps – Hookmark](https://hookproductivity.com/help/integration/using-hook-with-onedrive/)
-- [Excel OneDrive file not Hookable \[workarounds\] - Discussion & Help - Hookmark Forum](https://discourse.hookproductivity.com/t/excel-onedrive-file-not-hookable-workarounds/2367/10)

set gMacAppLink to false

tell application "Microsoft Word"
	set activeDoc to active document
	set activeDocName to name of activeDoc
	set activeDocPath to path of activeDoc
	set fullURL to full name of activeDoc
	if fullURL does not start with "http" then
		-- TODO: improve this error return
		return "file://" & POSIX path of fullURL
	end if
    -- this URL will open in the application
	set appURL to "ms-word:ofe|u|" & fullURL

    -- create an encoded url version (without ms-word pattern which likely onely works on Mac)
	-- need to encode the doc name before putting it in the url
	set encodedDocName to my encodeText(activeDocName, true, false)
	set docURL to activeDocPath & "/" & encodedDocName	

    if gMacAppLink is true then 
        return appURL
    else
        return docURL
    end if
end tell

-- from [Mac Automation Scripting Guide: Encoding and Decoding Text](https://developer.apple.com/library/archive/documentation/LanguagesUtilities/Conceptual/MacAutomationScriptingGuide/EncodeandDecodeText.html)
on encodeCharacter(theCharacter)
	set theASCIINumber to (the ASCII number theCharacter)
	set theHexList to {"0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "A", "B", "C", "D", "E", "F"}
	set theFirstItem to item ((theASCIINumber div 16) + 1) of theHexList
	set theSecondItem to item ((theASCIINumber mod 16) + 1) of theHexList
	return ("%" & theFirstItem & theSecondItem) as string
end encodeCharacter

on encodeText(theText, encodeCommonSpecialCharacters, encodeExtendedSpecialCharacters)
	set theStandardCharacters to "abcdefghijklmnopqrstuvwxyz0123456789"
	set theCommonSpecialCharacterList to "$+!'/?;&@=#%><{}\"~`^\\|*"
	set theExtendedSpecialCharacterList to ".-_:"
	set theAcceptableCharacters to theStandardCharacters
	if encodeCommonSpecialCharacters is false then set theAcceptableCharacters to theAcceptableCharacters & theCommonSpecialCharacterList
	if encodeExtendedSpecialCharacters is false then set theAcceptableCharacters to theAcceptableCharacters & theExtendedSpecialCharacterList
	set theEncodedText to ""
	repeat with theCurrentCharacter in theText
		if theCurrentCharacter is in theAcceptableCharacters then
			set theEncodedText to (theEncodedText & theCurrentCharacter)
		else
			set theEncodedText to (theEncodedText & encodeCharacter(theCurrentCharacter)) as string
		end if
	end repeat
	return theEncodedText
end encodeText
```

These scripts return Mac app links to files.
``` applescript
tell application "Microsoft Excel"
	set activeDoc to active workbook
	set activeDocName to name of active workbook
	set activeDocPath to path of active workbook
	set fullURL to full name of active workbook
	if fullURL does not start with "http" then
		return "file://" & POSIX path of fullURL
	end if
end tell

set appURL to "ms-excel:ofe|u|" & fullURL

tell application "Microsoft PowerPoint"
    set activeDoc to active presentation
    set activeDocName to name of activeDoc
    set activeDocPath to path of activeDoc
    set fullURL to full name of activeDoc
    if fullURL does not start with "http" then
        return "file://" & POSIX path of fullURL
    end if
end tell
set appURL to "ms-powerpoint:ofe|u|" & fullURL

tell application "Microsoft Word"
    set activeDoc to active document
    set activeDocName to name of activeDoc
    set activeDocPath to path of activeDoc
    set fullURL to posix full name of activeDoc
    if fullURL does not start with "http" then
        return "file://" & POSIX path of fullURL
    end if
end tell

set appURL to "ms-word:ofe|u|" & fullURL
```

For reference here are the original scripts
```applescript
use scripting additions
use framework "Foundation"
property NSURL : a reference to current application's NSURL

tell application "Microsoft Excel"
    set n to full name of active workbook
    set fp to POSIX path of n
    set rawUrl to NSURL's fileURLWithPath:fp
    set f to rawUrl's absoluteString
    return f as string
end tell

use framework "Foundation"
property NSURL : a reference to current application's NSURL

tell application "Microsoft PowerPoint"
    set n to full name of active presentation
    set fp to POSIX path of n
    set rawUrl to NSURL's fileURLWithPath:fp
    set f to rawUrl's absoluteString
    return f as string
end tell

--Thanks to @lawyerboy https://discourse.hookproductivity.com/t/microsoft-word-and-deep-linking/3446/6

use framework "Foundation"

use AppleScript version "2.4" -- Yosemite (10.10) or later
use scripting additions
property NSURL : a reference to current application's NSURL

set isFromPolling to 0

try
	if isHMLinkedStatusPolling is 1 then
		set isFromPolling to 1
	end if
end try

tell application "Microsoft Word"
	set n to name of active document
	set f to full name of active document
	set ppf to POSIX path of f
	set rawUrl to NSURL's fileURLWithPath:ppf
	set urlStr to rawUrl's absoluteString
	set selectedText to selection
	set selStart to selection start of selectedText
	set selEnd to selection end of selectedText
	if isFromPolling is 0 and selStart is not equal to selEnd then
		
		set bkName to "AS" & (current application's NSUUID's UUID's UUIDString's stringByReplacingOccurrencesOfString:"-" withString:"")
		make new bookmark at active document with properties {name:bkName, text object:text object of selectedText}
		
		
		return "[" & n & " bkMark: " & bkName & "](" & urlStr & "#bkName=" & bkName & ")"
	else
		return urlStr as string
	end if
	
end tell


```


## Velja

* Start at launch
* Set as default browser
* Change icon to primary browser
* Set shown browsers
* Grant profile access
* Load rules from OneDrive Common Info folder


## PopClip

TODO: figure out list of all extensions you install.

## Itsy calendar

* go through preferences
* configure system clock to just time

## Maccy

* select paste automatically
* set hot key to command-shift-V

## MenuBar Status

License - NFRTM-4BUJN-ZVE23-CGBFT-KUKDI-YZGK5-LHO53
Restore backup from iCloud in preferences

## Fig - shell integrations

No longer used.
Open and configure as directed

## Markdown Quicklook

see [sbarex/QLMarkdown: macOS Quick Look extension for Markdown files.](https://github.com/sbarex/QLMarkdown)
`brew install qlmarkdown`
and launch the application one time; this will register the quicklook extension.

## Apple Music, TV, Photos

Configure them to point to the correct music library, media library (for TV), and photos library

## Messages

* enable iCloud message sync

## Disk Drill

Set up data recovery.

## Daisy Disk

Remember to configure to measure cloud storage providers (OneDrive, Google Drive)

## Calibre ebooks

* Point at library on OneDrive
* Make sure OneDrive library is set to always be kept on device
* Copy calibre config from previous ~/Library/Preferences/calibre/
  * a copy from 06-24-2023 is in Common Info folder on OneDrive

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

## Java

Install via homebrew and follow instructions here https://formulae.brew.sh/formula/openjdk@11#default

`brew install openjdk`

For the system Java wrappers to find this JDK, symlink it with
`sudo ln -sfn $(brew --prefix)/opt/openjdk@11/libexec/openjdk.jdk /Library/Java/JavaVirtualMachines/openjdk-11.jdk`

## Fantasy Grounds

* Download from the [Fantasy Grounds Unity](https://www.fantasygrounds.com/home/FantasyGroundsUnity.php) site.
* Exit the updater app as you need to fix permissions first.
* Fix permissions will fail, so in System Preferences > Security and Privacy and added the FantasyGrounds App and the FGUpdaterEngine App to Full Disk Access. Note that it is installed in the Smiteworks folder.
* Quit and restart FantasyGroundsUpdater
* Now configure the app
  * Make sure the Fantasy Grounds folder is downloaded through OneDrive
  * Set up the data directory to /Users/bryan/OneDrive/Dungeons and Dragons (D&D)/Fantasy Grounds
    * You must manually pick it with the file picker. This will trigger giving access to OneDrive.
  * Login as gebhardt
    * For the second instance you can use your tdeckard login
  * Get license key from your softare serial numbers
* Click update

Reference:
[Installing on Mac OSX - Fantasy Grounds Customer Portal - Confluence](https://fantasygroundsunity.atlassian.net/wiki/spaces/FGCP/pages/996639724/Installing+on+Mac+OSX)
[Unable to fix permissions](https://www.fantasygrounds.com/forums/showthread.php?70206-Unable-to-fix-permissions)
[Please explain Mac FGU permissions request](https://www.fantasygrounds.com/forums/showthread.php?52631-Please-explain-Mac-FGU-permissions-request)


## Other core apps to set up

* PowerPhotos
* Velja - https://apps.apple.com/nz/app/velja/i... -- browser picker - download it from the app store and configure
* iDrive - login and set up cloud backups; set up continuous data protection
* Amphetamine - set it up to start at login
* Photos
* Music
* PDFExpert - download installer from their website instead of brew cask version.
* iMazing
* Swish
* Itsycal
* Stats
* Rocket
* PopClip
* Batteries

* BetterZip
* Harmony remote software: see https://support.myharmony.com/en-us/harmony-and-macos
* Plex
* Disk Drill

* Steam
* Epic Launcher
* GOG
* Parallels

* Calibre - ebooks - see folder on one drive too
* Kindle

* Mountain Duck (instead of CloudMounter)
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

# Retired Applications

## Joplin Note taking Setup 
I use [Joplin](https://joplinapp.org/) for cross platform note taking instead of Apple Notes so I can get my notes on Windows as well. It has great plugins but requires you to write all in markdown. Synchronization is through OneDrive and is not quite as robust as Apple Notes. Overall though it's a great app.

All files are in ~/.config/joplin-desktop and ~/.config/joplin.

**Settings**
* <TBD pull from settings.json?>

* Change app layout to move tabs to the top - see instructions

**Install the following plugins**

com.andrejilderda.macOSTheme.jpl
_com.font.size.shortcut.jpl_
com.github.joplin.kanban.jpl
com.hieuthi.joplin.copy-anchor-link.jpl
com.hieuthi.joplin.slash-commands.jpl
com.septemberhx.pluginBundle.jpl
com.whatever.inline-tags.jpl
com.whatever.quick-links.jpl
cx.evermeet.tessus.menu-shortcut-toolbar.jpl
de.habelt.CsvImport.jpl
io.github.daeraxa.match-highlight.jpl
joplin-insert-date.jpl
joplin.plugin.ambrt.copyNoteLink.jpl
_joplin.plugin.ambrt.goToItem.jpl_
joplin.plugin.benji.favorites.jpl
joplin.plugin.benji.quick-move.jpl
joplin.plugin.note.tabs.jpl
plugin.calebjohn.MathMode.jpl
plugin.calebjohn.todo.jpl
retr0ve.EmojiPlugin.jpl
sadmice.TextColorize.jpl



_Enabled_
com.hieuthi.joplin.copy-anchor-link.jpl
com.hieuthi.joplin.slash-commands.jpl
com.septemberhx.pluginBundle.jpl
com.whatever.inline-tags.jpl
com.whatever.quick-links.jpl
cx.evermeet.tessus.menu-shortcut-toolbar.jpl
de.habelt.CsvImport.jpl
io.github.daeraxa.match-highlight.jpl
joplin.plugin.ambrt.copyNoteLink.jpl
joplin.plugin.benji.persistentLayout.jpl
joplin.plugin.benji.quick-move.jpl
joplin.plugin.note.tabs.jpl
net.rmusin.joplin-table-formatter.jpl
plugin.calebjohn.MathMode.jpl
_plugin.calebjohn.rich-markdown.jpl_
plugin.calebjohn.todo.jpl
sadmice.TextColorize.jpl

_Disabled_
com.andrejilderda.macOSTheme.jpl
joplin-insert-date.jpl
com.github.joplin.kanban.jpl
joplin.plugin.benji.favorites.jpl
retr0ve.EmojiPlugin.jpl

_Just added_
https://github.com/cqroot/joplin-outline

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
