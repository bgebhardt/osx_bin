#!/usr/bin/env bash

# A collection of my favorite default changes to set up on a Mac

# disable 2 finger swipe to navigate which is built into Chrome
# http://osxdaily.com/2015/05/09/disable-swipe-navigation-google-chrome-mac/
defaults write com.google.Chrome.plist AppleEnableSwipeNavigateWithScrolls -bool FALSE

# Mail
# add mail plugins enabling