
-- from [Setting Other Applications' Keyboard Shortcuts using NSUserDefaults - Defaults Not Updating - AppleScript - Late Night Software Ltd.](https://forum.latenightsw.com/t/setting-other-applications-keyboard-shortcuts-using-nsuserdefaults-defaults-not-updating/3537/6)

(* Public Release 1.0 *)

use scripting additions
use framework "Foundation"

-- Add notes shortcuts.
addGUICustomKeyboardShortcutApplication("com.apple.Notes")
addCustomKeyboardShortcut("com.apple.Notes", "Strikethrough", "@$x")
addCustomKeyboardShortcut("com.apple.Notes", "Checklist", "@m")
addCustomKeyboardShortcut("com.apple.Notes", "Minimize", "^m")

--- HANDLERS ---
-- Getting a user defaults object.
to getUserDefaults(domain)
	log "getUserDefaults domain " & domain
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
	set gui_defaults to my getUserDefaults("com.apple.universalaccess")
	return (gui_defaults's stringArrayForKey:"com.apple.custommenu.apps") as list
end getGUICustomKeyboardShortcutApplications

to setGUICustomKeyboardShortcutApplications(bundle_ids)
	-- Set the ordered list of applications appearing in the custom keyboard shortcut section of System Preferences.
	set gui_defaults to my getUserDefaults("com.apple.universalaccess")
	gui_defaults's setObject:(my getUniqueItems(bundle_ids)) forKey:"com.apple.custommenu.apps"
end setGUICustomKeyboardShortcutApplications

to hasGUICustomKeyboardShortcutApplications(bundle_id)
	-- Return whether the application id bundle_id appears in the custom keyboard shortcut section of System Preferences.
	return {bundle_id} is in my getGUICustomKeyboardShortcutApplications()
end hasGUICustomKeyboardShortcutApplications

to addGUICustomKeyboardShortcutApplication(bundle_id)
	-- Add the application id bundle_id to the custom keyboard shortcut section of System Preferences if it is not already included therein.
	set gui_defaults to my getUserDefaults("com.apple.universalaccess")
	set gui_bundle_ids to (gui_defaults's stringArrayForKey:"com.apple.custommenu.apps") as list
	--log "gui_defaults " & gui_defaults
	log "bundle_id " & bundle_id
	log "gui_bundle_ids " & gui_bundle_ids
	if {bundle_id} is not in gui_bundle_ids then
		log "bundle id not in"
	else
		log "bundle id in"
	end if
	if {bundle_id} is not in gui_bundle_ids then gui_defaults's setObject:(gui_bundle_ids & {bundle_id}) forKey:"com.apple.custommenu.apps"
end addGUICustomKeyboardShortcutApplication

to removeGUICustomKeyboardShortcutApplication(bundle_id)
	-- Remove the application id bundle_id from the custom keyboard shortcut section of System Preferences if it is found therein.
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
	if dictionary_representation is missing value then -- The defaults domain does not exist.
		log "dictionary does not exist"
		set shortcut_dictionary to current application's NSDictionary's dictionary()
	else -- The domain exists (but the key may not).
		log "dictionary does exist"
		set shortcut_dictionary to dictionary_representation's objectForKey:"NSUserKeyEquivalents"
		if shortcut_dictionary is missing value then set shortcut_dictionary to current application's NSDictionary's dictionary()
	end if
	return shortcut_dictionary
end getCustomKeyboardShortcutDictionary

to setCustomKeyboardShortcutDictionary(bundle_id, shortcut_dictionary)
	-- Set the custom keyboard shortcuts for application id bundle_id using the NSDictionary shortcut_dictionary.
	-- Like System Preferences, this sets the shortcuts in the legacy domain & sandboxed domain (if the container exists).
	
	-- Get the user defaults.
	set has_container to my applicationHasContainer(bundle_id)
	set legacy_defaults to my getUserDefaults(my getLegacyDomain(bundle_id))
	if has_container then set sandboxed_defaults to my getUserDefaults(my getSandboxedDomain(bundle_id))
	
	-- Add the new custom keyboard shortcut.
	legacy_defaults's setObject:shortcut_dictionary forKey:"NSUserKeyEquivalents"
	if has_container then sandboxed_defaults's setObject:shortcut_dictionary forKey:"NSUserKeyEquivalents"
end setCustomKeyboardShortcutDictionary

to addCustomKeyboardShortcut(bundle_id, menu_title, keyboard_shortcut)
	-- Add the custom keyboard shortcut keyboard_shortcut for menu item menu_title for application id bundle_id. If the menu item already has a keyboard shortcut, it will be updated to the new shortcut.
	-- The menu title is processed to handle menu hierarchies.
	-- Like System Preferences, this adds the shortcut to the legacy domain & sandboxed domain (if the container exists).
	
	log "adding to bundle id " & bundle_id
	-- Get the user defaults.
	set has_container to my applicationHasContainer(bundle_id)
	set legacy_defaults to my getUserDefaults(my getLegacyDomain(bundle_id))
	if has_container then set sandboxed_defaults to my getUserDefaults(my getSandboxedDomain(bundle_id))
	
	log "has containter is " & has_container
	
	-- Get the current keyboard shortcuts.
	set shortcut_dictionary to my getCustomKeyboardShortcutDictionary(bundle_id)
	set mutable_dictionary to current application's NSMutableDictionary's dictionaryWithDictionary:shortcut_dictionary
	
	-- Add the new custom keyboard shortcut.
	mutable_dictionary's setObject:keyboard_shortcut forKey:(my encodeMenuTitle(menu_title))
	legacy_defaults's setObject:mutable_dictionary forKey:"NSUserKeyEquivalents"
	if has_container then sandboxed_defaults's setObject:mutable_dictionary forKey:"NSUserKeyEquivalents"
end addCustomKeyboardShortcut

to removeCustomKeyboardShortcut(bundle_id, menu_title)
	-- Remove the custom keyboard shortcut for menu item menu_title for application id bundle_id.
	-- The menu title is processed to handle menu hierarchies.
	-- Unlike System Preferences, this always removes the shortcut from the legacy domain & sandboxed domain (if the container exists).
	
	-- Get the user defaults.
	set has_container to my applicationHasContainer(bundle_id)
	set legacy_defaults to my getUserDefaults(my getLegacyDomain(bundle_id))
	if has_container then set sandboxed_defaults to my getUserDefaults(my getSandboxedDomain(bundle_id))
	
	-- Get the current keyboard shortcuts.
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
	set unique_items to {}
	repeat with an_item in L
		set an_item to contents of an_item
		if an_item is not in unique_items then set the end of unique_items to an_item
	end repeat
	return unique_items
end getUniqueItems

to makeListByRemovingItem(L, O)
	set L_length to length of L
	set new_L to {}
	repeat with i from 1 to L_length
		set L_item to item i of L
		if L_item is not O then set the end of new_L to L_item
	end repeat
	return new_L
end makeListByRemovingItem

to replaceText(s, search_string, replacement_string)
	set previous_TIDs to AppleScript's text item delimiters
	set AppleScript's text item delimiters to search_string
	set s_text_items to text items of s
	set AppleScript's text item delimiters to replacement_string
	set s to s_text_items as string
	set AppleScript's text item delimiters to previous_TIDs
	return s
end replaceText