; Always replace the running instance
#SingleInstance Force

#Include, WinExplorer.ahk

; Useful shared globals    
; Standardize the RFC3339 timestamp. 
Get_now()
{
    global
    UTCFormatStr := "yyyy-MM-dd'T'HH:mm:ss"
    FormatTime, TimeStr, CurrentDateTime, %UTCFormatStr%
    T1 := A_Now
    T2 := A_NowUTC
    EnvSub, T1, %T2%, M
    TZD := Round( T1/60, 0 ) 
    if (TZD == "0") {
      return Format("{}Z", TimeStr)
    } else if (TZD < 0) {
    return Format("{}-{2:02}:00", TimeStr, -TZD )
    } else {
    return Format("{}+{2:02}:00", TimeStr, TZD )
    }
}

F2::
msgbox % getUTCOffset(,"HH:mm")
return

getUTCOffset(timeStamp:="",format:="HH:mm"){
    timeStamp:=timeStamp?timeStamp:a_now
    timeStamp-=a_nowUTC,hours
    timeStamp:=timeStamp . 0000
    return formatTime(timeStamp,format)
}
formatTime(dateStamp,format:=""){
    local out,sign
    if(subStr(dateStamp,1,1)="-") ; preserve sign
        dateStamp:=abs(dateStamp),sign:="-"
    while(strLen(dateStamp)<14) ; ensure proper length
        dateStamp:=0 . dateStamp
    formatTime,out,% dateStamp,% format
    return sign . out
}

;Ctrl + Shift + D to add date time
^+d::
    FormatTime, CurrentDateTime, , dd/MM/yyyy
    SendInput %CurrentDateTime%
return

; Ctrl Alt H: Add entry to quicknote
; ^!H::
;     inputbox, text, Diary, , , 300, 100
;     TimeStr := Get_now()
;     fileappend, %TimeStr%`n%text%`n, D:\Sync\knowledge\zettlr\inbox\quicknote.md
; return
; Ctrl Alt H: Add entry to quicknote
^!H::
    ; Show the Input Box to the user.
    inputbox, text, Diary, , , 300, 100
    FormatTime, TodayDate, , dd-MM-yyyy
    ; Format the time-stamp.
    UTCFormatStr := "yyyy-MM-dd'T'HH:mm'Z'"
    TimeStr := Get_now()
    ;  current=%A_DD%/%A_MM%/%A_YYYY%, %A_Hour%:%A_Min%
    fileappend, %TimeStr%`n%text%`n, D:\Sync\knowledge\zettlr\inbox\quicknote.md
return

; Check mouse click. Whenever click, it will execute that function
; OnMessage(0x201 "Check_Control")

Check_Control()
{
    global
    loop, read, D:\Sync\knowledge\tags.txt
    {
        loop, parse, A_LoopReadLine, %A_Tab%
        {
            GuiControl, , ColorChoice, %A_LoopField%
            ; MsgBox, Field number %A_Index% is %A_LoopField%.
        }
    }
}

F1::
    sel := Explorer_GetSelected()
    ; MsgBox % sel
    SplitPath, sel, OutFileName, DirFolder, OutExt
    if (OutExt != "pdf") {
      return
  }

destFolder := "D:\Sync\KnowledgeObjectStore\magazines"
; MsgBox %DirFolder%`n%destFolder%
desired := Format("{}\{}", destFolder, OutFileName)
TimeStr := Get_now()

if (destFolder == DirFolder) {
    ; MsgBox, Already in object store. Doing nothing
} else {
    ; MsgBox, Moved to %desired%
    FileMove, %sel%, %desired%
    ;  current=%A_DD%/%A_MM%/%A_YYYY%, %A_Hour%:%A_Min%
    fileappend, %TimeStr%`n%destFolder%`\%OutFileName%`n, D:\Sync\knowledge\magazines.txt
}
Run, %desired%
notesPath := Format("D:\Sync\knowledge\ext\{}.md", OutFileName)
if (!FileExist(notesPath)) {
    MsgBox, Creating new file
    template := Format("---`ndate: {}`ntitle: {}`nsource: {}`n---`n", TimeStr, OutFileName, desired)
    MsgBox %template%
    fileappend, %template%, %notesPath%
}

Run, %notesPath%
return

^!P::
    Gui, 1:+AlwaysOnTop
    Gui, 1:Add, Text, , Please enter your name:
    gui, 1:add, Edit, w400 vXXX ; note that the var is XXX
    Gui, 1:Add, ComboBox, vColorChoice, 
    Check_Control()
    Gui, 1:Add, Button, , &Reload ; The label ButtonOK (if it exists) will be run when the button is pressed.
    Gui, 1:Add, Button, default, OK  ; The label ButtonOK (if it exists) will be run when the button is pressed.
    Gui, 1:Show, w500 Center, dNotes
return

GuiEscape:
    Gui, 1:Destroy
return

ButtonReload:
    Check_Control()
return

ButtonOK:
    Gui, 1:Submit  ; Save the input from the user to each control's associated variable.
    TimeStr := Get_now()
    fileappend, %TimeStr%`n%XXX%`n, D:\Sync\knowledge\zettlr\inbox\quicknote.md
    Gui, 1:Destroy
return

^!J::
    fileName=D:\Sync\knowledge\zettlr\inbox\quicknote.md
    Run, %fileName%
return

; Ctrl Alt D Open download dir
^!D::
    Run, D:\Downloads, , 
return

; Ctrl Alt E Open home dir
^!E::
    Run, C:\Users\Daniel, , 
return

; Ctrl Win H - Toggle view hidden. Might require a refresh.
^#h::
    RegRead, ValorHidden, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced, Hidden
    if ValorHidden = 2
        RegWrite, REG_DWORD, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced, Hidden, 1
    else
        RegWrite, REG_DWORD, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced, Hidden, 2
return

; Edit source
^!U::
    Edit %A_ScriptFullPath%
return

; Reload source
^!I::
    MsgBox, Reloaded
    Run, %A_ScriptFullPath%
return

; Ctrl Alt F12 open last screenshot and add a note
^!F12::
    Folder="D:\Sync\knowledge\screenshots"
    loop, %Folder%\*.png
    {
        if (A_LoopFileTimeCreated>Rec) {
            FPath=%A_LoopFileFullPath%
            Rec=%A_LoopFileTimeCreated%
            MetaFile=%A_LoopFileDir%\%A_LoopFileName%.md
        }
    }
    ; Open the image
    fileappend, , %MetaFile%
    Run %MetaFile%
    Run %Fpath%
return