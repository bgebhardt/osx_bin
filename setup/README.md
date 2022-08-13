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

# Add all Scripts

Follow installation instructions here: https://github.com/bgebhardt/osx_scripts_folder
Configure all the FastScript shortcuts for the scripts.

# Configure Critical Apps and Settings

Spotlight might not be done indexing so you may have to run apps from Applications

Migrate over settings files from previous mac.
TODO: how to do that without migration assistant.

Install Rosetta Intel emulation via `sudo softwareupdate --install-rosetta`

Enable iCloud messages in Messages app preferences

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



---

# TODO

Set up ssh-keys
https://github.com/settings/keys
https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent

* Register BusyCal and BusyContacts



# Other minimum apps to install

- iClock
- Adobe Reader
- Harmony remote software: see https://support.myharmony.com/en-us/harmony-and-macos
- iDrive


Key Notifications settings to update
