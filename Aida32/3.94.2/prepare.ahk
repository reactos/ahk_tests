/*
 * Designed for Aida32 3.94.2
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

Process, Close, aida32.bin
Process, Close, aida32.exe
Sleep, 1500
ModuleExe = %A_ProgramFiles%\Aida32\aida32.exe


; Test if can start application
RunApplication()
{
    global ModuleExe
    
    IfExist, %ModuleExe%
    {
        Run, %ModuleExe% ; 'Max' doesn't work with aida32
        Sleep, 1000
        WinWaitActive, AIDA32 - Enterprise System Information,,15
        if not ErrorLevel
        {
            Sleep, 1500
            WinMaximize, AIDA32 - Enterprise System Information ; Maximize the window
        }
        else
        {
            WinGetTitle, title, A
            OutputDebug, %TestName%:%A_LineNumber%: Test failed: Window 'AIDA32 - Enterprise System Information' failed to appear. Active window caption: '%title%'`n
        }
    }
    else
    {
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: Can NOT find '%ModuleExe%'.`n
    }
}
