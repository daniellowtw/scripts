; Function: DisableCloseButton
; Author: Skan
; Source: http://www.autohotkey.com/forum/viewtopic.php?p=62506#62506
;
;
; Synopsis
; --------
; This function is used disable the Close button on the title bar and remove
; the "Close" menu item from SysMenu.
;
; Important: This function does not disable the ALT+F4 option.  The user can
; use ALT+F4 to close the window/hide the window unless additional restrictions
; have been employed.
;
;-------------------------------------------------------------------------------
DisableCloseButton(hWnd="") { 
 If hWnd= 
    hWnd:=WinExist("A") 
 hSysMenu:=DllCall("GetSystemMenu","Int",hWnd,"Int",FALSE) 
 nCnt:=DllCall("GetMenuItemCount","Int",hSysMenu) 
 DllCall("RemoveMenu","Int",hSysMenu,"UInt",nCnt-1,"Uint","0x400") 
 DllCall("RemoveMenu","Int",hSysMenu,"UInt",nCnt-2,"Uint","0x400") 
 DllCall("DrawMenuBar","Int",hWnd) 
Return "" 
}
