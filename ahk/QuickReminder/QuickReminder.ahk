;**********************************************
;*                                            *
;*                                            *
;*                                            *
;*                                            *
;*                Main program                *
;*                                            *
;*                                            *
;*                                            *
;*                                            *
;**********************************************
$Version:="0.5"


;*************************
;*                       *
;*    AHK environment    *
;*                       *
;*************************
#NoEnv
#NoTrayIcon
#SingleInstance Force
ListLines Off
DetectHiddenWindows Off
    ;-- Note: "Off" is the AutoHotkey default for this command but it is defined
    ;   explicitly here to indicate that this script depends on this setting.

OnExit ExitApp


;***************************
;*                         *
;*    General constants    *
;*                         *
;***************************
;-- Microsoft constants
EM_SETSEL        :=0xB1
LVM_GETITEMSTATE :=0x102C
LVIS_SELECTED    :=0x2

;-- Data constants
$GUIDelimiter    :=Chr(131)
$FieldDelimiter  :=Chr(134)
$RecordDelimiter :=Chr(135)
$iniBorder       :=Chr(142)


;***********************
;*                     *
;*    TTS constants    *
;*                     *
;***********************
;[============]
;[  Priority  ]
;[============]
SVPNormal :=0
    ;-- Normal voice. Text streams spoken by a normal voice are added to the end
    ;   of the voice queue. A voice with SVPNormal priority cannot interrupt
    ;   another voice.

SVPAlert :=1
    ;-- Alert voice. Text streams spoken by an alert voice are inserted into the
    ;   voice queue ahead of normal voice streams.  An alert voice will
    ;   interrupt a normal voice, which will resume speaking when the alert
    ;   voice has finished speaking.

SVPOver :=2
    ;-- Over voice. Text streams spoken by an over voice go into the voice queue
    ;   ahead of normal and alert streams.  An over voice will not interrupt,
    ;   but speaks over (mixes with) the voices of lower priorities.


;[===============]
;[  Speak Flags  ]
;[===============]
SVSFDefault :=0x0
    ;-- Specifies that the default settings should be used. The defaults are:
    ;
    ;     - To speak the given text string synchronously (override with
    ;       SVSFlagsAsync),
    ;
    ;     - Not to purge pending speak requests (override with
    ;       SVSFPurgeBeforeSpeak),
    ;
    ;     - To parse the text as XML only if the first character is a
    ;       left-angle-bracket (override with SVSFIsXML or SVSFIsNotXML),
    ;
    ;     - Not to persist global XML state changes across speak calls (override
    ;       with SVSFPersistXML), and
    ;
    ;     - Not to expand punctuation characters into words (override with
    ;       SVSFNLPSpeakPunc).

SVSFlagsAsync :=0x1
    ;-- Specifies that the Speak call should be asynchronous. That is, it will
    ;   return immediately after the speak request is queued.

SVSFPurgeBeforeSpeak :=0x2
    ;-- Purges all pending speak requests prior to this speak call.

SVSFIsFilename :=0x4
    ;-- The string passed to the Speak method is a file name rather than text.
    ;   As a result, the string itself is not spoken but rather the file the
    ;   path that points to is spoken.

SVSFIsXML :=0x8
    ;-- The input text will be parsed for XML markup.

SVSFIsNotXML :=0x10  ;-- (16)
    ;-- The input text will not be parsed for XML markup.

SVSFPersistXML :=0x20  ;-- (32)
    ;-- Global state changes in the XML markup will persist across speak calls.

SVSFNLPSpeakPunc :=0x40  ;-- (64)
    ;-- Punctuation characters should be expanded into words (e.g. "This is it."
    ;   would become "This is it period").

;[=======================]
;[  Status.RunningState  ]
;[=======================]
SRSEWaitingToSpeak :=0x0
    ;-- Active but not speaking.  This status can occur under the following
    ;   conditions:
    ;
    ;     - Before the voice has begun speaking
    ;     - The voice has been paused
    ;     - The voice has been interrupted by an Alert voice
    ;
    ;   Note: There is no documented constant name for this status

SRSEDone :=0x1
    ;-- The voice has finished rendering all queued phrases.

SRSEIsSpeaking :=0x2
    ;-- The SpVoice currently claims the audio queue.

SRSETBD2 :=0x3
    ;-- Undocumented.  Haven't figured out what this value represents


;********************
;*                  *
;*    Initialize    *
;*                  *
;********************
;-- Init COM
COM_Init()

;-- Global variables.  Inital values
SplitPath A_ScriptName,,,,$ScriptName
$ConfigFile   :=A_ScriptDir . "\" . $ScriptName . ".ini"
$IconsDir     :=A_ScriptDir . "\Icons"
$SoundsDir    :=A_ScriptDir . "\Sounds"

$BR_Edit:=0
$Reload :=False

$TotalNumberOfAlarms :=20
    ;-- Note:  This value (currently set at 20) can be reduced without any
    ;   harm but cannot be increased without 1) making changes to the following
    ;   static variables, 2) increasing the number of labels in several sections
    ;   of the script to account for the additional alarms, and 3) recalculating
    ;   the X and Y positions of the alarm windows.

;;-- AlarmGUIx -  x=1 to %$TotalNumberOfAlarms%
$RLGUI     :=21  ;-- Reminder list
$BRGUI     :=22  ;-- Build Reminder GUI.  Used to Add and Edit reminders.
$OptionsGUI:=23
$CheckReminderInterval:=1000  ;-- 1000=Once per second
$RLGUIRefreshInterval :=4250  ;-- 1000=Once per second
    ;-- Note: This variable only reflects the interval that the Reminder List
    ;   window is updated without any other actions.  The window is
    ;   automatically updated (without delay) on all significant events.

$DefaultNoteList=
   (ltrim join%$GUIDelimiter%
    User-defined Note 01
    User-defined Note 02
    User-defined Note 03
    The following are example notes...
    Mow the lawn!
    Take out the trash!
    Check the JW423 server (San Francisco)
    Today is {$Date$LongDate}.  The time is {$Time$}
    The time is {$Time$}.
    The current month is {$Date$MMMM}.
    It is the {$Date$d}th day of the month.
    The year is {$Date$yyyy}.
   )

$DefaultSnoozeDDL=
   (ltrim join%$GUIDelimiter%
     1 min
     2 min
     3 min
     4 min
     5 min
    10 min
    15 min
    20 min
    30 min
    45 min
     1 hour
     2 hours
     3 hours
     4 hours
     5 hours
     6 hours
     7 hours
     8 hours
     1 day
     1 week
   )

;-- Build Sound File DDL
$SoundFileDDL:=""
Loop %$SoundsDir%\*.*
    {
    if $SoundFileDDL is Space
        $SoundFileDDL:=A_LoopFileName
     else
        $SoundFileDDL.=$GUIDelimiter . A_LoopFileName
    }

;[==================]
;[  System metrics  ]
;[==================]
SysGet SM_CXVSCROLL,2
    ;-- Width of a vertical scroll bar, in pixels.

;[======================]
;[  Read configuration  ]
;[======================]
gosub ReadConfiguration

;********************
;*                  *
;*    RLGUI menu    *
;*                  *
;********************
;-- File
Menu RLGUI_FileMenu
    ,Add
    ,&Refresh`tF5
    ,RLGUI_Refresh

Menu RLGUI_FileMenu
    ,Add

Menu RLGUI_FileMenu
    ,Add
    ,&Close`tAlt+F4
    ,RLGUI_Close

;-- Edit
Menu RLGUI_EditMenu
    ,Add
    ,&Add`tA
    ,RLGUI_Add

Menu RLGUI_EditMenu
    ,Add
    ,&Delete`tDel
    ,RLGUI_Delete

Menu RLGUI_EditMenu
    ,Add
    ,&Edit`tE
    ,RLGUI_Edit

Menu RLGUI_EditMenu
    ,Default
    ,&Edit`tE

Menu RLGUI_EditMenu
    ,Add
    ,&Hold`tH
    ,RLGUI_Hold

Menu RLGUI_EditMenu
    ,Add
    ,&Start`tS
    ,RLGUI_Start

Menu RLGUI_EditMenu
    ,Add

Menu RLGUI_EditMenu
    ,Add
    ,Select &All`tCtrl+A
    ,RLGUI_SelectAll

;-- Menu bar
Menu RLGUI_MenuBar
    ,Add
    ,&File
    ,:RLGUI_FileMenu

Menu RLGUI_MenuBar
    ,Add
    ,&Add
    ,RLGUI_Add

Menu RLGUI_MenuBar
    ,Add
    ,&Edit
    ,:RLGUI_EditMenu


;*******************
;*                 *
;*    Tray menu    *
;*                 *
;*******************
if A_IsCompiled
    Menu Tray,NoStandard
 else
    Menu Tray,Add

Menu Tray
    ,Add
    ,&Delete All Reminders
    ,DeleteAllReminders

Menu Tray
    ,Add

Menu Tray
    ,Add
    ,&Add Reminder
    ,BRGUI

if $BR_DefaultTray
    Menu Tray
        ,Default
        ,&Add Reminder

Menu Tray
    ,Add
    ,&View Reminder List
    ,RLGUI

if $RL_DefaultTray
    Menu Tray
        ,Default
        ,&View Reminder List



Menu Tray,Add

Menu Tray
    ,Add
    ,&Options
    ,OptionsGUI

Menu Tray
    ,Add
    ,About...
    ,About

Menu Tray
    ,Add

Menu Tray
    ,Add
    ,Disable
    ,EnableDisable

Menu Tray
    ,Add
    ,E&xit
    ,Exit

;-- Tray tooltip
gosub UpdateTrayTooltip

;-- Assign custom icon?
if not A_IsCompiled
    IfExist %$IconsDir%\%$ScriptName%.ico
        Menu Tray,Icon,%$IconsDir%\%$ScriptName%.ico

;-- Show it
Menu Tray,Icon


;********************
;*                  *
;*    Build GUIs    *
;*                  *
;********************
;[=================]
;[  Reminder List  ]
;[     (RLGUI)     ]
;[=================]
gui %$RLGUI%:Default
gui Margin,0,0
gui Menu,RLGUI_MenuBar
gui +Resize -MinimizeBox -MaximizeBox +LabelRLGUI_
gui Add
   ,ListView
   ,xs y+0 w630 r10          ; r%$TotalNumberOfAlarms%
        || Section
        || +AltSubmit
        || +NoSortHdr
        || Count50              ;-- Very small list.  Increase if necessary
        || +LV0x8000            ;-- LVS_EX_BORDERSELECT
        || +BackgroundE8E8FF
        || hWnd$RLGUI_ListView_hWnd
        || v$RLGUI_ListView
        || gRLGUI_ListViewAction
   ,#|Note|Status

;-- Initialize ListView
Loop %$TotalNumberOfAlarms%
    LV_Add("",A_Index)

;-- Adjust columns
LV_ModifyCol(1,"AutoHdr Integer")
LV_ModifyCol(2,250)
LV_ModifyCol(3,320)

;-- Attach
Attach($RLGUI_ListView_hWnd,"w h")

;-- Get hWnd
gui +LastFound
WinGet $RLGUI_hWnd,ID
GroupAdd $RLGUI_Group,ahk_id %$RLGUI_hWnd%

SetTimer RLGUI_Update,%$RLGUIRefreshInterval%
gosub RLGUI_Update

;-- Render but don't show
gui Show,AutoSize Hide,%$ScriptName% - Reminder List

;[=====================]
;[  Add/Edit Reminder  ]
;[       (BRGUI)       ]
;[=====================]
gui %$BRGUI%:Default
gui +Owner        ;-- No taskbar icon
gui Margin,6,6
gui +AlwaysOnTop  ;-- Must-have option
    || +Delimiter%$GUIDelimiter%
    || +LabelBRGUI_
    || -MinimizeBox

gui Add
   ,GroupBox
   ,w10 h10
        || v$BRGUI_RemindersGB

gui Add
   ,Text
   ,xp+10 yp+20 w90
        || Section
   ,Note:

gui Add
   ,Edit
   ,x+0 w280 h60
        || v$BRGUI_Note

gui Font,s13,Webdings
gui Add
   ,Button
   ,x+0 w20 h30
        || hwnd$BRGUI_SelectNote_hWnd
        || v$BRGUI_SelectNote
        || gBRGUI_SelectNote
   ,ù

AddTooltip($BRGUI_SelectNote_hWnd,"Select from a list of notes (F2)")
gui Font

gui Font,s10,Webdings
gui Add
   ,Button
   ,y+0 wp hp
        || hwnd$BRGUI_TTSButton_hWnd
        || v$BRGUI_TTSButton
        || gBRGUI_TTS
   ,4

AddTooltip($BRGUI_TTSButton_hWnd,"Speak note text")
gui Font

gui Add
   ,Text
   ,xs+90 w48
        || Right
   ,Hours

gui Add
   ,Text
   ,x+0 w60
        || Right
   ,Min

gui Add
   ,Text
   ,x+0 wp
        || Right
   ,Sec


gui Add
   ,Text
   ,xs y+0 w90
   ,Countdown:

gui Add
   ,Edit
   ,x+0 w60
        || Right
        || v$BRGUI_Hours
        || gBRGUI_DateTimeAction

gui Add
   ,UpDown
   ,Range0-999

gui Add
   ,Edit
   ,x+0 wp
        || Right
        || v$BRGUI_Minutes
        || gBRGUI_DateTimeAction

gui Add
   ,UpDown
   ,Range0-999

gui Add
   ,Edit
   ,x+0 wp
        || Right
        || v$BRGUI_Seconds
        || gBRGUI_DateTimeAction

gui Add
   ,UpDown
   ,Range0-999
   ,60


gui Add
   ,Button
   ,x+5 hp
        || gBRGUI_ResetDateTime
   ,Reset

gui Add
   ,Text
   ,xs w90
   ,Date/Time:

gui Add
   ,DateTime
   ,x+0 w170
        || v$BRGUI_Date
        || gBRGUI_DateTimeAction
   ,MMMM d, yyyy

gui Add
   ,DateTime
   ,x+0 w120
        || Choose%t_Now%
        || v$BRGUI_Time
        || gBRGUI_DateTimeAction
   ,Time

gui Add
   ,Text
   ,xs w90
   ,Sound file:

gui Add
   ,DropDownList
   ,x+0 w280 r9
        || v$BRGUI_SoundFile
        || gBRGUI_SoundFileDropDown
   ,%$SoundFileDDL%

GUIControl ChooseString,$BRGUI_SoundFile,Alarm.wav
    ;-- Note: this default may be set customizable in the future.


gui Font,s10,Webdings
gui Add
   ,Button
   ,x+0 w20 hp
        || hwnd$BRGUI_SoundFileButton_hWnd
        || v$BRGUI_SoundFileButton
        || gBRGUI_SoundFileButton
   ,4

AddTooltip($BRGUI_SoundFileButton_hWnd,"Play sound file")
gui Font

;-- Resize the group box
GUIControlGet $Group1Pos,Pos,$BRGUI_RemindersGB
GUIControlGet $Group2Pos,Pos,$BRGUI_SoundFileButton
GUIControl
    ,Move
    ,$BRGUI_RemindersGB
    ,% " w" . ($Group2PosX-$Group1PosX)+$Group2PosW+10 . " h" . ($Group2PosY-$Group1PosY)+$Group2PosH+10

;-- Buttons
gui Add
   ,Button
   ,xm+265 y+20 w70
        || Default
        || v$BRGUI_StartReminderButton
        || gBRGUI_StartReminder
   ,&Start

gui Add
   ,Button
   ,x+5 wp hp
        || v$BRGUI_HoldReminderButton
        || gBRGUI_HoldReminder
   ,&Hold

;-- Render but don't show
gui Show,AutoSize Hide,%A_Space%
    ;-- No title here.  Title is determined on use.

;-- Get hWnd
gui +LastFound
WinGet $BRGUI_hWnd,ID
GroupAdd $BRGUI_Group,ahk_id %$BRGUI_hWnd%

;[==============]
;[  Alarm GUIs  ]
;[==============]
Loop %$TotalNumberOfAlarms%
    {
    gui %A_Index%:Default
    gui Margin,6,6
    gui +AlwaysOnTop
        || +Delimiter%$GUIDelimiter%
        || +LabelAlarmGUI%A_Index%_
        || -MinimizeBox

    gui Add
       ,Text
       ,v$AlarmGUI%A_Index%_AlarmTime
       ,Wednesday, September 25, 2888  88:88:88 PM

    gui Add
       ,Edit
       ,w350 r9
            || v$AlarmGUI%A_Index%_Note

    gui Add
       ,ComboBox
       ,xm y+5 w90 r9
            || v$AlarmGUI%A_Index%_Snooze
       ,%$SnoozeDDL%

    gui Add
       ,Button
       ,x+5 w70 hp
            || Default
            || v$AlarmGUI%A_Index%_SnoozeButton
            || gAlarmGUI%A_Index%_SnoozeButton
       ,&Snooze

    gui Font,s10,Webdings
    gui Add
       ,Button
       ,x+5 w25 hp
            || hwnd$AlarmGUI%A_Index%_TTSButton_hWnd
            || v$AlarmGUI%A_Index%_TTSButton
            || gAlarmGUI%A_Index%_TTS
       ,4

    AddTooltip($AlarmGUI%A_Index%_TTSButton_hWnd,"Speak note text")
    gui Font

    gui Add
       ,Button
       ,x+5 w70 hp
            || gAlarmGUI%A_Index%_Edit
       ,&Edit

    gui Add
       ,Button
       ,x+10 w70 hp
            || gAlarmGUI%A_Index%_Close
       ,&Close

    ;-- Set initial focus
    GUIControl Focus,$AlarmGUI%A_Index%_Snooze

    ;-- Get hWnd
    gui +LastFound
    WinGet $AlarmGUI%A_Index%_hWnd,ID
    GroupAdd $AlarmGUI_Group,% "ahk_id " . $AlarmGUI%A_Index%_hWnd

    if A_Index<11
        {
        XPos:=A_Index*25
        YPos:=A_Index*25
        }
     else
        {
        XPos:=((A_Index-10)*25)+250
        YPos:=(A_Index-10)*25
        }

    ;-- Render but don't show
    gui Show
        ,Hide x%XPos% y%YPos%
       ,%$ScriptName% Alarm %A_Index%
    }

;[==================]
;[  Global Hotkeys  ]
;[==================]
if $BR_EnableHotKey and $BR_HotKey
    {
    Hotkey %$BR_HotKey%,BRGUI,UseErrorLevel
    if ErrorLevel
        MsgBox
            ,16  ;-- 16=0 (OK button) + 16 (Stop/Error icon)
            ,%$ScriptName% - Create Hotkey Error
            ,Unable to create a global hotkey for the Add Reminder window.
    }

if $RL_EnableHotKey and $RL_HotKey
    {
    Hotkey %$RL_HotKey%,RLGUI,UseErrorLevel
    if ErrorLevel
        MsgBox
            ,16  ;-- 16=0 (OK button) + 16 (Stop/Error icon)
            ,%$ScriptName% - Create Hotkey Error
            ,Unable to create a global hotkey for the Reminder List window.
    }

;[=============================]
;[  Start CheckReminder timer  ]
;[=============================]
SetTimer CheckReminder,%$CheckReminderInterval%
SoundPlay %$SoundsDir%\StartUp.wav,Wait
return
;--------------------------------------------------- End of Auto-Execute section



;*******************************************
;*                                         *
;*                                         *
;*                                         *
;*                                         *
;*                Functions                *
;*                                         *
;*                                         *
;*                                         *
;*                                         *
;*******************************************
#include _Functions\AddTooltip.ahk
#include _Functions\Attach.ahk
#include _Functions\COM.ahk
#include _Functions\DisableCloseButton.ahk  ;-- Used by ListManagerGUI
#include _Functions\HotkeyGUI.ahk
#include _Functions\HtmDlg.ahk
#include _Functions\InfoGUI.ahk
#include _Functions\ListManagerGUI.ahk
#include _Functions\PopupXY.ahk             ;-- Used by ListManagerGUI


;*********************
;*                   *
;*    CleanupList    *
;*                   *
;*********************
;
;
;   Description
;   ===========
;   This function performs the following tasks:
;
;    1) Removes leading and trailing spaces from each item.
;
;    2) Removes all blank (null) items.
;
;    3) Removes duplicate items.
;
;
;
;   Parameters
;   ==========
;
;       Name            Description
;       ----            -----------
;       p_List          The list.  [Required]  List items are delimited by the
;                       newline ("`n") character.
;
;
;   Return Codes
;   ============
;   The updated list is returned.
;
;-------------------------------------------------------------------------------
CleanupList(p_List)
    {
    ;-- AutoTrim
    p_List=%p_List%

    ;-- Remove leading spaces from each item
    Loop
        {
        StringReplace p_List,p_List,%A_Space%`n,`n,UseErrorLevel
        if ErrorLevel=0
            Break
        }

    ;-- Remove trailing spaces from each item
    Loop
        {
        StringReplace p_List,p_List,`n%A_Space%,`n,UseErrorLevel
        if ErrorLevel=0
            Break
        }

    ;-- Remove extraneous blank lines
    Loop
        {
        StringReplace p_List,p_List,`n`n,`n,UseErrorLevel
        if ErrorLevel=0
            Break
        }

    ;-- Remove leading and trailing blank lines (if they exist)
    if SubStr(p_List,1,1)="`n"
        StringTrimLeft p_List,p_List,1

    if SubStr(p_List,0)="`n"
        StringTrimRight p_List,p_List,1

    ;-- Remove duplicates
    l_List:=""
    l_UniqueItems:="`n"
    Loop Parse,p_List,`n
        {
        ;-- Dup?
        if InStr(l_UniqueItems,"`n" . A_LoopField . "`n")
            Continue

        ;-- Add to the unique list
        l_UniqueItems.=A_LoopField . "`n"

        ;-- Add to the list
        if l_List is Space
            l_List:=A_LoopField
         else
            l_List.="`n" . A_LoopField
        }

    ;-- Return updated list
    Return l_List
    }


