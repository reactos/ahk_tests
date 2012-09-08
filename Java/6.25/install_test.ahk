/*
 * Designed for Java 6.25
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

ModuleExe = %A_WorkingDir%\Apps\Java 6.25 Setup.exe
TestName = 1.install
MainAppFile = javaw.exe ; Mostly this is going to be process we need to look for


; Test if Setup file exists, if so, delete installed files, and run Setup
TestsTotal++
IfNotExist, %ModuleExe%
    TestsFailed("'" ModuleExe "' not found.")
else
{
    Process, Close, %MainAppFile% ; Teminate process
    Process, WaitClose, %MainAppFile%, 4
    if ErrorLevel ; The PID still exists.
        TestsFailed("Unable to terminate '" MainAppFile "' process.") ; So, process still exists
    else
    {
        RegRead, InstallLocation, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{26A24AE4-039D-4CA4-87B4-2F83216025FF}, InstallLocation
        if ErrorLevel
        {
            ; There was a problem (such as a nonexistent key or value). 
            ; That probably means we have not installed this app before.
            ; Check in default directory to be extra sure
            IfNotExist, %A_ProgramFiles%\Java
                bContinue := true ; No previous versions detected in hardcoded path
            else
            {
                bHardcoded := true ; To know if we got path from registry or not
                IfExist, %A_ProgramFiles%\Java
                {
                    RunWait, MsiExec.exe /X{26A24AE4-039D-4CA4-87B4-2F83216025FF} /norestart /qb-! ; Silently uninstall it
                    Sleep, 7000
                }

                IfNotExist, %A_ProgramFiles%\Java ; Uninstaller might delete the dir
                    bContinue := true
                {
                    FileRemoveDir, %A_ProgramFiles%\Java, 1
                    if ErrorLevel
                        TestsFailed("Unable to delete existing '" A_ProgramFiles "\Java' ('" MainAppFile "' process is reported as terminated).'")
                    else
                        bContinue := true
                }
            }
        }
        else
        {
            IfNotExist, %InstallLocation%
                bContinue := true
            else
            {
                IfExist, %InstallLocation%
                {
                    RunWait, MsiExec.exe /X{26A24AE4-039D-4CA4-87B4-2F83216025FF} /norestart /qb-! ; Silently uninstall it
                    Sleep, 7000
                }

                IfNotExist, %InstallLocation%
                    bContinue := true
                else
                {
                    FileRemoveDir, %InstallLocation%, 1 ; Delete just in case
                    if ErrorLevel
                        TestsFailed("Unable to delete existing '" InstallLocation "' ('" MainAppFile "' process is reported as terminated).")
                    else
                        bContinue := true
                }
            }
        }
    }

    if bContinue
    {
        RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\MicroSoft\Windows\CurrentVersion\Uninstall\{26A24AE4-039D-4CA4-87B4-2F83216025FF}
        IfExist, %A_AppData%\Sun
        {
            FileRemoveDir, %A_AppData%\Sun, 1
            if ErrorLevel
                TestsFailed("Unable to delete '" A_AppData "\Sun'.")
        }

        if bContinue
        {
            if bHardcoded
                TestsOK("Either there was no previous versions or we succeeded removing it using hardcoded path.")
            else
                TestsOK("Either there was no previous versions or we succeeded removing it using data from registry.")
            Run %ModuleExe%
        }
    }
}



; Test if 'Java Setup - Welcome (Welcome to)' window can appear, if so, check 'Change Destination Folder' and hit 'Install' button
TestsTotal++
if bContinue
{
    WinWaitActive, Java Setup - Welcome, Welcome to, 20
    if ErrorLevel
        TestsFailed("'Java Setup - Welcome (Welcome to)' window failed to appear.")
    else
    {
        Sleep, 700
        Control, Check, , Button1, Java Setup - Welcome, Welcome to ; Check 'Change Destination Folder' checkbox
        if ErrorLevel
            TestsFailed("Unable to check 'Change Destination Folder' checkbox in 'Java Setup - Welcome (Welcome to)' window.")
        else
        {
            Sleep, 700
            ControlClick, Button3, Java Setup - Welcome, Welcome to ; Hit 'Install' button
            if ErrorLevel
                TestsFailed("Unable to hit 'Install' button in 'Java Setup - Welcome (Welcome to)' window.")
            else
                TestsOK("'Java Setup - Welcome (Welcome to)' window appeared, 'Change Destination Folder' checkbox checked and 'Install' button was clicked.")
        }
    }
}


; Test if 'Java Setup - Destination Folder (Install to)' window can appear, if so, hit 'Next' button
TestsTotal++
if bContinue
{
    WinWaitActive, Java Setup - Destination Folder, Install to, 5
    if ErrorLevel
        TestsFailed("'Java Setup - Destination Folder (Install to)' window failed to appear.")
    else
    {
        Sleep, 700
        ControlClick, Button1, Java Setup - Destination Folder, Install to ; Hit 'Next' button
        if ErrorLevel
            TestsFailed("Unable to hit 'Next' button in 'Java Setup - Destination Folder (Install to)' window.")
        else
            TestsOK("'Java Setup - Destination Folder (Install to)' window appeared and 'Next' button was clicked.")
    }
}


; Test if 'Java Setup - Progress (Status)' window can appear, if so, wait for it to close
TestsTotal++
if bContinue
{
    WinWaitActive, Java Setup - Progress, Status, 10
    if ErrorLevel
        TestsFailed("'Java Setup - Progress (Status)' window failed to appear.")
    else
    {
        OutputDebug, OK: %TestName%:%A_LineNumber%: 'Java Setup - Progress (Status)' window appeared, waiting for it to close.`n
        WinWaitClose, Java Setup - Progress, Status, 25 ; Should be enough time to get it installed
        if ErrorLevel
            TestsFailed("'Java Setup - Progress (Status)' window failed to close.")
        else
            TestsOK("'Java Setup - Progress (Status)' window went away.")
    }
}


; Test if 'Java Setup - Complete (You have)' window can appear, if so, hit 'Close' button
TestsTotal++
if bContinue
{
    WinWaitActive, Java Setup - Complete, You have, 5
    if ErrorLevel
        TestsFailed("'Java Setup - Complete (You have)' window failed to appear.")
    else
    {
        Sleep, 700
        ControlClick, Button2, Java Setup - Complete, You have ; Hit 'Close' button
        if ErrorLevel
            TestsFailed("Unable to hit 'Close' button in 'Java Setup - Complete (You have)' window.")
        else
        {
            WinWaitClose, Java Setup - Complete, You have, 5
            if ErrorLevel
                TestsFailed("'Java Setup - Complete (You have)' window failed to close despite 'Close' button being clicked.")
            else
                TestsOK("'Java Setup - Complete (You have)' window appeared and 'Close' button was clicked.")
        }
    }
}


; Check if program exists
TestsTotal++
if bContinue
{
    Sleep, 2000
    RegRead, InstalledDir, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{26A24AE4-039D-4CA4-87B4-2F83216025FF}, InstallLocation
    if ErrorLevel
        TestsFailed("Either we can't read from registry or data doesn't exist.")
    else
    {
        IfNotExist, %InstalledDir%bin\%MainAppFile% ; Registry data (the path) contains trailing backslash
            TestsFailed("Something went wrong, can't find '" InstalledDir "bin\" MainAppFile "'.")
        else
            TestsOK("The application has been installed, because '" InstalledDir "bin\" MainAppFile "' was found.")
    }
}
