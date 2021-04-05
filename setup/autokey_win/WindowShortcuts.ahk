
;MsgBox, "Loaded WindowShortcuts.ahk"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; WINDOW RELATED FUNCTIONS

;; TODO: 
;   move window between monitors

MonitorHeight(windowMonitor)
{
  ;SysGet, primeMonitor, MonitorPrimary ; gets the primary monitor
  SysGet, workArea, MonitorWorkArea, %windowMonitor%
  workAreaWidth := workAreaRight - workAreaLeft
  workAreaHeight := workAreaBottom - workAreaTop
  return workAreaHeight
}

MonitorWidth(windowMonitor)
{
  ;SysGet, primeMonitor, MonitorPrimary ; gets the primary monitor
  SysGet, workArea, MonitorWorkArea, %windowMonitor%
  workAreaWidth := workAreaRight - workAreaLeft
  workAreaHeight := workAreaBottom - workAreaTop
  ; MsgBox, %workAreaRight%, %workAreaLeft%, ; 1259, -241
  ; MsgBox, %workAreaTop%, %workAreaBottom% ; 1440, 2500
  ; MsgBox, %workAreaWidth%, %workAreaHeight% ; 1500,960 ; 2560, 1400
  ; MsgBox, %A_ScreenHeight%, %A_ScreenWidth% ; 1440, 2560
  return workAreaWidth ; return bottom
}

CenterWindow(WinTitle)
{
    WinRestore, %WinTitle% ; make sure it's not maximized before moving
    WinGetPos,,, Width, Height, %WinTitle%
    ; this one uses primary monitor full width and height as it moves the window without making it bigger
    WinMove, %WinTitle%,, (A_ScreenWidth/2)-(Width/2), (A_ScreenHeight/2)-(Height/2)
    return
}

LeftVerticalWindow(WinTitle, percentageWidth)
{
    if (percentageWidth > 100) {
        return ; do nothing if more than 100%
    }

    windowMonitor := GetWindowMonitor(WinTitle)
    SysGet, workArea, MonitorWorkArea, %windowMonitor%
  
    WinRestore, %WinTitle% ; make sure it's not maximized before moving
    WinGetPos, WinX, WinY, Width, Height, %WinTitle%
    WinMove, %WinTitle%,, %workAreaLeft%, %workAreaTop%, MonitorWidth(windowMonitor)*percentageWidth, MonitorHeight(windowMonitor)
    return
}

RightVerticalWindow(WinTitle, percentageWidth)
{
    if (percentageWidth > 100) {
        return ; do nothing if more than 100%
    }
    
    windowMonitor := GetWindowMonitor(WinTitle)
    SysGet, workArea, MonitorWorkArea, %windowMonitor%
  
    WinRestore, %WinTitle% ; make sure it's not maximized before moving
    WinGetPos, WinX, WinY, Width, Height, %WinTitle%

    leftStart := (workAreaLeft + MonitorWidth(windowMonitor)*(1-percentageWidth)) ; we want to start 1-the % from the left start
    WinMove, %WinTitle%,, %leftStart%, %workAreaTop%, MonitorWidth(windowMonitor)*percentageWidth, MonitorHeight(windowMonitor)
    return
}

; ; TODO: REMOVE
; LeftTwoThirdsWindow(WinTitle)
; {
;     windowMonitor := GetWindowMonitor(WinTitle)
;     SysGet, workArea, MonitorWorkArea, %windowMonitor%
  
;     WinRestore, %WinTitle% ; make sure it's not maximized before moving
;     WinGetPos, WinX, WinY, Width, Height, %WinTitle%
;     WinMove, %WinTitle%,, %workAreaLeft%, %workAreaTop%, MonitorWidth(windowMonitor)*2/3, MonitorHeight(windowMonitor)
;     return
; }

; RightHalfWindow(WinTitle)
; {
;     windowMonitor := GetWindowMonitor(WinTitle)
;     SysGet, workArea, MonitorWorkArea, %windowMonitor%
  
;     WinRestore, %WinTitle% ; make sure it's not maximized before moving
;     WinGetPos, WinX, WinY, Width, Height, %WinTitle%

;     leftStart := (workAreaLeft + MonitorWidth(windowMonitor)/2)
;     WinMove, %WinTitle%,, %leftStart%, %workAreaTop%, MonitorWidth(windowMonitor)/2, MonitorHeight(windowMonitor)
;     return
; }
; ;WinMove, WinTitle, WinText, X, Y, [Width, Height, ExcludeTitle, ExcludeText]

; LeftHalfWindow(WinTitle)
; {
;     windowMonitor := GetWindowMonitor(WinTitle)
;     SysGet, workArea, MonitorWorkArea, %windowMonitor%
  
;     WinRestore, %WinTitle% ; make sure it's not maximized before moving
;     WinGetPos, WinX, WinY, Width, Height, %WinTitle%
;     WinMove, %WinTitle%,, %workAreaLeft%, %workAreaTop%, MonitorWidth(windowMonitor)/2, MonitorHeight(windowMonitor)
;     return
; }

