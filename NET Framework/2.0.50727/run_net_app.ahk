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

TestName = 2.run_net_app

; Test if can run NET application and then close it.
TestsTotal++
RunApplication()
if not bContinue
    TestsFailed("We failed somwehere in 'prepare.ahk'.")
else
{
    IfWinNotActive, Hello from .NET, .NET apps work
        TestsFailed("'Hello from .NET (.NET apps work)' window is not active.")
    else
    {
        WinClose
        WinWaitClose,,,3
        if ErrorLevel
            TestsFailed("Unable to close 'Hello from .NET (.NET apps work)' window.")
        else
        {
            Process, WaitClose, %ProcessExe%, 4
            if ErrorLevel
                TestsFailed("'" ProcessExe "' process failed to close despite 'Hello from .NET (.NET apps work)' window being closed.")
            else
                TestsOK("Closed 'Hello from .NET (.NET apps work)' window, then '" ProcessExe "' process closed too.")
        }
    }
}
