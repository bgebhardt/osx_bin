-- This script calculates the current week's dates starting from Monday to Sunday
-- It formats the dates in MM-DD-YYYY format and returns them as a string
-- Example output: "07-27-2025 to 08-01-2025"
-- The script can be used in Typinator or other automation tools to quickly get the current week's date range
-- It accounts for the current day of the week and adjusts accordingly to always start from Monday

--gives me the current weeks dates starting with monday. For example it should output: "07-27-2025 to 08-01-2025}}
-- I use it in Typinator to print out the current weeks Mon to Sun dates.
set today to current date
set dayOfWeek to weekday of today as integer
-- Calculate days to subtract to get to Monday (Monday = 2)
set daysToMonday to (dayOfWeek - 2)
if daysToMonday < 0 then set daysToMonday to daysToMonday + 7

-- Get Monday of current week
set ThisMonday to today - (daysToMonday * days)

-- Get Friday of current week  
set ThisFriday to ThisMonday + (4 * days)
set ThisSunday to ThisMonday + (7 * days)

-- Format dates as MM-DD-YYYY
set mondayFormatted to my formatDate(ThisMonday)
set sundayFormatted to my formatDate(ThisSunday)

return mondayFormatted & " to " & sundayFormatted

on formatDate(theDate)
	set theMonth to month of theDate as integer
	set theDay to day of theDate
	set theYear to year of theDate
	
	-- Add leading zeros if needed
	if theMonth < 10 then set theMonth to "0" & theMonth
	if theDay < 10 then set theDay to "0" & theDay
	
	return (theMonth as string) & "-" & (theDay as string) & "-" & (theYear as string)
end formatDate
