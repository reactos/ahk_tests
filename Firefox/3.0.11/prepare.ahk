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

bContinue := false
TestsTotal := 0
TestsSkipped := 0
TestsFailed := 0
TestsOK := 0
TestsExecuted := 0
TestName = prepare

RegRead, UninstallerPath, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Mozilla Firefox (3.0.11), UninstallString
if not ErrorLevel
{
    StringReplace, UninstallerPath, UninstallerPath, `",, All ; String contains quotes, replace em
    SplitPath, UninstallerPath,, InstalledDir
    ModuleExe = %InstalledDir%\..\firefox.exe ; Go back one folder
}
else
{
    ModuleExe = %A_ProgramFiles%\Mozilla Firefox\firefox.exe
    OutputDebug, %TestName%:%A_LineNumber%: Can NOT read data from registry. Key might not exist. Using hardcoded path.`n
}

IfExist, %ModuleExe%
{
    Process, Close, firefox.exe ; Teminate process
    Sleep, 2500 ; To make sure folders are not locked
    FileRemoveDir, %A_AppData%\Mozilla, 1 ; Delete all saved settings
    Sleep, 1500
    IfNotExist, %A_AppData%\Mozilla
    {
        FileCreateDir, %A_AppData%\Mozilla\Firefox\Profiles\ReactOS.default
        if not ErrorLevel
        {
            FileAppend, [General]`nStartWithLastProfile=0`n`n[Profile0]`nName=default`nIsRelative=1`nPath=Profiles/ReactOS.default`n, %A_AppData%\Mozilla\Firefox\profiles.ini
            if not ErrorLevel
            {
                szNoWarningOnClose := "user_pref(""browser.tabs.warnOnClose""`, false)`;" ; Now, new do not want any warnings when closing multiple tabs
                szNoFirstRun := "user_pref(""browser.startup.homepage_override.mstone""`, ""rv:1.9.0.11"")`;" ; Lets pretend we ran it once
                szRightsShown := "user_pref(""browser.rights.3.shown""`, true)`;" ; We know your rights, no need to ask
                szNoImprvHelp := "user_pref(""toolkit.telemetry.prompted""`, 2)`;`nuser_pref(""toolkit.telemetry.rejected""`, true)`;" ; We don't want to help to improve
                szDownloadDir := "user_pref(""browser.download.folderList""`, 0)`;" ; Desktop is our default download directory
                FileAppend, %szNoWarningOnClose%`n%szNoFirstRun%`n%szRightsShown%`n%szNoImprvHelp%`n`n%szDownloadDir%, %A_AppData%\Mozilla\Firefox\Profiles\ReactOS.default\prefs.js
                if not ErrorLevel
                {
                    Run, %ModuleExe%,,Max ; Start maximized
                    WinWaitActive, Mozilla Firefox Start Page - Mozilla Firefox,, 12
                    if not ErrorLevel
                    {
                        bContinue := true ; We are up and running
                        Sleep, 700
                    }
                    else
                    {
                        OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'Mozilla Firefox Start Page - Mozilla Firefox' window failed to appear.`n
                        bContinue := false
                    }
                }
                else
                {
                    OutputDebug, %TestName%:%A_LineNumber%: Test failed: Failed to create and edit '%A_AppData%\Mozilla\Firefox\Profiles\ReactOS.default\prefs.js'.`n
                    bContinue := false
                }
            }
            else
            {
                OutputDebug, %TestName%:%A_LineNumber%: Test failed: Failed to create and edit '%A_AppData%\Mozilla\Firefox\profiles.ini'.`n
                bContinue := false
            }
        }
        else
        {
            OutputDebug, %TestName%:%A_LineNumber%: Test failed: Failed to create dir tree '%A_AppData%\Mozilla\Firefox\ReactOS.default'.`n
            bContinue := false
        }
    }
    else
    {
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: Seems like we failed to delete '%A_AppData%\Mozilla'.`n
        bContinue := false
    }
}
else
{
    OutputDebug, %TestName%:%A_LineNumber%: Test failed: Can NOT find '%ModuleExe%'.`n
    bContinue := false
}
