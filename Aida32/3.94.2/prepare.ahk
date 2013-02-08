/*
 * Designed for Aida32 3.94.2
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
ModuleExe = %A_ProgramFiles%\Aida32\aida32.exe


; Test if can start application
RunApplication()
{
    global ModuleExe
    global TestName
    global bContinue
    global TestsTotal
    
    TestsTotal++
    Process, Close, aida32.exe
    Process, WaitClose, aida32.exe, 4
    if ErrorLevel
        TestsFailed("RunApplication(): Process 'aida32.exe' failed to close.")
    else
    {
        Process, Close, aida32.bin
        Process, WaitClose, aida32.bin, 4
        if ErrorLevel
            TestsFailed("RunApplication(): Process 'aida32.bin' failed to close.")
        else
        {
            IfNotExist, %ModuleExe%
                TestsFailed("RunApplication(): Can NOT find '" ModuleExe "'.")
            else
            {
                Run, %ModuleExe% ; 'Max' doesn't work with aida32
                WinWaitActive, AIDA32 - Enterprise System Information,,10
                if ErrorLevel
                {
                    Process, Exist, aida32.bin
                    NewPID = %ErrorLevel%  ; Save the value immediately since ErrorLevel is often changed.
                    if NewPID = 0
                        TestsFailed("RunApplication(): Window 'AIDA32 - Enterprise System Information' failed to appear. No 'aida32.bin' process detected.")
                    else
                        TestsFailed("RunApplication(): Window 'AIDA32 - Enterprise System Information' failed to appear. 'aida32.bin' process detected.")
                }
                else
                {
                    WinMaximize, AIDA32 - Enterprise System Information ; Maximize the window
                    TestsOK("")
                }
            }
        }
    }
}
