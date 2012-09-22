/*
 * Designed for Mozilla Firefox 3.0.11
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
RegRead, UninstallerPath, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Mozilla Firefox (3.0.11), UninstallString
if ErrorLevel
    TestsFailed("Either registry key does not exist or we failed to read it.")
else
{
    SplitPath, UninstallerPath,, InstalledDir
    ModuleExe = %InstalledDir%\..\firefox.exe ; Go back one folder
    TestsOK("")
}


TestsTotal++
if bContinue
{
    IfNotExist, %ModuleExe%
        TestsFailed("Can NOT find '" ModuleExe "'.")
    else
    {
        SplitPath, ModuleExe, ProcessExe
        Process, Close, %ProcessExe%
        Process, WaitClose, %ProcessExe%, 5
        if ErrorLevel ; The PID still exists.
            TestsFailed("Unable to terminate '" ProcessExe "' process.")
        else
        {
            FileRemoveDir, %A_AppData%\Mozilla, 1 ; Delete all saved settings
            IfExist, %A_AppData%\Mozilla
                TestsFailed("Seems like we failed to delete '" A_AppData "\Mozilla'.")
            else
            {
                FileCreateDir, %A_AppData%\Mozilla\Firefox\Profiles\ReactOS.default
                if ErrorLevel
                    TestsFailed("Failed to create dir tree '" A_AppData "\Mozilla\Firefox\ReactOS.default'.")
                else
                {
                    FileAppend, [General]`nStartWithLastProfile=0`n`n[Profile0]`nName=default`nIsRelative=1`nPath=Profiles/ReactOS.default`n, %A_AppData%\Mozilla\Firefox\profiles.ini
                    if ErrorLevel
                        TestsFailed("Failed to create and edit '" A_AppData "\Mozilla\Firefox\profiles.ini'.")
                    else
                    {
                        szNoWarningOnClose := "user_pref(""browser.tabs.warnOnClose""`, false)`;" ; Now, new do not want any warnings when closing multiple tabs
                        szNoFirstRun := "user_pref(""browser.startup.homepage_override.mstone""`, ""rv:1.9.0.11"")`;" ; Lets pretend we ran it once
                        szRightsShown := "user_pref(""browser.rights.3.shown""`, true)`;" ; We know your rights, no need to ask
                        szNoImprvHelp := "user_pref(""toolkit.telemetry.prompted""`, 2)`;`nuser_pref(""toolkit.telemetry.rejected""`, true)`;" ; We don't want to help to improve
                        szDownloadDir := "user_pref(""browser.download.folderList""`, 0)`;" ; Desktop is our default download directory
                        FileAppend, %szNoWarningOnClose%`n%szNoFirstRun%`n%szRightsShown%`n%szNoImprvHelp%`n`n%szDownloadDir%, %A_AppData%\Mozilla\Firefox\Profiles\ReactOS.default\prefs.js
                        if ErrorLevel
                            TestsFailed("Failed to create and edit '" A_AppData "\Mozilla\Firefox\Profiles\ReactOS.default\prefs.js'.")
                        else
                        {
                            Run, %ModuleExe%,,Max ; Start maximized
                            WinWaitActive, Mozilla Firefox Start Page - Mozilla Firefox,, 20
                            if ErrorLevel
                            {
                                Process, Exist, %ProcessExe%
                                NewPID = %ErrorLevel%  ; Save the value immediately since ErrorLevel is often changed.
                                if NewPID = 0
                                    TestsFailed("'Mozilla Firefox Start Page - Mozilla Firefox' window failed to appear. No '" ProcessExe "' process detected.")
                                else
                                    TestsFailed("'Mozilla Firefox Start Page - Mozilla Firefox' window failed to appear. '" ProcessExe "' process detected.")
                            }
                            else
                            {
                                TestsOK("")
                            }
                        }
                    }
                }
            }
        }
    }
}
