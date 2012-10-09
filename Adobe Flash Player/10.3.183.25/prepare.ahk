/*
 * Designed for Flash Player 10.3.183.25
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
ModuleExe = %A_WorkingDir%\Apps\Standalone Flash Player 10.3.183.25.exe
MainAppFile = Standalone Flash Player 10.3.183.25.exe

TestsTotal++
IfNotExist, %ModuleExe%
    TestsFailed("Can NOT find ' "ModuleExe "'.")
else
{
    Process, Close, %MainAppFile%
    Process, WaitClose, %MainAppFile%, 4
    if ErrorLevel
        TestsFailed("Unable to terminate '" MainAppFile "' process.")
    else
    {
        Run, %ModuleExe% ; Do not run it maximized!
        WinWaitActive, Adobe Flash Player 10,,7
        if ErrorLevel
        {
            Process, Exist, %MainAppFile%
            NewPID = %ErrorLevel%  ; Save the value immediately since ErrorLevel is often changed.
            if NewPID = 0
                TestsFailed("Window 'Adobe Flash Player 10' failed to appear. No '" MainAppFile "' process detected.")
            else
                TestsFailed("Window 'Adobe Flash Player 10' failed to appear. '" MainAppFile "' process detected.")
        }
        else
            TestsOK("")
    }
}