;****************************
;*                          *
;*    Hotkey description    *
;*                          *
;****************************
HotkeyDescription(p_Hotkey)
    {
    if p_Hotkey is Space
        l_Description=None
     else
        {
        l_Description:=p_Hotkey
        StringReplace l_Description,l_Description,~,
        StringReplace l_Description,l_Description,*,
        StringReplace l_Description,l_Description,<,
        StringReplace l_Description,l_Description,>,
        StringReplace l_Description,l_Description,+,Shift +%A_Space%   ;-- This modifier must be done 1st
        StringReplace l_Description,l_Description,^,Ctrl +%A_Space%
        StringReplace l_Description,l_Description,#,Win +%A_Space%
        StringReplace l_Description,l_Description,!,Alt +%A_Space%
        }

    return l_Description
    }


;**************************
;*                        *
;*    FormattedTimeout    *
;*                        *
;**************************
FormattedTimeout(p_Timeout,p_MaxUnits=4)
    {
    ;----------------------
    ;-- Convert timeout to
    ;--    # of seconds
    ;----------------------
    EnvSub p_Timeout,A_Now,Seconds
    if p_Timeout<1
        Return "Expired"

    ;-------------------
    ;-- Convert timeout
    ;--  to time units
    ;-------------------
    ;-- Days
    l_Days :=Floor(p_Timeout/86400)
    l_DaysR:=Round(p_Timeout/86400,1)
    if l_Days
        p_Timeout:=p_Timeout-(l_Days*86400)

    ;-- Hours
    l_Hours :=Floor(p_Timeout/3600)
    l_HoursR:=Round(p_Timeout/3600,1)
    if l_Hours
        p_Timeout:=p_Timeout-(l_Hours*3600)

    ;-- Minutes
    l_Minutes :=Floor(p_Timeout/60)
    l_MinutesR:=Round(p_Timeout/60,1)
    if l_Minutes
        p_Timeout:=p_Timeout-(l_Minutes*60)

    ;-- Seconds
    l_Seconds:=p_Timeout

    ;---------------------
    ;-- Formatted timeout
    ;---------------------
    l_Return   :=""
    l_UnitCount:=0

    ;-- Days
    if l_Days
        {
        l_UnitCount++
        if (l_UnitCount=p_MaxUnits)
            {
            l_Days:=l_DaysR
            if (l_Days=Round(l_Days))  ;-- ends with ".0"
                l_Days:=Round(l_Days)
            }

        l_Return:=l_Return . l_Days . " day"
        if l_Days<>1
            l_Return:=l_Return . "s"

        if (p_MaxUnits>l_UnitCount and (l_Hours or l_Minutes or l_Seconds))
            l_Return:=l_Return . ", "
        }

    ;-- Hours
     if (l_Hours
     or (l_Days and (l_Minutes or l_Seconds)))
    and (p_MaxUnits>l_UnitCount)
        {
        l_UnitCount++
        if (l_UnitCount=p_MaxUnits)
            {
            l_Hours:=l_HoursR
            if (l_Hours=Round(l_Hours))  ;-- ends with ".0"
                l_Hours:=Round(l_Hours)
            }


        l_Return:=l_Return . l_Hours . " hour"
        if l_Hours<>1
            l_Return:=l_Return . "s"

        if (p_MaxUnits>l_UnitCount and (l_Minutes or l_Seconds))
            l_Return:=l_Return . ", "
        }

    ;-- Minutes
     if  (l_Minutes
     or ((l_Days or l_Hours) and l_Seconds))
    and (p_MaxUnits>l_UnitCount)
        {
        l_UnitCount++
        if (l_UnitCount=p_MaxUnits)
            {
            l_Minutes:=l_MinutesR
            if (l_Minutes=Round(l_Minutes))  ;-- ends with ".0"
                l_Minutes:=Round(l_Minutes)
            }


        l_Return:=l_Return . l_Minutes . " minute"
        if l_Minutes<>1
            l_Return:=l_Return . "s"

        if (p_MaxUnits>l_UnitCount) and l_Seconds
            l_Return.=", "
        }

    ;-- Seconds
    if l_Seconds and (p_MaxUnits>l_UnitCount)
        {
        l_Return.=l_Seconds . " second"
        if l_Seconds<>1
            l_Return.="s"
        }

    Return l_Return
    }


;**************************
;*                        *
;*    Convert metadata    *
;*                        *
;**************************
ConvertMD(p_String,p_Time="")
    {
    ;[==============]
    ;[  Initialize  ]
    ;[==============]
    l_CurrentStringCaseSense:=A_StringCaseSense
    StringCaseSense On

    ;-- AutoTrim
    p_String=%p_String%

    ;-- If necessary, trim "TTS:" prefix
    if SubStr(p_String,1,4)="TTS:"
        StringTrimLeft p_String,p_String,4

    ;-- Replace time only format, i.e. {$Time$}, to time in current user's locale
    StringReplace p_String,p_String,{$Time$},{$Time$Time},All

    ;[=============]
    ;[  Date/Time  ]
    ;[=============]
    Loop
        {
        ;-- Search for metadata
        Loop Parse,p_String,{,
            {
            l_Replace:=""
            if SubStr(A_LoopField,1,6)="$Date$"
            or SubStr(A_LoopField,1,6)="$Time$"
                if InStr(A_LoopField,"}")
                    {
                    Loop Parse,A_LoopField,}
                        {
                        l_Replace={%A_LoopField%}
                        Break
                        }
                    }

            ;-- Stop parsing when one is found
            if StrLen(l_Replace)
                Break
            }

        ;-- Convert metadata to requested date/time format
        if StrLen(l_Replace)
            {
            l_TimeFormat:=l_Replace
            StringTrimLeft  l_TimeFormat,l_TimeFormat,7  ;-- Identifier
            StringTrimRight l_TimeFormat,l_TimeFormat,1  ;-- Trailing "}"

            ;-- Convert to requested format
            FormatTime l_FTResults,%p_Time%,%l_TimeFormat%

            ;-- Replace metadata with requested information
            StringReplace p_String,p_String,%l_Replace%,%l_FTResults%,All

            ;-- Keep looking
            Continue
            }

        ;-- Stop looking
        Break
        }

    ;-- Housekeeping
    StringCaseSense %l_CurrentStringCaseSense%

    ;-- Return to sender
    Return p_String
    }


;***************************
;*                         *
;*    Swap ListView row    *
;*                         *
;***************************
SwapLVRow(p_SourceRow,p_TargetRow,p_Focus=True)
    {
    ;-- Note: Set p_Focus to FALSE if focus is automatically moved by a hotkey
    ;   or other method.

    ;-- Get Select
    if LV_GetNext(p_SourceRow-1)=p_SourceRow
        l_SourceOptions:="+Select"
     else
        l_SourceOptions:="-Select"

    if LV_GetNext(p_TargetRow-1)=p_TargetRow
        l_TargetOptions:="+Select"
     else
        l_TargetOptions:="-Select"

    ;-- Get Focus
    if p_Focus
	    {
	    if LV_GetNext(p_SourceRow-1,"Focused")=p_SourceRow
	        l_SourceOptions.=" +Focus"
	     else
	        l_SourceOptions.=" -Focus"

	    if LV_GetNext(p_TargetRow-1,"Focused")=p_TargetRow
	        l_TargetOptions.=" +Focus"
	     else
	        l_TargetOptions.=" -Focus"
	    }

    ;-- Get Check
    if LV_GetNext(p_SourceRow-1,"Checked")=p_SourceRow
        l_SourceOptions.=" +Check"
     else
        l_SourceOptions.=" -Check"

    if LV_GetNext(p_TargetRow-1,"Checked")=p_TargetRow
        l_TargetOptions.=" +Check"
     else
        l_TargetOptions.=" -Check"

    ;-- Get Text
    LV_GetText(l_SourceText,p_SourceRow,1)
    LV_GetText(l_TargetText,p_TargetRow,1)

    ;-- Swap attributes and text
    LV_Modify(p_SourceRow,l_TargetOptions,l_TargetText)
    LV_Modify(p_TargetRow,l_SourceOptions,l_SourceText)
    }



;*********************************************
;*                                           *
;*                                           *
;*                                           *
;*                                           *
;*                Subroutines                *
;*                                           *
;*                                           *
;*                                           *
;*                                           *
;*********************************************
;****************************
;*                          *
;*    Read configuration    *
;*                          *
;****************************
ReadConfiguration:

;[====================]
;[  Section: General  ]
;[====================]
iniRead
    ,$PlayAlarmSound
    ,%$ConfigFile%
    ,General
    ,PlayAlarmSOund
    ,%True%

iniRead
    ,$PlayAlarmNagSound
    ,%$ConfigFile%
    ,General
    ,PlayAlarmNagSound
    ,%True%

iniRead
    ,$NagInterval
    ,%$ConfigFile%
    ,General
    ,NagInterval
    ,40

;-------------
;-- Note List
;-------------
iniRead
    ,$NoteList
    ,%$ConfigFile%
    ,General
    ,NoteList
    ,%A_Space%

