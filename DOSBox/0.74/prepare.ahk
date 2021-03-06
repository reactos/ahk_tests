/*
 * Designed for DOSBox 0.74
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

TestName = prepare
ModuleExe = %A_ProgramFiles%\DOSBox\dosbox.exe


; Test if can start application
RunApplication()
{
    global ModuleExe
    global TestName
    global bContinue
    global TestsTotal

    TestsTotal++
    Process, Close, dosbox.exe
    Process, WaitClose, dosbox.exe, 4
    if ErrorLevel
        TestsFailed("RunApplication(): Process 'dosbox.exe' failed to close.")
    else
    {
        IfNotExist, %ModuleExe%
            TestsFailed("RunApplication(): Can NOT find '" ModuleExe "'.")
        else
        {
            Run, %ModuleExe%
            SetTitleMatchMode, 1 ; A window's title must start with the specified WinTitle to be a match.
            WinWaitActive, DOSBox 0.74,, 10
            if ErrorLevel
            {
                Process, Exist, dosbox.exe
                NewPID = %ErrorLevel%  ; Save the value immediately since ErrorLevel is often changed.
                if NewPID = 0
                    TestsFailed("RunApplication(): Window 'DOSBox 0.74' failed to appear (SetTitleMatchMode=" A_TitleMatchMode "). No 'dosbox.exe' process detected.")
                else
                    TestsFailed("RunApplication(): Window 'DOSBox 0.74' failed to appear (SetTitleMatchMode=" A_TitleMatchMode "). 'dosbox.exe' process detected.")
            }
            else
            {
                TestsOK("")
                SetTitleMatchMode, 3 ; A window's title must exactly match WinTitle to be a match
            }
        }
    }
}