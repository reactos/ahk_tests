/*
 * Designed for OllyDbg 1.10
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
ModuleExe = %A_ProgramFiles%\OllyDbg\OLLYDBG.EXE


; Terminate application
TestsTotal++
SplitPath, ModuleExe, ProcessExe
Process, Close, %ProcessExe%
Process, WaitClose, %ProcessExe%, 4
if ErrorLevel
    TestsFailed("Process '" ProcessExe "' failed to close.")
else
    TestsOK("")


; Delete previously saved settings
TestsTotal++
if bContinue
{
    SplitPath, ModuleExe,, OllyDbgDir
    IfExist, %OllyDbgDir%\ollydbg.ini
    {
        FileDelete, %OllyDbgDir%\ollydbg.ini
        if ErrorLevel
            TestsFailed("Unable to delete '" OllyDbgDir "\ollydbg.ini'.")
        else
            TestsOK("")
    }
    FileDelete, %OllyDbgDir%\*.udd
    FileDelete, %OllyDbgDir%\*.bak
    Sleep, 500
}


; Test if can start application
RunApplication(PathToFile)
{
    global ModuleExe
    global TestName
    global bContinue
    global TestsTotal
    global OllyDbgDir
    global ProcessExe

    TestsTotal++
    IfNotExist, %ModuleExe%
        TestsFailed("Can NOT find '" ModuleExe "'.")
    else
    {
        FileAppend, [Settings]`nCheck DLL versions=0`n, %OllyDbgDir%\ollydbg.ini
        if ErrorLevel
            TestsFailed("Unable to create '" OllyDbgDir "\ollydbg.ini'.")
        else
        {
            Sleep, 1000
            if PathToFile =
            {
                Run, %ModuleExe%,, Max
                WinWaitActive, OllyDbg,, 10
                if ErrorLevel
                {
                    Process, Exist, %ProcessExe%
                    NewPID = %ErrorLevel%  ; Save the value immediately since ErrorLevel is often changed.
                    if NewPID = 0
                        TestsFailed("Window 'OllyDbg' failed to appear. No '" ProcessExe "' process detected.")
                    else
                        TestsFailed("Window 'OllyDbg' failed to appear. '" ProcessExe "' process detected.")
                }
                else
                {
                    TestsOK("")
                    Sleep, 1000
                }
            }
            else
            {
                IfNotExist, %PathToFile%
                    TestsFailed("Can NOT find '" PathToFile "'.")
                else
                {
                    Run, %ModuleExe% "%PathToFile%",, Max
                    SplitPath, PathToFile, NameExt
                    WinWaitActive, OllyDbg - %NameExt%,,10
                    if ErrorLevel
                    {
                        Process, Exist, %ProcessExe%
                        NewPID = %ErrorLevel%  ; Save the value immediately since ErrorLevel is often changed.
                        if NewPID = 0
                            TestsFailed("Window 'OllyDbg - " NameExt "' failed to appear. No '" ProcessExe "' process detected.")
                        else
                            TestsFailed("Window 'OllyDbg - " NameExt "' failed to appear. '" ProcessExe "' process detected.")
                    }
                    else
                    {
                        TestsOK("")
                        Sleep, 1000
                    }
                }
            }
        }
    }
}