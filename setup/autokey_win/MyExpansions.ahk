; for advice see
; http://www.thenickmay.com/articles/how-to-expand-text-for-free-with-autohotkey/
; http://www.thenickmay.com/books/practical-autohotkey/examples/
; http://www.thenickmay.com/articles/how-to-quickly-insert-the-current-date-or-time-using-autohotkey/

; may require a space to expand
; if add :*: it will expand right away after you end the word
; if add :?: it will expand if part of a word
; if add :?*: it will expand no matter what

:: bg::bryan.gebhardt@gmail.com
::bgm::bryan.gebhardt@microsoft.com
::bgmm::brgebhar@microsoft.com
::bgm2::brgebhar
::bg.com::bryan.gebhardt@gmail.com
::-b::Bryan
::bcg::Bryan Gebhardt

::mphone::408-318-9114
::mmphone::510-543-4566

::sig::
(
Thanks

Bryan Gebhardt
bryan.gebhardt@gmail.com
408-38-9114 (m)
)

::sigw::
(
Thanks

Bryan Gebhardt
Modern Life Experiences (MLX) Chief of Staff
bryan.gebhardt@microsoft.com
)

;dtt insert date
::dtt::
SendInput %A_MM%-%A_DD%-%A_YYYY%
return