/*
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

ModuleExe = %A_WorkingDir%\Apps\HelloWorldSpace.exe
TestName = 1.space

; Terminate application
SplitPath, ModuleExe, ProcessExe
bTerminateProcess(ProcessExe)


TestsTotal++
if bContinue
{
    IfNotExist, %ModuleExe%
        TestsFailed("Can NOT find '" ModuleExe "'.")
    else
    {
        Run, %ModuleExe%
        WndCaption := "Hello, World "
        SetTitleMatchMode, 3 ; A window's title must exactly match WinTitle to be a match.
        WinWaitActive, %WndCaption%,,5
        if ErrorLevel
            TestsFailed("OS removed the space from the end of the window caption.")
        else
        {
            Process, Close, %ProcessExe%
            Process, WaitClose, %ProcessExe%, 4
            if ErrorLevel
                TestsFailed("Unable to terminate '" ProcessExe "' process after running it.")
            else
                TestsOK("OS did not remove the space from the end of the window title.")
        }
    }
}
