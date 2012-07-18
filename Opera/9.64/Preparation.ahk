/*
 * Designed for Opera v9.64
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

Module = Opera_9.64_%1%
ModuleExe = %A_ProgramFiles%\Opera\Opera.exe
bContinue := false
TestsTotal := 0
TestsSkipped := 0
TestsFailed := 0
TestsOK := 0
TestsExecuted := 0


;Check if Opera.exe exists in program files
TestsTotal++
{
    Sleep, 2500
    IfExist, %ModuleExe%
    {
        TestsOK++
        OutputDebug, OK: %Module%:%A_LineNumber%: '%ModuleExe%' was found.`n
        bContinue := true
    }
    else
    {
        TestsFailed++
        OutputDebug, FAILED: %Module%:%A_LineNumber%: Can NOT find '%ModuleExe%'.`n
        bContinue := false
    }
}


; Test if we can start the app and enter URL
TestsTotal++
if bContinue
{
    Run, %ModuleExe% ; Setup/install registers Opera as default browser
    Sleep, 4500 ; Let it to load
    WinWaitActive, Welcome to Opera - Opera,, 20 ; Window caption might change?
    if not ErrorLevel
    {
        TestsOK++
        ; OutputDebug, OK: %Module%:%A_LineNumber%: Window 'Welcome to Opera - Opera' was found.`n
        bContinue := true 
    }
    else
    {
        TestsFailed++
        WinGetTitle, title, A
        OutputDebug, FAILED: %Module%:%A_LineNumber%: Window 'Welcome to Opera - Opera' was NOT found. Active window caption: '%title%'`n
        bContinue := false
    }
}