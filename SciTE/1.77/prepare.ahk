/*
 * Designed for SciTE 1.77
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
ModuleExe = %A_ProgramFiles%\SciTE\SciTE.exe

; Terminate application
TestsTotal++
SplitPath, ModuleExe, ProcessExe
Process, Close, %ProcessExe%
Process, WaitClose, %ProcessExe%, 4
if ErrorLevel
    TestsFailed("Unable to terminate '" ProcessExe "' process.")
else
    TestsOK("")


; Test if can start application
RunApplication(PathToFile)
{
    global ModuleExe
    global TestName
    global bContinue
    global TestsTotal
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
                Run, %ModuleExe% ; Max does not work here
                WinWaitActive, (Untitled) - SciTE,, 7
                if ErrorLevel
                {
                    Process, Exist, %ProcessExe%
                    NewPID = %ErrorLevel%  ; Save the value immediately since ErrorLevel is often changed.
                    if NewPID = 0
                        TestsFailed("RunApplication(): Window '(Untitled) - SciTE' failed to appear. No '" ProcessExe "' process detected.")
                    else
                        TestsFailed("RunApplication(): Window '(Untitled) - SciTE' failed to appear. '" ProcessExe "' process detected.")
                }
                else
                {
                    TestsOK("")
                    WinMaximize, (Untitled) - SciTE
                }
            }
            else
            {
                IfNotExist, %PathToFile%
                    TestsFailed("RunApplication(): Can NOT find '" PathToFile "'.")
                else
                {
                    Run, %ModuleExe% "%PathToFile%" ; Max does not work here
                    SplitPath, PathToFile, NameExt
                    WinWaitActive, %NameExt% - SciTE,,7
                    if ErrorLevel
                    {
                        Process, Exist, %ProcessExe%
                        NewPID = %ErrorLevel%  ; Save the value immediately since ErrorLevel is often changed.
                        if NewPID = 0
                            TestsFailed("RunApplication(): Window '" NameExt " - SciTE' failed to appear. No '" ProcessExe "' process detected.")
                        else
                            TestsFailed("RunApplication(): Window '" NameExt " - SciTE' failed to appear. '" ProcessExe "' process detected.")
                    }
                    else
                    {
                        TestsOK("")
                        WinMaximize, %NameExt% - SciTE
                    }
                }
            }
        }
    }
}