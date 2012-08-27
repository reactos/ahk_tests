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

bContinue := false
TestsTotal := 0
TestsSkipped := 0
TestsFailed := 0
TestsOK := 0
TestsExecuted := 0
TestName = prepare

RegRead, UninstallerPath, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Mozilla Sunbird (0.9), UninstallString
if ErrorLevel
{
    ModuleExe = %A_ProgramFiles%\Mozilla Sunbird\sunbird.exe
    OutputDebug, %TestName%:%A_LineNumber%: Can NOT read data from registry. Key might not exist. Using hardcoded path.`n
}
else
{
    StringReplace, UninstallerPath, UninstallerPath, `",, All ; String contains quotes, replace em
    SplitPath, UninstallerPath,, InstalledDir
    ModuleExe = %InstalledDir%\..\sunbird.exe ; Go back one folder
}


IfNotExist, %ModuleExe%
    OutputDebug, %TestName%:%A_LineNumber%: Test failed: Can NOT find '%ModuleExe%'.`n
else
{
    Process, Close, sunbird.exe ; Teminate process
    Sleep, 2500 ; To make sure folders are not locked
    FileRemoveDir, %A_AppData%\Mozilla, 1 ; Delete all saved settings
    Sleep, 1500
    IfExist, %A_AppData%\Mozilla
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: Seems like we failed to delete '%A_AppData%\Mozilla'.`n
    else
    {
        FileCreateDir, %A_AppData%\Mozilla\Sunbird\Profiles\ReactOS.default
        if ErrorLevel
            OutputDebug, %TestName%:%A_LineNumber%: Test failed: Failed to create dir tree '%A_AppData%\Mozilla\Sunbird\ReactOS.default'.`n
        else
        {
            FileAppend, [General]`nStartWithLastProfile=0`n`n[Profile0]`nName=default`nIsRelative=1`nPath=Profiles/ReactOS.default`n, %A_AppData%\Mozilla\Sunbird\profiles.ini
            if ErrorLevel
                OutputDebug, %TestName%:%A_LineNumber%: Test failed: Failed to create and edit '%A_AppData%\Mozilla\Sunbird\profiles.ini'.`n
            else
            {
                szNoUpdate := "user_pref(""app.update.enabled""`, false)`;`n" ; Disable automatic application update
                szNoPluginUpdate := "user_pref(""extensions.update.enabled""`, false)`;" ; Disable automatic extansion update
                szUpdateMode := "user_pref(""app.update.mode""`, 0)`;`n" ; Don't warn
                
                FileAppend, %szNoUpdate%%szNoPluginUpdate%%szUpdateMode%, %A_AppData%\Mozilla\Sunbird\Profiles\ReactOS.default\prefs.js
                if ErrorLevel
                    OutputDebug, %TestName%:%A_LineNumber%: Test failed: Failed to create and edit '%A_AppData%\Mozilla\Sunbird\Profiles\ReactOS.default\prefs.js'.`n
                else
                {
                    Run, %ModuleExe% ; 'Max' does not work
                    FormatTime, TimeString,, LongDate
                    WinWaitActive, %TimeString% - Sunbird,, 12
                    if ErrorLevel
                        OutputDebug, %TestName%:%A_LineNumber%: Test failed: '%TimeString% - Sunbird' window failed to appear.`n
                    else
                    {
                        bContinue := true ; We are up and running
                        WinMaximize, %TimeString% - Sunbird
                        Sleep, 1000
                    }
                }
            }
        }
    }
}
