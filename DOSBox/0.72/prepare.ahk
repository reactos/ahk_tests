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

bContinue := false
TestsTotal := 0
TestsSkipped := 0
TestsFailed := 0
TestsOK := 0
TestsExecuted := 0
TestName = prepare

ModuleExe = %A_ProgramFiles%\DOSBox\dosbox.exe
Process, Close, dosbox.exe
Sleep, 1000

; Test if can start application
RunApplication()
{
    global ModuleExe
    global TestName
    global bContinue

    IfExist, %ModuleExe%
    {
        Run, %ModuleExe%
        Sleep, 1000
        SetTitleMatchMode, 1 ; A window's title must start with the specified WinTitle to be a match.
        WinWaitActive, DOSBox 0.72,, 10
        if not ErrorLevel
        {
            bContinue := true
            SetTitleMatchMode, 3 ; A window's title must exactly match WinTitle to be a match
            Sleep, 1000
        }
        else
        {
            WinGetTitle, title, A
            OutputDebug, %TestName%:%A_LineNumber%: Test failed: Window 'DOSBox 0.72' failed to appear (SetTitleMatchMode=1). Active window caption: '%title%'`n
        }
    }
    else
    {
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: Can NOT find '%ModuleExe%'.`n
    }
}