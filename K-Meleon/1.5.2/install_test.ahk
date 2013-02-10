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

ModuleExe = %A_WorkingDir%\Apps\K-Meleon 1.5.2 Setup.exe
TestName = 1.install
MainAppFile = k-meleon.exe ; Mostly this is going to be process we need to look for

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
        IfExist, %A_AppData%\K-Meleon ; Get rid of settings before running uninstaller
            FileRemoveDir, %A_AppData%\K-Meleon, 1

        IfExist, %A_AppData%\K-Meleon
            TestsFailed("Unable to delete '" A_AppData "\K-Meleon'.")
        else
        {
            RegRead, UninstallerPath, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\K-Meleon, UninstallString
            if ErrorLevel
            {
                ; There was a problem (such as a nonexistent key or value). 
                ; That probably means we have not installed this app before.
                ; Check in default directory to be extra sure
                bHardcoded := true ; To know if we got path from registry or not
                szDefaultDir = %A_ProgramFiles%\K-Meleon
                IfNotExist, %szDefaultDir%
                {
                    TestsInfo("No previous versions detected in hardcoded path: '" szDefaultDir "'.")
                    bContinue := true
                }
                else
                {   
                    UninstallerPath = %szDefaultDir%\uninstall.exe /S
                    WaitUninstallDone(UninstallerPath, 4)
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
                    WaitUninstallDone(UninstallerPath, 4) ; Reported child name is 'Au_.exe'
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
    }

    if bContinue
    {
        RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\MicroSoft\Windows\CurrentVersion\Uninstall\K-Meleon

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


; Test if 'K-Meleon 1.5.2 Install Wizard' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, K-Meleon 1.5.2 en-US Setup, K-Meleon 1.5.2 Install Wizard, 7
    if ErrorLevel
        TestsFailed("'K-Meleon 1.5.2 en-US Setup (K-Meleon 1.5.2 Install Wizard)' window failed to appear.")
    else
    {
        ControlClick, Button2, K-Meleon 1.5.2 en-US Setup, K-Meleon 1.5.2 Install Wizard
        if ErrorLevel
            TestsFailed("Unable to click 'Next' in 'K-Meleon 1.5.2 en-US Setup (K-Meleon 1.5.2 Install Wizard)' window.")
        else
        {
            WinWaitClose, K-Meleon 1.5.2 en-US Setup, K-Meleon 1.5.2 Install Wizard, 3
            if ErrorLevel
                TestsFailed("'K-Meleon 1.5.2 en-US Setup (K-Meleon 1.5.2 Install Wizard)' window failed to close despite 'Next' button being clicked.")
            else
                TestsOK("'K-Meleon 1.5.2 en-US Setup (K-Meleon 1.5.2 Install Wizard)' window appeared, 'Next' button clicked, window closed.")
        }
    }
}


; Test if 'License Agreement' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, K-Meleon 1.5.2 en-US Setup, License Agreement, 3
    if ErrorLevel
        TestsFailed("'K-Meleon 1.5.2 en-US Setup (License Agreement)' window failed to appear.")
    else
    {
        ControlClick, Button2, K-Meleon 1.5.2 en-US Setup, License Agreement ; Hit 'I Agree' button
        if ErrorLevel
            TestsFailed("Unable to click 'Next' in 'K-Meleon 1.5.2 en-US Setup (License Agreement)' window.")
        else
            TestsOK("'K-Meleon 1.5.2 en-US Setup (License Agreement)' window appeared and 'I Agree' button was clicked.")
    }
}


; Test if 'Choose Components' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, K-Meleon 1.5.2 en-US Setup, Choose Components, 3
    if ErrorLevel
        TestsFailed("'K-Meleon 1.5.2 en-US Setup (Choose Components)' window failed to appear.")
    else
    {
        ControlClick, Button2, K-Meleon 1.5.2 en-US Setup, Choose Components
        if ErrorLevel
            TestsFailed("Unable to click 'Next' in 'K-Meleon 1.5.2 en-US Setup (Choose Components)' window.")
        else
            TestsOK("'K-Meleon 1.5.2 en-US Setup (Choose Components)' window appeared and 'Next' was clicked.")
    }
}


