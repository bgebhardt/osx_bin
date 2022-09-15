# Setting up a new Computer from scratch

Based on 8-10-2022 setup of MacBook Pro
Setting up from scratch without Migration assistant


# Initial steps to get running

Set up Apple iCloud and minimal settings

- enter iCloud account
- Set up 1Password
- Turn on internet accounts in System Preferences -> Internet Accounts
    - Started with personal google - passkey didn’t work though
- Set mouse speed and secondary click
- Set trackpad right corner secondary click and tap to click
- In system preferences items
  - Show Bluetooth menu
  - Show TimeMachine menu

Finder settings

* Show filenames
* Change default to list view
* View -> Show status bar
* Change default to list view: View Options -> Set Default


## Now set up dev environment

- Login to GitHub
- Set your git user name. see https://git-scm.com/book/en/v2/Getting-Started-First-Time-Git-Setup

$ git config --global user.name "Bryan Gebhardt"
$ git config --global user.email bryan.gebhardt@gmail.com

- TODO: Set up ssh keys for new computer

# Install applications

- Follow read me: https://github.com/bgebhardt/osx_bin
    - install Brew
    - Set up shell settings
    - run ./brew-cask-minimum.sh
    - set up the apps -- look in the file for the list to set up

## Install and set up Core Microsoft apps (now added to brew-cask-min install)

- Download and Install Microsoft Office (if not done by scripts)
- Set up Outlook with personal email account
    - Turn off alert on desktop and new message sound in prefs
- Set up OneDrive
- Set up Edge
    - Log in with Microsoft account
    - Change default browser in System Preferences -> General
    - Enable edge extensions you want in the toolbar (edge://extensions) (currently: 1Password, Session Buddy, Pocket, TabCopy, MSFT Editor)
- Set up Visual code (installed by brew-cask-minimum)
    - Login to sync with MSFT account
    - Install cmd line tools with command-P and search for "install code" (see [The Visual Studio Code command-line interface](https://code.visualstudio.com/docs/editor/command-line))

# Download key OneDrive Files

From OneDrive always sync the folders in your private file (not checked in)
*Do this before setting up apps incase they need the files.*
It seems to take a long time to download all teh files

# Set up rest of apps

* run ./mas.sh
  * There may be errors as app id's may have changed
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

Spotlight might not be done indexing so you may have to run apps from Applications

Migrate over settings files from previous mac.
TODO: how to do that without migration assistant.

Install Rosetta Intel emulation via `sudo softwareupdate --install-rosetta`

Enable iCloud messages in Messages app preferences

Install [Epson Printer Drivers](https://epson.com/Support/wa00607d)

## General

* Set CAPSLOCK to Control in System Preferences -> Keyboard -> Modifiers...

## Alfred (to replace spotlight)

* Change the spotlight short cut to Control-Option-Command-Space
* Change Alfred to command-space in General pane of Alfred settings

## Karabiner (for EMACS style keybindings)

* In Karabiner-Elements to to Misc pane and open ~/.config/karabiner
* Copy karabiner config from OneDrive to ~/.config/karabiner

## Rectangle - For Window movement shortcuts

* Open Rectangle preferences by clicking the gear tab
* Click Import to import in shortcuts file from OneDrive


## Login apps to set up

*Done*
caffeine 
popchar
Lunar -- very nice set up system
bartender -- configure it once all apps installed
Typinator 
FastScripts
Google Drive

* configure sets folder to one on OneDrive; restart Typinator
* pick sets My snippets, Date Stamps, Plain Clipboard Text, DOuble CAps, Inline calculation, Date Steps, Auto-Cap Sentences, Symbols, Emoji, TidBITS Auto (if not automatic after setting to onedrive folder)

Default-folder-x

* prefs: 
    * general: check all
    * folders: shortcuts for OneDrive Personal, Downloads
    * options: check and set open in iTerm2; check for updates.

*Partial*
alfred -- configure search items

*To do*


# Notes on other apps

Great 
[Amazing FREE Mac Apps You Aren’t Using! - YouTube](https://www.youtube.com/watch?v=FxUk8gxzHI8&list=WL&index=7&t=140s)

* Orion - https://browser.kagi.com -- safari based web browser that can run chrome, firefox, and safari extensions
* Velja - https://apps.apple.com/nz/app/velja/i... -- browser picker
* [alyssaxuu/later: Save all your Mac apps for later with one click 🖱️](https://github.com/alyssaxuu/later) -- free app to save and restore open windows. Awesome!
* [Dropover - Easier Drag & Drop on the Mac App Store](https://apps.apple.com/us/app/dropover-easier-drag-drop/id1355679052?mt=12) -- Use it to stash, gather or move any draggable content without having to open side-by-side windows.
* [Shottr – Screenshot Annotation App For Mac](https://shottr.cc/) -- free great screen shot tool!
* [Raycast](https://www.raycast.com/) -- spotlight replacement; similar to Alfred
* [ImageOptim — better Save for Web](https://imageoptim.com/mac) -- Removes bloated metadata. Saves disk space & bandwidth by compressing images without losing quality.
* [CopyClip - Clipboard History on the Mac App Store](https://apps.apple.com/us/app/copyclip-clipboard-history/id595191960?mt=12) -- free clipboard history app
* [Hidden Bar on the Mac App Store](https://apps.apple.com/us/app/hidden-bar/id1452453066?mt=12) -- hide menu bar items; free app like Bartender
* Hand Mirror - https://apps.apple.com/us/app/hand-mi... -- menubar item that will turn on your webcam to check out how you look
* [QuickShade on the Mac App Store](https://apps.apple.com/us/app/quickshade/id931571202?mt=12) -- free brightness control like Lunar or BetterDisplay which I like better
* [Operating system utilities for Mac - OnyX](https://www.titanium-software.fr/en/onyx.html) -- UI on a lot of system utilities
* [One Thing on the Mac App Store](https://apps.apple.com/us/app/one-thing/id1604176982?mt=12) -- Put one task in your menu bar

* [raycast vs alfred - Search](https://www.bing.com/search?q=raycast+vs+alfred&cvid=40c3758d7fc84f6d872e9566ddbe306c&aqs=edge.0.0j69i57j0.1896j0j1&pglt=171&FORM=ANNTA1&PC=U531)

---

# TODO

Set up ssh-keys
https://github.com/settings/keys
https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent

* Setup default applications (example: all PDF's open in PDF Expert instead of Preview). Look to see if there's a tool or script that can do this quickly.

* Register BusyCal and BusyContacts



# Other minimum apps to install

- iClock
- Adobe Reader
- Harmony remote software: see https://support.myharmony.com/en-us/harmony-and-macos
- iDrive


Key Notifications settings to update
