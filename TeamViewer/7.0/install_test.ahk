/*
 * Designed for TeamViewer 7.0 (7.0.12979)
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

ModuleExe = %A_WorkingDir%\Apps\TeamViewer_7.0_Setup.exe
TestName = 1.install
MainAppFile = TeamViewer.exe ; Mostly this is going to be process we need to look for

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
        RegRead, UninstallerPath, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\TeamViewer 7, UninstallString
        if ErrorLevel
        {
            ; There was a problem (such as a nonexistent key or value). 
            ; That probably means we have not installed this app before.
            ; Check in default directory to be extra sure
            bHardcoded := true ; To know if we got path from registry or not
            szDefaultDir = %A_ProgramFiles%\TeamViewer
            IfNotExist, %szDefaultDir%
            {
                TestsInfo("No previous versions detected in hardcoded path: '" szDefaultDir "'.")
                bContinue := true
            }
            else
            {   
                UninstallerPath = %szDefaultDir%\uninstall.exe /S
                WaitUninstallDone(UninstallerPath, 8)
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
            UninstallerPath := ExeFilePathNoParam(UninstallerPath)
            SplitPath, UninstallerPath,, InstalledDir
            IfNotExist, %InstalledDir%
            {
                TestsInfo("Got '" InstalledDir "' from registry and such path does not exist.")
                bContinue := true
            }
            else
            {
                UninstallerPath = %UninstallerPath% /S
                WaitUninstallDone(UninstallerPath, 8) ; Child process 'Au_.exe'

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
        RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\MicroSoft\Windows\CurrentVersion\Uninstall\TeamViewer 7
        IfExist, %A_AppData%\TeamViewer
        {
            FileRemoveDir, %A_AppData%\TeamViewer, 1
            if ErrorLevel
                TestsFailed("Unable to delete '" A_AppData "\TeamViewer'.")
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


; Test if can start setup
TestsTotal++
if bContinue
{
    DetectHiddenText, Off ; Hidden text is not detected
    WinWaitActive, TeamViewer 7 Setup, Welcome to TeamViewer, 7 ; Wait 15 secs for window to appear
    if ErrorLevel
        TestsFailed("'TeamViewer 7 Setup (Welcome to TeamViewer)' window failed to appear.")
    else
    {
        ; Check 'Install' radiobutton
        SendMessage, 0x201, 0, 0, Button4
        SendMessage, 0x202, 0, 0, Button4

        ; Check 'Show advanced settings' checkbox
        SendMessage, 0x201, 0, 0, Button6
        SendMessage, 0x202, 0, 0, Button6

        ; Hit 'Next' button
        SendMessage, 0x201, 0, 0, Button2
        SendMessage, 0x202, 0, 0, Button2
        if ErrorLevel
            TestsFailed("Unable to hit 'Next' button in 'TeamViewer 7 Setup (Welcome to TeamViewer)' window.")
        else
        {
            WinWaitClose, TeamViewer 7 Setup, Welcome to TeamViewer, 3
            if ErrorLevel
                TestsFailed("'TeamViewer 7 Setup (Welcome to TeamViewer)' window failed to close despite 'Next' button being clicked.")
            else
                TestsOK("'TeamViewer 7 Setup (Welcome to TeamViewer)' window appeared, 'Install' radiobutton and 'Show advanced settings' checkbox checked, 'Next' button was clicked.")
        }
    }
}


; Choose 'Company / commercial use' in 'Environment'
TestsTotal++
if bContinue
{
    WinWaitActive, TeamViewer 7 Setup, Environment, 3
    if ErrorLevel
        TestsFailed("'TeamViewer 7 Setup (Environment)' window failed to appear.")
    else
    {
        ; Check 'company / commercial use' radiobutton
        SendMessage, 0x201, 0, 0, Button5
        SendMessage, 0x202, 0, 0, Button5
        if ErrorLevel
            TestsFailed("Failed to check 'personal / non-commercial use' radiobutton in 'TeamViewer 7 Setup (Environment)' window.")
        else
        {
            ; Hit 'Next' button
            SendMessage, 0x201, 0, 0, Button2
            SendMessage, 0x202, 0, 0, Button2
            if ErrorLevel
                TestsFailed("Unable to click 'Next' button in 'TeamViewer 7 Setup (Environment)' window.")
            else
                TestsOK("'company / commercial use' radiobutton checked, 'Next' button was clicked in 'TeamViewer 7 Setup (Environment)' window.")
        }
    }
}


; Test if 'License Agreement' window can appear
TestsTotal++
if bContinue
{
    WinWaitActive, TeamViewer 7 Setup, License Agreement, 3
    if ErrorLevel
        TestsFailed("'License Agreement' window failed to appear.")
    else
    {   
        ; Check 'I accept the terms...' checkbox
        SendMessage, 0x201, 0, 0, Button4
        SendMessage, 0x202, 0, 0, Button4
        if ErrorLevel
            TestsFailed("Failed to check 'I accept the terms...' checkbox in 'License Agreement'.")
        else
        {
            ; Hit 'Next' button
            SendMessage, 0x201, 0, 0, Button2
            SendMessage, 0x202, 0, 0, Button2
            if ErrorLevel
                TestsFailed("Unable to hit 'Next' button in 'TeamViewer 7 Setup (License Agreement)' window.")
            else
                TestsOK("'I accept the terms...' checkbox checked, 'Next' button was clicked in 'TeamViewer 7 Setup (License Agreement)' window.")
        }
    }
}


; Test if 'Choose installation type' window can appear
TestsTotal++
if bContinue
{
    WinWaitActive, TeamViewer 7 Setup, Choose installation type, 3
    if ErrorLevel
        TestsFailed("'TeamViewer 7 Setup (Choose installation type)' window failed to appear.")
    else
    {   
        ; Check 'No (default)' radiobutton
        SendMessage, 0x201, 0, 0, Button4
        SendMessage, 0x202, 0, 0, Button4
        if ErrorLevel
            TestsFailed("Failed to check 'No (default)' radiobutton in 'TeamViewer 7 Setup (Choose installation type)' window.")
        else
        {
            ; Hit 'Next' button
            SendMessage, 0x201, 0, 0, Button2
            SendMessage, 0x202, 0, 0, Button2
            if ErrorLevel
                TestsFailed("Unable to hit 'Next' button in 'TeamViewer 7 Setup (Choose installation type)' window.")
            else
                TestsOK("'No (default)' radiobutton checked, 'Next' button was clicked in 'TeamViewer 7 Setup (Choose installation type)' window.")
        }
    }
}


; Test if 'Access Control' window can appear
TestsTotal++
if bContinue
{
    WinWaitActive, TeamViewer 7 Setup, Access Control, 3
    if ErrorLevel
        TestsFailed("'TeamViewer 7 Setup (Access Control)' window failed to appear.")
    else
    {   
        ; Check 'Full access (recommended)' radiobutton
        SendMessage, 0x201, 0, 0, Button4
        SendMessage, 0x202, 0, 0, Button4
        if ErrorLevel
            TestsFailed("Failed to check 'Full access (recommended)' radiobutton in 'TeamViewer 7 Setup (Access Control)' window.")
        else
        {
            ; Hit 'Next' button
            SendMessage, 0x201, 0, 0, Button2
            SendMessage, 0x202, 0, 0, Button2
            if ErrorLevel
                TestsFailed("Unable to hit 'Next' button in 'TeamViewer 7 Setup (Access Control)' window.")
            else
                TestsOK("'Full access (recommended)' radiobutton checked, 'Next' button was clicked in 'TeamViewer 7 Setup (Access Control)' window.")
        }
    }
}


; Test if 'Install VPN adapter' window can appear
TestsTotal++
if bContinue
{
    WinWaitActive, TeamViewer 7 Setup, Install VPN adapter, 3
    if ErrorLevel
        TestsFailed("'TeamViewer 7 Setup (Install VPN adapter)' window window failed to appear.")
    else
    {   
        ; Check 'Use TeamViewer VPN' checkbox
        SendMessage, 0x201, 0, 0, Button4
        SendMessage, 0x202, 0, 0, Button4
        if ErrorLevel
            TestsFailed("Failed to check 'Use TeamViewer VPN' checkbox in 'TeamViewer 7 Setup (Install VPN adapter)' window.")
        else
        {
            ; Hit 'Next' button
            SendMessage, 0x201, 0, 0, Button2
            SendMessage, 0x202, 0, 0, Button2
            if ErrorLevel
                TestsFailed("Unable to hit 'Next' button in 'TeamViewer 7 Setup (Install VPN adapter)' window.")
            else
                TestsOK("'Use TeamViewer VPN' checkbox checked, 'Next' button was clicked in 'Install VPN adapter'.")
        }
    }  
}


; Test if 'Choose Install Location' window can appear
TestsTotal++
if bContinue
{
    WinWaitActive, TeamViewer 7 Setup, Choose Install Location, 3
    if ErrorLevel
        TestsFailed("'TeamViewer 7 Setup (Choose Install Location)' window failed to appear.")
    else
    {   
        ; Hit 'Next' button //For some reason SendMessage doesn't work here on XP.
        PostMessage, 0x201, 0, 0, Button2
        PostMessage, 0x202, 0, 0, Button2 
        if ErrorLevel
            TestsFailed("Unable to hit 'Next' button in 'TeamViewer 7 Setup (Choose Install Location)' window.")
        else
            TestsOK("'Next' button was clicked in 'TeamViewer 7 Setup (Choose Install Location)' window.")
    }
}


; Test if 'Choose Start Menu Folder' window can appear
TestsTotal++
if bContinue
{
    WinWaitActive, TeamViewer 7 Setup, Choose Start, 3
    if ErrorLevel
        TestsFailed("'TeamViewer 7 Setup (Choose Start Menu Folder)' window failed to appear.")
    else
    {   
        ; Hit 'Finish' button
        SendMessage, 0x201, 0, 0, Button2
        SendMessage, 0x202, 0, 0, Button2
        if ErrorLevel
            TestsFailed("Unable to hit 'Finish' button in 'TeamViewer 7 Setup (Choose Start Menu Folder)' window.")
        else
            TestsOK("'Finish' button was clicked in 'TeamViewer 7 Setup (Choose Start Menu Folder)' window.")
    }
}


; Test if 'Installing' window can appear
TestsTotal++
if bContinue
{
    WinWaitActive, TeamViewer 7 Setup, Installing, 3
    if ErrorLevel
        TestsFailed("'TeamViewer 7 Setup (Installing)' window failed to appear.")
    else
    {
        TestsInfo("'TeamViewer 7 Setup (Installing)' window appeared, waiting for it to close.")
        WinWaitClose, TeamViewer 7 Setup, Installing, 35 ; 35secs should be enough time to get thru install
        if ErrorLevel
            TestsFailed("'TeamViewer 7 Setup (Installing)' window failed to close.")
        else
        {
            Process, wait, TeamViewer.exe, 10
            NewPID = %ErrorLevel%  ; Save the value immediately since ErrorLevel is often changed.
            if NewPID = 0
                TestsFailed("Process '" MainAppFile "' failed to appear.")
            else
            {
                Process, Close, %MainAppFile%
                Process, WaitClose, %MainAppFile%, 7
                if ErrorLevel
                    TestsFailed("Unable to terminate '" MainAppFile "' process.")
                else
                    TestsOK("Process '" MainAppFile "' appeared, terminating it.")
            }
        }
    }
}


; Check if program exists
TestsTotal++
if bContinue
{
    RegRead, UninstallerPath, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\TeamViewer 7, UninstallString
    if ErrorLevel
        TestsFailed("Either we can't read from registry or data doesn't exist.")
    else
    {
        SplitPath, UninstallerPath,, InstalledDir
        IfNotExist, %InstalledDir%\%MainAppFile%
            TestsFailed("Something went wrong, can't find '" InstalledDir "\" MainAppFile "'.")
        else
            TestsOK("The application has been installed, because '" InstalledDir "\" MainAppFile "' was found.")
    }
}

