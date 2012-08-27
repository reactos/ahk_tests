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

TestName = prepare
ModuleExe = %A_ProgramFiles%\Opera\Opera.exe
bContinue := false
TestsTotal := 0
TestsSkipped := 0
TestsFailed := 0
TestsOK := 0
TestsExecuted := 0


IfExist, %ModuleExe%
{
    FileRemoveDir, %A_AppData%\Opera, 1
    Sleep, 1000
    Run, %ModuleExe% ; Setup/install registers Opera as default browser
    WinWaitActive, Welcome to Opera - Opera,, 20 ; Window caption might change?
    if not ErrorLevel
    {
        Sleep, 1000
        bContinue := true 
    }
    else
        OutputDebug, FAILED: %TestName%:%A_LineNumber%: Window 'Welcome to Opera - Opera' was NOT found. Active window caption: '%title%'`n
}
else
    OutputDebug, FAILED: %TestName%:%A_LineNumber%: Can NOT find '%ModuleExe%'.`n
