#!/bin/bash

# my custom app shortcuts which are set using the shortcut_writer.applescript

# taken from https://forum.latenightsw.com/t/setting-other-applications-keyboard-shortcuts-using-nsuserdefaults-defaults-not-updating/3537/1

# Example for calling script
# shortcut_writer.applescript com.apple.mail add 'Message->Move to->Mailbox1' '^@1' 'Message->Move to->Mailbox2' '^@2'
# shortcut_writer.applescript com.apple.mail rm  'Message->Move to->Mailbox1' 'Message->Move to->Mailbox2'

# In brief, the shortcuts use the same format as in DefaultKeyBinding.dict (but delete is \U0008 and forward delete is \U007F). The following are used to specify the modifier keys:

# ^ is control
# ~ is option
# $ is shift
# @ is command
# # is used to denote number pad keys on full keyboards (e.g. #1 means 1 key on the number pad)
# There’s also a little known feature in System Preferences that allows you to specify full menu hierarchies by separating the items with -> (e.g. File->Save, which is converted behind the scenes to use the escape character as a leading & separating character), which allows for disambiguation in the event multiple menu items exist with the same name. That’s supported here as well & is automatically converted.

# Global shortcuts
# Minimize - Control-M
echo "Setting global shortcuts"
./shortcut_writer.applescript NSGlobalDomain add 'Minimize' '^m'

# Apple Notes
# Add a checklist - Command-M, Strikethrough - Command-Shift-X, Minimize - Control-M
echo "Setting Notes shortcuts"
./shortcut_writer.applescript com.apple.Notes add 'Checklist' '@m' 'Strikethrough' '@$x' 'Minimize' '^m'

# Microsoft Outlook
# New email - Command-N, Send - Command-Shift-D, Reply - Command-R, Forward - Command-J, Delete - Command-Delete, Archive - Command-Shift-M, Mark as read - Command-K, Mark as unread - Command-Shift-K, Minimize - Command-M
echo "Setting Outlook shortcuts"
./shortcut_writer.applescript com.microsoft.Outlook add 'Work Week' '~w' 'Three Day' '~3'
