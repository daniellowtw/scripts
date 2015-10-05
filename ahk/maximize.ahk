/*
 * BoD winsupermaximize v1.01.
 *
 * This program and its source are in the public domain.
 * Contact BoD@JRAF.org for more information.
 *
 * Version history:
 * 2008-05-12: v1.01
 * 2008-05-10: v1.00
 */

#SingleInstance ignore

/*
 * Tray menu.
 */
Menu, tray, NoStandard
Menu, tray, Add, Super maximize window, menuSuperMaximize
Menu, tray, Add, About..., menuAbout
Menu, tray, Add, Exit, menuExit
Menu, tray, Default, Super maximize window

/*
 * Bind to Win-F11.
 */
#F11::superMaximize()


menuAbout:
    MsgBox, 8256, About, BoD winsupermaximize v1.01.`n`nThis program and its source are in the public domain.`nContact BoD@JRAF.org for more information.
return

menuExit:
    ExitApp
return

menuSuperMaximize:
    Send !{Tab} ; go to previously active window (the currently active window is the taskbar !)
    Sleep, 200
    superMaximize()
return


/*
 * Super Maximizes the currently active window.
 */
superMaximize() {
    global

    WinActive("A")
    WinGet, winId, ID

    if (isSuperMaximized_%winId% = 1) {
        ; already supermaximized: we restore the window
        WinSet, Style, +0x800000
        WinMove, , , orig_%winId%_x, orig_%winId%_y, orig_%winId%_width, orig_%winId%_height
        if (orig_%winId%_wasMaximized) {
            WinMaximize
        }
        isSuperMaximized_%winId% = 0
    } else {
        ; not supermaximized: we supermaximize it
        WinGet, orig_%winId%_wasMaximized, MinMax
        if (orig_%winId%_wasMaximized = 1) {
            WinRestore
        }
        WinGetPos, orig_%winId%_x, orig_%winId%_y, orig_%winId%_width, orig_%winId%_height ; store the old bounds
        WinSet, Style, -0x800000
        WinMove, , , -8, -8, A_ScreenWidth + 32, A_ScreenHeight +8 - 1 ; 1 pixel less, to be able to use the auto-hide taskbar
        isSuperMaximized_%winId% = 1
    }
}