;-- Restore Note List
if StrLen($NoteList)=0
    $NoteList:=$DefaultNoteList
 else
    {
    ;-- Remove border
    $NoteList:=SubStr($NoteList,2,-1)

    ;-- Restore line feed characters
    StringReplace $NoteList,$NoteList,%$FieldDelimiter%,`n,All
    }

;--------------
;-- Snooze DDL
;--------------
iniRead
    ,$SnoozeDDL
    ,%$ConfigFile%
    ,General
    ,SnoozeDDL
    ,%A_Space%

if StrLen($SnoozeDDL)=0
    $SnoozeDDL:=$DefaultSnoozeDDL

;[==================]
;[  Section: BRGUI  ]
;[==================]
iniRead
    ,$BR_DefaultTray
    ,%$ConfigFile%
    ,BRGUI
    ,DefaultTray
    ,%True%

iniRead
    ,$BR_EnableHotkey
    ,%$ConfigFile%
    ,BRGUI
    ,EnableHotkey
    ,%True%

iniRead
    ,$BR_Hotkey
    ,%$ConfigFile%
    ,BRGUI
    ,Hotkey
    ,^!R

;[==================]
;[  Section: RLGUI  ]
;[==================]
iniRead
    ,$RL_DefaultTray
    ,%$ConfigFile%
    ,RLGUI
    ,DefaultTray
    ,%False%

iniRead
    ,$RL_EnableHotkey
    ,%$ConfigFile%
    ,RLGUI
    ,EnableHotkey
    ,%True%

iniRead
    ,$RL_Hotkey
    ,%$ConfigFile%
    ,RLGUI
    ,Hotkey
    ,^#!R

;[=========================]
;[  Section: TextToSpeech  ]
;[=========================]
iniRead
    ,$SpeakOnAlarm
    ,%$ConfigFile%
    ,TextToSpeech
    ,SpeakOnAlarm
    ,%False%

iniRead
    ,$TTSVoice
    ,%$ConfigFile%
    ,TextToSpeech
    ,Voice
    ,%A_Space%

iniRead
    ,$TTSPriority
    ,%$ConfigFile%
    ,TextToSpeech
    ,Priority
    ,1          ;-- 1=Alert

;[======================]
;[  Section: Reminders  ]
;[======================]
Loop %$TotalNumberOfAlarms%
    {
    ;-- Timestamp
    iniRead
        ,ReminderTS%A_Index%
        ,%$ConfigFile%
        ,Reminders
        ,TimeStamp%A_Index%
        ,0

    ;-- Countdown
    iniRead
        ,ReminderCD%A_Index%
        ,%$ConfigFile%
        ,Reminders
        ,Countdown%A_Index%
        ,%A_Space%

    ;-- Note
    iniRead
        ,ReminderNote%A_Index%
        ,%$ConfigFile%
        ,Reminders
        ,Note%A_Index%
        ,%A_Space%

    ;-- Restore note
    if StrLen(ReminderNote%A_Index%)
        {
        ;-- Remove border
        ReminderNote%A_Index%:=SubStr(ReminderNote%A_Index%,2,-1)

        ;-- Restore line feed characters
        StringReplace
            ,ReminderNote%A_Index%
            ,ReminderNote%A_Index%
            ,%$RecordDelimiter%
            ,`n
            ,All
        }

    ;-- Sound file
    iniRead
        ,ReminderSound%A_Index%
        ,%$ConfigFile%
        ,Reminders
        ,Sound%A_Index%
        ,%A_Space%


    ;-- Mode
    iniRead
        ,ReminderMode%A_Index%
        ,%$ConfigFile%
        ,Reminders
        ,Mode%A_Index%
        ,%A_Space%
    }

;[=======================]
;[  Section: OptionsGUI  ]
;[=======================]
iniRead
    ,$OptionsGUI_Tab
    ,%$ConfigFile%
    ,OptionsGUI
    ,Tab
    ,%A_Space%

return


;****************************
;*                          *
;*    Save configuration    *
;*                          *
;****************************
SaveConfiguration:

;[====================]
;[  Section: General  ]
;[====================]
iniWrite
    ,%$PlayAlarmSound%
    ,%$ConfigFile%
    ,General
    ,PlayAlarmSOund

iniWrite
    ,%$PlayAlarmNagSound%
    ,%$ConfigFile%
    ,General
    ,PlayAlarmNagSound

iniWrite
    ,%$NagInterval%
    ,%$ConfigFile%
    ,General
    ,NagInterval

;-------------
;-- Note List
;-------------
;-- Assign to temp
t_NoteList :=$NoteList

;-- Anything to save?
if StrLen(t_NoteList)
    {
    ;-- Convert line feed characters to $FieldDelimiter characters
    StringReplace t_NoteList,t_NoteList,`n,%$FieldDelimiter%,All

    ;-- Add $iniBorder characters to preserve leading and trailing spaces
    t_NoteList:=$iniBorder . t_NoteList . $iniBorder
    }

;-- Save it!
iniWrite
    ,%t_NoteList%
    ,%$ConfigFile%
    ,General
    ,NoteList

;--------------
;-- Snooze DDL
;--------------
iniWrite
    ,%$SnoozeDDL%
    ,%$ConfigFile%
    ,General
    ,SnoozeDDL

;[==================]
;[  Section: BRGUI  ]
;[==================]
iniWrite
    ,%$BR_DefaultTray%
    ,%$ConfigFile%
    ,BRGUI
    ,DefaultTray

iniWrite
    ,%$BR_EnableHotkey%
    ,%$ConfigFile%
    ,BRGUI
    ,EnableHotkey

iniWrite
    ,%$BR_Hotkey%
    ,%$ConfigFile%
    ,BRGUI
    ,Hotkey

;[==================]
;[  Section: RLGUI  ]
;[==================]
iniWrite
    ,%$RL_DefaultTray%
    ,%$ConfigFile%
    ,RLGUI
    ,DefaultTray

iniWrite
    ,%$RL_EnableHotkey%
    ,%$ConfigFile%
    ,RLGUI
    ,EnableHotkey

iniWrite
    ,%$RL_Hotkey%
    ,%$ConfigFile%
    ,RLGUI
    ,Hotkey

;[=========================]
;[  Section: TextToSpeech  ]
;[=========================]
iniWrite
    ,%$SpeakOnAlarm%
    ,%$ConfigFile%
    ,TextToSpeech
    ,SpeakOnAlarm

iniWrite
    ,%$TTSVoice%
    ,%$ConfigFile%
    ,TextToSpeech
    ,Voice

iniWrite
    ,%$TTSPriority%
    ,%$ConfigFile%
    ,TextToSpeech
    ,Priority

;[======================]
;[  Section: Reminders  ]
;[======================]
Loop %$TotalNumberOfAlarms%
    {
    ;-- Timestamp
    iniWrite
        ,% ReminderTS%A_Index%
        ,%$ConfigFile%
        ,Reminders
        ,TimeStamp%A_Index%


    ;-- Countdown
    iniWrite
        ,% ReminderCD%A_Index%
        ,%$ConfigFile%
        ,Reminders
        ,Countdown%A_Index%

    ;--------
    ;-- Note
    ;--------
    ;-- Assign to temp
    t_Note:=ReminderNote%A_Index%

    ;-- Anything to save?
    if StrLen(t_Note)
        {
        ;-- Convert line feed characters to $RecordDelimiter characters
        StringReplace t_Note,t_Note,`n,%$RecordDelimiter%,All

        ;-- Add $iniBorder characters to preserve leading and trailing spaces
        t_Note:=$iniBorder . t_Note . $iniBorder
        }

    ;-- Save it!
    iniWrite
        ,%t_Note%
        ,%$ConfigFile%
        ,Reminders
        ,Note%A_Index%


    ;-- Sound file
    iniWrite
        ,% ReminderSound%A_Index%
        ,%$ConfigFile%
        ,Reminders
        ,Sound%A_Index%


    ;-- Mode
    iniWrite
        ,% ReminderMode%A_Index%
        ,%$ConfigFile%
        ,Reminders
        ,Mode%A_Index%
    }

;[=======================]
;[  Section: OptionsGUI  ]
;[=======================]
iniWrite
    ,%$OptionsGUI_Tab%
    ,%$ConfigFile%
    ,OptionsGUI
    ,Tab

return


;*****************************
;*                           *
;*    Update Tray Tooltip    *
;*                           *
;*****************************
UpdateTrayTooltip:

;-- Collect statistics
$ActiveReminders:=0
$OnHoldReminders:=0

Loop %$TotalNumberOfAlarms%
    {
    if ReminderMode%A_Index%=Hold
        {
        $OnHoldReminders++
        Continue
        }

    if ReminderTS%A_Index%
        {
        $ActiveReminders++
        Continue
        }
    }

;-- Build Tooltip
$Tooltip:=$ScriptName
if $ActiveReminders
    {
    $ToolTip.="`n" . $ActiveReminders . " active reminder"
    if $ActiveReminders>1
        $ToolTip.="s"
    }

if $OnHoldReminders
    {
    $ToolTip.="`n" . $OnHoldReminders . " reminder"
    if $OnHoldReminders>1
        $ToolTip.="s"

    $ToolTip.=" on hold"
    }

;-- Update Tray tooltip
Menu Tray
    ,Tip
    ,%$ToolTip%

return



;*****************
;*               *
;*    General    *
;*               *
;*****************
Alarm1:
Alarm2:
Alarm3:
Alarm4:
Alarm5:
Alarm6:
Alarm7:
Alarm8:
Alarm9:
Alarm10:
Alarm11:
Alarm12:
Alarm13:
Alarm14:
Alarm15:
Alarm16:
Alarm17:
Alarm18:
Alarm19:
Alarm20:

;-- Collect reminder number
ThisReminder :=SubStr(A_ThisLabel,-1)
if ThisReminder is not Integer
    StringTrimLeft ThisReminder,ThisReminder,1

;-- Set default GUI
gui %ThisReminder%:Default

;-- Update GUI fields
FormatTime AlarmTime,% ReminderTS%ThisReminder%,dddd, MMMM d, yyyy  hh:mm:ss tt

GUIControl,,$AlarmGUI%ThisReminder%_AlarmTime,%AlarmTime%
GUIControl,,$AlarmGUI%ThisReminder%_Note,% ReminderNote%ThisReminder%
GUIControl,,$AlarmGUI%ThisReminder%_Snooze,%$GUIDelimiter%%$SnoozeDDL%

;-- Show but don't steal focus
gui Show,NA

;-- Update RLGUI
SetTimer RLGUI_QuickUpdate,-1

;-- Set nag
gosub SetAlarmNag

;-- Alarm sound
if $PlayAlarmSound
    {
    ;-- Custom alarm sound
    IfExist % ReminderSound%ThisReminder%
        SoundPlay % ReminderSound%ThisReminder%,Wait
     else
        SoundPlay %$SoundsDir%\Alarm.wav,Wait

        ;-- Note: The "Wait" parameter was added to these SoundPlay commands so
        ;   that multiple alarm sounds will not step on each other.
    }

;-- Recollect reminder number
ThisReminder :=SubStr(A_ThisLabel,-1)
if ThisReminder is not Integer
    StringTrimLeft ThisReminder,ThisReminder,1
    ;-- Note:  These statements are necessary because this routine can be
    ;   interrupted while the alarm sound is played (previous statement).  The
    ;   routine that interrupts this statement can reset the commonly used
    ;   "ThisReminder" global variable.


;-- Bounce if Alarm window is already closed
IfWinNotExist % "ahk_id " . $AlarmGUI%ThisReminder%_hWnd
    return
    ;-- Note: This test was added because it's possible to close the alarm
    ;   window while the alarm sound is playing but before the TTS engine has
    ;   begun to speak.  Without this test, the TTS engine would speak without
    ;   a means of stopping it.

;-- Text to speech?
t_Note :=ReminderNote%ThisReminder%
t_Note=%t_Note%  ;-- AutoTrim
if $SpeakOnAlarm or SubStr(t_Note,1,4)="TTS:"
    gosub AlarmGUI%ThisReminder%_TTS

return


EnableDisable:
if A_ThisMenuItem=Enable
    SetTimer EnableQR,250
 else
    SetTimer DisableQR,250

;-- Note: Timers are used here to allow queued timers (namely CheckReminder) to
;   complete before continuing.

return


EnableQR:
SetTimer EnableQR,Off

Menu Tray,Icon,%$IconsDir%\%$ScriptName%.ico
Menu Tray,Rename,Enable,Disable
SetTimer CheckReminder,%$CheckReminderInterval%
gosub CheckReminder
return


DisableQR:
SetTimer DisableQR,Off
SetTimer CheckReminder,Off

;-- Enable RLGUI (May have been disabled by the BRGUI routine)
gui %$RLGUI%:-Disabled

;-- Hide all windows
IfWinExist ahk_id %$RLGUI_hWnd%
    {
    SetTimer RLGUI_Update,Off
    gui %$RLGUI%:Hide
    }

IfWinExist ahk_id %$BRGUI_hWnd%
    gui %$BRGUI%:Hide

Loop %$TotalNumberOfAlarms%
    IfWinExist % "ahk_id " . $AlarmGUI%A_Index%_hWnd
        gui %A_Index%:Hide

gosub SetAlarmNag
Menu Tray,Icon,%$IconsDir%\%$ScriptName%_Disabled.ico
Menu Tray,Rename,Disable,Enable
return


CheckReminder:
Loop %$TotalNumberOfAlarms%
    {
    if ReminderMode%A_Index%=Hold
        Continue

    if ReminderTS%A_Index%
        if (A_Now>=ReminderTS%A_Index%)
            {
            ;-- Alarm already showing?
            IfWinExist % "ahk_id " . $AlarmGUI%A_Index%_hWnd
                Continue

            gosub Alarm%A_Index%
            }
    }

return


SetAlarmNag:
IfWinExist ahk_group $AlarmGUI_Group
    {
    if $PlayAlarmNagSound
        {
        SetTimer AlarmNag,% $NagInterval*1000
        SetTimer AlarmIcon,1000
        }
    }
 else
    {
    SetTimer AlarmNag,Off
    SetTimer AlarmIcon,Off
    gosub AlarmIcon2
    }


return


AlarmNag:
SoundPlay %$SoundsDir%\AlarmNag.wav,Wait
return


AlarmIcon:
Menu Tray,Icon,%$IconsDir%\%$ScriptName%_Alarm.ico  ;-- Alarm icon
SetTimer AlarmIcon2,500
return


AlarmIcon2:
SetTimer AlarmIcon2,Off
Menu Tray,Icon,%$IconsDir%\%$ScriptName%.ico        ;-- Standard icon
return


DeleteAllReminders:

;-- Get confirmation if there is anything to delete
Loop %$TotalNumberOfAlarms%
    if ReminderTS%A_Index%
        {
        MsgBox
            ,262193
                ;-- 262193=1 (OK/Cancel buttons) + 48 ("!" icon) + 262144 (AOT)
            ,%$ScriptName% - Confirm Delete
            ,All reminders will be deleted.  Press OK to proceed.  %A_Space%

        IfMsgBox Cancel
            return

        ;-- Skip the rest
        Break
        }

;-- Delete 'em
ReminderDeleted:=False
Loop %$TotalNumberOfAlarms%
    {
    ;-- Reminder set?
    if not ReminderTS%A_Index%
        Continue

    ;-- Alarm window showing?
    IfWinExist % "ahk_id " . $AlarmGUI%A_Index%_hWnd
        gui %A_Index%:Hide

    ;-- Reset all Reminder fields
    ReminderDeleted       :=True
    ReminderTS%A_Index%   :=0
    ReminderCD%A_Index%   :=""
    ReminderNote%A_Index% :=""
    ReminderSound%A_Index%:=""
    ReminderMode%A_Index% :=""
    }

;-- Inform and bounce if nothing to delete
if not ReminderDeleted
    {
    MsgBox
        ,262192
            ;-- 262192=0 (OK button) + 48 ("!" icon) + 262144 (AOT)
        ,%$ScriptName%
        ,There are no reminders to delete.  %A_Space%

    return
    }

;-- Update RLGUI
SetTimer RLGUI_QuickUpdate,-1

;-- Housekeeping
gosub SetAlarmNag
gosub UpdateTrayTooltip
gosub SaveConfiguration
SoundPlay %$SoundsDir%\ReminderDelete.wav,Wait
return


;***************
;*             *
;*    About    *
;*             *
;***************
About:
InfoGUI(0                                                   ;-- Owner
    ,"`n" . $ScriptName . "`nv" . $Version                  ;-- Text
    ,"About"                                                ;-- Title
    ,"+AlwaysOnTop"                                         ;-- GUI options
    ,"Text"                                                 ;-- Object type
    ,"r4 w200 Center"                                       ;-- Object options
    ,"Black"                                                ;-- Background color
    ,"Arial"                                                ;-- Font
    ,"cAqua s16 Bold")                                      ;-- Font options

return


;**************
;*            *
;*    Exit    *
;*            *
;**************
Exit:
ExitApp
return


;*****************
;*               *
;*    ExitApp    *
;*               *
;*****************
ExitApp:

;-- Release Alarm SpVoice instances (if any)
Loop %$TotalNumberOfAlarms%
    if pSpVoice%A_Index%
        COM_Release(pSpVoice%A_Index%)

;-- Release SpVoice instance used by BRGUI
if $BRGUI_pSpVoice
    COM_Release($BRGUI_pSpVoice)

