DetectHiddenText, Off ; Hidden text is not detected
Sleep, 3500
 
 
WinGetTitle, ActiveWndTitle, A
WinGetText, ActiveWndText, %ActiveWndTitle%
ControlGetFocus, FocusedName, %ActiveWndTitle%
ControlGetText, FocusedText, %FocusedName%, %ActiveWndTitle%
MsgBox, ActiveWnd: "%ActiveWndTitle%" `nFocused: %FocusedText% `nText: %ActiveWndText%
 
 
; This example allows you to move the mouse around to see
; the title of the window currently under the cursor:
#Persistent
SetTimer, WatchCursor, 100
return
 
WatchCursor:
MouseGetPos, OutputVarX, OutputVarY, id, control
WinGetTitle, title, ahk_id %id%
WinGetClass, class, ahk_id %id%
ControlGetText, FocusedText, %control%, A
ControlGet, ControlHwnd, Hwnd,, %control%, A
PixelGetColor, color, %OutputVarX%, %OutputVarY%
SetTitleMatchMode, 2
IfWinNotActive, Notepad
    ToolTip, ahk_id %id%`n ahk_class %class%`n WinTitle: "%title%"`n Control: %control%`n HWND: %ControlHwnd%`n ControlText: %FocusedText%`n MousePos: %OutputVarX%x%OutputVarY%`n Color: %color%
return
