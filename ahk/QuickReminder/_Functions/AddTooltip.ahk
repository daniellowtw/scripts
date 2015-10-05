;-- Author: Superfraggle
;-- Post:   http://www.autohotkey.com/forum/viewtopic.php?t=30300
;-- Additional documentation and constants added by jballi

AddTooltip(p_ControlhWnd,p_Text,p_Modify=False)
    {
    Static  TThwnd
           ,GUIhWnd
           ,TTM_ADDTOOLA:=0x404
                ;-- Used to add a tool and assign it to a control
            
           ,TTM_UPDATETIPTEXTA:=0x40C
                ;-- Used to adjust the text of a tip.

           ,TTM_SETMAXTIPWIDTH:=0x418
                ;-- Allows the use of multiline tooltips.

            ;-- Documentation for Tooltip Styles can be found here:
            ;     http://msdn.microsoft.com/en-us/library/bb760248(VS.85).aspx

           ,TTS_ALWAYSTIP:=0x1
                ;-- Indicates that the ToolTip control appears when the cursor
                ;   is on a tool, even if the ToolTip control's owner window is
                ;   inactive. Without this style, the ToolTip appears only when
                ;   the tool's owner window is active.

           ,TTS_NOPREFIX:=0x2
                ;-- Prevents the system from stripping ampersand characters from
                ;   a string or terminating a string at a tab character. Without
                ;   this style, the system automatically strips ampersand
                ;   characters and terminates a string at the first tab
                ;   character. This allows an application to use the same string
                ;   as both a menu item and as text in a ToolTip control.

           ,TTS_NOANIMATE:=0x10
                ;-- Version 5.80. Disables sliding tooltip animation on
                ;   Microsoft Windows 98 and Windows 2000 systems. This style is
                ;   ignored on earlier systems.
        
           ,TTS_NOFADE:=0x20
                ;-- Version 5.80. Disables fading tooltip animation on Windows
                ;   2000 systems. This style is ignored on earlier Microsoft
                ;   Windows NT systems, and on Windows 95 and Windows 98.

           ,TTS_BALLOON:=0x40
                ;-- Version 5.80. Indicates that the ToolTip control has the
                ;   appearance of a cartoon "balloon," with rounded corners and
                ;   a stem pointing to the item.
                ;
                ;   Observation: This style does not work well here.  The 
                ;   Tooltip sometimes appears to be jumpy because the window is
                ;   often hidden and redrawn after it is initially displayed.

           ,TTS_CLOSE:=0x80
                ;-- Displays a Close button on the tooltip. Valid only when the
                ;   tooltip has the TTS_BALLOON style and a title; see
                ;   TTM_SETTITLE.

    if (!TThwnd)
        {
        gui +LastFound
        GUIhWnd:=WinExist()
        TThwnd:=DllCall("CreateWindowEx"       
            ,"Uint",0                           ;-- dwExStyle
            ,"Str","TOOLTIPS_CLASS32"           ;-- lpClassName
            ,"Uint",0                           ;-- lpWindowName
            ,"Uint",TTS_ALWAYSTIP|TTS_NOPREFIX  ;-- dwStyle
            ,"Uint",0                           ;-- x
            ,"Uint",0                           ;-- y
            ,"Uint",0                           ;-- nWidth
            ,"Uint",0                           ;-- nHeight
            ,"Uint",GUIhWnd                     ;-- hWndParent
            ,"Uint",0                           ;-- hMenu
            ,"Uint",0                           ;-- hInstance
            ,"Uint",0)                          ;-- lpParam 

        }

    Varsetcapacity(TOOLINFO,44,0)
    Numput(44,TOOLINFO)
        ;-- cbSize.  Unsigned integer that specifies the size of this structure,
        ;   in bytes. You must specify a value for this member.


    Numput(1|16,TOOLINFO,4)
        ;-- uFlags.  Unsigned integer that specifies values that control the
        ;   display of the ToolTip. The following table shows the possible
        ;   values, which can be combined.
        ;
        ;       Value
        ;       -----
        ;           Description
        ;           -----------
        ;       TTF_ABSOLUTE:=0x80 (128)
        ;           Positions the ToolTip window at the same coordinates as
        ;           provided by TTM_TRACKPOSITION. You must use this flag with
        ;           the TTF_TRACK flag.
        ;
        ;       TTF_CENTERTIP:=0x2 (2)
        ;           Centers the ToolTip window below the tool specified by the
        ;           uId member.
        ;
        ;       TTF_IDISHWND:=0x1 (1)
        ;           Indicates that the uId member is the window handle to the
        ;           tool. If this flag is not set, uId is the identifier of the
        ;           tool.
        ;
        ;       TTF_SUBCLASS:=0x10 (16)
        ;           Indicates that the ToolTip control should subclass the
        ;           window for the tool in order to intercept messages, such
        ;           as WM_MOUSEMOVE. If you do not set this flag, you must use
        ;           the TTM_RELAYEVENT message to forward messages to the
        ;           ToolTip control. For a list of messages that a ToolTip
        ;           control processes, see TTM_RELAYEVENT.
        ;
        ;       TTF_TRACK:=0x20 (32)
        ;           Positions the ToolTip window next to the tool to which it
        ;           corresponds and moves the window according to coordinates
        ;           supplied by the TTM_TRACKPOSITION messages. You must
        ;           activate this type of tool using the TTM_TRACKACTIVATE
        ;           message.
        ;
        ;       TTF_TRANSPARENT:=0x100 (256)
        ;           Causes the ToolTip control to forward mouse event messages
        ;           to the parent window. This forwarding is limited to mouse
        ;           events that occur within the bounds of the ToolTip window.

    Numput(GUIhWnd,TOOLINFO,8)
        ;-- hWnd.  Handle to the window that contains the tool. If lpszText
        ;   includes the LPSTR_TEXTCALLBACK value, hwnd identifies the window
        ;   that receives the TTN_GETDISPINFO messages.

    Numput(p_ControlhWnd,TOOLINFO,12)
        ;-- uId.  Unsigned integer that specifies an application-defined
        ;   identifier of the tool. If uFlags includes the TTF_IDISHWND flag,
        ;   uId must specify the window handle to the tool.

    Numput(&p_Text,TOOLINFO,36)
        ;-- rect.  RECT structure that specifies the coordinates of the
        ;   bounding rectangle for the tool. The coordinates are relative to the
        ;   upper-left corner of the client area of the window identified by
        ;   hwnd. If uFlags includes the TTF_IDISHWND flag, the value of rect is
        ;   ignored.

    l_DetectHiddenWindows:=A_DetectHiddenWindows
    DetectHiddenWindows On

    if p_Modify
        SendMessage TTM_UPDATETIPTEXTA,0,&TOOLINFO,,ahk_id %TThwnd% 
     else 
        {
        SendMessage TTM_ADDTOOLA,0,&TOOLINFO,,ahk_id %TThwnd%
        SendMessage TTM_SETMAXTIPWIDTH,0,300,,ahk_id %TThwnd%  
        }

    DetectHiddenWindows %l_DetectHiddenWindows%
    }
