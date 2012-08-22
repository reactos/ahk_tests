/*
 * Designed for Notepad Lite 3.3.1.0
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

ModuleExe = %A_ProgramFiles%\Notepad Lite\gsnote3.exe
Process, Close, gsnote3.exe
Sleep, 1000

; Test if can start application
RunApplication(PathToFile)
{
    global ModuleExe
    global TestName
    global bContinue

    RegDelete, HKEY_CURRENT_USER, SOFTWARE\GridinSoft\Notepad3 ; Delete saved settings
    IfExist, %ModuleExe%
    {
        if PathToFile =
        {
            Run, %ModuleExe%,, Max
            Sleep, 1000
            WinWaitActive, GridinSoft Notepad Lite - [Untitled-1],, 10
            if not ErrorLevel
            {
                bContinue := true
                Sleep, 1000
            }
            else
            {
                WinGetTitle, title, A
                OutputDebug, %TestName%:%A_LineNumber%: Test failed: Window 'GridinSoft Notepad Lite - [Untitled-1]' failed to appear. Active window caption: '%title%'`n
            }
        }
        else
        {
            IfExist, %PathToFile%
            {
                Run, %ModuleExe% "%PathToFile%",, Max
                Sleep, 1000
                WinWaitActive, GridinSoft Notepad Lite - [%PathToFile%],,10
                if not ErrorLevel
                {
                    bContinue := true
                    Sleep, 1000
                }
                else
                {
                    WinGetTitle, title, A
                    OutputDebug, %TestName%:%A_LineNumber%: Test failed: Window 'GridinSoft Notepad Lite - [%PathToFile%]' failed to appear. Active window caption: '%title%'`n
                }
            }
            else
            {
                OutputDebug, %TestName%:%A_LineNumber%: Test failed: Can NOT find '%PathToFile%'.`n
            }
        }
    }
    else
    {
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: Can NOT find '%ModuleExe%'.`n
    }
}