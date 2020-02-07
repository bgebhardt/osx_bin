#!/usr/bin/env bash

# Defaults inspired by 
# * [Change macOS user preferences via command line | pawelgrzybek.com](https://pawelgrzybek.com/change-macos-user-preferences-via-command-line/)
# * [GitHub - mathiasbynens/dotfiles: .files, including ~/.macos — sensible hacker defaults for macOS](https://github.com/mathiasbynens/dotfiles)
# * [dotfiles/.macos at master · mathiasbynens/dotfiles · GitHub](https://github.com/mathiasbynens/dotfiles/blob/master/.macos)
# * [GitHub - pawelgrzybek/dotfiles](https://github.com/pawelgrzybek/dotfiles)
# * [dotfiles/setup-macos.sh at master · pawelgrzybek/dotfiles · GitHub](https://github.com/pawelgrzybek/dotfiles/blob/master/setup-macos.sh)

# A collection of my favorite default changes to set up on a Mac

# disable 2 finger swipe to navigate which is built into Chrome
# http://osxdaily.com/2015/05/09/disable-swipe-navigation-google-chrome-mac/
# old one: defaults write com.google.Chrome.plist AppleEnableSwipeNavigateWithScrolls -bool FALSE

###############################################################################
# Finder                                                                      #
###############################################################################

# Finder: allow quitting via ⌘ + Q; doing so will also hide desktop icons
defaults write com.apple.finder QuitMenuItem -bool true

# Disable the warning when changing a file extension
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

###############################################################################
# Google Chrome & Google Chrome Canary                                        #
###############################################################################

# Disable the all too sensitive backswipe on trackpads
defaults write com.google.Chrome AppleEnableSwipeNavigateWithScrolls -bool false
defaults write com.google.Chrome.canary AppleEnableSwipeNavigateWithScrolls -bool false

# Disable the all too sensitive backswipe on Magic Mouse
defaults write com.google.Chrome AppleEnableMouseSwipeNavigateWithScrolls -bool false
defaults write com.google.Chrome.canary AppleEnableMouseSwipeNavigateWithScrolls -bool false

# Use the system-native print preview dialog
# defaults write com.google.Chrome DisablePrintPreview -bool true
# defaults write com.google.Chrome.canary DisablePrintPreview -bool true

# # Expand the print dialog by default
# defaults write com.google.Chrome PMPrintingExpandedStateForPrint2 -bool true
# defaults write com.google.Chrome.canary PMPrintingExpandedStateForPrint2 -bool true

# Mail
# add mail plugins enabling