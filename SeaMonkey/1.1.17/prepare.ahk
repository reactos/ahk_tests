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
        RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\Mozilla
        RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\mozilla.org
        RegDelete, HKEY_CURRENT_USER, SOFTWARE\Mozilla
        RegDelete, HKEY_CURRENT_USER, SOFTWARE\mozilla.org
        RegisterAsDefault := "C:\PROGRA~1\MOZILLA.ORG\SEAMON~1\SEAMON~1.EXE -osint -url ""%1"""
        RegWrite, REG_SZ, HKEY_LOCAL_MACHINE, SOFTWARE\Classes\http\shell\open\command,, %RegisterAsDefault% ; Register as default web browser
        if ErrorLevel
            TestsFailed("Unable to set SeaMonkey as default browser.")
        else
        {
            RegWrite, REG_SZ, HKEY_LOCAL_MACHINE, SOFTWARE\Mozilla\Desktop, haveBeenSet, 1 ; Get rid of 'Do you want to set SeaMonkey as default browser' dialog
            if ErrorLevel
                TestsFailed("Unable to set HKLM\Software\Mozilla\Desktop, 'haveBeenSet' to '1'.")
            else
            {
                FileRemoveDir, %A_AppData%\Mozilla, 1 ; Delete all saved settings. P.S. there is no way to create settings for it, because it uses protection
                IfExist, %A_AppData%\Mozilla
                    TestsFailed("Seems like we failed to delete '" A_AppData "\Mozilla'.")
                else
                {
                    Run, %ModuleExe%,, Max ; Start maximized
                    WinWaitActive, Welcome to SeaMonkey - SeaMonkey,,20
                    if ErrorLevel
                    {
                        Process, Exist, %ProcessExe%
                        NewPID = %ErrorLevel%  ; Save the value immediately since ErrorLevel is often changed.
                        if NewPID = 0
                            TestsFailed("Window 'Welcome to SeaMonkey - SeaMonkey' failed to appear. No '" ProcessExe "' process detected.")
                        else
                            TestsFailed("Window 'Welcome to SeaMonkey - SeaMonkey' failed to appear. '" ProcessExe "' process detected.")
                    }
                    else
                        TestsOK("")
                }
            }
        }
    }
}
