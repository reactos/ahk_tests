/*
 * Designed for Abyss Web Server X1 2.7
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

ModuleExe = %A_WorkingDir%\Apps\Abyss Web Server X1 2.7 Setup.exe
TestName = 1.install
MainAppFile = abyssws.exe ; Mostly this is going to be process we need to look for

; Test if Setup file exists, if so, delete installed files, and run Setup
TestsTotal++
IfNotExist, %ModuleExe%
    TestsFailed("'" ModuleExe "' not found.")
else
{
    loop, 2 ; There are two 'abyssws.exe' processes running
    {
        Process, Close, %MainAppFile% ; Teminate process
        Sleep, 1000 ; Sleep is required
    }
    Process, WaitClose, %MainAppFile%, 4
    if ErrorLevel ; The PID still exists.
        TestsFailed("Unable to terminate '" MainAppFile "' process.") ; So, process still exists
    else
    {
        RegRead, UninstallerPath, HKEY_CURRENT_USER, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\AbyssWebServer, UninstallString
        if ErrorLevel
        {
            ; There was a problem (such as a nonexistent key or value). 
            ; That probably means we have not installed this app before.
            ; Check in default directory to be extra sure
            bHardcoded := true ; To know if we got path from registry or not
            szDefaultDir = %A_ProgramFiles%\Abyss Web Server
            IfNotExist, %szDefaultDir%
            {
                TestsInfo("No previous versions detected in hardcoded path: '" szDefaultDir "'.")
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
        else
        {
            UninstallerPath := ExeFilePathNoParam(UninstallerPath)
            SplitPath, UninstallerPath,, InstalledDir
            IfNotExist, %InstalledDir%
            {
                TestsInfo("Got '" InstalledDir "' from registry and such path does not exist.")
                bContinue := true
            }
            else
            {
                ; Silent switch '/S' shows a dialog
                FileRemoveDir, %InstalledDir%, 1
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

    if bContinue
    {
        RegDelete, HKEY_CURRENT_USER, Software\AbyssWebServer ; If this is not deleted, window 'Abyss Web Server X1 Setup (Another version)' will pop-up
        RegDelete, HKEY_CURRENT_USER, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\AbyssWebServer

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


; Test if 'Abyss Web Server X1 Setup: License Agreement (Please read)' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Abyss Web Server X1 Setup: License Agreement, Please read, 7
    if ErrorLevel
    {
        IfWinActive, Abyss Web Server X1 Setup, Another version
            TestsFailed("We probably failed to delete 'HKCU\Software\AbyssWebServer'.")
        else
            TestsFailed("'Abyss Web Server X1 Setup: License Agreement (Please read)' window failed to appear.")
    }
    else
    {
        ControlClick, Button2, Abyss Web Server X1 Setup: License Agreement, Please read ; Hit 'I Agree' button
        if ErrorLevel
            TestsFailed("Unable to hit 'I Agree' button in 'Abyss Web Server X1 Setup: License Agreement (Please read)' window.")
        else
        {
            WinWaitClose, Abyss Web Server X1 Setup: License Agreement, Please read, 3
            if ErrorLevel
                TestsFailed("'Abyss Web Server X1 Setup: License Agreement (Please read)' window failed to close despite 'I Agree' button being clicked.")
            else
                TestsOK("'Abyss Web Server X1 Setup: License Agreement (Please read)' window appeared, 'I Agree' button clicked and window closed.")
        }
    }
}


; Test if 'Abyss Web Server X1 Setup: Installation Options (This will install)' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Abyss Web Server X1 Setup: Installation Options, This will install, 3
    if ErrorLevel
        TestsFailed("'Abyss Web Server X1 Setup: Installation Options (This will install)' window failed to appear.")
    else
    {
        ControlClick, Button2, Abyss Web Server X1 Setup: Installation Options, This will install ; Hit 'Next' button
        if ErrorLevel
            TestsFailed("Unable to hit 'Next' button in 'Abyss Web Server X1 Setup: Installation Options (This will install)' window.")
        else
            TestsOK("'Abyss Web Server X1 Setup: Installation Options (This will install)' window appeared and 'Next' button was clicked.")
    }
}


; Test if 'Abyss Web Server X1 Setup: Installation Folder (Choose a directory)' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Abyss Web Server X1 Setup: Installation Folder, Choose a directory, 3
    if ErrorLevel
        TestsFailed("'Abyss Web Server X1 Setup: Installation Folder (Choose a directory)' window failed to appear.")
    else
    {
        ControlClick, Button2, Abyss Web Server X1 Setup: Installation Folder, Choose a directory ; Hit 'Install' button
        if ErrorLevel
            TestsFailed("Unable to hit 'Install' button in 'Abyss Web Server X1 Setup: Installation Folder (Choose a directory)' window.")
        else
            TestsOK("'Abyss Web Server X1 Setup: Installation Folder (Choose a directory)' window appeared and 'Install' button was clicked.")
    }
}


; Test if can get thru 'Abyss Web Server X1 Setup: Installing (Show)' window
TestsTotal++
if bContinue
{
    WinWaitActive, Abyss Web Server X1 Setup: Installing, Show, 3
    if ErrorLevel
        TestsFailed("'Abyss Web Server X1 Setup: Installing (Show)' window failed to appear.")
    else
    {
        WinWaitActive, Abyss Web Server Startup Configuration, Select the startup, 25
        if ErrorLevel
            TestsFailed("'Abyss Web Server Startup Configuration (Select the startup)' window failed to pop-up.")
        else
        {
            ControlClick, Button3, Abyss Web Server Startup Configuration, Select the startup ; Check 'Manual startup' radiobutton
            if ErrorLevel
                TestsFailed("Unable to check 'Manual startup' radiobutton in 'Abyss Web Server Startup Configuration (Select the startup)' window.")
            else
            {
                ControlClick, Button1, Abyss Web Server Startup Configuration, Select the startup ; Hit 'OK' button
                if ErrorLevel
                    TestsFailed("Unable to hit 'OK' button in 'Abyss Web Server Startup Configuration (Select the startup)' window.")
                else
                {
                    WinWaitClose, Abyss Web Server Startup Configuration, Select the startup, 5
                    if ErrorLevel
                        TestsFailed("'Abyss Web Server Startup Configuration (Select the startup)' window failed to close despite 'OK' button being clicked.")
                    else
                    {
                        TestsInfo("'Abyss Web Server Startup Configuration (Select the startup)' window appeared and closed.")
                        WinWaitActive, Abyss Web Server X1 Setup, Setup has completed, 5
                        if ErrorLevel
                            TestsFailed("'Abyss Web Server X1 Setup (Setup has completed)' window failed to appear.")
                        else
                        {
                            ControlClick, Button2, Abyss Web Server X1 Setup, Setup has completed ; Hit 'No' button
                            if ErrorLevel
                                TestsFailed("Unable to hit 'No' button in 'Abyss Web Server X1 Setup (Setup has completed)' window.")
                            else
                            {
                                WinWaitActive, Abyss Web Server X1 Setup: Completed, Completed, 5
                                if ErrorLevel
                                    TestsFailed("'Abyss Web Server X1 Setup: Completed (Completed)' window failed to appear.")
                                else
                                {
                                    ControlClick, Button2, Abyss Web Server X1 Setup: Completed, Completed ; Hit 'Close' button
                                    if ErrorLevel
                                        TestsFailed("Unable to hit 'Close' button in 'Abyss Web Server X1 Setup: Completed (Completed)' window.")
                                    else
                                    {
                                        WinWaitClose, Abyss Web Server X1 Setup: Completed, Completed, 5
                                        if ErrorLevel
                                            TestsFailed("'Abyss Web Server X1 Setup: Completed (Completed)' window failed to close.")
                                        else
                                            TestsOK("Got thu a lot of windows successfully.")
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


; Check if program exists
TestsTotal++
if bContinue
{
    RegRead, UninstallerPath, HKEY_CURRENT_USER, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\AbyssWebServer, UninstallString
    if ErrorLevel
        TestsFailed("Either we can't read from registry or data doesn't exist.")
    else
    {
        StringReplace, UninstallerPath, UninstallerPath, `", , All ; Abyss string path contains quotes
        SplitPath, UninstallerPath,, InstalledDir
        IfNotExist, %InstalledDir%\%MainAppFile%
            TestsFailed("Something went wrong, can't find '" InstalledDir "\" MainAppFile "'.")
        else
            TestsOK("The application has been installed, because '" InstalledDir "\" MainAppFile "' was found.")
    }
}