DisplayMonitorInfo()
{
  ; Displays info about each monitor.
  ;https://www.autohotkey.com/docs/commands/SysGet.htm
  SysGet, MonitorCount, MonitorCount
  SysGet, MonitorPrimary, MonitorPrimary
  MsgBox, Monitor Count:`t%MonitorCount%`nPrimary Monitor:`t%MonitorPrimary%
  Loop, %MonitorCount%
  {
      SysGet, MonitorName, MonitorName, %A_Index%
      SysGet, Monitor, Monitor, %A_Index%
      SysGet, MonitorWorkArea, MonitorWorkArea, %A_Index%
      MsgBox, Monitor:`t#%A_Index%`nName:`t%MonitorName%`nLeft:`t%MonitorLeft% (%MonitorWorkAreaLeft% work)`nTop:`t%MonitorTop% (%MonitorWorkAreaTop% work)`nRight:`t%MonitorRight% (%MonitorWorkAreaRight% work)`nBottom:`t%MonitorBottom% (%MonitorWorkAreaBottom% work)
  }
  return
}

; returns the monitor number this window is on
; assumes two monitors right next to each other
GetWindowMonitor(WinTitle)
{
  SysGet, Mon1, Monitor, 1
  SysGet, Mon2, Monitor, 2
  WinGetPos, WinX, WinY, WinWidth, WinHeight, %WinTitle%

  ; Determines which monitor this is on by the position of the center pixel.
  WinXCenter := WinX + (WinWidth / 2) 
  WinYCenter := WinY + (WinHeight / 2)

  winOnDisplay := 1 ; default to display one

  ; if center point is within bounds of a display then return that display
  ; figure out the display
  ; if x point is between left and right AND
  ; if y pint is between top and bottom THEN
  ; you're on that display
  
  ; for now moving to monitor as full screen; TODO: size window when moved
  ; if on monitor 1
  if (WinXCenter > Mon1Left and WinXCenter < Mon1Right and WinYCenter > Mon1Top and WinYCenter < Mon1Bottom) {
    winOnDisplay :=1
  } else { ; on monitor 2
    winOnDisplay :=2
  }
  return winOnDisplay
}

; inspired by these posts
; https://autohotkey.com/board/topic/17885-dual-monitor-swap/
; https://autohotkey.com/board/topic/32874-moving-the-active-window-from-one-monitor-to-the-other/
SwapMonitor(WinTitle) 
{
;  WinGetPos, X, Y, W, H, %WinTitle%
;  MsgBox, the win is at %X%,%Y% and its size is %W%x%H%
  
  ; assumes two monitors right next to each other
  SysGet, Mon1, Monitor, 1
  SysGet, Mon2, Monitor, 2
  WinGetPos, WinX, WinY, WinWidth, WinHeight, %WinTitle%
  
  ; Determines which monitor this is on by the position of the center pixel.
  WinXCenter := WinX + (WinWidth / 2) 
  WinYCenter := WinY + (WinHeight / 2)

  ; for now moving to monitor as full screen; TODO: size window when moved
  winOnDisplay := GetWindowMonitor(WinTitle)
  
  ; TODO remove -40 hack to account for task bar
  if (winOnDisplay = 1) {
    ; then move to monitor 2
    WinMove, %WinTitle%, , Mon2Left, Mon2Top, Mon2Right, (Mon2Bottom - 40)
  } else { ; on monitor 2
    ; move to monitor 1
    WinMove, %WinTitle%, , Mon1Left, Mon1Top, Mon1Right, (Mon1Bottom - 40)
  }
  return
}

; for diplaying and testing
^+m::
{
  MonitorHeight(1)
  MonitorWidth(1)
  DisplayMonitorInfo()
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ADD OTHER GLOBAL KEY BINDINGS

; from https://windowsloop.com/best-autohotkey-scripts/
; Minimize active window
#+Down::WinMinimize, A ; Windows+Shift+Down

; Maximize active window
#+Up::WinMaximize, A  ; Windows+Shift+Up

; Restores active window
#+Right::WinRestore, A  ; Windows+Shift+Right

#+c::CenterWindow("A")  ; Windows+Shift+C
#+d::LeftVerticalWindow("A", 2/3)  ; move window to left 2/3rd of screen; Windows+Shift+D
#^d::RightVerticalWindow("A", 2/3)  ; move window to right 2/3rd of screen; Windows+Control+D

#+s::LeftVerticalWindow("A", 1/2)  ; move window to left half of screen; Windows+Shift+S
#^s::LeftVerticalWindow("A", 1/3)  ; move window to left third of screen; Windows+Control+S

#+f::RightVerticalWindow("A", 1/2)  ; move window to right half of screen; Windows+Shift+F
#^f::RightVerticalWindow("A", 1/3)  ; move window to right third of screen; Windows+Control+F

#+w::SwapMonitor("A") ; swap window to other monitor



; not working! TODO
;#+Left::LeftHalfWindow("A")  ; Windows+Shift+left arrow
;#+Right::RightHalfWindow("A")  ; Windows+Shift+right arrow

; TODO: look at hotkeys to position windows
; post with windows resize function - https://www.damirscorner.com/blog/posts/20200522-PositioningWithAutoHotkey.html
; look at centerwindow function in https://www.autohotkey.com/docs/commands/WinMove.htm
