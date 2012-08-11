/*
 * Designed for Flash Player 10.3.183.11
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

Process, Close, Standalone Flash Player 10.3.183.11.exe

ModuleExe = %A_WorkingDir%\Apps\Standalone Flash Player 10.3.183.11.exe

IfExist, %ModuleExe%
{
    Run, %ModuleExe% ; Do not run it maximized!
    WinWaitActive, Adobe Flash Player 10,,7
    if not ErrorLevel
    {
        Sleep, 1000 ; We are good to go
    }
    else
    {
        TestsFailed()
        WinGetTitle, title, A
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'Adobe Flash Player 10' window failed to appear. Active window caption: '%title%'.`n
    }
}
else
{
    OutputDebug, %TestName%:%A_LineNumber%: Test failed: Can NOT find '%ModuleExe%'.`n
}
