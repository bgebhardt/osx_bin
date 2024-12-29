#! /usr/bin/osascript

(* Public Release 1.2 *)
-- from https://forum.latenightsw.com/t/setting-other-applications-keyboard-shortcuts-using-nsuserdefaults-defaults-not-updating/3537/1

(*
Example for calling script
shortcut_writer.applescript com.apple.mail add 'Message->Move to->Mailbox1' '^@1' 'Message->Move to->Mailbox2' '^@2'
shortcut_writer.applescript com.apple.mail rm  'Message->Move to->Mailbox1' 'Message->Move to->Mailbox2'

Use NSGlobalDomain for global shortcuts

In brief, the shortcuts use the same format as in DefaultKeyBinding.dict (but delete is \U0008 and forward delete is \U007F). The following are used to specify the modifier keys:

^ is control
~ is option
$ is shift
@ is command
# is used to denote number pad keys on full keyboards (e.g. #1 means 1 key on the number pad)
There’s also a little known feature in System Preferences that allows you to specify full menu hierarchies by separating the items with -> (e.g. File->Save, which is converted behind the scenes to use the escape character as a leading & separating character), which allows for disambiguation in the event multiple menu items exist with the same name. That’s supported here as well & is automatically converted.

*)

use scripting additions
use framework "Foundation"

on usage()
	local appName, opts, ans
	set appName to name of me & ".applescript"
	set opts to " [-h | --help]"
	set ans to "usage: "
	set ans to ans & appName & opts & " appID add menutitle1 shortcut1 [menutitle2 shortcut2 ...]"
	set ans to ans & linefeed & "       " & appName & opts & " appID rm  menutitle1 [menutitle2 ...]"
	ans
end usage

on run argv
	if class of argv is not list then -- running withing Script Editor
		error "" & (quoted form of name of me) & " is intended to run from the command line."
		-- set argv to {"com.apple.Safari", "rm", "Quit Safari", "@~q"} -- for testing
	end if
	local n, i, arg -- modified 12/29/2023
	set n to count items of argv
	set i to 0
	repeat while (i < n)
		set arg to item (i + 1) of argv as string
		if arg starts with "-" then
			set i to i + 1
			if arg is "--" then exit repeat
			if {"-h", "-H", "--help"} contains arg then
				return usage()
			else
				error "unknown switch: " & arg
			end if
		else
			exit repeat
		end if
	end repeat
	local action, domain -- moved here 12/29/2023
	if i + 1 < n then
		set i to i + 1
		set domain to item i of argv as string
		set i to i + 1
		set action to item i of argv as string
	else
		error "must have appID and action arguments" & linefeed & usage()
	end if
	if action is "remove" then set action to "rm"
	if {"add", "rm"} does not contain action then error "\"" & action & "\" is not a valid action" & linefeed & usage()
	if i < n then
		set arg to items (i + 1) thru -1 of argv as list
	else
		set arg to {}
	end if
	set n to count items of arg
	if action is "add" then
		if n mod 2 is not 0 then error "add action must be followed by menutitle/shortcut pairs" & linefeed & usage()
		set n to n div 2
	end if
	verifyFullDiskAccess()
	addGUICustomKeyboardShortcutApplication(domain)
	if action is "add" then
		addCustomKeyboardShortcuts(domain, arg)
	else
		removeCustomKeyboardShortcuts(domain, arg)
	end if
end run



