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
            bHardcoded := true ; To know if we got path from registry or not
            szDefaultDir = %A_ProgramFiles%\Java
            IfNotExist, %szDefaultDir%
            {
                TestsInfo("No previous versions detected in hardcoded path: '" szDefaultDir "'.")
                bContinue := true
            }
            else
            {   
                UninstallerPath = %A_WinDir%\System32\MsiExec.exe /X{26A24AE4-039D-4CA4-87B4-2F83216025FF} /norestart /qb-!
                WaitUninstallDone(UninstallerPath, 7)
                if bContinue
                {
                    IfNotExist, %szDefaultDir% ; Uninstaller might delete the dir
                    {
                        TestsInfo("Uninstaller deleted hardcoded path: '" szDefaultDir "'.")
                        bContinue := true
                    }
                    else
                    {
                        FileRemoveDir, %szDefaultDir%, 1
                        if ErrorLevel
                            TestsFailed("Unable to delete hardcoded path '" szDefaultDir "' ('" MainAppFile "' process is reported as terminated).'")
                        else
                        {
                            TestsInfo("Succeeded deleting hardcoded path, because uninstaller did not: '" szDefaultDir "'.")
                            bContinue := true
                        }
                    }
                }
            }
        }
        else
        {
            InstalledDir = %InstallLocation%
            IfNotExist, %InstalledDir%
            {
                TestsInfo("Got '" InstalledDir "' from registry and such path does not exist.")
                bContinue := true
            }
            else
            {
                UninstallerPath = %A_WinDir%\System32\MsiExec.exe /X{26A24AE4-039D-4CA4-87B4-2F83216025FF} /norestart /qb-!
                WaitUninstallDone(UninstallerPath, 7)
                if bContinue
                {
                    IfNotExist, %InstalledDir%
                    {
                        TestsInfo("Uninstaller deleted path (registry data): '" InstalledDir "'.")
                        bContinue := true
                    }
                    else
                    {
                        FileRemoveDir, %InstalledDir%, 1 ; Uninstaller leaved the path for us to delete, so, do it
                        if ErrorLevel
                            TestsFailed("Unable to delete existing '" InstalledDir "' ('" MainAppFile "' process is reported as terminated).")
                        else
                        {
                            TestsInfo("Succeeded deleting path (registry data), because uninstaller did not: '" InstalledDir "'.")
                            bContinue := true
                        }
                    }
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
    iTimeOut := 40
    SplitPath, ModuleExe, ProcessExe 
    while iTimeOut > 0
    {
        Process, Exist, %ProcessExe%
        if ErrorLevel = 0
        {
            TestsFailed("Process '" ProcessExe "' does not exist (iTimeOut=" iTimeOut ").")
            break ; exit the loop
        }
        else
        {
            IfWinNotActive, Java Setup - Welcome, Welcome to
            {
                WinWaitActive, Java Setup - Welcome, Welcome to, 1
                iTimeOut--
            }
            else
                break
        }
    }

    WinWaitActive, Java Setup - Welcome, Welcome to, 1
    if ErrorLevel
        TestsFailed("'Java Setup - Welcome (Welcome to)' window failed to appear (iTimeOut=" iTimeOut ").")
    else
    {
        Control, Check, , Button1, Java Setup - Welcome, Welcome to ; Check 'Change Destination Folder' checkbox
        if ErrorLevel
            TestsFailed("Unable to check 'Change Destination Folder' checkbox in 'Java Setup - Welcome (Welcome to)' window.")
        else
        {
            ; Java Setup haves wrong characters displayed, but ControlGetText returns right text, so, need better way to
            ; check if correct characters are displayed.
            ;szControlText := "Click Install to accept the"
            ;ControlGetText, OutputVar, Static8, Java Setup - Welcome, Welcome to
            ;if ErrorLevel
            ;    TestsInfo("Unable to get control text in 'Java Setup - Welcome, Welcome to' window.")
            ;else
            ;{
            ;    if OutputVar <> %szControlText%
            ;        TestsInfo("FAILED: Control text is not the same as expected. (is '" OutputVar "', should be '" szControlText "').")
            ;    else
            ;        TestsInfo("OK: Control text is the same as expected, so, Java setup characters are all right.")
            ;}
            ControlClick, Button3, Java Setup - Welcome, Welcome to ; Hit 'Install' button
            if ErrorLevel
                TestsFailed("Unable to hit 'Install' button in 'Java Setup - Welcome (Welcome to)' window.")
            else
            {
                WinWaitClose, Java Setup - Welcome, Welcome to, 3
                if ErrorLevel
                    TestsFailed("'Java Setup - Welcome (Welcome to)' window failed to close despite 'Install' button being clicked.")
                else
                    TestsOK("'Java Setup - Welcome (Welcome to)' window appeared, 'Change Destination Folder' checkbox checked and 'Install' button was clicked (iTimeOut=" iTimeOut ").")
            }
        }
    }
}


; Test if 'Java Setup - Destination Folder (Install to)' window can appear, if so, hit 'Next' button
TestsTotal++
if bContinue
{
    WinWaitActive, Java Setup - Destination Folder, Install to, 3
    if ErrorLevel
        TestsFailed("'Java Setup - Destination Folder (Install to)' window failed to appear.")
    else
    {
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
    WinWaitActive, Java Setup - Progress, Status, 15 ; Takes some time
    if ErrorLevel
        TestsFailed("'Java Setup - Progress (Status)' window failed to appear.")
    else
    {
        TestsInfo("'Java Setup - Progress (Status)' window appeared, waiting for it to close.")
        
        iTimeOut := 65
        while iTimeOut > 0
        {
            IfWinActive, Java Setup - Progress, Status
            {
                WinWaitClose, Java Setup - Progress, Status, 1
                iTimeOut--
            }
            else
                break ; exit the loop if something poped-up
        }
        
        WinWaitClose, Java Setup - Progress, Status, 1
        if ErrorLevel
            TestsFailed("'Java Setup - Progress (Status)' window failed to close (iTimeOut=" iTimeOut ").")
        else
            TestsOK("'Java Setup - Progress (Status)' window closed (iTimeOut=" iTimeOut ").")
    }
}


; Test if 'Java Setup - Complete (You have)' window can appear, if so, hit 'Close' button
TestsTotal++
if bContinue
{
    WinWaitActive, Java Setup - Complete, You have, 3
    if ErrorLevel
        TestsFailed("'Java Setup - Complete (You have)' window failed to appear.")
    else
    {
        ControlClick, Button2, Java Setup - Complete, You have ; Hit 'Close' button
        if ErrorLevel
            TestsFailed("Unable to hit 'Close' button in 'Java Setup - Complete (You have)' window.")
        else
        {
            WinWaitClose, Java Setup - Complete, You have, 3
            if ErrorLevel
                TestsFailed("'Java Setup - Complete (You have)' window failed to close despite 'Close' button being clicked.")
            else
                TestsOK("'Java Setup - Complete (You have)' window appeared and 'Close' button clicked, window closed.")
        }
    }
}


; Check if program exists
TestsTotal++
if bContinue
{
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
