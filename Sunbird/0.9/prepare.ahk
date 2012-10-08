/*
 * Designed for Sunbird 0.9
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

; Test if the app is installed
TestsTotal++
RegRead, UninstallerPath, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Mozilla Sunbird (0.9), UninstallString
if ErrorLevel
    TestsFailed("Either registry key does not exist or we failed to read it.")
else
{
    SplitPath, UninstallerPath,, InstalledDir
    SplitPath, InstalledDir,, InstalledDir ; Split path once more
    ModuleExe = %InstalledDir%\sunbird.exe
    TestsOK("")
}


; Terminate application
TestsTotal++
if bContinue
{
    SplitPath, ModuleExe, ProcessExe
    Process, Close, %ProcessExe%
    Process, WaitClose, %ProcessExe%, 4
    if ErrorLevel
        TestsFailed("Unable to terminate '" ProcessExe "' process.")
    else
        TestsOK("")
}


TestsTotal++
if bContinue
{
    IfNotExist, %ModuleExe%
        TestsFailed("Can NOT find '" ModuleExe "'.")
    else
    {
        FileRemoveDir, %A_AppData%\Mozilla, 1 ; Delete all saved settings
        IfExist, %A_AppData%\Mozilla
            TestsFailed("Seems like we failed to delete '" A_AppData "\Mozilla'.")
        else
        {
            FileCreateDir, %A_AppData%\Mozilla\Sunbird\Profiles\ReactOS.default
            if ErrorLevel
                TestsFailed("Failed to create dir tree '" A_AppData "\Mozilla\Sunbird\ReactOS.default'.")
            else
            {
                FileAppend, [General]`nStartWithLastProfile=0`n`n[Profile0]`nName=default`nIsRelative=1`nPath=Profiles/ReactOS.default`n, %A_AppData%\Mozilla\Sunbird\profiles.ini
                if ErrorLevel
                    TestsFailed("Failed to create and edit '" A_AppData "\Mozilla\Sunbird\profiles.ini'.")
                else
                {
                    szNoUpdate := "user_pref(""app.update.enabled""`, false)`;`n" ; Disable automatic application update
                    szNoPluginUpdate := "user_pref(""extensions.update.enabled""`, false)`;" ; Disable automatic extansion update
                    szUpdateMode := "user_pref(""app.update.mode""`, 0)`;`n" ; Don't warn
                    
                    FileAppend, %szNoUpdate%%szNoPluginUpdate%%szUpdateMode%, %A_AppData%\Mozilla\Sunbird\Profiles\ReactOS.default\prefs.js
                    if ErrorLevel
                        TestsFailed("Failed to create and edit '" A_AppData "\Mozilla\Sunbird\Profiles\ReactOS.default\prefs.js'.")
                    else
                    {
                        Run, %ModuleExe% ; 'Max' does not work
                        FormatTime, TimeString,, LongDate
                        WinWaitActive, %TimeString% - Sunbird,, 12
                        if ErrorLevel
                            TestsFailed("'" TimeString " - Sunbird' window failed to appear.")
                        else
                        {
                            TestsOK("")
                            WinMaximize, %TimeString% - Sunbird
                        }
                    }
                }
            }
        }
    }
}