-- EAJ HANDLERS -- 
to verifyFullDiskAccess()
	local theFile, msg, num
	try
		set theFile to (path to library folder from user domain as string) & "Containers:com.apple.Safari:eajtmp"
		close access (open for access theFile with write permission)
		do shell script "/bin/rm -f " & quoted form of POSIX path of theFile -- tell application "Finder" to delete theFile
	on error msg number num
		activate
		display dialog "Need \"Full Disk Access\" to change most system prefs. Open System Settings to toggle the setting \"on\" for \"" & (name of current application) & "\"?" buttons {"Cancel", "Open System Settings"} cancel button 1 default button 2
		tell application id "com.apple.systempreferences"
			tell pane id "com.apple.settings.PrivacySecurity.extension" to reveal anchor named "Privacy_AllFiles"
		end tell
		try -- bail if Accessibility is not turned on
			tell application "System Events" to tell process "System Settings" -- application id "sevs"
				repeat until window "Full Disk Access" exists
					delay 0.02
				end repeat
			end tell
		on error msg number num
			delay 1 -- just assume this will be long enough
		end try
		tell application id "com.apple.systempreferences" to activate
		local timer
		repeat with timer from 1 to 40
			try
				close access (open for access theFile with write permission)
				do shell script "/bin/rm -f " & quoted form of POSIX path of theFile -- tell application "Finder" to delete theFile
				set num to 0
				activate
				exit repeat
			on error msg number num
				delay 0.25
			end try
		end repeat
		if num is not 0 then verifyFullDiskAccess()
	end try
	return
end verifyFullDiskAccess


--- HANDLERS ---
-- Getting a user defaults object.
to getUserDefaults(domain)
	-- Return a NSUserDefaults object for domain, which may be a bundle ID or path-style domain.
	if domain is "NSGlobalDomain" then set domain to ".NSGlobalDomain"
	return current application's NSUserDefaults's alloc()'s initWithSuiteName:domain
end getUserDefaults


-- Getting preference domain paths.
to applicationHasContainer(bundle_id)
	-- Return true if a container exists for bundle_id, false otherwise.
	return my fileExists(POSIX path of (path to home folder) & "Library/Containers/" & bundle_id & "/")
end applicationHasContainer

to getLegacyDomain(bundle_id)
	-- Return the standard preferences domain for bundle_id (without the .plist extension) starting with "~/Library/Preferences/".
	if bundle_id is "NSGlobalDomain" then set bundle_id to ".GlobalPreferences"
	return POSIX path of (path to home folder) & "Library/Preferences/" & bundle_id
end getLegacyDomain

to getSandboxedDomain(bundle_id)
	-- Return the containerized preferences domain for bundle_id (without the .plist extension) for use with sandboxed applications.
	return POSIX path of (path to home folder) & "Library/Containers/" & bundle_id & "/Data/Library/Preferences/" & bundle_id
end getSandboxedDomain