; Test if 'Choose Install Location' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, K-Meleon 1.5.2 en-US Setup, Choose Install Location, 3
    if ErrorLevel
        TestsFailed("'K-Meleon 1.5.2 en-US Setup (Choose Install Location)' window failed to appear.")
    else
    {
        ControlClick, Button2, K-Meleon 1.5.2 en-US Setup, Choose Install Location ; Hit 'Install' button
        if ErrorLevel
            TestsFailed("Unable to click 'Next' in 'K-Meleon 1.5.2 en-US Setup (Choose Install Location)' window.")
        else
            TestsOK("'K-Meleon 1.5.2 en-US Setup (Choose Install Location)' window appeared and 'Next' was clicked.")
    }
}


; Test if can get thru 'Installing'
TestsTotal++
if bContinue
{
    WinWaitActive, K-Meleon 1.5.2 en-US Setup, Installing, 3
    if ErrorLevel
        TestsFailed("'K-Meleon 1.5.2 en-US Setup (Installing)' window failed to appear.")
    else
    {
        TestsInfo("'K-Meleon 1.5.2 en-US Setup (Installing)' window appeared, waiting for it to close.")
        
        iTimeOut := 30
        while iTimeOut > 0
        {
            IfWinActive,  K-Meleon 1.5.2 en-US Setup, Installing
            {
                WinWaitClose,  K-Meleon 1.5.2 en-US Setup, Installing, 1
                iTimeOut--
            }
            else
                break ; exit the loop if something poped-up
        }
        
        WinWaitClose, K-Meleon 1.5.2 en-US Setup, Installing, 1
        if ErrorLevel
            TestsFailed("'K-Meleon 1.5.2 en-US Setup (Installing)' window failed to close (iTimeOut=" iTimeOut ").")
        else
        {
            WinWaitActive, K-Meleon 1.5.2 en-US Setup, Installation Complete, 3
            if ErrorLevel
                TestsFailed("'K-Meleon 1.5.2 en-US Setup (Installation Complete)' window failed to appear (iTimeOut=" iTimeOut ").")
            else
            {
                ControlClick, Button2, K-Meleon 1.5.2 en-US Setup, Installation Complete
                if ErrorLevel
                    TestsFailed("Unable to hit 'Next' button in 'K-Meleon 1.5.2 en-US Setup (Installation Complete)' window (iTimeOut=" iTimeOut ").")
                else
                    TestsOK("'Installing' went away, 'Installation Complete' appeared, and 'Next' was clicked (iTimeOut=" iTimeOut ").")
            }
        }
    }
}


; Test if 'Completing' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, K-Meleon 1.5.2 en-US Setup, Completing, 3
    if ErrorLevel
        TestsFailed("'K-Meleon 1.5.2 en-US Setup (Completing)' window failed to appear.")
    else
    {
        Control, Uncheck,, Button4, K-Meleon 1.5.2 en-US Setup, Completing ; Uncheck 'Run K-Meleon 1.5.2'
        if ErrorLevel
            TestsFailed("Unable to uncheck 'Run K-Meleon 1.5.2' checkbox in 'K-Meleon 1.5.2 en-US Setup (Completing)' window.")
        else
        {
            ControlGet, bChecked, Checked,, Button4
            if bChecked = 1
                TestsFailed("'Run K-Meleon 1.5.2' checkbox in 'K-Meleon 1.5.2 en-US Setup (Completing)' window reported as unchecked, but further inspection proves that it was still checked.")
            else
            {
                ControlClick, Button2, K-Meleon 1.5.2 en-US Setup, Completing ; Hit 'Finish'
                if ErrorLevel
                    TestsFailed("Unable to click 'Finish' in 'K-Meleon 1.5.2 en-US Setup (Completing)' window.")
                else
                {
                    WinWaitClose, K-Meleon 1.5.2 en-US Setup, Completing, 3
                    if ErrorLevel
                        TestsFailed("'K-Meleon 1.5.2 en-US Setup (Completing)' window failed to close despite the 'Finish' button being reported as clicked .")
                    else
                        TestsOK("'K-Meleon 1.5.2 en-US Setup (Completing)' window appeared, 'Run K-Meleon 1.5.2' unchecked, 'Finish' clicked, window closed.")
                }
            }
        }
    }   
}


; Check if program exists
TestsTotal++
if bContinue
{
    RegRead, UninstallerPath, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\K-Meleon, UninstallString
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
