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

TestName = prepare

RegRead, UninstallerPath, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Mozilla Thunderbird (2.0.0.18), UninstallString
if ErrorLevel
{
    ModuleExe = %A_ProgramFiles%\Mozilla Thunderbird\thunderbird.exe
    OutputDebug, %TestName%:%A_LineNumber%: Can NOT read data from registry. Key might not exist. Using hardcoded path.`n
}
else
{
    StringReplace, UninstallerPath, UninstallerPath, `",, All ; String contains quotes, replace em
    SplitPath, UninstallerPath,, InstalledDir
    ModuleExe = %InstalledDir%\..\thunderbird.exe ; Go back one folder
}

szDocument = %A_WorkingDir%\Media\Thunderbird 2.0.0.18 prefs.js ; Case insensitive

TestsTotal++
IfNotExist, %ModuleExe%
    TestsFailed("Can NOT find '" ModuleExe "'").
else
{
    Process, Close, thunderbird.exe ; Teminate process
    Sleep, 2500 ; To make sure folders are not locked
    FileRemoveDir, %A_AppData%\Thunderbird, 1 ; Delete all saved settings
    Sleep, 1500
    IfExist, %A_AppData%\Thunderbird
        TestsFailed("Seems like we failed to delete '" A_AppData "\Thunderbird'.")
    else
    {
        FileCreateDir, %A_AppData%\Thunderbird\Profiles\ReactOS.default\Mail\Local Folders
        if ErrorLevel
            TestsFailed("Failed to create dir tree '" A_AppData "\Thunderbird\ReactOS.default\Mail\Local Folders'.")
        else
        {
            FileAppend, [General]`nStartWithLastProfile=1`n`n[Profile0]`nName=default`nIsRelative=1`nPath=Profiles/ReactOS.default`n, %A_AppData%\Thunderbird\profiles.ini
            if ErrorLevel
                TestsFailed("Failed to create and edit '" A_AppData "\Thunderbird\profiles.ini'.")
            else
            {
                IfNotExist, %szDocument%
                    TestsFailed("Can NOT find '" szDocument "'.")
                else
                {
                    FileCopy, %szDocument%, %A_AppData%\Thunderbird\Profiles\ReactOS.default\prefs.js
                    if ErrorLevel <> 0
                        TestsFailed("Can NOT copy '" szDocument "' to '" A_AppData "\Thunderbird\Profiles\ReactOS.default\prefs.js'.")
                    else
                    {
                        ; We need those two extension-less files
                        FileAppend,, %A_AppData%\Thunderbird\Profiles\ReactOS.default\Mail\Local Folders\Trash
                        if ErrorLevel
                            TestsFailed("Unable to create extension-less file '" A_AppData "\Thunderbird\Profiles\ReactOS.default\Mail\Local Folders\Trash'.")
                        else
                        {
                            FileAppend,, %A_AppData%\Thunderbird\Profiles\ReactOS.default\Mail\Local Folders\Unsent Messages
                            if ErrorLevel
                                TestsFailed("Unable to create extension-less file '" A_AppData "\Thunderbird\Profiles\ReactOS.default\Mail\Local Folders\Unsent Messages'.")
                            else
                            {
                                Run, %ModuleExe%,, Max ; Start maximized
                                WinWaitActive, Enter your password:,,15
                                if ErrorLevel
                                {
                                    Process, Exist, thunderbird.exe
                                    NewPID = %ErrorLevel%  ; Save the value immediately since ErrorLevel is often changed.
                                    if NewPID = 0
                                        TestsFailed("Window 'Enter your password:' failed to appear. No 'thunderbird.exe' process detected.")
                                    else
                                        TestsFailed("Window 'Enter your password:' failed to appear. 'thunderbird.exe' process detected.")
                                }
                                else
                                {
                                    SendInput, 3d1ju5test{ENTER} ; ControlClick won't work
                                    WinWaitActive, Inbox for reactos.dev@gmail.com - Thunderbird,,15
                                    if ErrorLevel
                                        TestsFailed("Window 'Inbox for reactos.dev@gmail.com - Thunderbird' failed to appear.")
                                    else
                                    {
                                        TestsOK("We are logged in.")
                                        Sleep, 3000 ; yeah, at least 3 secs
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
