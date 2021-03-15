
; from https://windowsloop.com/best-autohotkey-scripts/

; NOT WORKING
;Minimize active window
^+Down::WinMinimize, A ; Control+Shift+Down
return

; Bing Search select text - Ctrl + Shift + C
 ^+c::
 {
  Send, ^c
  Sleep 50
  Run, http://www.bing.com/search?q=%clipboard%
  Return
 }
return

; https://autohotkey.com/board/topic/5074-map-caps-lock-to-ctrl-and-arrow-keys/

; these didn't work when holding down capslock; using powertools instead
; Remap CapsLock key
;CapsLock::Send {LControl Down}
;CapsLock Up::Send {LControl Up}
;Capslock::Control
;return


; Create Emacs Style text movement commmands
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


