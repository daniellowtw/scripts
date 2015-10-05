;*******************
;*                 *
;*    HotkeyGUI    *
;*                 *
;*******************
;
;   Description
;   ===========
;   This function displays a GUI window that will allow a user to enter/select a
;   hotkey without using the keyboard.  See the "Processing and Usage Notes"
;   section for more information.
;
;
;   Parameters
;   ==========
;
;       Name                Description
;       -----               -----------
;       p_Owner             The GUI owner of the HotkeyGUI window.  [Optional]
;                           The default is 0 (no owner).    If not defined, the
;                           AlwaysOnTop attribute is added to the HotkeyGUI
;                           window to make sure that the window is not lost.
;
;       p_Hotkey            The default hotkey value.  [Optional]  The default
;                           is blank.
;
;       p_Limit             Hotkey limit.  [Optional]  The default is 0.  See
;                           the "Hotkey Limit" section below for more
;                           information.
;
;       p_OptionalAttrib    Optional hotkey attributes.  [Optional].  The
;                           default is TRUE.
;
;                           If TRUE, all fields in the "Optional Attributes"
;                           group are enabled.  If FALSE, all of these fields
;                           are disabled.
;
;       p_Title             Window title.  [Optional]  The default is the
;                           current script name (sans the extention) plus
;                           " - Select Hotkey".
;
;
;   Processing and Usage Notes
;   ==========================
;    o  This function does not exit until the user closes the HotkeyGUI window.
;
;    o  This function uses the first GUI window that is available in the s_GUI
;       (usually 53) to 99 range. If an available window cannot be found, an
;       error message is displayed.
;
;    o  A shift-only key (Ex: ~!@#$%^&*()_+{}|:"<>?) cannot be directly selected
;       as a key by this function.  To use a shift-only key, select the Shift
;       modifier and then select the non-shift version of the key.  For example,
;       to set the "(" key as a hotkey, select the Shift modifier and then
;       select the "9" key.  The net result is the "(" key.
;
;       Shift-only keys are also not supported as values for the p_Hotkey
;       parameter as a default hotkey.  If a shift-only key is used, no default
;       key will be selected.
;
;   o   To resolve a minor AutoHotkey inconsistency, the "Pause" key and the
;       "Break" keys are automatically converted to the "CtrlBreak" key if the
;       Ctrl modifier is selected.  The "CtrlBreak" key is automatically
;       converted to the "Pause" key if the Ctrl modifier is not selected.
;
;
;   Hotkey Limits
;   =============
;   The p_Limit parameter allows the developer to restrict the types of keys
;   that are selected.  The following limit values are available:
;
;       Limit   Description
;       -----   -----------
;       1       Prevent unmodified keys
;       2       Prevent Shift-only keys
;       4       Prevent Ctrl-only keys
;       8       Prevent Alt-only keys
;       16      Prevent Win-only keys
;       32      Prevent Shift-Ctrl keys
;       64      Prevent Shift-Alt keys
;       128     Prevent Shift-Win keys
;       256     Prevent Shift-Ctrl-Alt keys
;       512     Prevent Shift-Ctrl-Win keys
;       1024    Prevent Shift-Win-Alt keys
;
;   To use a limit, enter the sum of one or more of these limit values.  For
;   example, a limit value of 1 will prevent unmodified keys from being used.
;   A limit value of 31 (1 + 2 + 4 + 8 + 16) will require that at least two
;   modifier keys be used.
;
;
;   Return Codes
;   ============
;   If the function ends after the user has selected a valid key and the
;   "Accept" button is clicked, the function returns the selected key in the
;   standard AutoHotkey hotkey format and ErrorLevel is set to 0.
;   Example: Hotkey=^a  ErrorLevel=0
;
;   If the HotkeyGUI window is canceled (Cancel button, Close button, or Escape
;   key), the function returns the original hotkey value (p_Hotkey) and
;   Errorlevel is set to 1.
;
;   If the function is unable to create a HotkeyGUI window for any reason,
;   ErrorLevel is set to the word FAIL.
;
;   Important: ErrorLevel is a system variable and is used by many commands.
;   If you are unable to test ErrorLevel immediate after calling this function,
;   assign the value to another variable so that the return value is retained.
;
;
;   Calls To Other Functions
;   ========================
;   PopupXY (optional)
;
;
;   Hotkey support
;   ==============
;   AutoHotkey is a very robust program and can accept hotkey definitions in an
;   multitude of formats.  Unfortuntely, this function is not that robust and
;   there are several important limitations to note:
;
;    *  The p_Limit parameter restricts the type of keys that can be supported.
;       For this reason, the following keys are not supported:
;
;        1. Modifier keys (as Hotkyes). Example: Alt, Shift, LWin, etc.
;        2. Joystick keys. Example: Joy1, Joy2, etc.
;        3. Custom combinations. Example: Numpad0 & Numpad1.
;
;    *  Shift-only keys (Ex: "~","!","@","#",etc.) are not supported.  See the
;       "Processing and Usage Notes" section for more information.
;
;
;   Programming Notes
;   =================
;   No global variables are used.  However, to get around the use of global
;   variables (especially when creating a GUI inside of a function), several
;   changes were made:
;
;    *  To keep the code as friendly as possible, static variables (in lieu of
;       global variables) are used whenever a GUI object needs a variable.
;       Object variables are defined so that a single "gui Submit" command can
;       be used to collect the GUI values instead of having to execute a
;       "GUIControlGet" command on every GUI control.
;
;    *  For the few GUI objects that are programmatically updated, the ClassNN
;       (class name and instance number of the object  Ex: Static4) is used.
;
;   Important: Any changes to the GUI (additions, deletions, etc.) may change
;   the ClassNN of objects that are updated.  Use Window Spy (or similar
;   program) to identify any changes.
;
;-------------------------------------------------------------------------------
HotkeyGUI(p_Owner=""
         ,p_Hotkey=""
         ,p_Limit=""
         ,p_OptionalAttrib=""
         ,p_Title="")
    {
    ;[====================]
    ;[  Static variables  ]
    ;[====================]
    Static s_GUI:=0
                ;-- This variable stores the currently active GUI.  If not zero
                ;   when entering the function, the GUI is currently showing.

          ,s_StartGUI:=53
                ;-- Default starting GUI window number for HotkeyGUI window.
                ;   Change if desired.

          ,s_PopupXY_Function:="PopupXY"
                ;-- Name of the PopupXY function.  Defined as a variable so that
                ;   function will use if the "PopupXY" function is included but
                ;   will not fail if it's not.

    ;[===========================]
    ;[  Window already showing?  ]
    ;[===========================]
    if s_GUI
        {
        Errorlevel=FAIL
        outputdebug,
           (ltrim join`s
            End Func: %A_ThisFunc% -
            A %A_ThisFunc% window already exists.  Errorlevel=FAIL
           )

        Return
        }

    ;[==============]
    ;[  Initialize  ]
    ;[==============]
    SplitPath A_ScriptName,,,,l_ScriptName
    l_GUIDelimiter:=Chr(131)
    l_ErrorLevel:=0

    ;-------------
    ;-- Key lists
    ;-------------
    ;-- Standard keys
    l_StandardKeysList=
       (ltrim joinÉ
        AÉBÉCÉDÉEÉFÉGÉHÉIÉJÉKÉLÉMÉNÉOÉPÉQÉRÉSÉTÉUÉVÉWÉXÉYÉZ
        0É1É2É3É4É5É6É7É8É9É0
        ``É-É=É[É]É`\É;
        'É,É.É/
        Space
        Tab
        Enter
        Escape
        Backspace
        Delete
        ScrollLock
        CapsLock
        NumLock
        PrintScreen
        CtrlBreak
        Pause
        Break
        Insert
        Home
        End
        PgUp
        PgDn
        Up
        Down
        Left
        Right
       )

    ;-- Function keys
    l_FunctionKeysList=
       (ltrim joinÉ
        F1
        F2
        F3
        F4
        F5
        F6
        F7
        F8
        F9
        F10
        F11
        F12
        F13
        F14
        F15
        F16
        F17
        F18
        F19
        F20
        F21
        F22
        F23
        F24
       )

    ;-- Numpad
    l_NumpadKeysList=
       (ltrim joinÉ
        NumLock
        NumpadDiv
        NumpadMult
        NumpadAdd
        NumpadSub
        NumpadEnter
        NumpadDel
        NumpadIns
        NumpadClear
        NumpadUp
        NumpadDown
        NumpadLeft
        NumpadRight
        NumpadHome
        NumpadEnd
        NumpadPgUp
        NumpadPgDn
        Numpad0
        Numpad1
        Numpad2
        Numpad3
        Numpad4
        Numpad5
        Numpad6
        Numpad7
        Numpad8
        Numpad9
        NumpadDot
       )

    ;-- Mouse
    l_MouseKeysList=
       (ltrim joinÉ
        LButton
        RButton
        MButton
        WheelDown
        WheelUp
        XButton1
        XButton2
       )

    ;-- Multimedia
    l_MultimediaKeysList=
       (ltrim joinÉ
        Browser_Back
        Browser_Forward
        Browser_Refresh
        Browser_Stop
        Browser_Search
        Browser_Favorites
        Browser_Home
        Volume_Mute
        Volume_Down
        Volume_Up
        Media_Next
        Media_Prev
        Media_Stop
        Media_Play_Pause
        Launch_Mail
        Launch_Media
        Launch_App1
        Launch_App2
       )

    ;-- Special
    l_SpecialKeysList=HelpÉSleep

    ;[==================]
    ;[    Parameters    ]
    ;[  (Set defaults)  ]
    ;[==================]
    ;-- Owner
    p_Owner=%p_Owner%  ;-- AutoTrim
    if p_Owner is not Integer
        p_Owner:=0
     else
        if p_Owner not between 1 and 99
            p_Owner:=0

    ;-- Owner window exist?
    if p_Owner
        {
        gui %p_Owner%:+LastFoundExist
        IfWinNotExist
            {
            outputdebug,
               (ltrim join`s
                Function: %A_ThisFunc% -
                Owner window does not exist.  p_Owner=%p_Owner%
               )

            p_Owner:=0
            }
        }

    ;-- Default hotkey
    l_Hotkey=%p_Hotkey%  ;-- AutoTrim

    ;-- Limit
    p_Limit=%p_Limit%  ;-- AutoTrim
    if p_Limit is not Integer
        p_Limit:=0
     else
        if p_Limit not between 0 and 2047
            p_Limit:=0

    ;-- OptionalAttrib
    p_OptionalAttrib=%p_OptionalAttrib%  ;-- AutoTrim
    if p_OptionalAttrib not in %True%,%False%
        p_OptionalAttrib:=True

    ;-- Title
    p_Title=%p_Title%  ;-- AutoTrim
    if p_Title is Space
        p_Title:=l_ScriptName . " - Select Hotkey"
     else
        {
        ;-- Append to script name if p_title begins with "++"?
        if SubStr(p_Title,1,2)="++"
            {
            StringTrimLeft p_Title,p_Title,2
            p_Title:=l_ScriptName . A_Space . p_Title
            }
        }

    ;[==============================]
    ;[     Find available window    ]
    ;[  (Starting with s_StartGUI)  ]
    ;[==============================]
    s_GUI:=s_StartGUI
    Loop
        {
        ;-- Window available?
        gui %s_GUI%:+LastFoundExist
        IfWinNotExist
            Break

        ;-- Nothing available?
        if s_GUI=99
            {
            MsgBox
                ,262160
                    ;-- 262160=0 (OK button) + 16 (Error icon) + 262144 (AOT)
                ,%A_ThisFunc% Error,
                   (ltrim join`s
                    Unable to create a %A_ThisFunc% window.  GUI windows
                    %s_StartGUI% to 99 are already in use.  %A_Space%
                   )

            s_GUI:=0
            ErrorLevel:="FAIL"
            Return
            }

        ;-- Increment window
        s_GUI++
        }

    ;[=============]
    ;[  Build GUI  ]
    ;[=============]
    ;-- Assign ownership
    if p_Owner
        {
        gui %p_Owner%:+Disabled      ;-- Disable Owner window
        gui %s_GUI%:+Owner%p_Owner%  ;-- Set ownership
        }
     else
        gui %s_GUI%:+Owner           ;-- Gives ownership to the script window

    ;-- GUI options
    gui %s_GUI%:Margin,6,6
;;;;;    gui %s_GUI%:Font,s12  ;--------------------- ##### For testing purposes only
    gui %s_GUI%:-MinimizeBox
     || +LabelHotkeyGUI_
     || +Delimiter%l_GUIDelimiter%

    if not p_Owner
        gui %s_GUI%:+AlwaysOnTop

    ;---------------
    ;-- GUI objects
    ;---------------
    ;-- Modifiers
    gui %s_GUI%:Add
       ,GroupBox
       ,xm y10 w160 h140
       ,Modifier

    Static HG_CtrlModifier
    gui %s_GUI%:Add
       ,CheckBox
       ,xp+10 yp+20
            || Section
            || vHG_CtrlModifier
            || gHotkeyGUI_UpdateHotkey
       ,Ctrl

    Static HG_ShiftModifier
    gui %s_GUI%:Add
       ,CheckBox
       ,xs
            || vHG_ShiftModifier
            || gHotkeyGUI_UpdateHotkey
       ,Shift

    Static HG_WinModifier
    gui %s_GUI%:Add
       ,CheckBox
       ,xs
            || vHG_WinModifier
            || gHotkeyGUI_UpdateHotkey
       ,Win

    Static HG_AltModifier
    gui %s_GUI%:Add
       ,CheckBox
       ,xs
            || vHG_AltModifier
            || gHotkeyGUI_UpdateHotkey
       ,Alt

    ;-- Optional Attributes
    gui %s_GUI%:Add
       ,GroupBox
       ,xs+150 y10 w160 h140
       ,Optional Attributes

    Static HG_NativeOption
    gui %s_GUI%:Add                                                 ;-- Button7
       ,CheckBox
       ,xp+10 yp+20
            || Disabled
            || Section
            || vHG_NativeOption
            || gHotkeyGUI_UpdateHotkey
       ,~ (Native)

    Static HG_WildcardOption
    gui %s_GUI%:Add                                                 ;-- Button8
       ,CheckBox
       ,xs
            || Disabled
            || vHG_WildcardOption
            || gHotkeyGUI_UpdateHotkey
       ,*  (Wildcard)

    Static HG_LeftPairOption
    gui %s_GUI%:Add                                                 ;-- Button9
       ,CheckBox
       ,xs
            || Disabled
            || vHG_LeftPairOption
            || gHotkeyGUI_LeftPair
       ,< (Left pair only)

    Static HG_RightPairOption
    gui %s_GUI%:Add                                                 ;-- Button10
       ,CheckBox
       ,xs
            || Disabled
            || vHG_RightPairOption
            || gHotkeyGUI_RightPair
       ,> (Right pair only)

    ;-- Enable "Optional Attributes"?
    if p_OptionalAttrib
        {
        GUIControl %s_GUI%:Enable,HG_NativeOption
        GUIControl %s_GUI%:Enable,HG_WildcardOption
        GUIControl %s_GUI%:Enable,HG_LeftPairOption
        GUIControl %s_GUI%:Enable,HG_RightPairOption
        }

    ;-- Keys
    gui %s_GUI%:Add
       ,GroupBox
       ,xm y150 w320 h180
       ,Keys

    Static HG_StandardKeysView
    gui %s_GUI%:Add
       ,Radio
       ,xp+10 yp+20
            || Checked
            || Section
            || vHG_StandardKeysView
            || gHotkeyGUI_UpdateKeyList
       ,Standard

    Static HG_FunctionKeysView
    gui %s_GUI%:Add
       ,Radio
       ,xs
            || vHG_FunctionKeysView
            || gHotkeyGUI_UpdateKeyList
       ,Function keys

    Static HG_NumpadKeysView
    gui %s_GUI%:Add
       ,Radio
       ,xs
            || vHG_NumpadKeysView
            || gHotkeyGUI_UpdateKeyList
       ,Numpad

    Static HG_MouseKeysView
    gui %s_GUI%:Add
       ,Radio
       ,xs
            || vHG_MouseKeysView
            || gHotkeyGUI_UpdateKeyList
       ,Mouse

    Static HG_MultimediaKeysView
    gui %s_GUI%:Add
       ,Radio
       ,xs
            || vHG_MultimediaKeysView
            || gHotkeyGUI_UpdateKeyList
       ,Multimedia

    Static HG_SpecialKeysView
    gui %s_GUI%:Add
       ,Radio
       ,xs
            || vHG_SpecialKeysView
            || gHotkeyGUI_UpdateKeyList
       ,Special

    Static HG_Key
    gui %s_GUI%:Add
       ,ListBox                                                     ;-- ListBox1
       ,xs+130 ys w170 h150
            || vHG_Key
            || gHotkeyGUI_UpdateHotkey

    ;-- Set initial values
    gosub HotkeyGUI_UpdateKeyList

    ;-- Hotkey display
    gui %s_GUI%:Add
       ,Text
       ,xm y340 w60
       ,Hotkey:

    gui %s_GUI%:Add
       ,Edit                                                        ;-- Edit1
       ,x+0 w260
            || +ReadOnly

    gui %s_GUI%:Add
       ,Text
       ,xm y+5 w60 hp
       ,Desc:

    gui %s_GUI%:Add
       ,Text                                                        ;-- Static3
       ,x+0 w260 hp
            || +ReadOnly
       ,None

    ;-- Buttons
    Static HG_AcceptButton
    gui %s_GUI%:Add                                                 ;-- Button18
       ,Button
       ,xm y+10 w80
            || Default
            || Disabled
            || vHG_AcceptButton
            || gHotkeyGUI_AcceptButton
       ,&Accept

    gui %s_GUI%:Add
       ,Button
       ,x+5 wp hp
            || gHotkeyGUI_Close
       ,Cancel

    ;[======================]
    ;[  Set default hotkey  ]
    ;[======================]
    ;-- Modifiers and optional attributes
    Loop
        {
        ;-- Ctrl
        if SubStr(l_Hotkey,1,1)="^"
            {
            GUIControl %s_GUI%:,HG_CtrlModifier,1
            StringTrimLeft l_Hotkey,l_Hotkey,1
            Continue
            }
        ;-- Shift
        if SubStr(l_Hotkey,1,1)="+"
            {
            GUIControl %s_GUI%:,HG_ShiftModifier,1
            StringTrimLeft l_Hotkey,l_Hotkey,1
            Continue
            }

        ;-- Win
        if SubStr(l_Hotkey,1,1)="#"
            {
            GUIControl %s_GUI%:,HG_WinModifier,1
            StringTrimLeft l_Hotkey,l_Hotkey,1
            Continue
            }

        ;-- Alt
        if SubStr(l_Hotkey,1,1)="!"
            {
            GUIControl %s_GUI%:,HG_AltModifier,1
            StringTrimLeft l_Hotkey,l_Hotkey,1
            Continue
            }

        ;-- Native
        if SubStr(l_Hotkey,1,1)="~"
            {
            GUIControl %s_GUI%:,HG_NativeOption,1
            StringTrimLeft l_Hotkey,l_Hotkey,1
            Continue
            }

        ;-- Wildcard
        if SubStr(l_Hotkey,1,1)="*"
            {
            GUIControl %s_GUI%:,HG_WildcardOption,1
            StringTrimLeft l_Hotkey,l_Hotkey,1
            Continue
            }

        ;-- Left pair only
        if SubStr(l_Hotkey,1,1)="<"
            {
            GUIControl %s_GUI%:,HG_LeftPairOption,1
            StringTrimLeft l_Hotkey,l_Hotkey,1
            Continue
            }

        ;-- Right pair only
        if SubStr(l_Hotkey,1,1)=">"
            {
            GUIControl %s_GUI%:,HG_RightPairOption,1
            StringTrimLeft l_Hotkey,l_Hotkey,1
            Continue
            }

        Break
        }

    ;-------------------------
    ;-- Find key in key lists
    ;-------------------------
    if l_Hotkey is not Space
        {
        ;-- Standard keys
        if Instr(l_GUIDelimiter . l_StandardKeysList . l_GUIDelimiter
                ,l_GUIDelimiter . l_Hotkey . l_GUIDelimiter)
            GUIControl %s_GUI%:,HG_StandardKeysView,1

        ;-- Function keys
        if Instr(l_GUIDelimiter . l_FunctionKeysList . l_GUIDelimiter
                ,l_GUIDelimiter . l_Hotkey . l_GUIDelimiter)
            GUIControl %s_GUI%:,HG_FunctionKeysView,1

        ;-- Numpad keys
        if Instr(l_GUIDelimiter . l_NumpadKeysList . l_GUIDelimiter
                ,l_GUIDelimiter . l_Hotkey . l_GUIDelimiter)
            GUIControl %s_GUI%:,HG_NumpadKeysView,1

        ;-- Mouse keys
        if Instr(l_GUIDelimiter . l_MouseKeysList . l_GUIDelimiter
                ,l_GUIDelimiter . l_Hotkey . l_GUIDelimiter)
            GUIControl %s_GUI%:,HG_MouseKeysView,1

        ;-- Multimedia keys
        if Instr(l_GUIDelimiter . l_MultimediaKeysList . l_GUIDelimiter
                ,l_GUIDelimiter . l_Hotkey . l_GUIDelimiter)
            GUIControl %s_GUI%:,HG_MultimediaKeysView,1

        ;-- Special keys
        if Instr(l_GUIDelimiter . l_SpecialKeysList . l_GUIDelimiter
                ,l_GUIDelimiter . l_Hotkey . l_GUIDelimiter)
            GUIControl %s_GUI%:,HG_SpecialKeysView,1

        ;-- Update keylist and select it
        gosub HotkeyGUI_UpdateKeyList
        GUIControl %s_GUI%:ChooseString,HG_Key,%l_Hotkey%
        gosub HotkeyGUI_UpdateHotkey
        }

    ;[================]
    ;[  Collect hWnd  ]
    ;[================]
    gui %s_GUI%:+LastFound
    WinGet l_HotkeyGUI_hWnd,ID

    ;[===============]
    ;[  Show window  ]
    ;[===============]
     if p_Owner and IsFunc(s_PopupXY_Function)
        {
        gui %s_GUI%:Show,Hide,%p_Title%   ;-- Render but don't show
        %s_PopupXY_Function%(p_Owner,"ahk_id " . l_HotkeyGUI_hWnd,PosX,PosY)
        gui %s_GUI%:Show,x%PosX% y%PosY%  ;-- Show in the correct location
        }
     else
        gui %s_GUI%:Show,,%p_Title%

    ;[=====================]
    ;[  Loop until window  ]
    ;[      is closed      ]
    ;[=====================]
    WinWaitClose ahk_id %l_HotkeyGUI_hWnd%

    ;[====================]
    ;[  Return to sender  ]
    ;[====================]
    ErrorLevel:=l_ErrorLevel
    Return HG_HotKey  ;-- End of function



    ;*****************************
    ;*                           *
    ;*                           *
    ;*        Subroutines        *
    ;*        (HotkeyGUI)        *
    ;*                           *
    ;*                           *
    ;*****************************
    ;***********************
    ;*                     *
    ;*    Update Hotkey    *
    ;*                     *
    ;***********************
    HotkeyGUI_UpdateHotkey:

    ;-- Attach any messages to the GUI
    gui %s_GUI%:+OwnDialogs


    ;-- Collect form values
    gui %s_GUI%:Submit,NoHide

    ;-- Enable/Disable Accept button
    if HG_Key
        GUIControl %s_GUI%:Enable,Button18
     else
        GUIControl %s_GUI%:Disable,Button18

    ;-- Substitute Pause|Break for CtrlBreak?
    if HG_Key in Pause,Break
        if HG_CtrlModifier
            HG_Key=CtrlBreak

    ;-- Substitute CtrlBreak for Pause (Break would work OK too)
    if HG_Key=CtrlBreak
        if not HG_CtrlModifier
            HG_Key=Pause

    ;[================]
    ;[  Build Hotkey  ]
    ;[================]
    ;-- Initialize
    HG_Hotkey=
    HG_HKDesc=

    ;-- Options
    if HG_NativeOption
        HG_Hotkey.="~"

    if HG_WildcardOption
        HG_Hotkey.="*"

    if HG_LeftPairOption
        HG_Hotkey.="<"

    if HG_RightPairOption
        HG_Hotkey.=">"

    ;-- Modifiers
    if HG_CtrlModifier
        {
        HG_Hotkey.="^"
        HG_HKDesc.="Ctrl + "
        }

    if HG_ShiftModifier
        {
        HG_Hotkey.="+"
        HG_HKDesc.="Shift + "
        }

    if HG_WinModifier
        {
        HG_Hotkey.="#"
        HG_HKDesc.="Win + "
        }

    if HG_AltModifier
        {
        HG_Hotkey.="!"
        HG_HKDesc.="Alt + "
        }

    HG_Hotkey.=HG_Key
    HG_HKDesc.=HG_Key

    ;-- Update Hotkey and HKDescr fields
    GUIControl %s_GUI%:,Edit1,%HG_Hotkey%
    GUIControl %s_GUI%:,Static3,%HG_HKDesc%
    return


    ;**********************
    ;*                    *
    ;*    Pair options    *
    ;*                    *
    ;**********************
    HotkeyGUI_LeftPair:

    ;-- Deselect HG_RightPairOption
    GUIControl %s_GUI%:,Button10,0
    gosub HotkeyGUI_UpdateHotkey
    return


    HotkeyGUI_RightPair:

    ;-- Deselect HG_LeftPairOption
    GUIControl %s_GUI%:,Button9,0
    gosub HotkeyGUI_UpdateHotkey
    return


    ;*************************
    ;*                       *
    ;*    Update Key List    *
    ;*                       *
    ;*************************
    HotkeyGUI_UpdateKeyList:

    ;-- Collect form values
    gui %s_GUI%:Submit,NoHide

    ;-- Standard
    if HG_StandardKeysView
        l_KeysList:=l_StandardKeysList
     else
        ;-- Function keys
        if HG_FunctionKeysView
            l_KeysList:=l_FunctionKeysList
         else
            ;-- Numpad
            if HG_NumpadKeysView
                l_KeysList:=l_NumpadKeysList
             else
                ;-- Mouse
                if HG_MouseKeysView
                    l_KeysList:=l_MouseKeysList
                 else
                    ;-- Multimedia
                    if HG_MultimediaKeysView
                        l_KeysList:=l_MultimediaKeysList
                     else
                        ;-- Special
                        if HG_SpecialKeysView
                            l_KeysList:=l_SpecialKeysList

    ;-- Update l_KeysList
    GUIControl %s_GUI%:-Redraw,ListBox1
    GUIControl %s_GUI%:,ListBox1,%l_GUIDelimiter%%l_KeysList%
    GUIControl %s_GUI%:+Redraw,ListBox1

    ;--- Reset HG_Hotkey and HG_HKDesc
    HG_Key=
    gosub HotkeyGUI_UpdateHotkey
    return


    ;***********************
    ;*                     *
    ;*    Accept Button    *
    ;*                     *
    ;***********************
    HotkeyGUI_AcceptButton:

    ;-- Attach any messages to the GUI
    gui %s_GUI%:+OwnDialogs

    ;-- (The following test is now redundant but it is retained as a failsafe)
    ;-- Any key?
    if HG_Key is Space
        {
        MsgBox
            ,16         ;-- Error icon
            ,%p_Title%
            ,A key must be selected.  %A_Space%

        return
        }

    ;[===============]
    ;[  Limit tests  ]
    ;[===============]
    l_Limit:=p_Limit
    l_LimitFailure:=False

    ;-- Loop until failure or until all tests have been performed
    Loop
        {
        ;-- Are we done here?
        if l_limit<=0
            Break

        ;-----------------
        ;-- Shift+Win+Alt
        ;-----------------
        if l_limit>=1024
            {
            if (HG_ShiftModifier and HG_WinModifier and HG_AltModifier)
                {
                l_Message=SHIFT+WIN+ALT keys are not allowed.
                l_LimitFailure:=True
                Break
                }

            l_limit:=l_limit-1024
            Continue
            }

        ;------------------
        ;-- Shift+Ctrl+Win
        ;------------------
        if l_limit>=512
            {
            if (HG_ShiftModifier and HG_CtrlModifier and HG_WinModifier)
                {
                l_Message=SHIFT+CTRL+WIN keys are not allowed.
                l_LimitFailure:=True
                Break
                }

            l_limit:=l_limit-512
            Continue
            }

        ;------------------
        ;-- Shift+Ctrl+Alt
        ;------------------
        if l_limit>=256
            {
            if (HG_ShiftModifier and HG_CtrlModifier and HG_AltModifier)
                {
                l_Message=SHIFT+CTRL+ALT keys are not allowed.
                l_LimitFailure:=True
                Break
                }

            l_limit:=l_limit-256
            Continue
            }

        ;-------------
        ;-- Shift+Win
        ;-------------
        if l_limit>=128
            {
            if (HG_ShiftModifier and HG_WinModifier)
                {
                l_Message=SHIFT+WIN keys are not allowed.
                l_LimitFailure:=True
                Break
                }

            l_limit:=l_limit-128
            Continue
            }

        ;-------------
        ;-- Shift+Alt
        ;-------------
        if l_limit>=64
            {
            if (HG_ShiftModifier and HG_AltModifier)
                {
                l_Message=SHIFT+ALT keys are not allowed.
                l_LimitFailure:=True
                Break
                }

            l_limit:=l_limit-64
            Continue
            }

        ;--------------
        ;-- Shift+Ctrl
        ;--------------
        if l_limit>=32
            {
            if (HG_ShiftModifier and HG_CtrlModifier)
                {
                l_Message=SHIFT+CTRL keys are not allowed.
                l_LimitFailure:=True
                Break
                }

            l_limit:=l_limit-32
            Continue
            }

        ;------------
        ;-- Win only
        ;------------
        if l_limit>=16
            {
            if (HG_WinModifier
            and not (HG_CtrlModifier or HG_ShiftModifier or HG_AltModifier))
                {
                l_Message=WIN-only keys are not allowed.
                l_LimitFailure:=True
                Break
                }

            l_limit:=l_limit-16
            Continue
            }

        ;------------
        ;-- Alt only
        ;------------
        if l_limit>=8
            {
            if (HG_AltModifier
            and not (HG_CtrlModifier or HG_ShiftModifier or HG_WinModifier))
                {
                l_Message=ALT-only keys are not allowed.
                l_LimitFailure:=True
                Break
                }

            l_limit:=l_limit-8
            Continue
            }

        ;-------------
        ;-- Ctrl only
        ;-------------
        if l_limit>=4
            {
            if (HG_CtrlModifier
            and not (HG_ShiftModifier or HG_WinModifier or HG_AltModifier))
                {
                l_Message=CTRL-only keys are not allowed.
                l_LimitFailure:=True
                Break
                }

            l_limit:=l_limit-4
            Continue
            }

        ;--------------
        ;-- Shift only
        ;--------------
        if l_limit>=2
            {
            if (HG_ShiftModifier
            and not (HG_CtrlModifier or HG_WinModifier or HG_AltModifier))
                {
                l_Message=SHIFT-only keys are not allowed.
                l_LimitFailure:=True
                Break
                }

            l_limit:=l_limit-2
            Continue
            }

        ;--------------
        ;-- Unmodified
        ;--------------
        if l_limit>=1
            {
            if not (HG_CtrlModifier
                or  HG_ShiftModifier
                or  HG_WinModifier
                or  HG_AltModifier)
                {
                l_Message=
                   (ltrim join`s
                    At least one modifier must be used.  Other restrictions
                    may apply.
                   )

                l_LimitFailure:=True
                Break
                }

            l_limit:=l_limit-1
            Continue
            }
        }

    ;[====================]
    ;[  Display message?  ]
    ;[====================]
    if l_LimitFailure
        {
        ;-- Display message
        MsgBox
            ,16         ;-- Error icon
            ,%p_Title%
            ,%l_Message%  %A_Space%

        ;-- Send 'em back
        return
        }

    ;[==================]
    ;[  Ok, We're done  ]
    ;[   Shut it done   ]
    ;[==================]
    gosub HotkeyGUI_Exit
    return


    ;***********************
    ;*                     *
    ;*    Close up shop    *
    ;*                     *
    ;***********************
    HotkeyGUI_Escape:
    HotkeyGUI_Close:
    HG_Hotkey:=p_Hotkey
    l_ErrorLevel:=1


    HotkeyGUI_Exit:

    ;-- Enable Owner window
    if p_Owner
        gui %p_Owner%:-Disabled

    ;-- Destroy the HotkeyGUI window so that the window can be reused
    gui %s_GUI%:Destroy
    s_GUI:=0

    return  ;-- End of subroutines
    }
