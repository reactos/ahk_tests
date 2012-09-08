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

TestName = prepare

RegRead, UninstallerPath, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\K-Meleon, UninstallString
if ErrorLevel
{
    ModuleExe = %A_ProgramFiles%\K-Meleon\k-meleon.exe
    OutputDebug, %TestName%:%A_LineNumber%: Can NOT read data from registry. Key might not exist. Using hardcoded path.`n
}
else
{
    StringReplace, UninstallerPath, UninstallerPath, `",, All ; String contains quotes, replace em
    SplitPath, UninstallerPath,, InstalledDir
    ModuleExe = %InstalledDir%\k-meleon.exe
}


; Terminate application
TestsTotal++
SplitPath, ModuleExe, ProcessExe
Process, Close, %ProcessExe%
Process, WaitClose, %ProcessExe%, 4
if ErrorLevel
    TestsFailed("Process '" ProcessExe "' failed to close.")
else
    TestsOK("")


; Delete settings separately from RunApplication() in case we want to write our own settings
TestsTotal++
IfExist, %A_AppData%\K-Meleon
{
    FileRemoveDir, %A_AppData%\K-Meleon, 1
    if ErrorLevel
        TestsFailed("Unable to delete '" A_AppData "\K-Meleon'.")
    else
        TestsOK("")
}
else
    TestsOK("")


; Test if can start application
RunApplication(PathToFile, Title)
{
    global ModuleExe
    global TestName
    global TestsTotal
    global ProcessExe

    TestsTotal++
    IfNotExist, %ModuleExe%
        TestsFailed("Can NOT find '" ModuleExe "'.")
    else
    {
        FileCreateDir, %A_AppData%\K-Meleon\ReactOS.default
        if ErrorLevel
            TestsFailed("Failed to create dir tree '" A_AppData "\K-Meleon\ReactOS.default'.")
        else
        {
            FileAppend, [General]`nStartWithLastProfile=1`n`n[Profile0]`nName=default`nDefault=1`nIsRelative=1`nPath=ReactOS.default`n, %A_AppData%\K-Meleon\profiles.ini
            if ErrorLevel
                TestsFailed("Failed to create and edit '" A_AppData "\K-Meleon\profiles.ini'.")
            else
            {
                szNoUpdate := "user_pref(""kmeleon.plugins.update.load""`, false)`;" ; Don't check for updates
                FileAppend, %szNoUpdate%`n, %A_AppData%\K-Meleon\ReactOS.default\prefs.js
                if ErrorLevel
                    TestsFailed("Failed to create and edit '" A_AppData "\K-Meleon\ReactOS.default\prefs.js'.")
                else
                {
                    Sleep, 2500
                    ; 'Title' param is ignored
                    If PathToFile =
                    {
                        Run, %ModuleExe% ; 'Max' doesn't work here
                        WinWaitActive, K-Meleon 1.5.2 (K-Meleon),, 12
                        if ErrorLevel
                        {
                            Process, Exist, %ProcessExe%
                            NewPID = %ErrorLevel%  ; Save the value immediately since ErrorLevel is often changed.
                            if NewPID = 0
                                TestsFailed("'K-Meleon 1.5.2 (K-Meleon)' window failed to appear. No '" ProcessExe "' process detected.")
                            else
                                TestsFailed("'K-Meleon 1.5.2 (K-Meleon)' window failed to appear. '" ProcessExe "' process detected.")
                        }
                        else
                        {
                            WinMaximize, K-Meleon 1.5.2 (K-Meleon)
                            TestsOK("")
                            Sleep, 1500
                        }
                    }
                    else
                    {
                        IfNotExist, %PathToFile%
                            TestsFailed("Can NOT find '" PathToFile "'.")
                        else
                        {
                            ; FIXME: read <title> from HTML instead of passing it as param2.
                            Run, %ModuleExe%  %PathToFile% ; 'Max' doesn't work here
                            WinWaitActive, %Title% (K-Meleon),, 12
                            if ErrorLevel
                            {
                                Process, Exist, %ProcessExe%
                                NewPID = %ErrorLevel%  ; Save the value immediately since ErrorLevel is often changed.
                                if NewPID = 0
                                    TestsFailed("'" Title " (K-Meleon)' window failed to appear. No '" ProcessExe "' process detected.")
                                else
                                    TestsFailed("'" Title " K-Meleon 1.5.2 (K-Meleon)' window failed to appear. '" ProcessExe "' process detected.")
                            }
                            else
                            {
                                WinMaximize, %Title% (K-Meleon)
                                TestsOK("")
                                Sleep, 1500
                            }
                        }
                    }
                }
            }
        }
    }
}
