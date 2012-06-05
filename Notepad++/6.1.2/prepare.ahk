/*
 * Designed for Notepad++ 6.1.2
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

Module = NotepadPP.6.1.2.%1%
ModuleExe = %A_ProgramFiles%\Notepad++\notepad++.exe
bContinue := false
TestsTotal := 0
TestsSkipped := 0
TestsFailed := 0
TestsOK := 0
TestsExecuted := 0


RunNotepad(PathToFile)
{
    global ModuleExe
    global TestsTotal
    global TestsOK
    global TestsFailed
    TestsTotal++

    Sleep, 500
    IfExist, %ModuleExe%
    {
        if PathToFile =
        {
            Run, %ModuleExe%,, Max ; Start maximized
            Sleep, 1000
            WinWaitActive, new  1 - Notepad++,,7
            if not ErrorLevel
            {
                TestsOK++
                bContinue := true
            }
            else
            {
                TestsFailed++
                WinGetTitle, title, A
                OutputDebug, FAILED: %Module%:%A_LineNumber%: Window 'new  1 - Notepad++' failed to appear. Active window caption: '%title%'`n
                bContinue := false
            }
        }
        else
        {
            Run, %ModuleExe% %PathToFile%,, Max
            Sleep, 1000
            WinWaitActive, %PathToFile% - Notepad++,,7
            if not ErrorLevel
            {
                TestsOK++
                bContinue := true
            }
            else
            {
                TestsFailed++
                WinGetTitle, title, A
                OutputDebug, FAILED: %Module%:%A_LineNumber%: Window '%PathToFile% - Notepad++' failed to appear. Active window caption: '%title%'`n
                bContinue := false
            }
        }
    }
    else
    {
        TestsFailed++
        OutputDebug, FAILED: %Module%:%A_LineNumber%: Can NOT find '%ModuleExe%'.`n
        bContinue := false
    }
}
