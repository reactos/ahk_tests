/*
 * Designed for SeaMonkey 1.1.17
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
ModuleExe = %A_ProgramFiles%\mozilla.org\SeaMonkey\seamonkey.exe ; Registry contains different location

IfExist, %ModuleExe%
{
    Process, Close, seamonkey.exe ; Teminate process
    Sleep, 1500 ; To make sure folders are not locked
    FileRemoveDir, %A_AppData%\Mozilla, 1 ; Delete all saved settings. P.S. there is no way to create settings for it, because it uses protection
    Sleep, 1500
    IfNotExist, %A_AppData%\Mozilla
    {
        Run, %ModuleExe%,, Max ; Start maximized
        WinWaitActive, Welcome to SeaMonkey - SeaMonkey,,15
        if not ErrorLevel
        {
            bContinue := true
            Sleep, 3500 ; Longer sleep is required
        }
        else
        {
            WinGetTitle, title, A
            OutputDebug, %TestName%:%A_LineNumber%: Test failed: Window 'Welcome to SeaMonkey - SeaMonkey' failed to appear. Active window caption: '%title%'`n
        }
    }
    else
    {
        WinGetTitle, title, A
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: Seems like we failed to delete '%A_AppData%\Mozilla'. Active window caption: '%title%'`n
    }
}
else
{
    OutputDebug, %TestName%:%A_LineNumber%: Test failed: Can NOT find '%ModuleExe%'.`n
}
