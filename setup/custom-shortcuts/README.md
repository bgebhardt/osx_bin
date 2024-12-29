# Keyboard Shortcut Automation

# Better GUI Shortcut setting

Use this app instead of the system preferences keyboard shortcuts

Use [CustomShortcuts 1.0 - Free Tool to Customize Menu Shortcuts](https://blog.houdah.com/2020/06/customshortcuts-1-0-free-tool-to-customize-menu-shortcuts/). It's also excellent for checking the automated shortcut keys.

[Free Video Tutorial: Tip - Custom Shortcuts for macOS - Apple Mac, iPad & iPhone Tutorials from ScreenCastsOnline](https://www.screencastsonline.com/tutorials/utility-apps/tip-customshortcuts-for-macos)

And KeyCluCask is great for seeing all shortcuts at a glance.
[Anze/KeyCluCask: Simple and handy overview of applications shortcuts](https://github.com/Anze/KeyCluCask)

Install with

```bash
brew install --cask customshortcuts # Customise menu item keyboard shortcuts https://www.houdah.com/customShortcuts/
brew install --cask keyclu # Find shortcuts for any installed application https://sergii.tatarenkov.name/keyclu/support/
# works with customshortcuts
```

# Custom Shortcut Writer Script

And now the script to automate it. The script shortcut_writer.applescript will let you add custom shortcuts which also show in the CustomShortcuts app.

example usage:
`./shortcut_writer.applescript com.apple.Notes add 'Checklist' '@m' 'Strikethrough' '@$x' 'Minimize' '^m'`

The script was taken from near the end of this post. See AppleScript code to do this in [Setting Other Applications' Keyboard Shortcuts using NSUserDefaults - Defaults Not Updating - AppleScript - Late Night Software Ltd.](https://forum.latenightsw.com/t/setting-other-applications-keyboard-shortcuts-using-nsuserdefaults-defaults-not-updating/3537/6)

# Other reading

[The 6 Best Tools for Customizing Mac Keyboard Shortcuts](https://www.howtogeek.com/361724/the-6-best-tools-for-customizing-mac-hotkeys/#hammerspoon-control-your-system-with-lua)

---

# AppleScript Library Approach - NOT USED

I started building a script library to use but did not get full disk access enabled easily so switched to the script I run in the shell.

## Example usage of KeyboardShortcutsLib

```applescript
use AppleScript version "2.4" -- Yosemite (10.10) or later
use framework "Foundation"
use scripting additions
use kLib : script "KeyboardShortcutsLib"

-- Add Kamenoko shortcuts.
addGUICustomKeyboardShortcutApplication("jp.piyomarusoft.kamenoko1") of kLib
addCustomKeyboardShortcut("jp.piyomarusoft.kamenoko1", "About Kamenoko", "@^s") of kLib
```

```applescript
-- Add global application shortcuts.
addGUICustomKeyboardShortcutApplication("NSGlobalDomain")
addCustomKeyboardShortcut("NSGlobalDomain", "File->Save As…", "@$s")
addCustomKeyboardShortcut("NSGlobalDomain", "System Preferences…", "@~^,")

-- Add Finder shortcuts.
addGUICustomKeyboardShortcutApplication("com.apple.finder")
addCustomKeyboardShortcut("com.apple.finder", "Show Package Contents", "@s")

-- Add notes shortcuts.
addGUICustomKeyboardShortcutApplication("com.apple.Notes")
addCustomKeyboardShortcut("com.apple.Notes", "Strikethrough", "@$x")
```

## Installation

Copy KeyboardShortcutsLib to ~/Library/Script Libraries/

```bash
mkdir -p "$HOME/Library/Script Libraries"
cp KeyboardShortcutsLib.scpt "$HOME/Library/Script Libraries/"
```

# More information on usage

I’ve updated & extensively commented the code in the previous post. It should now be fully functional & feature-complete! This has been a long, tortuous (and torturous) road for me, so I’m thrilled to be able to share something that works.

At a later date, I will try to fully document the keyboard shortcut format, and determine if there are any API ergonomics to improve.

In brief, the shortcuts use the same format as in DefaultKeyBinding.dict (but delete is \U0008 and forward delete is \U007F). The following are used to specify the modifier keys:

^ is control
~ is option
$ is shift
@ is command
# is used to denote number pad keys on full keyboards (e.g. #1 means 1 key on the number pad)
There’s also a little known feature in System Preferences that allows you to specify full menu hierarchies by separating the items with -> (e.g. File->Save, which is converted behind the scenes to use the escape character as a leading & separating character), which allows for disambiguation in the event multiple menu items exist with the same name. That’s supported here as well & is automatically converted.

The example below shows how to add global shortcuts and application-specific shortcuts for Finder (a non-sandboxed application) and Notes (a sandboxed application).

addGUICustomKeyboardShortcutApplication ensures the application will appear in the list in System Preferences (but is not necessary for the shortcut to be functional).

If creating your own shortcuts, remember:

Use NSGlobalDomain for global shortcuts.

Bundle IDs are case sensitive.
Full Disk Access must be enabled for applications protected by SIP (e.g. Safari, Mail, Preview).
-- Add global application shortcuts.
addGUICustomKeyboardShortcutApplication("NSGlobalDomain")
addCustomKeyboardShortcut("NSGlobalDomain", "File->Save As…", "@$s")
addCustomKeyboardShortcut("NSGlobalDomain", "System Preferences…", "@~^,")

-- Add Finder shortcuts.
addGUICustomKeyboardShortcutApplication("com.apple.finder")
addCustomKeyboardShortcut("com.apple.finder", "Show Package Contents", "@s")

-- Add notes shortcuts.
addGUICustomKeyboardShortcutApplication("com.apple.Notes")
addCustomKeyboardShortcut("com.apple.Notes", "Strikethrough", "@$x")
Open in Script Debugger
Applications must be re-started for the changes to take effect. If anyone knows how to post a notification to notify the applications that the preferences have changed (like System Preferences does on recent versions of macOS), I’d love to know!