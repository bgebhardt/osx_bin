-- office-to-pdf.applescript
--
-- Batch-exports Word/Excel/PowerPoint documents to PDF, mirroring the
-- source folder's structure into a sibling "<folder>-pdf" directory.
--
-- Because the PDF is produced by driving the real Office app (not a
-- third-party converter), documents protected with a Microsoft Purview
-- sensitivity label export exactly as they would from File > Save As,
-- as long as the label/policy permits it and you're signed into Office
-- with an account that has rights to the label. There is no way to
-- read or convert a label-protected file without Office (or another
-- Purview-aware app) doing the decryption -- that's the label's whole
-- point. If a label blocks "Save As"/export, that file will show up
-- in _export-errors.log with whatever error Office reports.
--
-- Usage:
--   osascript office-to-pdf.applescript /path/to/source/folder
--   osascript office-to-pdf.applescript          (prompts for a folder)
--
-- Or save as an Application (Script Editor > File > Export > File
-- Format: Application) and drag a folder onto it in Finder.
--
-- Supported inputs: .doc .docx .xls .xlsx .ppt .pptx
-- Office lock files (~$foo.docx) and dotfiles are skipped automatically.

on run argv
	if (count of argv) > 0 then
		my processFolder(item 1 of argv)
	else
		set chosenFolder to choose folder with prompt "Choose a folder of Office documents to export to PDF:"
		my processFolder(POSIX path of chosenFolder)
	end if
end run

on open droppedItems
	set folderPosix to POSIX path of (item 1 of droppedItems)
	my processFolder(folderPosix)
end open

on processFolder(sourcePosixIn)
	set sourcePosix to sourcePosixIn
	if sourcePosix ends with "/" then set sourcePosix to text 1 thru -2 of sourcePosix

	set destPosix to sourcePosix & "-pdf"
	do shell script "mkdir -p " & quoted form of destPosix

	set fileListText to do shell script "cd " & quoted form of sourcePosix & ¬
		" && find . -type f \\( -iname '*.doc' -o -iname '*.docx' -o -iname '*.xls' -o -iname '*.xlsx' -o -iname '*.ppt' -o -iname '*.pptx' \\) ! -name '~\\$*' ! -name '.*' | sort"

	if fileListText is "" then
		display dialog "No Office documents found in:" & return & sourcePosix buttons {"OK"} default button "OK"
		return
	end if

	-- `do shell script` returns multi-line output with CR (\r) separators,
	-- not LF, so split on paragraphs (handles CR/LF/CRLF) rather than linefeed.
	set relativePaths to paragraphs of fileListText

	-- Only quit apps at the end if we're the ones who launched them.
	set launchedWord to not (application "Microsoft Word" is running)
	set launchedExcel to not (application "Microsoft Excel" is running)
	set launchedPowerPoint to not (application "Microsoft PowerPoint" is running)

	set errorLog to {}
	set successCount to 0

	repeat with relPathRef in relativePaths
		set relPath to relPathRef as text
		if relPath starts with "./" then set relPath to text 3 thru -1 of relPath

		set srcFile to sourcePosix & "/" & relPath
		set destFile to destPosix & "/" & relPath
		set destFolder to do shell script "dirname " & quoted form of destFile
		set pdfDest to do shell script "printf '%s' " & quoted form of destFile & " | sed -E 's/\\.[^.\\/]+$/.pdf/'"

		do shell script "mkdir -p " & quoted form of destFolder
		-- Strip the Gatekeeper quarantine flag (if present) so Office doesn't
		-- open the file in Protected View and stall waiting for a click.
		-- This has no effect on Purview label protection, only macOS's
		-- "downloaded from the internet" flag.
		do shell script "xattr -d com.apple.quarantine " & quoted form of srcFile & " 2>/dev/null; true"

		set lowerPath to my toLower(relPath)

		try
			if lowerPath ends with ".doc" or lowerPath ends with ".docx" then
				my exportWord(srcFile, pdfDest)
			else if lowerPath ends with ".xls" or lowerPath ends with ".xlsx" then
				my exportExcel(srcFile, pdfDest)
			else if lowerPath ends with ".ppt" or lowerPath ends with ".pptx" then
				my exportPowerPoint(srcFile, pdfDest)
			end if
			set successCount to successCount + 1
		on error errMsg
			set end of errorLog to relPath & " -> " & errMsg
		end try
	end repeat

	if launchedWord then try
		tell application "Microsoft Word" to quit saving no
	end try
	if launchedExcel then try
		tell application "Microsoft Excel" to quit saving no
	end try
	if launchedPowerPoint then try
		tell application "Microsoft PowerPoint" to quit saving no
	end try

	set summaryText to (successCount as text) & " file(s) exported to:" & return & destPosix

	if (count of errorLog) > 0 then
		set AppleScript's text item delimiters to linefeed
		set errorText to errorLog as text
		set AppleScript's text item delimiters to ""
		set logFile to destPosix & "/_export-errors.log"
		do shell script "printf '%s\\n' " & quoted form of errorText & " > " & quoted form of logFile
		set summaryText to summaryText & return & return & (count of errorLog) & " file(s) failed - see " & logFile
	end if

	display dialog summaryText buttons {"OK"} default button "OK"
end processFolder

on toLower(t)
	set lowerChars to "abcdefghijklmnopqrstuvwxyz"
	set upperChars to "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
	set outText to ""
	repeat with c in t
		set i to offset of c in upperChars
		if i > 0 then
			set outText to outText & (character i of lowerChars)
		else
			set outText to outText & c
		end if
	end repeat
	return outText
end toLower

on exportWord(srcPosix, pdfPosix)
	tell application "Microsoft Word"
		with timeout of 600 seconds
			open (POSIX file srcPosix) confirm conversions false
			set theDoc to active document
			save as theDoc file name pdfPosix file format format PDF
			close theDoc saving no
		end timeout
	end tell
end exportWord

on exportExcel(srcPosix, pdfPosix)
	tell application "Microsoft Excel"
		with timeout of 600 seconds
			set theBook to open workbook workbook file name srcPosix
			save workbook as theBook filename pdfPosix file format PDF file format
			close theBook saving no
		end timeout
	end tell
end exportExcel

on exportPowerPoint(srcPosix, pdfPosix)
	tell application "Microsoft PowerPoint"
		with timeout of 600 seconds
			open (POSIX file srcPosix)
			set theDeck to active presentation
			save theDeck in (POSIX file pdfPosix) as save as PDF
			close theDeck saving no
		end timeout
	end tell
end exportPowerPoint
