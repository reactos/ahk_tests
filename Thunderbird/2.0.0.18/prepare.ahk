/*
 * Designed for Thunderbird 2.0.0.18
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

RegRead, UninstallerPath, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Mozilla Thunderbird (2.0.0.18), UninstallString
if not ErrorLevel
{
    StringReplace, UninstallerPath, UninstallerPath, `",, All ; String contains quotes, replace em
    SplitPath, UninstallerPath,, InstalledDir
    ModuleExe = %InstalledDir%\..\thunderbird.exe ; Go back one folder
}
else
{
    ModuleExe = %A_ProgramFiles%\Mozilla Thunderbird\thunderbird.exe
    OutputDebug, %TestName%:%A_LineNumber%: Can NOT read data from registry. Key might not exist. Using hardcoded path.`n
}

szDocument = %A_WorkingDir%\Media\Thunderbird 2.0.0.18 prefs.js ; Case insensitive

IfExist, %ModuleExe%
{
    Process, Close, thunderbird.exe ; Teminate process
    Sleep, 2500 ; To make sure folders are not locked
    FileRemoveDir, %A_AppData%\Thunderbird, 1 ; Delete all saved settings
    Sleep, 1500
    IfNotExist, %A_AppData%\Thunderbird
    {
        FileCreateDir, %A_AppData%\Thunderbird\Profiles\ReactOS.default\Mail\Local Folders
        if not ErrorLevel
        {
            FileAppend, [General]`nStartWithLastProfile=1`n`n[Profile0]`nName=default`nIsRelative=1`nPath=Profiles/ReactOS.default`n, %A_AppData%\Thunderbird\profiles.ini
            if not ErrorLevel
            {
                IfExist, %szDocument%
                {
                    FileCopy, %szDocument%, %A_AppData%\Thunderbird\Profiles\ReactOS.default\prefs.js
                    if ErrorLevel = 0
                    {
                        ; We need those two extension-less files
                        FileAppend,, %A_AppData%\Thunderbird\Profiles\ReactOS.default\Mail\Local Folders\Trash
                        FileAppend,, %A_AppData%\Thunderbird\Profiles\ReactOS.default\Mail\Local Folders\Unsent Messages
                        Run, %ModuleExe%,, Max ; Start maximized
                        WinWaitActive, Enter your password:,,15
                        if not ErrorLevel
                        {
                            SendInput, 3d1ju5test{ENTER} ; ControlClick won't work
                            WinWaitActive, Inbox for reactos.dev@gmail.com - Thunderbird,,15
                            if not ErrorLevel
                            {
                                OutputDebug, OK: %TestName%:%A_LineNumber%: We are logged in.`n
                                Sleep, 3000 ; yeah, at least 3 secs
                                bContinue := true
                            }
                            else
                            {
                                WinGetTitle, title, A
                                OutputDebug, %TestName%:%A_LineNumber%: Test failed: Window 'Inbox for reactos.dev@gmail.com - Thunderbird' failed to appear. Active window caption: '%title%'`n
                            }
                        }
                        else
                        {
                            WinGetTitle, title, A
                            OutputDebug, %TestName%:%A_LineNumber%: Test failed: Window 'Enter your password:' failed to appear. Active window caption: '%title%'`n
                        }
                    }
                    else
                    {
                        WinGetTitle, title, A
                        OutputDebug, %TestName%:%A_LineNumber%: Can NOT copy '%szDocument%' to '%A_AppData%\Thunderbird\Profiles\ReactOS.default\prefs.js'. Active window caption: '%title%'`n
                    }
                }
                else
                {
                    WinGetTitle, title, A
                    OutputDebug, %TestName%:%A_LineNumber%: Test failed: Can NOT find '%szDocument%'. Active window caption: '%title%'`n
                }
            }
            else
            {
                WinGetTitle, title, A
                OutputDebug, %TestName%:%A_LineNumber%: Test failed: Failed to create and edit '%A_AppData%\Thunderbird\profiles.ini'. Active window caption: '%title%'`n
            }
        }
        else
        {
            WinGetTitle, title, A
            OutputDebug, %TestName%:%A_LineNumber%: Test failed: Failed to create dir tree '%A_AppData%\Thunderbird\ReactOS.default\Mail\Local Folders'. Active window caption: '%title%'`n
        }
    }
    else
    {
        WinGetTitle, title, A
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: Seems like we failed to delete '%A_AppData%\Thunderbird'. Active window caption: '%title%'`n
    }
}
else
{
    OutputDebug, %TestName%:%A_LineNumber%: Test failed: Can NOT find '%ModuleExe%'.`n
}
