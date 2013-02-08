/*
 * Designed for Fox Audio Player 0.9.1
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

InstallLocation = %A_ProgramFiles%\Fox Audio Player\fap-0.9.1-win32-bin
ModuleExe = %InstallLocation%\fap.exe
bContinue := true


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
RegDelete, HKEY_CURRENT_USER, Software\DrFiemost


; Test if can start application
RunApplication(PathToFile)
{
    global ModuleExe
    global TestName
    global TestsTotal
    global bContinue
    global ProcessExe

    TestsTotal++
    if bContinue
    {
        IfNotExist, %ModuleExe%
            TestsFailed("RunApplication(): Can NOT find '" ModuleExe "'.")
        else
        {
            if PathToFile =
            {
                Run, %ModuleExe%
                WinWaitActive, Fox Audio Player,,7
                if ErrorLevel
                {
                    Process, Exist, %ProcessExe%
                    NewPID = %ErrorLevel%  ; Save the value immediately since ErrorLevel is often changed.
                    if NewPID = 0
                        TestsFailed("RunApplication(): Window 'Fox Audio Player' failed to appear. No '" ProcessExe "' process detected.")
                    else
                        TestsFailed("RunApplication(): Window 'Fox Audio Player' failed to appear. '" ProcessExe "' process detected.")
                }
                else
                {
                    WinMaximize
                    TestsOK("")
                }
            }
            else
            {
                IfNotExist, %PathToFile%
                    TestsFailed("RunApplication(): Can NOT find '" PathToFile "'.")
                else
                {
                    Run, %ModuleExe% "%PathToFile%"
                    SplitPath, PathToFile,,,, name_no_ext
                    WinWaitActive, %name_no_ext%,,7
                    if ErrorLevel
                    {
                        Process, Exist, %ProcessExe%
                        NewPID = %ErrorLevel%  ; Save the value immediately since ErrorLevel is often changed.
                        if NewPID = 0
                            TestsFailed("RunApplication(): Window '" name_no_ext "' failed to appear. No '" ProcessExe "' process detected.")
                        else
                            TestsFailed("RunApplication(): Window '" name_no_ext "' failed to appear. '" ProcessExe "' process detected.")
                    }
                    else
                    {
                        WinMaximize
                        TestsOK("")
                    }
                }
            }
        }
    }
}
