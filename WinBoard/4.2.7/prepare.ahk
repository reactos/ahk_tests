/*
 * Designed for Foxit IrfanView 4.23
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

; Test if the app is installed. No registry information.
ModuleExe = %A_ProgramFiles%\WinBoard-4.2.7\winboard.exe
TestsTotal++
IfNotExist, %ModuleExe%
    TestsFailed("Unable to find '" ModuleExe "'.")
else
    TestsOK("")


; Terminate application
TestsTotal++
if bContinue
{
    SplitPath, ModuleExe, ProcessExe
    Process, Close, %ProcessExe%
    Process, WaitClose, %ProcessExe%, 4
    if ErrorLevel
        TestsFailed("Unable to terminate '" ProcessExe "' process.")
    else
        TestsOK("")
}


; Delete settings separately from RunApplication() in case we want to write our own settings
TestsTotal++
if bContinue
{
    FilePattern = %A_ProgramFiles%\WinBoard-4.2.7\*.ini
    IfExist, %FilePattern%
    {
        FileDelete, %FilePattern%
        if ErrorLevel
            TestsFailed("Unable to delete files that match '" FilePattern "' file pattern.")
        else
            TestsOK("")
    }
    else
        TestsOK("")
}


; Test if can start application
RunApplication()
{
    global ModuleExe
    global TestName
    global TestsTotal
    global bContinue
    global ProcessExe

    TestsTotal++
    if bContinue
    {
        Run, %ModuleExe%
        WinWaitActive, WinBoard Startup, Play against,7
        if ErrorLevel
        {
            Process, Exist, %ProcessExe%
            NewPID = %ErrorLevel%  ; Save the value immediately since ErrorLevel is often changed.
            if NewPID = 0
                TestsFailed("Window 'WinBoard Startup (Play against)' failed to appear. No '" ProcessExe "' process detected.")
            else
                TestsFailed("Window 'WinBoard Startup (Play against)' failed to appear. '" ProcessExe "' process detected.")
        }
        else
        {
            Control, Check,, Button1 ; Check 'Play against a chess engine or match two engines' radiobutton
            if ErrorLevel
                TestsFailed("Unable to check 'Play against...' radiobutton in 'WinBoard Startup (Play against)' window.")
            else
            {
                ControlGet, OutputVar, Enabled,, Button5 ; Check if 'OK' button is enabled
                if not %OutputVar%
                    TestsFailed("'Play against...' radiobutton is checked in 'WinBoard Startup (Play against)', but 'OK' button is disabled.")
                else
                    TestsOK("")
            }
        }
    }
}