;-- Release SpVoice instance used by OptionsGUI
if $OptionsGUI_pSpVoice
    COM_Release($OptionsGUI_pSpVoice)

;-- Terminate COM
COM_Term()

;-- Shut it down
ExitApp
return


;*****************************
;*                           *
;*                           *
;*        Subroutines        *
;*         (AlarmGUI)        *
;*                           *
;*                           *
;*****************************
AlarmGUI1_SnoozeButton:
AlarmGUI2_SnoozeButton:
AlarmGUI3_SnoozeButton:
AlarmGUI4_SnoozeButton:
AlarmGUI5_SnoozeButton:
AlarmGUI6_SnoozeButton:
AlarmGUI7_SnoozeButton:
AlarmGUI8_SnoozeButton:
AlarmGUI9_SnoozeButton:
AlarmGUI10_SnoozeButton:
AlarmGUI11_SnoozeButton:
AlarmGUI12_SnoozeButton:
AlarmGUI13_SnoozeButton:
AlarmGUI14_SnoozeButton:
AlarmGUI15_SnoozeButton:
AlarmGUI16_SnoozeButton:
AlarmGUI17_SnoozeButton:
AlarmGUI18_SnoozeButton:
AlarmGUI19_SnoozeButton:
AlarmGUI20_SnoozeButton:

;-- Collect form values
gui Submit,NoHide

;-- Initialize
SnoozeFactor :=""
SnoozeTime   :=""
SnoozeHour   :=True
SnoozeMinute :=True
SnoozeHH     :=""
SnoozeMM     :=""
SnoozeSS     :=""

;-- Clock time? (contains ":", "a", or "p" but not "da")
 if (InStr($AlarmGUI%A_GUI%_Snooze,":")
 or  InStr($AlarmGUI%A_GUI%_Snooze,"a")
 or  InStr($AlarmGUI%A_GUI%_Snooze,"p"))
and (Instr($AlarmGUI%A_GUI%_Snooze,"da")=0)
    {
    Loop Parse,$AlarmGUI%A_GUI%_Snooze
        {
        if A_LoopField is Space
            Continue

        if (A_LoopField=":")
            {
            SnoozeHour:=False
            Continue
            }

        if (A_LoopField=".")
            {
            SnoozeHour  :=False
            SnoozeMinute:=False
            Continue
            }
            
        if A_LoopField is Integer
            {
            if SnoozeHour
                SnoozeHH.=A_LoopField
             else
                if SnoozeMinute
                    SnoozeMM.=A_LoopField
                 else
                    SnoozeSS.=A_LoopField

            Continue
            }

        if (A_LoopField="p")
            {
            ;-- If necessary, convert HH to 24hour
            if SnoozeHH is Integer
                if SnoozeHH between 01 and 11
                    SnoozeHH+=12
            }
         else 
            {
            if (A_LoopField="a")
                {
                if SnoozeHH=12  ;-- Numeric test
                    SnoozeHH:="00"
                }
            }
                        
        Break  ;-- We're done here
        }

    ;-- If possible, shrink to remove any extraneous leading zeros
    if SnoozeHH is Integer
        SnoozeHH+=0

    if SnoozeMM is Integer
        SnoozeMM+=0

    if SnoozeSS is Integer
        SnoozeSS+=0

    ;-- If necessary, initialize SnoozeXX variables
    if SnoozeHH is Space
        SnoozeHH:="00"
    
    if SnoozeMM is Space
        SnoozeMM:="00"

    if SnoozeSS is space
        SnoozeSS:="00"

    ;-- Zero pad/repad if necessary
    if StrLen(SnoozeHH)=1
        SnoozeHH:="0" . SnoozeHH

    if StrLen(SnoozeMM)=1
        SnoozeMM:="0" . SnoozeMM

    if StrLen(SnoozeSS)=1
        SnoozeSS:="0" . SnoozeSS

    ;-- Bounce if any invalid value found
    ValidSnooze:=False
    if SnoozeHH is Integer
        if SnoozeHH between 00 and 23
            if SnoozeMM is Integer
                if SnoozeMM between 00 and 59
                    if SnoozeSS is Integer
                        if SnoozeSS between 00 and 59
                            ValidSnooze:=True

    if not ValidSnooze
        return

    ;-- Build new time stamp
    ReminderTS%A_GUI%:=SubStr(A_Now,1,8) . SnoozeHH . SnoozeMM . SnoozeSS

    ;-- If the time stamp is earlier than now, add 1 day
    if (ReminderTS%A_GUI%<A_Now)
        EnvAdd ReminderTS%A_GUI%,1,Days        
    }
 else
    {
    ;-- Parse for a snooze time.  This looks for any number followed by any
    ;   letter.  Spaces are ignored.
    ;
    ;   Letter conversion:
    ;
    ;       s=seconds
    ;       m=minutes
    ;       h=hours,
    ;       d=days
    ;       w=weeks
    ;       {none or any other character}=minutes
    ;
    Loop Parse,$AlarmGUI%A_GUI%_Snooze
        {
        if A_LoopField is Space
            Continue
    
        if A_LoopField is Number
            {
            SnoozeTime.=A_LoopField
            Continue
            }
    
        if (A_LoopField=".")
            {
            SnoozeTime.=A_LoopField
            Continue
            }
    
        SnoozeFactor:=A_LoopField
        Break
        }
    
    ;-- Bounce if extracted value is not number
    if SnoozeTime is not Number
        return
    
    ReminderTS%A_GUI%:=A_Now
    if SnoozeFactor=s
        EnvAdd ReminderTS%A_GUI%,SnoozeTime,Seconds
     else
        if SnoozeFactor=h
            EnvAdd ReminderTS%A_GUI%,SnoozeTime,Hours
         else
            if SnoozeFactor=d
                EnvAdd ReminderTS%A_GUI%,SnoozeTime,Days
             else
                if SnoozeFactor=w
                    EnvAdd ReminderTS%A_GUI%,SnoozeTime*7,Days
                 else
                    EnvAdd ReminderTS%A_GUI%,SnoozeTime,Minutes
    }

;-- Update Note
ReminderNote%A_GUI%:=$AlarmGUI%A_GUI%_Note

;-- If necessary, stop TTS playback
gosub AlarmGUI%A_GUI%_TTS_Stop

;-- Build formatted timeout time
$Timeout:=FormattedTimeout(ReminderTS%A_GUI%,2)

;-- Show tooltip?
if Instr($GUIDelimiter . $SnoozeDDL . $GUIDelimiter,$GUIDelimiter . $AlarmGUI%A_GUI%_Snooze . $GUIDelimiter)=0  ;-- Not selected from the snooze DDL
    if $Timeout Contains hour,day  ;-- 1 hour or more
        {
        ;-- Build message
        $Message=`n     Alarm will expire in %$Timeout%     `n

        ;-- Show tootip
        ToolTip %$Message%,0,0,%A_GUI%
        SetTimer AlarmGUI%A_GUI%_ToolTipOff,5500
        }

;-- Hide window
gui Hide

;-- Update RLGUI
SetTimer RLGUI_QuickUpdate,-1

;-- Housekeeping
gosub SetAlarmNag
gosub SaveConfiguration
SoundPlay %$SoundsDir%\ReminderStart.wav,Wait
return


;*********************
;*                   *
;*    ToolTip Off    *
;*     (AlarmGUI)    *
;*                   *
;*********************
AlarmGUI1_ToolTipOff:
AlarmGUI2_ToolTipOff:
AlarmGUI3_ToolTipOff:
AlarmGUI4_ToolTipOff:
AlarmGUI5_ToolTipOff:
AlarmGUI6_ToolTipOff:
AlarmGUI7_ToolTipOff:
AlarmGUI8_ToolTipOff:
AlarmGUI9_ToolTipOff:
AlarmGUI10_ToolTipOff:
AlarmGUI11_ToolTipOff:
AlarmGUI12_ToolTipOff:
AlarmGUI13_ToolTipOff:
AlarmGUI14_ToolTipOff:
AlarmGUI15_ToolTipOff:
AlarmGUI16_ToolTipOff:
AlarmGUI17_ToolTipOff:
AlarmGUI18_ToolTipOff:
AlarmGUI19_ToolTipOff:
AlarmGUI20_ToolTipOff:
SetTimer %A_ThisLabel%,Off

;-- Collect Tooltip number
ThisTooltip :=SubStr(A_ThisLabel,9,2)
if ThisAlarm is not Integer
    StringTrimRight ThisTooltip,ThisTooltip,1

;-- Turn off tooltip
ToolTip,,,,%ThisTooltip%
return


;************************
;*                      *
;*    Text-To-Speech    *
;*      (AlarmGUI)      *
;*                      *
;************************
AlarmGUI1_TTS:
AlarmGUI2_TTS:
AlarmGUI3_TTS:
AlarmGUI4_TTS:
AlarmGUI5_TTS:
AlarmGUI6_TTS:
AlarmGUI7_TTS:
AlarmGUI8_TTS:
AlarmGUI9_TTS:
AlarmGUI10_TTS:
AlarmGUI11_TTS:
AlarmGUI12_TTS:
AlarmGUI13_TTS:
AlarmGUI14_TTS:
AlarmGUI15_TTS:
AlarmGUI16_TTS:
AlarmGUI17_TTS:
AlarmGUI18_TTS:
AlarmGUI19_TTS:
AlarmGUI20_TTS:
Critical
    ;-- Since this routine is used by both a button and as a subroutine call,
    ;   "Critical" is used to keep the routine from stepping on itself.

;-- Collect alarm number
ThisAlarm :=SubStr(A_ThisLabel,9,2)
if ThisAlarm is not Integer
    StringTrimRight ThisAlarm,ThisAlarm,1

