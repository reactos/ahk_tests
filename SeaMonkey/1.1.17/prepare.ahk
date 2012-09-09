/*
 * Designed for SeaMonkey 1.1.17
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
ModuleExe = %A_ProgramFiles%\mozilla.org\SeaMonkey\seamonkey.exe ; Registry contains different location


; Terminate application
TestsTotal++
SplitPath, ModuleExe, ProcessExe
Process, Close, %ProcessExe%
Process, WaitClose, %ProcessExe%, 4
if ErrorLevel
    TestsFailed("Unable to terminate '" ProcessExe "' process.")
else
    TestsOK("")


TestsTotal++
if bContinue
{
    IfNotExist, %ModuleExe%
        TestsFailed("Can NOT find '" ModuleExe "'.")
    else
    {
        RegisterAsDefault := "C:\PROGRA~1\MOZILLA.ORG\SEAMON~1\SEAMON~1.EXE -osint -url ""%1"""
        RegWrite, REG_SZ, HKEY_LOCAL_MACHINE, SOFTWARE\Classes\http\shell\open\command,, %RegisterAsDefault% ; Register as default web browser
        if ErrorLevel
            TestsFailed("Unable to set def browser")
        else
        {
            FileRemoveDir, %A_AppData%\Mozilla, 1 ; Delete all saved settings. P.S. there is no way to create settings for it, because it uses protection
            Sleep, 1500
            IfExist, %A_AppData%\Mozilla
                TestsFailed("Seems like we failed to delete '" A_AppData "\Mozilla'.")
            else
            {
                Run, %ModuleExe%,, Max ; Start maximized
                WinWaitActive, Welcome to SeaMonkey - SeaMonkey,,15
                if ErrorLevel
                    TestsFailed("Window 'Welcome to SeaMonkey - SeaMonkey' failed to appear.")
                else
                {
                    TestsOK("")
                    Sleep, 3500 ; Longer sleep is required
                }
            }
        }
    }
}
