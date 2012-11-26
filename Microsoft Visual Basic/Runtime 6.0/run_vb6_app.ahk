/*
 * Designed for Microsoft Visual Basic 6.0 Runtime
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

TestName = 2.run_vb6_app
szTestApp = %A_WorkingDir%\Apps\VB6_GUI.exe

; Test if can VB6 Runtime is installed and if simple VB6 GUI app can start properly
TestsTotal++
szRuntimeFile = %A_WinDir%\System32\MSVBVM60.DLL
IfNotExist, %szRuntimeFile%
    TestsInfo("Seems like VB6.0 Runtime is NOT installed, because '" szRuntimeFile "' doesn't exist.")
else
    TestsInfo("Seems like VB6.0 Runtime is installed, because '" szRuntimeFile "' exist.")

; Runtime might not exist, we want to check how OS reacts if we start VB app anyway
IfNotExist, %szTestApp%
    TestsFailed("Can NOT find '" szTestApp "'.")
else
{
    Run, %szTestApp%
    WinWaitActive, VB6 Hello World, this is simple, 3
    if ErrorLevel
        TestsFailed("'VB6 Hello World (this is simple)' window failed to appear.")
    else
    {
        TestsInfo("'VB6 Hello World (this is simple)' window appeared.")
        WinClose, VB6 Hello World, this is simple
        WinWaitClose, VB6 Hello World, this is simple, 3
        if ErrorLevel
            TestsFailed("Unable to close 'VB6 Hello World (this is simple)' window.")
        else
            TestsOK("Simple VB6 GUI app works, because 'VB6 Hello World (this is simple)' window appeared and closed just fine.")
    }
}