;-- If necessary, create SpVoice instance
if not pSpVoice%ThisAlarm%
    {
    pSpVoice%ThisAlarm%:=COM_CreateObject("SAPI.SpVoice")

    ;-- Get default voice?
    if $TTSVoice is Space
        $TTSVoice:=COM_Invoke(pSpVoice%ThisAlarm%,"Voice.GetDescription")

    ;-- Set Voice and priority
    COM_Invoke(pSpVoice%ThisAlarm%,"Voice","+" . COM_Invoke(pSpVoice%ThisAlarm%,"GetVoices(" . """" . "Name=" . $TTSVoice . """" . ").Item(0)"))
    COM_Invoke(pSpVoice%ThisAlarm%,"Priority",$TTSPriority)
    }

;-- Collect Note
GUIControlGet $AlarmGUI%ThisAlarm%_Note,%ThisAlarm%:,$AlarmGUI%ThisAlarm%_Note

;-- Bounce if note is empty
if $AlarmGUI%ThisAlarm%_Note is Space
    return

;-- If playing, stop play
if COM_Invoke(pSpVoice%ThisAlarm%,"Status.RunningState")<>SRSEDone
    {
    gosub AlarmGUI%ThisAlarm%_TTS_Stop
    return
    }

;-- Change button label
GUIControl,%ThisAlarm%:,$AlarmGUI%ThisAlarm%_TTSButton,<

;-- Speak!
COM_Invoke(pSpVoice%ThisAlarm%,"Speak",ConvertMD($AlarmGUI%ThisAlarm%_Note),SVSFlagsAsync|SVSFPurgeBeforeSpeak)
    ;-- Not sure if the SVSFPurgeBeforeSpeak flag provides any value here.

;-- Monitor speech stream
SetTimer AlarmGUI%ThisAlarm%_TTS_Monitor,200
return


AlarmGUI1_TTS_Monitor:
AlarmGUI2_TTS_Monitor:
AlarmGUI3_TTS_Monitor:
AlarmGUI4_TTS_Monitor:
AlarmGUI5_TTS_Monitor:
AlarmGUI6_TTS_Monitor:
AlarmGUI7_TTS_Monitor:
AlarmGUI8_TTS_Monitor:
AlarmGUI9_TTS_Monitor:
AlarmGUI10_TTS_Monitor:
AlarmGUI11_TTS_Monitor:
AlarmGUI12_TTS_Monitor:
AlarmGUI13_TTS_Monitor:
AlarmGUI14_TTS_Monitor:
AlarmGUI15_TTS_Monitor:
AlarmGUI16_TTS_Monitor:
AlarmGUI17_TTS_Monitor:
AlarmGUI18_TTS_Monitor:
AlarmGUI19_TTS_Monitor:
AlarmGUI20_TTS_Monitor:

;-- Collect alarm number
ThisAlarm :=SubStr(A_ThisLabel,9,2)
if ThisAlarm is not Integer
    StringTrimRight ThisAlarm,ThisAlarm,1

;-- Bounce if voice is active (speaking, paused, or interrupted)
if COM_Invoke(pSpVoice%ThisAlarm%,"Status.RunningState")<>SRSEDone
    return

;-- Stop timer
SetTimer AlarmGUI%ThisAlarm%_TTS_Monitor,Off

;-- Reset button label
GUIControl,%ThisAlarm%:,$AlarmGUI%ThisAlarm%_TTSButton,4
return


AlarmGUI1_TTS_Stop:
AlarmGUI2_TTS_Stop:
AlarmGUI3_TTS_Stop:
AlarmGUI4_TTS_Stop:
AlarmGUI5_TTS_Stop:
AlarmGUI6_TTS_Stop:
AlarmGUI7_TTS_Stop:
AlarmGUI8_TTS_Stop:
AlarmGUI9_TTS_Stop:
AlarmGUI10_TTS_Stop:
AlarmGUI11_TTS_Stop:
AlarmGUI12_TTS_Stop:
AlarmGUI13_TTS_Stop:
AlarmGUI14_TTS_Stop:
AlarmGUI15_TTS_Stop:
AlarmGUI16_TTS_Stop:
AlarmGUI17_TTS_Stop:
AlarmGUI18_TTS_Stop:
AlarmGUI19_TTS_Stop:
AlarmGUI20_TTS_Stop:

;-- Collect alarm number
ThisAlarm :=SubStr(A_ThisLabel,9,2)
if ThisAlarm is not Integer
    StringTrimRight ThisAlarm,ThisAlarm,1

;-- Bounce if SpVoice instance doesn't exist
if not pSpVoice%ThisAlarm%
    return

;-- Bounce if stream has already ended
if COM_Invoke(pSpVoice%ThisAlarm%,"Status.RunningState")=SRSEDone
    return

;-- Stop monitor timer
SetTimer AlarmGUI%ThisAlarm%_TTS_Monitor,Off
    ;-- Note: This timer may not be running

;-- Stop stream
COM_Invoke(pSpVoice%ThisAlarm%,"Speak","",SVSFlagsAsync|SVSFPurgeBeforeSpeak)
    ;-- Send empty string with SVSFPurgeBeforeSpeak flag to stop playback

;-- Reset button label
GUIControl,%ThisAlarm%:,$AlarmGUI%ThisAlarm%_TTSButton,4
return


;********************
;*                  *
;*       Edit       *
;*    (AlarmGUI)    *
;*                  *
;********************
AlarmGUI1_Edit:
AlarmGUI2_Edit:
AlarmGUI3_Edit:
AlarmGUI4_Edit:
AlarmGUI5_Edit:
AlarmGUI6_Edit:
AlarmGUI7_Edit:
AlarmGUI8_Edit:
AlarmGUI9_Edit:
AlarmGUI10_Edit:
AlarmGUI11_Edit:
AlarmGUI12_Edit:
AlarmGUI13_Edit:
AlarmGUI14_Edit:
AlarmGUI15_Edit:
AlarmGUI16_Edit:
AlarmGUI17_Edit:
AlarmGUI18_Edit:
AlarmGUI19_Edit:
AlarmGUI20_Edit:

;-- Collect form values
gui Submit,NoHide

;-- Error/Bounce if the BRGUI window is already showing
IfWinExist ahk_id %$BRGUI_hWnd%
    {
;;;;;    WinActivate
    SoundPlay *16  ;-- System error sound
    return
    }

;-- Update Note
ReminderNote%A_GUI%:=$AlarmGUI%A_GUI%_Note
    ;-- Note: This will save any changes to the note that may have been made
    ;   before the "Edit" button was pressed.

;-- Hold current alarm
ReminderMode%A_GUI%:="Hold"

;-- If necessary, stop TTS playback
gosub AlarmGUI%A_GUI%_TTS_Stop

;-- Reset focus before hiding
GUIControl Focus,$AlarmGUI%A_GUI%_Snooze

;-- Hide window
gui Hide

;-- Update RLGUI
SetTimer RLGUI_QuickUpdate,-1

;-- Housekeeping
gosub SetAlarmNag
gosub UpdateTrayTooltip
gosub SaveConfiguration
SoundPlay %$SoundsDir%\ReminderHold.wav,Wait

;-- Begin Edit
$BR_Edit:=A_GUI
gosub BRGUI
return



;****************************
;*                          *
;*    Turn off Reminder,    *
;*      Hide Alarm GUI      *
;*        (AlarmGUI)        *
;*                          *
;****************************
AlarmGUI1_Close:
AlarmGUI2_Close:
AlarmGUI3_Close:
AlarmGUI4_Close:
AlarmGUI5_Close:
AlarmGUI6_Close:
AlarmGUI7_Close:
AlarmGUI8_Close:
AlarmGUI9_Close:
AlarmGUI10_Close:
AlarmGUI11_Close:
AlarmGUI12_Close:
AlarmGUI13_Close:
AlarmGUI14_Close:
AlarmGUI15_Close:
AlarmGUI16_Close:
AlarmGUI17_Close:
AlarmGUI18_Close:
AlarmGUI19_Close:
AlarmGUI20_Close:

;-- If necessary, stop TTS playback
gosub AlarmGUI%A_GUI%_TTS_Stop

;-- Reset reminder fields
ReminderTS%A_GUI%   :=0
ReminderCD%A_GUI%   :=""
ReminderNote%A_GUI% :=""
ReminderSound%A_GUI%:=""
ReminderMode%A_GUI% :=""

;-- Reset focus before hiding
GUIControl Focus,$AlarmGUI%A_GUI%_Snooze

;-- Hide window
gui Hide

;-- Update RLGUI
SetTimer RLGUI_QuickUpdate,-1

;-- Housekeeping
gosub SetAlarmNag
gosub UpdateTrayTooltip
gosub SaveConfiguration
return


;***********************
;*                     *
;*                     *
;*        BRGUI        *
;*                     *
;*                     *
;***********************
BRGUI:

;-- Set default GUI
gui %$BRGUI%:Default

;[=================]
;[  Edit Reminder  ]
;[=================]
;-- Edit mode?
if $BR_Edit
    {
    ;-- Already showing?
    IfWinExist ahk_id %$BRGUI_hWnd%
        {
        WinActivate
        SoundPlay *16  ;-- System error sound
        return
        }

    ;-- Disable RLGUI
    gui %$RLGUI%:+Disabled

    ;-- Set default values
    gosub BRGUI_ResetDateTime

    ;-- Note
    GUIControl ,,$BRGUI_Note,% ReminderNote%$BR_Edit%

    ;-- Countdown
    if ReminderCD%$BR_Edit% is not Space
        {
        StringSplit $Countdown,ReminderCD%$BR_Edit%,`,
        if $Countdown1 is Number
            GUIControl ,,$BRGUI_Hours,%$Countdown1%

        if $Countdown2 is Number
            GUIControl ,,$BRGUI_Minutes,%$Countdown2%

        if $Countdown3 is Number
            GUIControl ,,$BRGUI_Seconds,%$Countdown3%
        }
     else
        {
        ;-- Date/Time
        GUIControl,,$BRGUI_Date,% ReminderTS%$BR_Edit%
        GUIControl,,$BRGUI_Time,% ReminderTS%$BR_Edit%
        }

    ;-- Sound
    SplitPath ReminderSound%$BR_Edit%,$FileName
    GUIControl ChooseString,$BRGUI_SoundFile,%$FileName%

    ;----------------------------
    ;-- Update window attributes
    ;----------------------------
    gosub BRGUI_DateTimeAction
    GUIControl Focus,$BRGUI_Note

    ;-- Select all Note field
    DetectHiddenWindows On
    SendMessage
        ,EM_SETSEL
        ,0          ;-- Starting character (0 = beginning)
        ,-1         ;-- Ending character (-1 = end of text)
        ,Edit1
        ,ahk_id %$BRGUI_hWnd%

    DetectHiddenWindows Off

    ;-----------
    ;-- Show it
    ;-----------
    gui Show,,%$ScriptName% - Edit Reminder
    return
    }

;[================]
;[  Add Reminder  ]
;[================]
;-- Already showing?
IfWinExist ahk_id %$BRGUI_hWnd%
    {
    WinActivate
    return
    }

;-- Any Reminders available?
ReminderAvailable :=False
Loop %$TotalNumberOfAlarms%
    if not ReminderTS%A_Index%
        {
        ReminderAvailable:=True
        Break
        }

if not ReminderAvailable
    {
    MsgBox
        ,262160  ;-- 262160=0 (OK button) +16 (Error icon) + 262144 (AOT)
        ,%$ScriptName% Error
        ,All reminders have been used. Try again later.  %A_Space%

    return
    }

;-- Disable RLGUI
gui %$RLGUI%:+Disabled

;-- Update window attributes
gosub BRGUI_ResetDateTime
gosub BRGUI_DateTimeAction

;-- Select all Note field
DetectHiddenWindows On
SendMessage
    ,EM_SETSEL
    ,0          ;-- Starting character (0 = beginning)
    ,-1         ;-- Ending character (-1 = end of text)
    ,Edit1
    ,ahk_id %$BRGUI_hWnd%

DetectHiddenWindows Off

GUIControl Focus,$BRGUI_Note

;-- Show GUI
gui Show,,%$ScriptName% - Add Reminder
return


;*********************
;*                   *
;*    Select Note    *
;*      (BRGUI)      *
;*                   *
;*********************
BRGUI_SelectNote:

;-- Set default to first item
$DefaultList:=""
Loop Parse,$NoteList,%$GUIDelimiter%
    {
    $DefaultList:=A_LoopField
    Break
    }

;-- Select
$Select:=ListManagerGUI($BRGUI                              ;-- Owner
    ,$NoteList                                              ;-- List
    ,$DefaultList                                           ;-- Default list
    ,$GUIDelimiter                                          ;-- Delimiter
    ,"Select"                                               ;-- Mode
    ,"+ContextMenu +Copy +DropBlank +DropDups"              ;-- Mode options
    ,"Notes"                                                ;-- List title
    ,"Select a Note"                                        ;-- Window title
    ,"w300 h120 BackgroundF8F8FF"                           ;-- List options
    ,""                                                     ;-- Font
    ,""                                                     ;-- Font options
    ,"+Resize -MaximizeBox"                                 ;-- GUI options
    ,"")                                                    ;-- Background color

;-- Cancel?
if ErrorLevel
    return

;-- Update Note control
GUIControl,,$BRGUI_Note,%$Select%
GUIControl Focus,$BRGUI_Note
return


;*****************************
;*                           *
;*    Test Text-To-Speech    *
;*          (BRGUI)          *
;*                           *
;*****************************
BRGUI_TTS:

;-- Collect form values
gui Submit,NoHide

;-- Bounce if note is empty
if $BRGUI_Note is Space
    return


;-- If necessary, create SpVoice instance
if not $BRGUI_pSpVoice
    {
    $BRGUI_pSpVoice:=COM_CreateObject("SAPI.SpVoice")

    ;-- Get default voice?
    if $TTSVoice is Space
        $TTSVoice:=COM_Invoke($BRGUI_pSpVoice,"Voice.GetDescription")

    ;-- Set Voice and priority
    COM_Invoke($BRGUI_pSpVoice,"Voice","+" . COM_Invoke($BRGUI_pSpVoice,"GetVoices(" . """" . "Name=" . $TTSVoice . """" . ").Item(0)"))
    COM_Invoke($BRGUI_pSpVoice,"Priority",$TTSPriority)
    }

;-- If playing, stop play
if COM_Invoke($BRGUI_pSpVoice,"Status.RunningState")<>SRSEDone
    {
    gosub BRGUI_TTS_Stop
    return
    }

;-- Change button label
GUIControl,,$BRGUI_TTSButton,<

;-- Speak!
COM_Invoke($BRGUI_pSpVoice,"Speak",ConvertMD($BRGUI_Note),SVSFlagsAsync|SVSFPurgeBeforeSpeak)
    ;-- Not sure if the SVSFPurgeBeforeSpeak flag provides any value here

;-- Set Playback timer
SetTimer BRGUI_TTS_Monitor,200
return


BRGUI_TTS_Monitor:

;-- Bounce if voice is active (speaking, paused, or interrupted)
if COM_Invoke($BRGUI_pSpVoice,"Status.RunningState")<>SRSEDone
    return

;-- Stop timer
SetTimer BRGUI_TTS_Monitor,Off

;-- Set default GUI
gui %$BRGUI%:Default

;-- Reset button label
GUIControl,,$BRGUI_TTSButton,4
return


BRGUI_TTS_Stop:

;-- Bounce if SpVoice instance doesn't exist
if not $BRGUI_pSpVoice
    return

;-- Bounce if stream has already ended
if COM_Invoke($BRGUI_pSpVoice,"Status.RunningState")=SRSEDone
    return

;-- Stop monitor timer
SetTimer BRGUI_TTS_Monitor,Off
    ;-- Note: This timer may not be running

;-- Stop stream
COM_Invoke($BRGUI_pSpVoice,"Speak","",SVSFlagsAsync|SVSFPurgeBeforeSpeak)
    ;-- Send empty string with SVSFPurgeBeforeSpeak flag to stop playback

;-- Reset button label
GUIControl,,$BRGUI_TTSButton,4
return


;*************************
;*                       *
;*    Play sound file    *
;*        (BRGUI)        *
;*                       *
;*************************
BRGUI_SoundFileButton:
BRGUI_SoundFileDropDown:

;-- Collect form values
gui Submit,NoHide

;-- Stop currently-playing sound file (if any)
gosub BRGUI_SoundFile_StopPlay
if A_ThisLabel contains Button
    if $ButtonLabel=<  ;-- "<" = Stop button
        return

;-- Sound file exists?
IfNotExist % $SoundsDir . "\" . $BRGUI_SoundFile
    {
    MsgBox Sound file not found
        ;--------------------------------------------------- Need to finish this
    return
    }

;-- Play sound.  Use independent thread.
SetTimer BRGUI_SoundFile_Play,0
return


BRGUI_SoundFile_Play:

;-- Turn off timer
SetTimer BRGUI_SoundFile_Play,Off

;-- Change button label
GUIControl,%$BRGUI%:,$BRGUI_SoundFileButton,<

;-- Play sound file.  Wait until finished.
SoundPlay % $SoundsDir . "\" . $BRGUI_SoundFile,Wait

;-- Reset button label
GUIControl,%$BRGUI%:,$BRGUI_SoundFileButton,4
return


BRGUI_SoundFile_StopPlay:

;-- Get current button label
GUIControlGet $ButtonLabel,,$BRGUI_SoundFileButton

;--Stop playback
SoundPlay ThisDoesNotExist.xyz
    ;-- Programming note: This command does nothing if a sound file is not
    ;   playing.  However, if a sound file is playing, this command will stop
    ;   playback and will allow BRGUI_SoundFile_Play rourtine to continue after
    ;   the Soundplay..Wait statement.

return


;*************************
;*                       *
;*    DateTime Action    *
;*        (BRGUI)        *
;*                       *
;*************************
BRGUI_DateTimeAction:

gui Submit,NoHide
if $BRGUI_Hours or $BRGUI_Minutes or $BRGUI_Seconds
    {
    GUIControl Disable,$BRGUI_Date
    GUIControl Disable,$BRGUI_Time
    GUIControl Enable ,$BRGUI_StartReminderButton
    GUIControl Enable ,$BRGUI_HoldReminderButton
    }
 else
    {
    GUIControl,Enable,$BRGUI_Date
    GUIControl,Enable,$BRGUI_Time
    $BRGUI_DateTime:=SubStr($BRGUI_Date,1,8) . SubStr($BRGUI_Time,9)
    if ($BRGUI_DateTime>A_Now)
        {
        GUIControl Enable,$BRGUI_StartReminderButton
        GUIControl Enable,$BRGUI_HoldReminderButton
        }
     else
        {
        GUIControl Disable,$BRGUI_StartReminderButton
        GUIControl Disable,$BRGUI_HoldReminderButton
        }
    }

return


;************************
;*                      *
;*    Reset DateTime    *
;*        (BRGUI)       *
;*                      *
;************************
BRGUI_ResetDateTime:
GUIControl,,$BRGUI_Hours,0
GUIControl,,$BRGUI_Minutes,0
GUIControl,,$BRGUI_Seconds,0
GUIControl,,$BRGUI_Date,%A_Now%
GUIControl,,$BRGUI_Time,%A_Now%
return


;************************
;*                      *
;*    Start Reminder    *
;*        (BRGUI)       *
;*                      *
;************************
BRGUI_StartReminder:

;-- Attach any messages to the current GUI
gui +OwnDialogs

;-- Collect form variables
gui Submit,NoHide

;[========================]
;[  Confirm "very large"  ]
;[    countdown values    ]
;[========================]
if $BRGUI_Seconds is Number
    if $BRGUI_Seconds>199
        {
        MsgBox
            ,49  ;-- 49=1 (OK/Cancel buttons) +48 ("!" icon)
            ,Confirm Very Large Countdown Period,
               (ltrim join`s
                The number of seconds entered (%$BRGUI_Seconds%) is very
                large.  Press OK to accept.  %A_Space%
               )

        IfMsgBox Cancel
            return
        }

if $BRGUI_Minutes is Number
    if $BRGUI_Minutes>199
        {
        MsgBox
            ,49  ;-- 49=1 (OK/Cancel buttons) +48 ("!" icon)
            ,Confirm Very Large Countdown Period,
               (ltrim join`s
                The number of minutes entered (%$BRGUI_Minutes%) is very
                large.  Press OK to accept.  %A_Space%
               )

        IfMsgBox Cancel
            return
        }

if $BRGUI_Hours is Number
    if $BRGUI_Hours>99
        {
        MsgBox
            ,49  ;-- 49=1 (OK/Cancel buttons) +48 ("!" icon)
            ,Confirm Very Large Countdown Period,
               (ltrim join`s
                The number of hours entered (%$BRGUI_Hours%) is very
                large.  Press OK to accept.  %A_Space%
               )

        IfMsgBox Cancel
            return
        }

;[=============]
;[  Countdown  ]
;[=============]
Countdown :=0
if $BRGUI_Seconds is Number
    Countdown:=$BRGUI_Seconds

if $BRGUI_Minutes is Number
    Countdown:=Countdown+($BRGUI_Minutes*60)

if $BRGUI_Hours is Number
    Countdown:=Countdown+($BRGUI_Hours*3600)

;[=============]
;[  Date/Time  ]
;[=============]
$BRGUI_DateTime:=SubStr($BRGUI_Date,1,8) . SubStr($BRGUI_Time,9)
if (Countdown=0 and $BRGUI_DateTime<A_Now)
    return

;[==========================]
;[  Start/Restart reminder  ]
;[==========================]
Loop %$TotalNumberOfAlarms%
    {
    if $BR_Edit
        {
        if ($BR_Edit<>A_Index)
            Continue
        }
     else
        {
        ;-- Hold mode?
        if ReminderMode%A_Index%=Hold
            Continue

        ;-- Not available
        if ReminderTS%A_Index%
            Continue
        }

    ;-- Update Reminder
    if Countdown
        {
        ReminderTS%A_Index%:=A_Now
        EnvAdd ReminderTS%A_Index%,Countdown,Seconds
        }
     else
        ReminderTS%A_Index%:=$BRGUI_DateTime

    ReminderCD%A_Index%   :=""
    ReminderNote%A_Index% :=$BRGUI_Note
    ReminderSound%A_Index%:=$SoundsDir . "\" . $BRGUI_SoundFile
    ReminderMode%A_Index% :=""

    ;-- We're done
    Break
    }

;-- Update RLGUI
SetTimer RLGUI_QuickUpdate,-1

;-- Housekeeping
gosub UpdateTrayTooltip
gosub SaveConfiguration
gosub BRGUI_Hide
SoundPlay %$SoundsDir%\ReminderStart.wav,Wait
return


;***********************
;*                     *
;*    Hold Reminder    *
;*       (BRGUI)       *
;*                     *
;***********************
BRGUI_HoldReminder:
gui Submit,NoHide

;[=============]
;[  Countdown  ]
;[=============]
Countdown :=0
if $BRGUI_Seconds is Number
    Countdown:=$BRGUI_Seconds

if $BRGUI_Minutes is Number
    Countdown:=Countdown+($BRGUI_Minutes*60)

if $BRGUI_Hours is Number
    Countdown:=Countdown+($BRGUI_Hours*3600)

;[=============]
;[  Date/Time  ]
;[=============]
$BRGUI_DateTime:=SubStr($BRGUI_Date,1,8) . SubStr($BRGUI_Time,9)
if (Countdown=0 and $BRGUI_DateTime<A_Now)
    return

;[===========]
;[  Hold it  ]
;[===========]
Loop %$TotalNumberOfAlarms%
    {
    if $BR_Edit
        {
        if ($BR_Edit<>A_Index)
            Continue
        }
     else
        {
        ;-- Hold mode?
        if ReminderMode%A_Index%=Hold
            Continue

        ;-- Not available
        if ReminderTS%A_Index%
            Continue
        }

    ReminderTS%A_Index%:=$BRGUI_DateTime
    ReminderCD%A_Index%:=""

    ;-- Countdown
    if Countdown
        ReminderCD%A_Index%:=$BRGUI_Hours
            . ","
            . $BRGUI_Minutes
            . ","
            . $BRGUI_Seconds

    ReminderNote%A_Index% :=$BRGUI_Note
    ReminderSound%A_Index%:=$SoundsDir . "\" . $BRGUI_SoundFile
    ReminderMode%A_Index% :="Hold"

    ;-- We're done
    Break
    }

;-- Update RLGUI
SetTimer RLGUI_QuickUpdate,-1

;-- Housekeeping
gosub UpdateTrayTooltip
gosub SaveConfiguration
gosub BRGUI_Hide
SoundPlay %$SoundsDir%\ReminderHold.wav,Wait
return


;**********************
;*                    *
;*    Shut it down    *
;*       (BRGUI)      *
;*                    *
;**********************
BRGUI_Escape:
BRGUI_Close:
BRGUI_Hide:

;-- If necessary, stop TTS and/or sound file playback
gosub BRGUI_TTS_Stop
gosub BRGUI_SoundFile_StopPlay

;-- Reset $BR_Edit
$BR_Edit:=0

;-- Enable RLGUI
gui %$RLGUI%:-Disabled

;-- Hide window
gui Hide
return


;*********************
;*                   *
;*                   *
;*        RLGUI        *
;*                   *
;*                   *
;*********************
RLGUI:

;-- Already showing?
IfWinExist ahk_id %$RLGUI_hWnd%
    {
    WinActivate
    return
    }

SetTimer RLGUI_Update,%$RLGUIRefreshInterval%
gosub RLGUI_Update

;-- Show GUI
gui %$RLGUI%:Show
return

;**********************
;*                    *
;*    Context menu    *
;*       (RLGUI)      *
;*                    *
;**********************
RLGUI_ContextMenu:
;-- Set GUI default
gui %$RLGUI%:Default

;-- ListView object?
if A_GUIControl=$RLGUI_ListView
    Menu RLGUI_EditMenu,Show,%A_GuiX%,%A_GuiY%

return


;*************************
;*                       *
;*    ListView Action    *
;*        (RLGUI)        *
;*                       *
;*************************
RLGUI_ListViewAction:

;-- Doubleclick?
if A_GuiEvent=DoubleClick
    gosub RLGUI_Edit

return


;*****************
;*               *
;*     Update    *
;*    (RLGUI)    *
;*               *
;*****************
RLGUI_Refresh:
SetTimer RLGUI_QuickUpdate,-1
return

RLGUI_QuickUpdate:

;-- Bounce if RLGUI window is not showing
IfWinNotExist ahk_id %$RLGUI_hWnd%
    return


RLGUI_Update:

;-- Set GUI default
gui %$RLGUI%:Default

;-- Redraw off
GUIControl %$RLGUI%:-Redraw,$RLGUI_ListView

;-- Update
Loop %$TotalNumberOfAlarms%
    {
    ;-- Build Status column
    $Status:=""
    if ReminderMode%A_Index%=Hold
        {
        if ReminderCD%A_Index% is not Space
            {
            $FormattedCD:=""
            StringSplit $Countdown,ReminderCD%A_Index%,`,

            $Countdown1=%$Countdown1%  ;-- AutoTrim
            if $Countdown1 is Number
                {
                if $Countdown1>0
                    {
                    $FormattedCD:=$Countdown1 . " hour"
                    if $Countdown1>1
                        $FormattedCD.="s"
                    }
                }

            $Countdown2=%$Countdown2%  ;-- AutoTrim
            if $Countdown2 is Number
                {
                if $Countdown2>0
                    {
                    if StrLen($FormattedCD)
                        $FormattedCD.=", "

                    $FormattedCD.=$Countdown2 . " minute"
                    if $Countdown2>1
                        $FormattedCD.="s"
                    }
                }

            $Countdown3=%$Countdown3%  ;-- AutoTrim
            if $Countdown3 is Number
                {
                if $Countdown3>0
                    {
                    if StrLen($FormattedCD)
                        $FormattedCD.=", "

                    $FormattedCD.=$Countdown3 . " second"
                    if $Countdown3>1
                        $FormattedCD.="s"
                    }
                }

            $Status:="Hold.  Countdown set to " . $FormattedCD
            }
         else
            {
            FormatTime
                ,$FormattedTS
                ,% ReminderTS%A_Index%
                ,MMMM d, yyyy  hh:mm:ss tt

            $Status :="Hold.  Reminder set for: " . $FormattedTS
            }
        }
     else
        {
        if ReminderTS%A_Index%
            {
            $Timeout:=FormattedTimeout(ReminderTS%A_Index%,3)
            if ($Timeout="Expired")
                $Status:=$Timeout
             else
                $Status:="Active.  Expires in " . $Timeout
            }
        }

    ;-- Update row
    LV_Modify(A_Index,"",A_Index,ReminderNote%A_Index%,$Status)
    }

;-- Redraw On
GUIControl %$RLGUI%:+Redraw,$RLGUI_ListView
return



;**********************
;*                    *
;*    Add Reminder    *
;*      (RLGUI)       *
;*                    *
;**********************
RLGUI_Add:
gosub BRGUI
return

;*****************
;*               *
;*     Delete    *
;*    (RLGUI)    *
;*               *
;*****************
RLGUI_Delete:

;-- Set GUI Default
gui %$RLGUI%:Default

;-- Check selected row(s)
ThisReminder  :=0
ReminderCount :=0
Loop % LV_GetCount("Selected")
    {
    ThisReminder:=LV_GetNext(ThisReminder)
    if ReminderTS%ThisReminder%
        ReminderCount++
    }

;-- Bounce if there is nothing to delete
if not ReminderCount
    {
    SoundPlay *16  ;-- System error sound
    return
    }

;-- Confirm     ##### Limit confirmation to more than 1???
gui +OwnDialogs
MsgBox
    ,49
        ;-- 49=1 (OK/Cancel buttons) + 48 ("!" icon) 
    ,%$ScriptName% - Confirm Delete
    ,%ReminderCount% reminder(s) will be deleted.  Press OK to proceed.  %A_Space%

IfMsgBox Cancel
    return

;-- Delete selected
ThisReminder :=0
Loop % LV_GetCount("Selected")
    {
    ThisReminder:=LV_GetNext(ThisReminder)
    if ReminderTS%ThisReminder%
        {
        ;-- Alarm window showing?
        IfWinExist % "ahk_id " . $AlarmGUI%ThisReminder%_hWnd
            gui %ThisReminder%:Hide
    
        ;-- Reset all Reminder fields
        ReminderTS%ThisReminder%   :=0
        ReminderCD%ThisReminder%   :=""
        ReminderNote%ThisReminder% :=""
        ReminderSound%ThisReminder%:=""
        ReminderMode%ThisReminder% :=""
        }
    }

;-- Update RLGUI
SetTimer RLGUI_QuickUpdate,-1

;-- Housekeeping
gosub SetAlarmNag
gosub UpdateTrayTooltip
gosub SaveConfiguration
SoundPlay %$SoundsDir%\ReminderDelete.wav,Wait
return


;*****************
;*               *
;*      Edit     *
;*    (RLGUI)    *
;*               *
;*****************
RLGUI_Edit:

;-- Set GUI Default
gui %$RLGUI%:Default

;-- Bounce if more than one row is selected.
if LV_GetCount("Selected")>1
    return

ThisReminder :=LV_GetNext(0)

;-- Bounce if row does not contain a reminder
if not ReminderTS%ThisReminder%
    {
    SoundPlay *16  ;-- System error sound
    return
    }

;-- Bounce if Alarm Window is show
IfWinExist % "ahk_id " . $AlarmGUI%ThisReminder%_hWnd
    {
    SoundPlay *16  ;-- System error sound
    return
    }

;-- Hold it
$BR_Edit:=LV_GetNext(0)
ReminderMode%$BR_Edit%:="Hold"

;--- Update RLGUI
SetTimer RLGUI_QuickUpdate,-1

;-- Housekeeping
gosub UpdateTrayTooltip
gosub SaveConfiguration
SoundPlay %$SoundsDir%\ReminderHold.wav,Wait

;-- Begin Edit
gosub BRGUI
return


;*****************
;*               *
;*      Hold     *
;*    (RLGUI)    *
;*               *
;*****************
RLGUI_Hold:

;-- Set GUI Default
gui %$RLGUI%:Default

;-- Hold selected
HoldCount    :=0
ThisReminder :=0
Loop % LV_GetCount("Selected")
    {
    ThisReminder:=LV_GetNext(ThisReminder)
    if (ReminderTS%ThisReminder% and ReminderMode%ThisReminder%<>"Hold")
        ;-- ...and Alarm window not showing
        IfWinNotExist % "ahk_id " . $AlarmGUI%ThisReminder%_hWnd
            {
            ;-- Count it
            HoldCOunt++

            ;-- Set Reminder fields
            ReminderMode%ThisReminder%:="Hold"
            }
    }

;-- Bounce if nothing set to hold
if not HoldCount
    {
    SoundPlay *16  ;-- System error sound
    return
    }

;-- Update RLGUI
SetTimer RLGUI_QuickUpdate,-1

;-- Housekeeping
gosub UpdateTrayTooltip
gosub SaveConfiguration
SoundPlay %$SoundsDir%\ReminderHold.wav,Wait
return


;*****************
;*               *
;*     Start     *
;*    (RLGUI)    *
;*               *
;*****************
RLGUI_Start:

;-- Set GUI Default
gui %$RLGUI%:Default

;-- Start selected
StartCount   :=0
ThisReminder :=0
Loop % LV_GetCount("Selected")
    {
    ThisReminder:=LV_GetNext(ThisReminder)
    if ReminderMode%ThisReminder%=Hold
        {
        ;-- Count it
        StartCount++

        ;-- Countdown
        if ReminderCD%ThisReminder% is not Space
            {
            StringSplit $Countdown,ReminderCD%ThisReminder%,`,
        
            ;-- Convert to seconds
            $CDSeconds:=0
            if $Countdown3 is Number
                $CDSeconds:=$Countdown3
        
            if $Countdown2 is Number
                $CDSeconds:=$CDSeconds+($Countdown2*60)
        
            if $Countdown1 is Number
                $CDSeconds:=$CDSeconds+($Countdown1*3600)
        
            ;-- Set ReminderTS
            ReminderTS%ThisReminder%:=A_Now
            EnvAdd ReminderTS%ThisReminder%,$CDSeconds,Seconds
            }
        
        ;-- Clear Reminder fields
        ReminderCD%ThisReminder%  :=""
        ReminderMode%ThisReminder%:=""
        }
    }

;-- Bounce if there nothing started
if not StartCount
    {
    SoundPlay *16  ;-- System error sound
    return
    }

;-- Update RLGUI
SetTimer RLGUI_QuickUpdate,-1

;-- Housekeeping
gosub UpdateTrayTooltip
gosub SaveConfiguration
SoundPlay %$SoundsDir%\ReminderStart.wav,Wait
return


;********************
;*                  *
;*    Select All    *
;*      (RLGUI)     *
;*                  *
;********************
RLGUI_SelectAll:

;-- Set GUI Default
gui %$RLGUI%:Default

;-- Select all
LV_Modify(0,"Select")
return


;**********************
;*                    *
;*    Shut it down    *
;*       (RLGUI)      *
;*                    *
;**********************
RLGUI_Escape:
RLGUI_Close:
SetTimer RLGUI_Update,Off
gui Hide
return

;*****************
;*               *
;*    HotKeys    *
;*    (RLGUI)    *
;*               *
;*****************
;-- Begin #IfWinActive directive
#IfWinActive ahk_group $RLGUI_Group

Insert::gosub RLGUI_Add
Delete::gosub RLGUI_Delete
^a::    gosub RLGUI_SelectAll
a::     gosub RLGUI_Add
e::     gosub RLGUI_Edit
h::     gosub RLGUI_Hold
s::     gosub RLGUI_Start
F5::    gosub RLGUI_Refresh

;-- End #IfWinActive directive
#IfWinActive

;*************************
;*                       *
;*                       *
;*        Hotkeys        *
;*        (BRGUI)        *
;*                       *
;*                       *
;*************************
;-- Begin #IfWinActive directive
#IfWinActive ahk_group $BRGUI_Group

;[=======]
;[  Tab  ]
;[=======]
~Tab::

;-- Set default GUI
gui %$BRGUI%:Default

;-- Ignore if focus is not on Note field
GUIControlGet $Control,FocusV
if $Control=$BRGUI_Note
    {
    ;-- Skip past buttons (Move focus to Hours)
    Sleep 1       ;-- Allow original Tab key to fire
    Send {Tab 2}
        ;-- Note:  Although this method is a bit jumpy, it forces all of the
        ;   screen objects to ????? the correct characteristics (focus, xxxxxx, etc.)
    }

return

;[=============]
;[  Shift+Tab  ]
;[=============]
~+Tab::

;-- Set default GUI
gui %$BRGUI%:Default

;-- Ignore if focus is not on Hours field
GUIControlGet $Control,FocusV
if $Control=$BRGUI_Hours
    {
    ;-- Skip past buttons (Move focus to Hours)
    Sleep 1       ;-- Allow original Shift-Tab key to fire
    Send +{Tab 2}
        ;-- Note:  Although this method is a bit jumpy, all of the screen
        ;   to ????? the correct characteristics (focus, xxxxxx, etc.)
    }

return

;[======]
;[  F2  ]
;[======]
F2::

;-- Set default GUI
gui %$BRGUI%:Default

;-- Bounce if focus is not on Note field
GUIControlGet $Control,FocusV
if $Control<>$BRGUI_Note
    return

;-- Select note from list
gosub BRGUI_SelectNote
return

;[==========]
;[  Ctrl+s  ]
;[==========]
^s::

;-- Set default GUI
gui %$BRGUI%:Default

;-- Ignore if focus is not on Note field
GUIControlGet $Control,FocusV
if $Control<>$BRGUI_Note
    return

;-- Collect form variables
gui Submit,NoHide


;-- Error (sound only) if blank
if $BRGUI_Note is Space
    {
    SoundPlay *16  ;-- System error sound
    return
    }

;-- Error (sound only) if duplicate.  Note: Not case sensitive.
Loop Parse,$NoteList,%$GUIDelimiter%
    {
    if (A_LoopField=$BRGUI_Note)
        {
        SoundPlay *16  ;-- System error sound
        return
        }
    }

;-- Add current Note to end of the $NoteList
if $NoteList is Space
    $NoteList:=$BRGUI_Note
 else
    $NoteList.=$GUIDelimiter . $BRGUI_Note

;-- Save changes
gosub SaveConfiguration

;-- Make a noise
SoundPlay *64  ;-- Asterisk (info)
return

;[==========]
;[  Ctrl+T  ]
;[==========]
^t::
GUIControl %$BRGUI%:Focus,$BRGUI_Time
return

;-- End #IfWinActive directive
#IfWinActive





;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;---------------------------- Begin OptionsGUI Stuff ---------------------------
;-------------------------------------------------------------------------------
;*****************************
;*                           *
;*                           *
;*        Options GUI        *
;*                           *
;*                           *
;*****************************
OptionsGUI:

;-- Already open
if $OptionsGUI_hWnd
    ifWinExist ahk_id %$OptionsGUI_hWnd%
        {
        WinActivate
        return
        }

;[==============]
;[  Initialize  ]
;[==============]
$OptionsGUI_BR_Hotkey:=$BR_Hotkey
$OptionsGUI_RL_Hotkey:=$RL_Hotkey

$OptionsGUI_StartProgramOnStartup:=False
if A_IsCompiled
    IfExist %A_StartUp%\%$ScriptName%.lnk
        $OptionsGUI_StartProgramOnStartup:=True

;-- If necessary, create SpVoice instance
if not $OptionsGUI_pSpVoice
    $OptionsGUI_pSpVoice:=COM_CreateObject("SAPI.SpVoice")

;-- If necessary, set $TTSVoice to default voice
if $TTSVoice is Space
    $TTSVoice:=COM_Invoke($OptionsGUI_pSpVoice,"Voice.GetDescription")

;-- Build list of Voices
$TTSVoiceList:=""
Loop % COM_Invoke($OptionsGUI_pSpVoice,"GetVoices.Count")
    {
    $TTSName:=COM_Invoke($OptionsGUI_pSpVoice,"GetVoices.Item(" . A_Index-1 . ")" . ".GetAttribute","Name")
    if $TTSVoiceList is Space
        $TTSVoiceList:=$TTSName
     else
        $TTSVoiceList.="|" . $TTSName
    }

;[=============]
;[  Build GUI  ]
;[=============]
;-- Set GUI default
gui %$OptionsGUI%:Default

;-- GUI options
gui Margin,6,6
gui +AlwaysOnTop    ;-- Must-have option
    || +LabelOptionsGUI_
    || +Resize
    || -MinimizeBox
    || -MaximizeBox
    || +MinSize

;-- Tab
gui Add
   ,Tab2
   ,xm y10 w420 h280
        || hWnd$OptionsGUI_Tab_hWnd
        || v$OptionsGUI_Tab
        || gOptionsGUI_Tab
   ,General|Windows|Notes|Snooze|Sounds|TTS

;----------------
;-- Tab: General
;----------------
gui Tab,General
gui Add
   ,GroupBox
   ,xm+10 y40 w400 h120
        || hWnd$OptionsGUI_StartupGB_hWnd
   ,Startup

gui Add
   ,Edit
   ,xp+10 yp+20
        || Hidden
   ,Dummy
        ;-- This dummy control is use to establish the height for the following
        ;   control

gui Add
   ,CheckBox
   ,xp yp hp
        || Section
        || Checked%$OptionsGUI_StartProgramOnStartup%
        || v$OptionsGUI_StartProgramOnStartup
   ,Start program when Windows starts


;-- Disable if running script
if not A_IsCompiled
    GUIControl Disable,$OptionsGUI_StartProgramOnStartup


gui Add
   ,GroupBox
   ,xm+10 y160 w400 h120
        || hWnd$OptionsGUI_AlarmSoundsGB_hWnd
   ,Alarm Sounds

gui Add
   ,Edit
   ,xp+10 yp+20
        || Hidden
   ,Dummy
        ;-- This dummy control is use to establish the height for the following
        ;   2 controls

gui Add
   ,CheckBox
   ,xp yp hp
        || Section
        || Checked%$PlayAlarmSound%
        || v$OptionsGUI_PlayAlarmSound
   ,Play Alarm Sound

gui Add
   ,CheckBox
   ,xs y+0 hp
        || Checked%$PlayAlarmNagSound%
        || v$OptionsGUI_PlayAlarmNagSound
        || gOptionsGUI_PlayAlarmNagSoundAction
   ,Play Alarm Nag sound


gui Add
   ,Edit
   ,xs+20 y+0 w60
        || Right
        || v$OptionsGUI_NagInterval

gui Add
   ,UpDown
   ,Range10-999
   ,%$NagInterval%

gui Add
   ,Text
   ,x+5
   ,Interval (in seconds)

;----------------
;-- Tab: Windows
;----------------
gui Tab,Windows
gui Add
   ,GroupBox
   ,xm+10 y40 w400 h120
        || hWnd$OptionsGUI_BuildReminderGB_hWnd
   ,Add Reminder window

gui Add
   ,Edit
   ,xp+10 yp+20
        || Hidden
   ,Dummy
        ;-- This dummy control is use to establish the height for the following
        ;   2 controls

gui Add
   ,CheckBox
   ,xp yp hp
        || Section
        || Checked%$BR_DefaultTray%
        || v$OptionsGUI_BR_DefaultTray
        || gOptionsGUI_BR_DefaultTray
   ,Default Tray Window

gui Add
   ,CheckBox
   ,xs y+0 hp
        || Checked%$BR_EnableHotkey%
        || v$OptionsGUI_BR_EnableHotkey
   ,Global Hotkey

gui Add
   ,Edit
   ,xs+20 y+0 w330 r1
        || +ReadOnly
        || v$OptionsGUI_BR_HotkeyDesc
   ,% HotkeyDescription($BR_Hotkey)

gui Add
   ,Button
   ,x+0 hp
        || gOptionsGUI_BR_Hotkey
  ,...

gui Add
   ,GroupBox
   ,xm+10 y160 w400 h120
        || hWnd$OptionsGUI_ReminderListGB_hWnd
   ,Reminder List window

gui Add
   ,Edit
   ,xp+10 yp+20
        || Hidden
   ,Dummy
        ;-- This dummy control is use to establish the height for the following
        ;   2 controls

gui Add
   ,CheckBox
   ,xp yp hp
        || Section
        || Checked%$RL_DefaultTray%
        || v$OptionsGUI_RL_DefaultTray
        || gOptionsGUI_RL_DefaultTray
   ,Default Tray Window

gui Add
   ,CheckBox
   ,xs y+0 hp
        || Checked%$RL_EnableHotkey%
        || v$OptionsGUI_RL_EnableHotkey
   ,Global Hotkey

gui Add
   ,Edit
   ,xs+20 y+0 w330
        || +ReadOnly
        || v$OptionsGUI_RL_HotkeyDesc
   ,% HotkeyDescription($RL_Hotkey)

gui Add
   ,Button
   ,x+0 hp
        || gOptionsGUI_RL_Hotkey
   ,...

;--------------
;-- Tab: Notes
;--------------
gui Tab,Notes
gui Add
   ,GroupBox
   ,xm+10 y40 w400 h240
        || hWnd$OptionsGUI_NoteListEditorGB_hWnd
   ,Note List Editor

gui Add
   ,Text
   ,xp+10 yp+20 w160
        || Section
   ,Note List

gui Add
   ,Text
   ,x+0
        || hWnd$OptionsGUI_NLE_Detail_Header_hWnd
   ,Detail

gui Add
   ,ListView
   ,xs y+0 w160 h150
        || Section
        || +AltSubmit
        || -Hdr
        || -Multi
        || Count100             ;-- Very small list.  Increase if necessary
        || +LV0x8000            ;-- LVS_EX_BORDERSELECT
        || +BackgroundE8E8FF    ;-- Original F8F8FF
        || hWnd$OptionsGUI_NoteList_hWnd
        || v$OptionsGUI_NoteList
        || gOptionsGUI_NLE_NoteList
   ,Note

;-- Populate ListView
Loop Parse,$NoteList,%$GUIDelimiter%
    LV_Add("",A_LoopField)

gui Add
   ,Edit
   ,x+0 ys w220 hp
        || hWnd$OptionsGUI_NLE_Detail_hWnd
        || v$OptionsGUI_NLE_Detail

gui Add
   ,Button
   ,xs w40
        || hWnd$OptionsGUI_NLE_Add_hWnd
        || gOptionsGUI_NLE_Add
   ,Add

gui Add
   ,Button
   ,x+0 wp hp
        || hWnd$OptionsGUI_NLE_Delete_hWnd
        || gOptionsGUI_NLE_Delete
   ,Del

gui Add
   ,Button
   ,x+0 wp hp
        || hWnd$OptionsGUI_NLE_MoveUp_hWnd
        || gOptionsGUI_NLE_MoveUp
   ,Up

gui Add,Button
   ,x+0 wp hp
        || hWnd$OptionsGUI_NLE_MoveDown_hWnd
        || gOptionsGUI_NLE_MoveDown
   ,Dn

gui Add
   ,Button
   ,x+170 w50 hp
        || hWnd$OptionsGUI_NLE_Help_hWnd
        || gOptionsGUI_NLE_Help
   ,Help

;---------------
;-- Tab: Snooze
;---------------
gui Tab,Snooze
gui Add
   ,GroupBox
   ,xm+10 y40 w400 h240
        || hWnd$OptionsGUI_SnoozeGB_hWnd
   ,Snooze Dropdown List - (One snooze period per line)

;-- Replace $GUIDelimiter characters with NL characters for display/edit
StringReplace $OptionsGUI_SnoozeDDL,$SnoozeDDL,%$GUIDelimiter%,`n,All

gui Add
   ,Edit
   ,xp+10 yp+20 w380 h210
        || -Wrap
        || hWnd$OptionsGUI_SnoozeDDL_hWnd
        || v$OptionsGUI_SnoozeDDL
   ,%$OptionsGUI_SnoozeDDL%

;---------------
;-- Tab: Sounds
;---------------
gui Tab,Sounds
gui Add,GroupBox
   ,xm+10 y40 w400 h240
        || hWnd$OptionsGUI_SoundsGB_hWnd
   ,Sounds (Future)

;------------
;-- Tab: TTS
;------------
gui Tab,TTS
gui Add
   ,GroupBox
   ,xm+10 y40 w400 h240
        || hWnd$OptionsGUI_TTSGB_hWnd
   ,Text-To-Speech

gui Add
   ,Edit
   ,xp+10 yp+20
        || Hidden
   ,Dummy
        ;-- This dummy control is use to establish the height for the following
        ;   controls

gui Add
   ,CheckBox
   ,xp yp hp
        || Section
        || Checked%$SpeakOnAlarm%
        || v$OptionsGUI_SpeakOnAlarm
   ,Speak Note Text on Alarm

gui Add
   ,Text
   ,xs y+5 w60 hp
   ,Voice:

gui Add
   ,DropDownList
   ,x+0 w200 hp r5
        || v$OptionsGUI_TTSVoice
   ,%$TTSVoiceList%

GUIControl
    ,ChooseString
    ,$OptionsGUI_TTSVoice
    ,%$TTSVoice%

gui Add
   ,Text
   ,xs y+0 w60 hp
   ,Priority:

gui Add
   ,DropDownList
   ,x+0 w200 hp r3
        || +AltSubmit
        || v$OptionsGUI_TTSPriority
   ,Normal|Alert|Over

GUIControl
    ,Choose
    ,$OptionsGUI_TTSPriority
    ,% $TTSPriority+1

;-- End of tabs
gui Tab

;-- Select last-used tab
if $OptionsGUI_Tab is not Space
    GUIControl Choose,$OptionsGUI_Tab,%$OptionsGUI_Tab%

;-----------
;-- Buttons
;-----------
gui Add
   ,Button
   ,xm y300 w70
        || hWnd$OptionsGUI_SaveButton_hWnd
        || gOptionsGUI_SaveButton
   ,&Save

gui Add
   ,Button
   ,x+5 wp hp
        || hWnd$OptionsGUI_CancelButton_hWnd
        || v$OptionsGUI_CancelButton
        || gOptionsGUI_Close
   ,Cancel

;--------------
;-- Initialize
;--------------
gosub OptionsGUI_PlayAlarmNagSoundAction
GUIControl Focus,$OptionsGUI_CancelButton

;----------
;-- Attach
;----------
Attach($OptionsGUI_Tab_hWnd              ,"w h")
Attach($OptionsGUI_StartupGB_hWnd        ,"w")
Attach($OptionsGUI_AlarmSoundsGB_hWnd    ,"w")
Attach($OptionsGUI_BuildReminderGB_hWnd  ,"w")
Attach($OptionsGUI_ReminderListGB_hWnd   ,"w")
Attach($OptionsGUI_NoteListEditorGB_hWnd ,"w h")
Attach($OptionsGUI_NLE_Detail_Header_hWnd,"x0.4")
Attach($OptionsGUI_NoteList_hWnd         ,"w0.4 h")
Attach($OptionsGUI_NLE_Detail_hWnd       ,"w0.6 h x0.4")
Attach($OptionsGUI_NLE_Add_hWnd          ,"y r")
Attach($OptionsGUI_NLE_Delete_hWnd       ,"y r")
Attach($OptionsGUI_NLE_MoveUp_hWnd       ,"x0.4 y r")
Attach($OptionsGUI_NLE_MoveDown_hWnd     ,"x0.4 y r")
Attach($OptionsGUI_NLE_Help_hWnd         ,"x y")
Attach($OptionsGUI_SnoozeGB_hWnd         ,"w h")
Attach($OptionsGUI_SnoozeDDL_hWnd        ,"w h")
Attach($OptionsGUI_SoundsGB_hWnd         ,"w h")
Attach($OptionsGUI_TTSGB_hWnd            ,"w h")
Attach($OptionsGUI_SaveButton_hWnd       ,"y r")
Attach($OptionsGUI_CancelButton_hWnd     ,"y r")

;[============]
;[  Show it!  ]
;[============]
gui Show,,%$ScriptName% Options

;-- Identify Window ID
gui +LastFound
WinGet $OptionsGUI_hWnd,ID
GroupAdd $OptionsGUI_Group,ahk_id %$OptionsGUI_hWnd%
return


;**********************
;*                    *
;*       Resize       *
;*    (OptionsGUI)    *
;*                    *
;**********************
OptionsGUI_Size:

;-- Minimize?
if A_EventInfo=1
    return

;-- Resize ListView column
GUIControlGet $OptionsGUI_NoteList,Pos
LV_ModifyCol(1,$OptionsGUI_NoteListW-(SM_CXVSCROLL+4))
return


;************************
;*                      *
;*    Play Alarm Nag    *
;*     Sound Action     *
;*     (OptionsGUI)     *
;*                      *
;************************
OptionsGUI_PlayAlarmNagSoundAction:
GUIControlGet $OptionsGUI_PlayAlarmNagSound,,$OptionsGUI_PlayAlarmNagSound

if $OptionsGUI_PlayAlarmNagSound
    GUIControl Enable,$OptionsGUI_NagInterval
 else
    GUIControl,Disable,$OptionsGUI_NagInterval

return


;**********************
;*                    *
;*         Tab        *
;*    (OptionsGUI)    *
;*                    *
;**********************
OptionsGUI_Tab:
GUIControlGet $OptionsGUI_Tab,,$OptionsGUI_Tab  ;-- Collect the current tab
return


OptionsGUI_BR_DefaultTray:
GUIControlGet $OptionsGUI_BR_DefaultTray,,$OptionsGUI_BR_DefaultTray
if $OptionsGUI_BR_DefaultTray
    GUIControl,,$OptionsGUI_RL_DefaultTray,%False%

return


OptionsGUI_RL_DefaultTray:
GUIControlGet $OptionsGUI_RL_DefaultTray,,$OptionsGUI_RL_DefaultTray
if $OptionsGUI_RL_DefaultTray
    GUIControl,,$OptionsGUI_BR_DefaultTray,%False%

return


OptionsGUI_BR_Hotkey:
$Hotkey:=HotkeyGUI($OptionsGUI,$OptionsGUI_BR_Hotkey)
if $Hotkey is not Space
    {
    $OptionsGUI_BR_Hotkey:=$Hotkey
    GUIControl,,$OptionsGUI_BR_HotkeyDesc,% HotkeyDescription($OptionsGUI_BR_Hotkey)
    }

return


OptionsGUI_RL_Hotkey:
$Hotkey:=HotkeyGUI($OptionsGUI,$OptionsGUI_RL_Hotkey)
if $Hotkey is not Space
    {
    $OptionsGUI_RL_Hotkey:=$Hotkey
    GUIControl,,$OptionsGUI_RL_HotkeyDesc,% HotkeyDescription($OptionsGUI_RL_Hotkey)
    }

return


OptionsGUI_NLE_NoteList:
Critical

if $EditingNL
    return

if (A_GUIEvent=="I")  ;-- Item change
    {
    if ErrorLevel contains S
        {
        Loop Parse,ErrorLevel,,%A_Space%
            {
            ;-- Select
            if (A_LoopField=="S")
                {
                ;-- Populate Note (Detail)
                LV_GetText($OptionsGUI_NLE_Detail,A_EventInfo,1)
                GUIControl,,$OptionsGUI_NLE_Detail,%$OptionsGUI_NLE_Detail%
                return
                }

            ;-- Deselect
            if (A_LoopField=="s")
                {
                ;-- Update ListView item
                GUIControlGet $OptionsGUI_NLE_Detail,,$OptionsGUI_NLE_Detail
                LV_Modify(A_EventInfo,"",$OptionsGUI_NLE_Detail)

                ;-- Clear Note (Detail)
                $OptionsGUI_NLE_Detail:=""
                GUIControl,,$OptionsGUI_NLE_Detail,%$OptionsGUI_NLE_Detail%
                return
                }
            }
        }
    }

return


;*****************************************
;*                                       *
;*                 Insert                *
;*    (OptionsGUI - Note List Editor)    *
;*                                       *
;*****************************************
OptionsGUI_NLE_Add:

;-- Insert
if LV_GetCount("Selected")
    {
    ;-- Insert in place
    l_Row:=LV_GetNext(0)
    LV_Insert(l_Row,"","-- New --")
    LV_Modify(0,"-Select")                  ;-- Unselect all
    LV_Modify(l_Row,"+Select +Focus +Vis")  ;-- Select new
    }
 else
    {
    ;-- Add to the end
    LV_Add("+Select +Focus","-- New --")
    LV_Modify(LV_GetNext(0),"+Vis")
    }

;-- Housekeeping
Sleep 50  ;-- Allow NoteList actions to complete

;-- Move focus to the Notes (Detail) field
GUIControl Focus,$OptionsGUI_NLE_Detail

;-- Select all
GUIControlGet $Control,Focus
SendMessage
    ,EM_SETSEL
    ,0          ;-- Starting character (0 = beginning)
    ,-1         ;-- Ending character (-1 = end of text)
    ,%$Control%
    ,ahk_id %$OptionsGUI_hWnd%

return



;*****************************************
;*                                       *
;*                 Delete                *
;*    (OptionsGUI - Note List Editor)    *
;*                                       *
;*****************************************
OptionsGUI_NLE_Delete:
GUIControl Focus,$OptionsGUI_NoteList

;[===================]
;[  Delete selected  ]
;[===================]
;-- Initialize
$EditingNL:=True

;-- Clear note
$OptionsGUI_NLE_Detail:=""
GUIControl,,$OptionsGUI_NLE_Detail,%$OptionsGUI_NLE_Detail%

;-- Redraw off
GUIControl -Redraw,$OptionsGUI_NoteList

;-- Delete row(s) from list
Loop
    {
    l_Row:=LV_GetNext(0)  ;-- Always restart at the top
    if not l_Row
        Break

    ;-- Delete row from ListView
    LV_Delete(l_Row)
    }

;-- Housekeeping
Sleep 50
$EditingNL:=False

;-- Select if anything is in focus
if LV_GetNext(0,"Focused")
    LV_Modify(LV_GetNext(0,"Focused"),"+Select")

;-- Redraw on
GUIControl +Redraw,$OptionsGUI_NoteList
return



;*****************************************
;*                                       *
;*                  Edit                 *
;*    (OptionsGUI - Note List Editor)    *
;*                                       *
;*****************************************
OptionsGUI_NLE_Edit:

;-- Skip if nothing is selected
if LV_GetCount("Selected")=0
    return

;-- Move focus to the Notes (Detail) field
GUIControl Focus,$OptionsGUI_NLE_Detail

;-- Select all
GUIControlGet $Control,Focus
SendMessage
    ,EM_SETSEL
    ,0          ;-- Starting character (0 = beginning)
    ,-1         ;-- Ending character (-1 = end of text)
    ,%$Control%
    ,ahk_id %$OptionsGUI_hWnd%

return


;*****************************************
;*                                       *
;*                Move up                *
;*    (OptionsGUI - Note List Editor)    *
;*                                       *
;*****************************************
OptionsGUI_NLE_MoveUp:
GUIControl Focus,$OptionsGUI_NoteList

;-- Get select status of 1st item
SendMessage
    ,LVM_GETITEMSTATE
    ,0
    ,LVIS_SELECTED
    ,SysListView321
    ,ahk_id %$OptionsGUI_hWnd%

;-- Already at the top?
if (ErrorLevel=LVIS_SELECTED)
    return

;[===========]
;[  Move up  ]
;[===========]
;-- Initialize
$EditingNL:=True

;-- Redraw off
GUIControl -Redraw,$OptionsGUI_NoteList

;-- Move 'em
$Row:=0
Loop
    {
    ;-- Get next selected
    $Row:=LV_GetNext($Row)
    if $Row=0
        Break

    ;-- Move up by 1
    SwapLVRow($Row,$Row-1)
    }

;-- Make sure 1st selected is visable
LV_Modify(LV_GetNext(0),"+Vis")

;-- Redraw on
GUIControl +Redraw,$OptionsGUI_NoteList

;-- Housekeeping
Sleep 50
$EditingNL:=False
return


;*****************************************
;*                                       *
;*               Move down               *
;*    (OptionsGUI - Note List Editor)    *
;*                                       *
;*****************************************
OptionsGUI_NLE_MoveDown:
GUIControl Focus,$OptionsGUI_NoteList

;-- Already at the bottom?
if LV_GetNext(LV_GetCount()-1)=LV_GetCount()
    return

;[=============]
;[  Move down  ]
;[=============]
;-- Initialize
$EditingNL:=True

;-- Redraw off
GUIControl -Redraw,$OptionsGUI_NoteList

;-- Create selected list
$Row            :=0
$SelectedList   :=""
$LastSelectedRow:=""
Loop
    {
    $Row:=LV_GetNext($Row)
    if $Row=0
        Break

    $LastSelectedRow:=$Row

    ;-- Store list in reverse (LIFO) order
    if $SelectedList is Space
        $SelectedList:=$Row
     else
        $SelectedList:=$Row . "|" . $SelectedList
    }

;-- Move 'em
Loop Parse,$SelectedList,|
    SwapLVRow(A_LoopField,A_LoopField+1)

;-- Make sure last selected is visable
LV_Modify($LastSelectedRow,"+Vis")

;-- Redraw on
GUIControl +Redraw,$OptionsGUI_NoteList

;-- Housekeeping
Sleep 50
$EditingNL:=False
return


;**************
;*            *
;*    Help    *
;*            *
;**************
OptionsGUI_NLE_Help:

;-- Create help file
FileDelete NoteListEditorHelp.html
FileAppend,
(join
<html>
<body bgcolor="#F0F0F0" leftmargin="10" topmargin="10">
<div align="left"><p>
<font face="Arial" size="2">
The Note List Editor is used to maintain a list of notes that can be selected from when adding or editing a Reminder.
<br><br>
<span style="color: darkblue"><span style="font-size: 16px; line-height: normal"><span style="font-weight: bold">Actions</span></span></span>
<br>
<ul><li><span style="font-weight: bold">Add</span>. To create a new note, select the position in the Note List where a new note is to be added and press the <span style="color: brown"><span style="font-weight: bold">Add</span></span> button.
<br><br>
<li><span style="font-weight: bold">Edit</span>. To edit a Note, select the desired Note item and make changes in the Detail field.
<br><br>
<li><span style="font-weight: bold">Delete</span>. To delete a Note, select the desired Note List item and press the <span style="color: brown"><span style="font-weight: bold">Del</span></span> button.
<br><br>
<li><span style="font-weight: bold">Sequence</span>. To change to the order in which the list is displayed, select the desired Note List item and click on the <span style="color: brown"><span style="font-weight: bold">Up</span></span> or <span style="color: brown"><span style="font-weight: bold">Dn</span></span> button to move the selected item up or down in the list.
</ul>
<br>
<span style="color: darkblue"><span style="font-size: 16px; line-height: normal"><span style="font-weight: bold">Keyboard Shortcuts</span></span></span>
<br>
<ul>Insert -  Add a new Note
<br>
Delete -  Delete selected Note
<br>
Ctrl+Up -  Move selected Note up 1 position
<br>
Ctrl+Down -  Move selected Note down 1 position
<br>
</ul>
<br>
<span style="color: darkblue"><span style="font-size: 16px; line-height: normal"><span style="font-weight: bold">Additional Stuff</span></span></span>
<ul><li>Changes to the Note List will only be saved when the main <span style="color: brown"><span style="font-weight: bold">Save</span></span> button is pressed.
<br><br>
<li>To add a note to the bottom of the Note List, press the <span style="color: brown"><span style="font-weight: bold">Add</span></span> button <span style="text-decoration: underline">before</span> selecting any Note items or scroll to bottom of the list and click past the last item.  This will unselect all items.  Press the <span style="color: brown"><span style="font-weight: bold">Add</span></span> button and a new item will be added to the end of the list.</ul></div>
</div>
</body>
</html>
)
,NoteListEditorHelp.html

$URL=file:///%A_ScriptDir%\NoteListEditorHelp.html
$Options=
   (ltrim join,
    Title=Note List Editor Help
    HtmW=600
    HtmH=250
    qqButtons=OK/Cancel
    Buttons=
    qqBAlign=2
    qqDlgDisable=1
    qqDlgStyle=Frame
    BHeight=0
    BSpVertical=0
    DlgWait=1
    HtmFocus=1
   )

Sel :=HtmDlg($URL,$OptionsGUI_hWnd,$Options)
FileDelete NoteListEditorHelp.html
return



;**********************
;*                    *
;*     Save button    *
;*    (OptionsGUI)    *
;*                    *
;**********************
OptionsGUI_SaveButton:

;-- Attach any messages to the current GUI
gui +OwnDialogs

;-- Collect form variables
gui Submit,NoHide

;[============================]
;[  Check for reload changes  ]
;[============================]
if ($BR_DefaultTray<>$OptionsGUI_BR_DefaultTray
or  $BR_EnableHotkey<>$OptionsGUI_BR_EnableHotkey
or  $BR_Hotkey<>$OptionsGUI_BR_Hotkey
or  $RL_DefaultTray<>$OptionsGUI_RL_DefaultTray
or  $RL_EnableHotkey<>$OptionsGUI_RL_EnableHotkey
or  $RL_Hotkey<>$OptionsGUI_RL_Hotkey
or  $TTSVoice<>$OptionsGUI_TTSVoice
or  $TTSPriority<>$OptionsGUI_TTSPriority-1)
    $Reload:=True

;[====================]
;[  Program shortcut  ]
;[====================]
if A_IsCompiled
    {
    ;-- Create shortcut if it doesn't already exist
    if $OptionsGUI_StartProgramOnStartup
        {
        IfNotExist %A_StartUp%\%$ScriptName%.lnk
            FileCreateShortcut
                ,%A_ScriptFullPath%                             ;-- Target
                ,%A_StartUp%\%$ScriptName%.lnk                  ;-- LinkFile
                ,%A_WorkingDir%                                 ;-- WorkingDir
        }
     else
        {
        ;-- Remove shortcut if it exists
        IfExist %A_StartUp%\%$ScriptName%.lnk
            FileDelete %A_StartUp%\%$ScriptName%.lnk
        }
    }

;[===========================]
;[  Update global variables  ]
;[===========================]
;-----------
;-- General
;-----------
$PlayAlarmSound   :=$OptionsGUI_PlayAlarmSound
$PlayAlarmNagSound:=$OptionsGUI_PlayAlarmNagSound
$NagInterval      :=$OptionsGUI_NagInterval
if $NagInterval<10
    $NagInterval:=10

if $NagInterval>999
    $NagInterval:=999

;-----------
;-- Windows
;-----------
$BR_DefaultTray :=$OptionsGUI_BR_DefaultTray
$BR_EnableHotkey:=$OptionsGUI_BR_EnableHotkey
$BR_Hotkey      :=$OptionsGUI_BR_Hotkey

$RL_DefaultTray :=$OptionsGUI_RL_DefaultTray
$RL_EnableHotkey:=$OptionsGUI_RL_EnableHotkey
$RL_Hotkey      :=$OptionsGUI_RL_Hotkey

;---------
;-- Notes
;---------
;-- Unselect all.  Allow for final change (if anything) to be made
LV_Modify(0,"-Select")
Sleep 50


;-- Rebuild $NoteList
$NoteList:=""
Loop % LV_GetCount()
    {
    ;-- Get text
    LV_GetText($Text,A_Index,1)

    ;-- Drop if blank
    if $Text is Space
        Continue

    ;-- Add to the list
    if StrLen($NoteList)=0
        $NoteList:=$Text
     else
        $NoteList.=$GUIDelimiter . $Text
    }

;----------
;-- Snooze
;----------
;-- Clean up list
$SnoozeDDL:=CleanUpList($OptionsGUI_SnoozeDDL)

;-- Replace NL characters with $GUIDelimiter characters
StringReplace $SnoozeDDL,$SnoozeDDL,`n,%$GUIDelimiter%,All

;-------
;-- TTS
;-------
$SpeakOnAlarm:=$OptionsGUI_SpeakOnAlarm
$TTSVoice    :=$OptionsGUI_TTSVoice
$TTSPriority :=$OptionsGUI_TTSPriority-1

;[=====================]
;[  Prompt to reload?  ]
;[=====================]
if $Reload
    {
    MsgBox
        ,49  ;-- 49=1 (OK/Cancel) + 48 ("?" icon)
        ,Restart required,
           (ltrim join`s
            Some of the changes made require that the program be
            restarted.  Don't worry, all active reminders will be
            saved.   `n`nPress OK to proceed.  Press Cancel to restart
            later.  %A_Space%
           )

    IfMsgBox OK
        {
        ;-- Save changes
        gosub SaveConfiguration

        ;-- Reload script
        Reload
        return
        }
    }

;-- Shut down window
gosub OptionsGUI_Exit
return


;***********************
;*                     *
;*    Close up shop    *
;*    (OptionsGUI)     *
;*                     *
;***********************
OptionsGUI_Escape:
OptionsGUI_Close:
OptionsGUI_Exit:

;-- Save changes
gosub SaveConfiguration
    ;-- Note: The current configuration is saved regardless of whether changes
    ;   were made or not.  This is to insure that the the last tab position is
    ;   saved.

;-- Destroy window so that it can be used again
gui Destroy
return



;******************************
;*                            *
;*                            *
;*           Hotkeys          *
;*        (OptionsGUI)        *
;*                            *
;*                            *
;******************************
#IfWinActive ahk_group $OptionsGUI_Group

~Insert::
gui %$OptionsGUI%:Default

GUIControlGet $Control,FocusV
if $Control=$OptionsGUI_NoteList
    gosub OptionsGUI_NLE_Add

return


~Delete::
gui %$OptionsGUI%:Default

GUIControlGet $Control,FocusV
if $Control=$OptionsGUI_NoteList
    gosub OptionsGUI_NLE_Delete

return


^Up::
gui %$OptionsGUI%:Default

GUIControlGet $Control,FocusV
if $Control=$OptionsGUI_NoteList
    gosub OptionsGUI_NLE_MoveUp

return


^Down::
gui %$OptionsGUI%:Default

GUIControlGet $Control,FocusV
if $Control=$OptionsGUI_NoteList
    gosub OptionsGUI_NLE_MoveDown

return


~F2::
gui %$OptionsGUI%:Default

GUIControlGet $Control,FocusV
if $Control=$OptionsGUI_NoteList
    gosub OptionsGUI_NLE_Edit

return


#IfWinActive
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;----------------------------- End OptionsGUI Stuff ----------------------------
;-------------------------------------------------------------------------------

