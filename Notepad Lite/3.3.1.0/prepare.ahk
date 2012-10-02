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

TestName = prepare
ModuleExe = %A_ProgramFiles%\Notepad Lite\gsnote3.exe


; Terminate application
TestsTotal++
SplitPath, ModuleExe, ProcessExe
Process, Close, %ProcessExe%
Process, WaitClose, %ProcessExe%, 4
if ErrorLevel
    TestsFailed("Process '" ProcessExe "' failed to close.")
else
    TestsOK("")


RegDelete, HKEY_CURRENT_USER, SOFTWARE\GridinSoft\Notepad3 ; Delete saved settings before RunApplication()


; Test if can start application
RunApplication(PathToFile)
{
    global ModuleExe
    global TestName
    global TestsTotal
    global ProcessExe
    global bContinue

    TestsTotal++
    if bContinue
    {
        IfNotExist, %ModuleExe%
            TestsFailed("Test failed: Can NOT find '" ModuleExe "'.")
        else
        {
            if PathToFile =
            {
                Run, %ModuleExe%,, Max
                WinWaitActive, GridinSoft Notepad Lite - [Untitled-1],, 7
                if ErrorLevel
                {
                    Process, Exist, %ProcessExe%
                    NewPID = %ErrorLevel%  ; Save the value immediately since ErrorLevel is often changed.
                    if NewPID = 0
                        TestsFailed("Window 'GridinSoft Notepad Lite - [Untitled-1]' failed to appear. No '" ProcessExe "' process detected.")
                    else
                        TestsFailed("Window 'GridinSoft Notepad Lite - [Untitled-1]' failed to appear. '" ProcessExe "' process detected.")
                }
                else
                    TestsOK("")
            }
            else
            {
                IfNotExist, %PathToFile%
                    TestsFailed("Can NOT find '" PathToFile "'.")
                else
                {
                    Run, %ModuleExe% "%PathToFile%",, Max
                    WinWaitActive, GridinSoft Notepad Lite - [%PathToFile%],, 7
                    if ErrorLevel
                    {
                        Process, Exist, %ProcessExe%
                        NewPID = %ErrorLevel%  ; Save the value immediately since ErrorLevel is often changed.
                        if NewPID = 0
                            TestsFailed("Window 'GridinSoft Notepad Lite - [" PathToFile "]' failed to appear. No '" ProcessExe "' process detected.")
                        else
                            TestsFailed("Window 'GridinSoft Notepad Lite - [" PathToFile "]' failed to appear. '" ProcessExe "' process detected.")
                    }
                    else
                        TestsOK("")
                }
            }
        }
    }
}