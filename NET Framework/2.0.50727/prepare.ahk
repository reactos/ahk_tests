/*
 * Designed for NET Framework 2.0.50727
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

bContinue := true
ModuleExe = %A_WorkingDir%\Apps\HelloWorldNET.exe


; Terminate application
if bContinue
{
    SplitPath, ModuleExe, ProcessExe
    bTerminateProcess(ProcessExe)
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
        IfNotExist, %ModuleExe%
            TestsFailed("RunApplication(): Can NOT find '" ModuleExe "'.")
        else
        {
            Run, %ModuleExe%
            WinWaitActive, Hello from .NET, .NET apps work, 3
            if ErrorLevel
            {
                szNETfile = %A_WinDir%\System32\mscoree.dll ; We need this file in order to run .NET application
                IfNotExist, %szNETfile%
                    bNETinstalled := false
                else
                    bNETinstalled := true

                Process, Exist, %ProcessExe%
                NewPID = %ErrorLevel%  ; Save the value immediately since ErrorLevel is often changed.
                if NewPID = 0
                {
                    if bNETinstalled
                        TestsFailed("RunApplication(): Window 'Hello from .NET (.NET apps work)' failed to appear, despite '" szNETfile "' exists. Different NET version? No '" ProcessExe "' process detected.")
                    else
                        TestsFailed("RunApplication(): Window 'Hello from .NET (.NET apps work)' failed to appear. '" szNETfile "' does not exist. No '" ProcessExe "' process detected.")
                }
                else
                {
                    if bNETinstalled
                        TestsFailed("RunApplication(): Window 'Hello from .NET (.NET apps work)' failed to appear, despite '" szNETfile "' exists. Different NET version? '" ProcessExe "' process detected.")
                    else
                        TestsFailed("RunApplication(): Window 'Hello from .NET (.NET apps work)' failed to appear. '" szNETfile "' does not exist. '" ProcessExe "' process detected.")
                }
            }
            else
                TestsOK("RunApplication(): 'Hello from .NET (.NET apps work)' window appeared.")
        }
    }
}
