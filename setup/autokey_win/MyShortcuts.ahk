;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; MY AUTOHOTKEY KEY BINDINGS

;; TODO: look at moving to a better factored project like this one
;; https://github.com/denolfe/AutoHotkeyBoilerplate
;; https://github.com/denolfe/AutoHotkey


;; simplified verion of https://github.com/usi3/emacs.ahk/blob/master/emacs.ahk
;; also uses Capslock key for all Emacs bindings

;;
;; An autohotkey script that provides emacs-like keybinding on Windows
;;
#InstallKeybdHook
#UseHook


#Include %A_ScriptDir% ; change to scripts directory
#Include WebShortcuts.ahk

; The following line is a contribution of NTEmacs wiki http://www49.atwiki.jp/ntemacs/pages/20.html
SetKeyDelay 0

; turns to be 1 when ctrl-x is pressed
is_pre_x = 0
; turns to be 1 when ctrl-space is pressed
is_pre_spc = 0

; Applications you want to disable emacs-like keybindings
; (Please comment out applications you don't use)
is_target()
{
  IfWinActive,ahk_class ConsoleWindowClass ; Cygwin
    Return 1 
  IfWinActive,ahk_class MEADOW ; Meadow
    Return 1 
  IfWinActive,ahk_class cygwin/x X rl-xterm-XTerm-0
    Return 1
  IfWinActive,ahk_class MozillaUIWindowClass ; keysnail on Firefox
    Return 1
  ; Avoid VMwareUnity with AutoHotkey
  IfWinActive,ahk_class VMwareUnityHostWndClass
    Return 1
  IfWinActive,ahk_class Vim ; GVIM
    Return 1
;  IfWinActive,ahk_class SWT_Window0 ; Eclipse
;    Return 1
;   IfWinActive,ahk_class Xming X
;     Return 1
;   IfWinActive,ahk_class SunAwtFrame
;     Return 1
;   IfWinActive,ahk_class Emacs ; NTEmacs
;     Return 1  
;   IfWinActive,ahk_class XEmacs ; XEmacs on Cygwin
;     Return 1
  Return 0
}

delete_char()
{
  Send {Del}
  global is_pre_spc = 0
  Return
}
delete_backward_char()
{
  Send {BS}
  global is_pre_spc = 0
  Return
}
kill_line()
{
  Send {ShiftDown}{END}{SHIFTUP}
  Sleep 50 ;[ms] this value depends on your environment
  Send ^x
  global is_pre_spc = 0
  Return
}
open_line()
{
  Send {END}{Enter}{Up}
  global is_pre_spc = 0
  Return
}
quit()
{
  Send {ESC}
  global is_pre_spc = 0
  Return
}
newline()
{
  Send {Enter}
  global is_pre_spc = 0
  Return
}
indent_for_tab_command()
{
  Send {Tab}
  global is_pre_spc = 0
  Return
}
newline_and_indent()
{
  Send {Enter}{Tab}
  global is_pre_spc = 0
  Return
}
isearch_forward()
{
  Send ^f
  global is_pre_spc = 0
  Return
}
isearch_backward()
{
  Send ^f
  global is_pre_spc = 0
  Return
}
kill_region()
{
  Send ^x
  global is_pre_spc = 0
  Return
}
kill_ring_save()
{
  Send ^c
  global is_pre_spc = 0
  Return
}
yank()
{
  Send ^v
  global is_pre_spc = 0
  Return
}
undo()
{
  Send ^z
  global is_pre_spc = 0
  Return
}
find_file()
{
  Send ^o
  global is_pre_x = 0
  Return
}
save_buffer()
{
  Send, ^s
  global is_pre_x = 0
  Return
}
kill_emacs()
{
  Send !{F4}
  global is_pre_x = 0
  Return
}


; refactor inspired by this post: https://stackoverflow.com/questions/21883696/autohotkey-my-hotkeys-dont-work-in-combination-with-other-modifier-keys
; allows me to pass shift key for selecting text
; TODO: not working, ugh

nav(action) 
{
    global
  if is_pre_spc
    Send +{action}
  Else if ( GetKeyState("Shift", "P") ) ; pass along the shift key
  {
    MsgBox, here
    Send "{" action "}"; Send +{action}
  }
  Else
    Send "{" action "}"
  Return
}

move_beginning_of_line()
{
  ;nav("HOME")
  global
  if is_pre_spc
    Send +{HOME}
  Else if ( GetKeyState("Shift", "P") ) ; pass along the shift key
    Send +{HOME}
  Else
    Send {HOME}
  Return
}
move_end_of_line()
{
  ;nav("END")
  global
  if is_pre_spc
    Send +{END}
  Else if ( GetKeyState("Shift", "P") ) ; pass along the shift key
    Send +{END}
  Else
    Send {END}
  Return
}
previous_line()
{
  global
  if is_pre_spc
    Send +{Up}
  Else
    Send {Up}
  Return
}
next_line()
{
  global
  if is_pre_spc
    Send +{Down}
  Else
    Send {Down}
  Return
}
forward_char()
{
  global
  if is_pre_spc
    Send +{Right}
  Else if ( GetKeyState("Shift", "P") ) ; pass along the shift key
    Send +{Right}
  Else
    Send {Right}
  Return
}
backward_char()
{
  global
  if is_pre_spc
    Send +{Left} 
  Else if ( GetKeyState("Shift", "P") ) ; pass along the shift key
    Send +{Left}
  Else
    Send {Left}
  Return
}
scroll_up()
{
  global
  if is_pre_spc
    Send +{PgUp}
  Else
    Send {PgUp}
  Return
}
scroll_down()
{
  global
  if is_pre_spc
    Send +{PgDn}
  Else
    Send {PgDn}
  Return
}

; set up capslock

; make capslock always off
SetCapsLockState, AlwaysOff

; Map CapsLock to left control
; the trick was to use ~ to fire capsLock and control AND have caps lock state always off.
; This will make all the CapsLock based mappings below also work.
; https://www.autohotkey.com/docs/Hotkeys.htm#Tilde
~CapsLock::LControl

; All the links I looked at to figure this out.

; Finally found this way to do this; but it doesn't work with setcapslock state always off!!!!
; https://autohotkey.com/board/topic/5074-map-caps-lock-to-ctrl-and-arrow-keys/
; https://autohotkey.com/board/topic/104173-capslock-to-control-and-escape/
; https://www.autohotkey.com/boards/viewtopic.php?f=76&t=64357&p=275991
; https://www.autohotkey.com/boards/viewtopic.php?style=1&t=70079
; https://stackoverflow.com/questions/64809036/how-to-map-capslock-to-esc-and-esc-to-capslock-in-autohotkey
; https://www.reddit.com/r/AutoHotkey/comments/399ff2/mapping_capslock_to_control_and_escape/
; https://autohotkey.com/board/topic/5074-map-caps-lock-to-ctrl-and-arrow-keys/


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; WINDOW RELATED FUNCTIONS

;; TODO: 
;   move window between monitors

MonitorHeight()
{
  SysGet, primeMonitor, MonitorPrimary
  SysGet, workArea, MonitorWorkArea, %primeMonitor%
  workAreaWidth := workAreaRight - workAreaLeft
  workAreaHeight := workAreaBottom - workAreaTop
  return workAreaHeight
}

MonitorWidth()
{
  SysGet, primeMonitor, MonitorPrimary
  SysGet, workArea, MonitorWorkArea, %primeMonitor%
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

RightTwoThirdsWindow(WinTitle)
{
    WinRestore, %WinTitle% ; make sure it's not maximized before moving
    WinGetPos,,, Width, Height, %WinTitle%
    WinMove, %WinTitle%,, 0,0, MonitorWidth()*2/3, MonitorHeight()
    return
}


RightHalfWindow(WinTitle)
{
    WinRestore, %WinTitle% ; make sure it's not maximized before moving
    WinGetPos,,, Width, Height, %WinTitle%
    WinMove, %WinTitle%,, MonitorWidth()/2, 0, MonitorWidth()/2, MonitorHeight()     
    return
}
;WinMove, WinTitle, WinText, X, Y, [Width, Height, ExcludeTitle, ExcludeText]

LeftHalfWindow(WinTitle)
{
    WinRestore, %WinTitle% ; make sure it's not maximized before moving
    WinGetPos,,, Width, Height, %WinTitle%
    WinMove, %WinTitle%,, 0,0, MonitorWidth()/2, MonitorHeight()     
    return
}

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
}

; for diplaying and testing
^+m::
{
  MonitorHeight()
  MonitorWidth()
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
#+d::RightTwoThirdsWindow("A")  ; Windows+Shift+D

#+s::LeftHalfWindow("A")  ; Windows+Shift+left arrow
#+f::RightHalfWindow("A")  ; Windows+Shift+right arrow

; not working! TODO
;#+Left::LeftHalfWindow("A")  ; Windows+Shift+left arrow
;#+Right::RightHalfWindow("A")  ; Windows+Shift+right arrow

; TODO: look at hotkeys to position windows
; post with windows resize function - https://www.damirscorner.com/blog/posts/20200522-PositioningWithAutoHotkey.html
; look at centerwindow function in https://www.autohotkey.com/docs/commands/WinMove.htm

; Bing Search select text - Ctrl + Shift + C
 ^+c::
 {
  Send, ^c
  Sleep 50
  Run, http://www.bing.com/search?q=%clipboard%
  Return
 }
return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ADD APP SPECIFIC KEY BINDINGS

;; for Microsoft Edge
 #If WinActive("ahk_exe msedge.exe")
    ^[::^+Tab ;; next tab
    ^]::^Tab ;; prev tab
 #If ; turns off context sensitivity


;; for Excel
 #If WinActive("ahk_exe EXCEL.EXE")
    ;; todo: see if there's a better way then embedding in delete_char hotkey below
;;^d::$^d
 #If ; turns off context sensitivity

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ADD EMACS-STYLE KEY BINDINGS

;; my favorite bindings
;; d, k, h, k, s, y, a, e, b
;; want but they overlap. set to capslock only; currently all set to capslock only.
;; p, n
;; v (but prefer paste to this)

;; ^ = control
;; CapsLock & d = CapsLock + character

CapsLock & d::
  If is_target()
    Send %A_ThisHotkey%
  Else if WinActive("ahk_exe EXCEL.EXE") ; in excel ^d is fill down
    Send ^d 
  Else
    delete_char()
  Return
CapsLock & h::
  If is_target()
    Send %A_ThisHotkey%
  Else
    delete_backward_char()
  Return
CapsLock & k::
  If is_target()
    Send %A_ThisHotkey%
  Else
    kill_line()
  Return
CapsLock & s:: ;; changed to always be save
  If is_target()
    Send %A_ThisHotkey%
  Else
    save_buffer()
  Return
CapsLock & y::
  If is_target()
    Send %A_ThisHotkey%
  Else if WinActive("ahk_exe EXCEL.EXE") ; in excel ^y is repeat
    Send ^y
  Else
    yank()
  Return
CapsLock & f::
  If is_target()
    Send %A_ThisHotkey%
  Else
    forward_char()
  Return  
CapsLock & a::
  If is_target()
    Send %A_ThisHotkey%
  Else
    move_beginning_of_line()
  Return
CapsLock & e::
  If is_target()
    Send %A_ThisHotkey%
  Else
    move_end_of_line()
  Return
CapsLock & p::
  If is_target()
    Send %A_ThisHotkey%
  Else
    previous_line()
  Return
CapsLock & n::
  If is_target()
    Send %A_ThisHotkey%
  Else
    next_line()
  Return
CapsLock & b::
  If is_target()
    Send %A_ThisHotkey%
  Else
    backward_char()
  Return
; CapsLock & v::
;   If is_target()
;     Send %A_ThisHotkey%
;   Else
;     scroll_down()
;   Return
; !v:: ;; Alt + V
;   If is_target()
;     Send %A_ThisHotkey%
;   Else
;     scroll_up()
;   Return



; Notes on creating Emacs Style text movement commmands
; running my emacs_baic.ahk script to map all these to CapsLock.

; using https://github.com/justintanner/universal-emacs-keybindings/blob/master/emacs_autohotkey.ahk
; run emacs script in this folder
; other options
; https://github.com/catweazle9/emacs-everywhere
; https://github.com/usi3/emacs.ahk/blob/master/emacs.ahk

; visual basic macro-based solution for Word to consider
; https://www.rath.ca/Misc/VBacs/

; Copy URL in a keystroke in Edge 
; TODO: make it just edge

; Other scripts to consider making
; https://autohotkey.com/board/topic/38653-see-running-autohotkey-scripts-and-end-them/


