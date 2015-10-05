;replaced by consolez
;#t::
;Run, "C:\cygwin64\Cygwin.bat",,
;return

;Ctrl + Shift + D to add date time

^+d::
FormatTime, CurrentDateTime,, dd/MM/yyyy
SendInput %CurrentDateTime%
return

;^!H::
;  ; Show the Input Box to the user.
;  inputbox, text, Diary,,,300,100
;
;  ; Format the time-stamp.
;  current=%A_DD%/%A_MM%/%A_YYYY%, %A_Hour%:%A_Min%
;
;  ; Write this data to the diary.txt file.
;  fileappend, %current% - %text%`n, diary.txt
;return

^!D::
Run, F:\Downloads,,
return

^!E::
Run, C:\Users\Daniel,,
return


^#h::
RegRead, ValorHidden, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced, Hidden
if ValorHidden = 2
  RegWrite, REG_DWORD, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced, Hidden, 1
else
  RegWrite, REG_DWORD, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced, Hidden, 2
return 