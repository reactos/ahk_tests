/*
 * Designed for Paint
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
ModuleExe = %A_WinDir%\System32\mspaint.exe

Process, Close, mspaint.exe

; Test if can start application
RunApplication(PathToFile)
{
    global ModuleExe
    global TestName
    global bContinue

    Sleep, 500
    RegDelete, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Applets\Paint
    IfExist, %ModuleExe%
    {
        if PathToFile =
        {
            Run, %ModuleExe%,, Max ; Start maximized
            WinWaitActive, untitled - Paint,,7
            if ErrorLevel
            {
                WinGetActiveTitle, title
                OutputDebug, %TestName%:%A_LineNumber%: Test failed: Window 'untitled - paint' failed to appear. Active window caption: '%title%'`n
            }
            else
            {
                bContinue := true
                Sleep, 1000
            }
        }
        else
        {
            IfExist, %PathToFile%
            {
                Run, %ModuleExe% "%PathToFile%",, Max
                SplitPath, PathToFile, NameExt
                WinWaitActive, %NameExt% - Paint,,7
                if ErrorLevel
                {
                    WinGetActiveTitle, title
                    OutputDebug, %TestName%:%A_LineNumber%: Test failed: Window '%NameExt% - Paint' failed to appear. Active window caption: '%title%'`n
                }
                else
                {
                    bContinue := true
                    Sleep, 1000
                }
            }
            else
                OutputDebug, %TestName%:%A_LineNumber%: Test failed: Can NOT find '%PathToFile%'.`n
        }
    }
    else
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: Can NOT find '%ModuleExe%'.`n
}
