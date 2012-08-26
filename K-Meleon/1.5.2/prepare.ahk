/*
 * Designed for K-Meleon 1.5.2
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

RegRead, UninstallerPath, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\K-Meleon, UninstallString
if not ErrorLevel
{
    StringReplace, UninstallerPath, UninstallerPath, `",, All ; String contains quotes, replace em
    SplitPath, UninstallerPath,, InstalledDir
    ModuleExe = %InstalledDir%\k-meleon.exe
}
else
{
    ModuleExe = %A_ProgramFiles%\K-Meleon\k-meleon.exe
    OutputDebug, %TestName%:%A_LineNumber%: Can NOT read data from registry. Key might not exist. Using hardcoded path.`n
}

IfExist, %ModuleExe%
{
    Process, Close, k-meleon.exe ; Teminate process
    Sleep, 2500 ; To make sure folders are not locked by process
    FileRemoveDir, %A_AppData%\K-Meleon, 1 ; Delete all saved settings
    Sleep, 1500
    IfNotExist, %A_AppData%\K-Meleon
    {
        FileCreateDir, %A_AppData%\K-Meleon\ReactOS.default
        if not ErrorLevel
        {
            FileAppend, [General]`nStartWithLastProfile=1`n`n[Profile0]`nName=default`nDefault=1`nIsRelative=1`nPath=ReactOS.default`n, %A_AppData%\K-Meleon\profiles.ini
            if not ErrorLevel
            {
                szNoUpdate := "user_pref(""kmeleon.plugins.update.load""`, false)`;" ; Don't check for updates
                FileAppend, %szNoUpdate%`n, %A_AppData%\K-Meleon\ReactOS.default\prefs.js
                if not ErrorLevel
                {
                    Sleep, 2500
                    Run, %ModuleExe% ; 'Max' doesn't work here
                    WinWaitActive, K-Meleon 1.5.2 (K-Meleon),, 12
                    if not ErrorLevel
                    {
                        WinMaximize, K-Meleon 1.5.2 (K-Meleon)
                        bContinue := true ; We are up and running
                        Sleep, 1500
                    }
                    else
                        OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'K-Meleon 1.5.2 (K-Meleon)' window failed to appear.`n
                }
                else
                    OutputDebug, %TestName%:%A_LineNumber%: Test failed: Failed to create and edit '%A_AppData%\K-Meleon\ReactOS.default\prefs.js'.`n
            }
            else
                OutputDebug, %TestName%:%A_LineNumber%: Test failed: Failed to create and edit '%A_AppData%\K-Meleon\profiles.ini'.`n
        }
        else
            OutputDebug, %TestName%:%A_LineNumber%: Test failed: Failed to create dir tree '%A_AppData%\K-Meleon\ReactOS.default'.`n
    }
    else
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: Seems like we failed to delete '%A_AppData%\K-Meleon'.`n
}
else
    OutputDebug, %TestName%:%A_LineNumber%: Test failed: Can NOT find '%ModuleExe%'.`n
