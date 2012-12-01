/*
 * Designed for Python 3.2.3
 * Copyright (C) 2012 Edijs Kolesnikovics
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
 */

TestName = 2.tkinter_gui
szDocument =  C:\python_gui_app.py ; Case insensitive
iWndWidth := 220 ; Since AHK can not detect label caption, we will use this to determine if everything is OK
szWndTitle = Python GUI App

; Test if can run Python GUI application
TestsTotal++
if bContinue
{
    szSourceCode =
(
from tkinter import * #Python cares about identation
from tkinter import ttk
root = Tk()
root.title("%szWndTitle%")
root.minsize(%iWndWidth%, 50)
lb = Label(root, text="AHK does not detect label caption.").grid()
root.mainloop()
)

    IfExist, %szDocument%
    {
        FileDelete, %szDocument%
        if ErrorLevel <> 0
            TestsFailed("Unable to delete existing '" szDocument "'.")
    }

    if bContinue
    {
        FileAppend, %szSourceCode%, %szDocument%
        if ErrorLevel
            TestsFailed("Unable to create '" szDocument "'.")
        else
        {
            RunApplication(szDocument)
            if bContinue
            {
                WinWaitActive, %szWndTitle%,,3
                if ErrorLevel
                    TestsFailed("'" szWndTitle "' window failed to appear.")
                else
                {
                    Sleep, 1000 ; Sleep, maybe it will crash
                    IfWinNotActive, %szWndTitle%
                        TestsFailed("Slept for a while and '" szWndTitle "' window is not active anymore.")
                    else
                    {
                        WinGetPos,,, Width, Height, %szWndTitle%
                        if (iWndWidth+8 != Width) ; +8 because of theme. Luna theme in XP and Windows Classic theme in win2k3, both +8
                            TestsFailed("'" szWndTitle "' window width is wrong (is " Width ", expected '" iWndWidth "').")
                        else
                            TestsOK("'" szWndTitle "' window appeared, window width is as expected, so, python GUI apps works.")
                    }
                }
            }
        }
    }
}


; Close application
TestsTotal++
if bContinue
{
    WinClose, %szWndTitle%
    WinWaitClose,,,3
    if ErrorLevel
        TestsFailed("Unable to close '" szWndTitle "' window.")
    else
    {
        Process, WaitClose, %ProcessExe%
        if ErrorLevel
            TestsFailed("'" ProcessExe "' process failed to close despite '" szWndTitle "' window being closed.")
        else
            TestsOK("Closed '" szWndTitle "' then '" ProcessExe "' process closed on its own.")
    }
}
