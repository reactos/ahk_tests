/*
 * Helper functions library
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

#NoEnv ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir% ; Ensures a consistent starting directory.

Helper = HelperFunctions

; Terminates application windows and closes error boxes
WindowCleanup(ProcessName)
{
    Process, wait, %ProcessName%, 1
    NewPID = %ErrorLevel%  ; Save the value immediately since ErrorLevel is often changed.
    if NewPID != 0
    {
        Process, close, %ProcessName%
    }
    else
    {
        SplitPath, ProcessName, name, dir, ext, name_no_ext, drive
        Process, close, %name_no_ext%.tmp ; Will kill some setups
        Process, close, Setup.exe
    }
    
    Sleep, 2500
    IfWinActive, Mozilla Crash Reporter
    {
        SendInput, {SPACE} ; Dont tell Mozilla about this crash
        Sleep, 200
        SendInput, {TAB}
        Sleep, 200
        SendInput, {TAB}
        Sleep, 200
        SendInput, {ENTER} ; Hit 'Quit Firefox'
    }
    else
    {
        WinGetTitle, ErrorWinTitle, A
        if not ErrorLevel
        {
            ControlFocus, OK, %ErrorWinTitle%
            if not ErrorLevel
            {
                Sleep, 1200
                SendInput, {ENTER} ; Hit 'OK' button
            }
        }
    }
}