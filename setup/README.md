# Setting up a new Computer from scratch

based on 8-10-2022 setup of MacBook Pro


# Initial steps to get running

Set up Apple iCloud and minimal settings

- enter iCloud account
- Set up 1Password
- Turn on internet accounts in System Preferences -> Internet Accounts
    - Started with personal google - passkey didn’t work though
- Set mouse speed and secondary click

Finder settings

* Show filenames
* Change default to list view
* View -> Show status bar
* Change default to list view: View Options -> Set Default

Install Core Microsoft apps (now added to brew-cask-min install)

- Download and Install Microsoft Office
- Set up Outlook with personal email account
    - Turn off alert on desktop and new message sound in prefs
- Install OneDrive
- Set up Edge
    - Log in with Microsoft account
    - Change default browser in System Preferences -> General
- Install Visual code
    - Login to sync with MSFT account
    - Install cmd line tools with command-P and search for "install code" (see [The Visual Studio Code command-line interface](https://code.visualstudio.com/docs/editor/command-line))

Now set up dev environment

- Login to GitHub
- TODO: Set up ssh keys for new computer
- Follow read me: https://github.com/bgebhardt/osx_bin
    - install Brew
    - Set up shell settings
    - run ./brew-cask-minimum.sh
    - set up the apps -- look in the file for the list to set up

- Set your git user name. see https://git-scm.com/book/en/v2/Getting-Started-First-Time-Git-Setup

$ git config --global user.name "Bryan Gebhardt"
$ git config --global user.email bryan.gebhardt@gmail.com

Other minimum apps to install
- iClock


From OneDrive always sync the folders in your private file (not checked in)
*Do this before setting up apps incase they need the files.*
It seems to take a long time to download all teh files

Key Notifications settings to update