-- Controlling whether applications should appear in the System Preferences "Application Shortcuts" list.
to getGUICustomKeyboardShortcutApplications()
	-- Return the ordered list of applications appearing in the custom keyboard shortcut section of System Preferences.
	local gui_defaults -- new 12/29/2023
	set gui_defaults to my getUserDefaults("com.apple.universalaccess")
	return (gui_defaults's stringArrayForKey:"com.apple.custommenu.apps") as list
end getGUICustomKeyboardShortcutApplications

to setGUICustomKeyboardShortcutApplications(bundle_ids)
	-- Set the ordered list of applications appearing in the custom keyboard shortcut section of System Preferences.
	local gui_defaults -- new 12/29/2023
	set gui_defaults to my getUserDefaults("com.apple.universalaccess")
	gui_defaults's setObject:(my getUniqueItems(bundle_idxs)) forKey:"com.apple.custommenu.apps"
end setGUICustomKeyboardShortcutApplications

to hasGUICustomKeyboardShortcutApplications(bundle_id)
	-- Return whether the application id bundle_id appears in the custom keyboard shortcut section of System Preferences.
	return {bundle_id} is in my getGUICustomKeyboardShortcutApplications()
end hasGUICustomKeyboardShortcutApplications

to addGUICustomKeyboardShortcutApplication(bundle_id)
	-- Add the application id bundle_id to the custom keyboard shortcut section of System Preferences if it is not already included therein.
	local gui_defaults, gui_bundle_ids -- new 12/29/2023
	set gui_defaults to my getUserDefaults("com.apple.universalaccess")
	set gui_bundle_ids to (gui_defaults's stringArrayForKey:"com.apple.custommenu.apps") as list
	if gui_bundle_ids is {missing value} then set gui_bundle_ids to {} -- new 12/29/2023
	if bundle_id is not in gui_bundle_ids then gui_defaults's setObject:(gui_bundle_ids & {bundle_id}) forKey:"com.apple.custommenu.apps"
end addGUICustomKeyboardShortcutApplication

to removeGUICustomKeyboardShortcutApplication(bundle_id)
	-- Remove the application id bundle_id from the custom keyboard shortcut section of System Preferences if it is found therein.
	local gui_defaults, gui_bundle_ids -- new 12/29/2023
	set gui_defaults to my getUserDefaults("com.apple.universalaccess")
	set gui_bundle_ids to (gui_defaults's stringArrayForKey:"com.apple.custommenu.apps") as list
	if {bundle_id} is in gui_bundle_ids then
		if length of gui_bundle_ids is 1 then -- This is the last bundle ID.
			gui_defaults's setObject:(missing value) forKey:"com.apple.custommenu.apps"
		else -- Other bundle IDs still exist.
			gui_defaults's setObject:(my makeListByRemovingItem(gui_bundle_ids, bundle_id)) forKey:"com.apple.custommenu.apps"
		end if
	end if
end removeGUICustomKeyboardShortcutApplication


-- Manipulating custom keyboard shortcuts.
to getCustomKeyboardShortcutDictionary(bundle_id)
	-- Return an NSDictionary representation of the custom keyboard shortcuts for application id bundle_id.
	-- Like System Preferences, this retrieves the values from the sandboxed domain if the container exists, or the legacy domain if it does not.
	
	-- Get the dictionary representation of the specified domain only (without using the standard defaults search path).
	local user_defaults, dictionary_representation -- new 12/29/2023
	set user_defaults to my getUserDefaults(bundle_id)
	if my applicationHasContainer(bundle_id) then -- Sandboxed application.
		set dictionary_representation to user_defaults's persistentDomainForName:(my getSandboxedDomain(bundle_id))
	else -- Not sandboxed.
		if bundle_id is "NSGlobalDomain" then
			set dictionary_representation to user_defaults's dictionaryRepresentation()
		else -- Legacy application.
			set dictionary_representation to user_defaults's persistentDomainForName:(my getLegacyDomain(bundle_id))
		end if
	end if
	
	-- Return the dictionary represenation, or an empty dictionary if no shortcuts are found.
	local shortcut_dictionary -- new 12/29/2023
	if dictionary_representation is missing value then -- The defaults domain does not exist.
		set shortcut_dictionary to current application's NSDictionary's dictionary()
	else -- The domain exists (but the key may not).
		set shortcut_dictionary to dictionary_representation's objectForKey:"NSUserKeyEquivalents"
		if shortcut_dictionary is missing value then set shortcut_dictionary to current application's NSDictionary's dictionary()
	end if
	return shortcut_dictionary
end getCustomKeyboardShortcutDictionary

to setCustomKeyboardShortcutDictionary(bundle_id, shortcut_dictionary)
	-- Set the custom keyboard shortcuts for application id bundle_id using the NSDictionary shortcut_dictionary.
	-- Like System Preferences, this sets the shortcuts in the legacy domain & sandboxed domain (if the container exists).
	
	-- Get the user defaults.
	local has_container, legacy_defaults -- new 12/29/2023
	set has_container to my applicationHasContainer(bundle_id)
	set legacy_defaults to my getUserDefaults(my getLegacyDomain(bundle_id))
	if has_container then set sandboxed_defaults to my getUserDefaults(my getSandboxedDomain(bundle_id))
	
	-- Add the new custom keyboard shortcut.
	legacy_defaults's setObject:shortcut_dictionary forKey:"NSUserKeyEquivalents"
	if has_container then sandboxed_defaults's setObject:shortcut_dictionary forKey:"NSUserKeyEquivalents"
end setCustomKeyboardShortcutDictionary

to addCustomKeyboardShortcuts(bundle_id, menu_titles__keyboard_shortcuts)
	-- Add the custom keyboard shortcut for menu items for application id bundle_id. If the menu item already has a keyboard shortcut, it will be updated to the new shortcut.
	-- The menu title is processed to handle menu hierarchies.
	-- Like System Preferences, this adds the shortcut to the legacy domain & sandboxed domain (if the container exists).
	
	-- Get the user defaults.
	local has_container, legacy_defaults -- new 12/29/2023
	set has_container to my applicationHasContainer(bundle_id)
	set legacy_defaults to my getUserDefaults(my getLegacyDomain(bundle_id))
	if has_container then set sandboxed_defaults to my getUserDefaults(my getSandboxedDomain(bundle_id))
	
	-- Get the current keyboard shortcuts.
	local shortcut_dictionary, mutable_dictionary -- new 12/29/2023
	set shortcut_dictionary to my getCustomKeyboardShortcutDictionary(bundle_id)
	set mutable_dictionary to current application's NSMutableDictionary's dictionaryWithDictionary:shortcut_dictionary
	
	-- Add the new custom keyboard shortcut.
	local i
	repeat with i from 1 to (count items of menu_titles__keyboard_shortcuts) by 2
		(mutable_dictionary's setObject:(item (i + 1) of menu_titles__keyboard_shortcuts as string) forKey:(my encodeMenuTitle(item i of menu_titles__keyboard_shortcuts as string)))
	end repeat
	legacy_defaults's setObject:mutable_dictionary forKey:"NSUserKeyEquivalents"
	if has_container then sandboxed_defaults's setObject:mutable_dictionary forKey:"NSUserKeyEquivalents"
end addCustomKeyboardShortcuts
to addCustomKeyboardShortcut(bundle_id, menu_title, keyboard_shortcut)
	-- Add the custom keyboard shortcut keyboard_shortcut for menu item menu_title for application id bundle_id. If the menu item already has a keyboard shortcut, it will be updated to the new shortcut.
	-- The menu title is processed to handle menu hierarchies.
	-- Like System Preferences, this adds the shortcut to the legacy domain & sandboxed domain (if the container exists).
	
	-- Get the user defaults.
	local has_container, legacy_defaults -- new 12/29/2023
	set has_container to my applicationHasContainer(bundle_id)
	set legacy_defaults to my getUserDefaults(my getLegacyDomain(bundle_id))
	if has_container then set sandboxed_defaults to my getUserDefaults(my getSandboxedDomain(bundle_id))
	
	-- Get the current keyboard shortcuts.
	local shortcut_dictionary, mutable_dictionary -- new 12/29/2023
	set shortcut_dictionary to my getCustomKeyboardShortcutDictionary(bundle_id)
	set mutable_dictionary to current application's NSMutableDictionary's dictionaryWithDictionary:shortcut_dictionary
	
	-- Add the new custom keyboard shortcut.
	mutable_dictionary's setObject:keyboard_shortcut forKey:(my encodeMenuTitle(menu_title))
	legacy_defaults's setObject:mutable_dictionary forKey:"NSUserKeyEquivalents"
	if has_container then sandboxed_defaults's setObject:mutable_dictionary forKey:"NSUserKeyEquivalents"
end addCustomKeyboardShortcut

to removeCustomKeyboardShortcuts(bundle_id, menu_titles)
	-- Remove the custom keyboard shortcut for menu items menu_titles for application id bundle_id.
	-- The menu title is processed to handle menu hierarchies.
	-- Unlike System Preferences, this always removes the shortcut from the legacy domain & sandboxed domain (if the container exists).
	
	-- Get the user defaults.
	local has_container, legacy_defaults -- new 12/29/2023
	set has_container to my applicationHasContainer(bundle_id)
	set legacy_defaults to my getUserDefaults(my getLegacyDomain(bundle_id))
	if has_container then set sandboxed_defaults to my getUserDefaults(my getSandboxedDomain(bundle_id))
	
	-- Get the current keyboard shortcuts.
	local shortcut_dictionary, mutable_dictionary -- new 12/29/2023
	set shortcut_dictionary to my getCustomKeyboardShortcutDictionary(bundle_id)
	set mutable_dictionary to current application's NSMutableDictionary's dictionaryWithDictionary:shortcut_dictionary
	
	-- Remove the custom keyboard shortcut.
	local menu_title
	repeat with menu_title in menu_titles
		(mutable_dictionary's removeObjectForKey:(my encodeMenuTitle(menu_title as string)))
		if mutable_dictionary's |count|() as integer is 0 then
			set mutable_dictionary to missing value
			exit repeat
		end if
	end repeat
	legacy_defaults's setObject:mutable_dictionary forKey:"NSUserKeyEquivalents"
	if has_container then sandboxed_defaults's setObject:mutable_dictionary forKey:"NSUserKeyEquivalents"
end removeCustomKeyboardShortcuts
to removeCustomKeyboardShortcut(bundle_id, menu_title)
	-- Remove the custom keyboard shortcut for menu item menu_title for application id bundle_id.
	-- The menu title is processed to handle menu hierarchies.
	-- Unlike System Preferences, this always removes the shortcut from the legacy domain & sandboxed domain (if the container exists).
	
	-- Get the user defaults.
	local has_container, legacy_defaults -- new 12/29/2023
	set has_container to my applicationHasContainer(bundle_id)
	set legacy_defaults to my getUserDefaults(my getLegacyDomain(bundle_id))
	if has_container then set sandboxed_defaults to my getUserDefaults(my getSandboxedDomain(bundle_id))
	
	-- Get the current keyboard shortcuts.
	local shortcut_dictionary, mutable_dictionary -- new 12/29/2023
	set shortcut_dictionary to my getCustomKeyboardShortcutDictionary(bundle_id)
	set mutable_dictionary to current application's NSMutableDictionary's dictionaryWithDictionary:shortcut_dictionary
	
	-- Remove the custom keyboard shortcut.
	mutable_dictionary's removeObjectForKey:(my encodeMenuTitle(menu_title))
	if mutable_dictionary's |count|() as integer is 0 then set mutable_dictionary to missing value
	legacy_defaults's setObject:mutable_dictionary forKey:"NSUserKeyEquivalents"
	if has_container then sandboxed_defaults's setObject:mutable_dictionary forKey:"NSUserKeyEquivalents"
end removeCustomKeyboardShortcut


-- Formatting custom keyboard shortcuts.
to encodeMenuTitle(menu_title)
	-- Convert the plain-text representation of menu hierarchie menu_title (e.g. "File->Save") to its escaped version.
	if menu_title contains "->" then
		return character id 27 & my replaceText(menu_title, "->", character id 27)
	else
		return menu_title
	end if
end encodeMenuTitle


-- Library helpers.
to fileExists(file_specifier)
	try
		((file_specifier as «class furl») as alias)
		return true
	on error number -1700
		try
			using terms from application "System Events"
				((path of file_specifier) as alias)
				return true
			end using terms from
		end try
	end try
	return false
end fileExists

to getUniqueItems(L)
	local unique_items, an_item -- new 12/29/2023
	set unique_items to {}
	repeat with an_item in L
		set an_item to contents of an_item
		if an_item is not in unique_items then set the end of unique_items to an_item
	end repeat
	return unique_items
end getUniqueItems

to makeListByRemovingItem(L, O)
	local L_length, new_L, i, L_item -- new 12/29/2023
	set L_length to length of L
	set new_L to {}
	repeat with i from 1 to L_length
		set L_item to item i of L
		if L_item is not O then set the end of new_L to L_item
	end repeat
	return new_L
end makeListByRemovingItem

to replaceText(s, search_string, replacement_string)
	local previous_TIDs, s_text_items, s -- new 12/29/2023
	set previous_TIDs to AppleScript's text item delimiters
	set AppleScript's text item delimiters to search_string
	set s_text_items to text items of s
	set AppleScript's text item delimiters to replacement_string
	set s to s_text_items as string
	set AppleScript's text item delimiters to previous_TIDs
	return s
end replaceText