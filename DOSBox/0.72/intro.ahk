/*
 * Designed for DOSBox 0.72
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

TestName = 2.intro

; Test if can type 'intro' and 'exit' in DOSBox window
TestsTotal++
RunApplication()
if bContinue
{
    SetTitleMatchMode, 1 ; A window's title must start with the specified WinTitle to be a match
    IfWinActive, DOSBox 0.72
    {
        SendInput, intro
        Sleep, 2000
        SendInput, {ENTER}
        SetTitleMatchMode, 2 ; A window's title can contain WinTitle anywhere inside it to be a match
        WinWaitActive, Program:    INTRO,,5
        if not ErrorLevel
        {
            SendInput, {ENTER}{ENTER}{ENTER} ; Read the intro
            Sleep, 1000
            SendInput, exit
            Sleep, 2000
            SendInput, {ENTER}
            WinWaitClose, Program:    INTRO,,5
            if not ErrorLevel
            {
                TestsOK("Typed 'intro' and 'exit' successfully.")
                SetTitleMatchMode, 3 ; A window's title must exactly match WinTitle to be a match
            }
            else
                TestsFailed("Window 'Program:    INTRO' failed to close (SetTitleMatchMode=2).")
        }
        else
            TestsFailed("Window 'Program:    INTRO' is not active (SetTitleMatchMode=2).")
    }
    else
        TestsFailed("Window 'DOSBox 0.72' is not active (SetTitleMatchMode=1).")
}
else
    TestsFailed("We failed somewhere in prepare.ahk.")
