
# Enable License

Activate with this Licence key. Open link in browser.

https://hook.cogsciapps.com/activate?info=d02975c273a42a6fa031c5e10e067ac856e8e3c3aee14a7020c528550ec991a879b576eec4638cc493b36c0915fdb3abb25fbe38760bb2a40a684adfcdf39d2f5d7653002625147ccafce1ec68aa2ff8ad643fe7b96ab0012680a3c0eb8bd87b867abc06fc2029bc30bf91691addafb0452473fd0f473e66196b0c8ca38af513eb195ad1b6151f6cbced0ee45cc0ad30660e0b43196ba0ecfc016b6a07c33a1d1083629b7d3d8d3fc2cbd6932a54f4f7ae803131589219a8fd784ae64cbe826eb14341e4173e892077f16e44a8a0a3947a8d8dd8b26f4228d5c6c7e96330d86b2e9d2aa1f14d42d0d9eef2d6bfee8052dbf714e53ffc2a257deda11b120bd007

# Set up Hookmark Core Settings

* Follow set up instructions
* Set Copy Link to Control-Command-C
* Set Copy Markdown Link to Control-Command-S
* Activate iCloud sync to sync links
* Import in link data if you have a recent backup
* Set up custom apps

Update Office apps in scripts tab. Change Get Address for each app as follows.

# Custom Scripts

"cur doc link v2.applescript" scripts return encoded URLs which are suitable for sharing in email, etc.
Here's one example. Note Excel uses workbook instead of document.
Likely found in ~/Library/Scripts/Applications/Microsoft Word/cur doc link v2.applescript. and Microsoft Excel and Microsoft PowerPoint directories.

Note: I added "?web=1" to the url so it opens on the web vs downloads the file.

https://microsoft.sharepoint-df.com/teams/M365CopilotTeam/Operations/MBR/M365%20Copilot%20Monthly%20Business%20Review%20-%204.30.2025.pptx?web=1 

[FY26 Priorities.xlsx](https://microsoft.sharepoint.com/teams/Office365BusinessOperations/Shared%20Documents/Planning/FY26/FY26%2520Priorities.xlsx?web=1)

## Word

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
	set docURL to activeDocPath & "/" & encodedDocName & "?web=1"

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

## Excel

```applescript
-- gets a url to the front window of Microsoft Excel.
-- can choose a link that will download if pasted into browser or a link format that opens in the Mac office app (set gMacAppLink).
-- when pasting the link into a Microsft app it should resolve to a clickable link that opens in web.

-- inspired by Hookmark's excel scripts 
-- Links with fixes for Office apps
-- [Using Hookmark in Microsoft OneDrive with Microsoft Office Apps – Hookmark](https://hookproductivity.com/help/integration/using-hook-with-onedrive/)
-- [Excel OneDrive file not Hookable \[workarounds\] - Discussion & Help - Hookmark Forum](https://discourse.hookproductivity.com/t/excel-onedrive-file-not-hookable-workarounds/2367/10)

set gMacAppLink to false

tell application "Microsoft Excel"
	set activeDoc to active workbook
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
	set docURL to activeDocPath & "/" & encodedDocName & "?web=1"	

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

## PowerPoint

```applescript
-- gets a url to the front window of Microsoft PowerPoint.
-- can choose a link that will download if pasted into browser or a link format that opens in the Mac office app (set gMacAppLink).
-- when pasting the link into a Microsft app it should resolve to a clickable link that opens in web.

-- inspired by Hookmark's excel scripts 
-- Links with fixes for Office apps
-- [Using Hookmark in Microsoft OneDrive with Microsoft Office Apps – Hookmark](https://hookproductivity.com/help/integration/using-hook-with-onedrive/)
-- [Excel OneDrive file not Hookable \[workarounds\] - Discussion & Help - Hookmark Forum](https://discourse.hookproductivity.com/t/excel-onedrive-file-not-hookable-workarounds/2367/10)

set gMacAppLink to false

tell application "Microsoft PowerPoint"
	set activeDoc to active presentation
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
	set docURL to activeDocPath & "/" & encodedDocName & "?web=1"

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

## Scripts that return file paths
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

## Original Scripts
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