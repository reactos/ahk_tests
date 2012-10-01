/*
 * Designed for mIRC 6.35
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

ModuleExe = %A_WorkingDir%\Apps\mIRC 6.35 Setup.exe
TestName = 1.install
MainAppFile = mirc.exe ; Mostly this is going to be process we need to look for

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
        RegRead, UninstallerPath, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\mIRC, UninstallString
        if ErrorLevel
        {
            ; There was a problem (such as a nonexistent key or value). 
            ; That probably means we have not installed this app before.
            ; Check in default directory to be extra sure
            bHardcoded := true ; To know if we got path from registry or not
            szDefaultDir = %A_ProgramFiles%\mIRC
            IfNotExist, %szDefaultDir%
            {
                TestsInfo("No previous versions detected in hardcoded path: '" szDefaultDir "'.")
                bContinue := true
            }
            else
            {   
                UninstallerPath = %szDefaultDir%\Uninstall.exe /S
                WaitUninstallDone(UninstallerPath, 3)
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
                WaitUninstallDone(UninstallerPath, 3) ; Reported child name is 'Au_.exe'
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
        RegDelete, HKEY_CURRENT_USER, SOFTWARE\mIRC
        RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\MicroSoft\Windows\CurrentVersion\Uninstall\mIRC
        IfExist, %A_AppData%\mIRC
        {
            FileRemoveDir, %A_AppData%\mIRC, 1
            if ErrorLevel
                TestsFailed("Unable to delete '" A_AppData "\mIRC'.")
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



; Test if 'This wizard' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, mIRC Setup, This wizard, 5
    if ErrorLevel
        TestsFailed("'mIRC Setup (This wizard)' window failed to appear.")
    else
    {
        ControlClick, Button2, mIRC Setup, This wizard ; Hit 'Next' button
        if ErrorLevel
            TestsFailed("Unable to click 'Next' in 'mIRC Setup (This wizard)' window.")
        else
        {
            WinWaitClose, mIRC Setup, This wizard, 3
            if ErrorLevel
                TestsFailed("'mIRC Setup (This wizard)' window failed to close despite 'Next' button being clicked.")
            else
                TestsOK("'mIRC Setup (This wizard)' window appeared, 'Next' button clicked and window closed.")
        }
    }
}


; Test if 'License Agreement' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, mIRC Setup, License Agreement, 3
    if ErrorLevel
        TestsFailed("'mIRC Setup (License Agreement)' window failed to appear.")
    else
    {
        ControlClick, Button2, mIRC Setup, License Agreement ; Hit 'I Agree' button
        if ErrorLevel
            TestsFailed("Unable to click 'I Agree' button in 'mIRC Setup (License Agreement)' window.")
        else
            TestsOK("'mIRC Setup (License Agreement)' window appeared and 'I Agree' button was clicked.")
    }
}


; Test if 'Choose Install Location' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, mIRC Setup, Choose Install Location, 3
    if ErrorLevel
        TestsFailed("'mIRC Setup (Choose Install Location)' window failed to appear.")
    else
    {
        ControlClick, Button2, mIRC Setup, Choose Install Location
        if ErrorLevel
            TestsFailed("Unable to click 'Next' in 'mIRC Setup (Choose Install Location)' window.")
        else
            TestsOK("'mIRC Setup (Choose Install Location)' window appeared and 'Next' was clicked.")
    }
}


; Test if 'Choose Components' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, mIRC Setup, Choose Components, 3
    if ErrorLevel
        TestsFailed("'mIRC Setup (Choose Components)' window failed to appear.")
    else
    {
        ControlClick, Button2, mIRC Setup, Choose Components
        if ErrorLevel
            TestsFailed("Unable to click 'Next' in 'mIRC Setup (Choose Components)' window.")
        else
            TestsOK("'mIRC Setup (Choose Components)' window appeared and 'Next' was clicked.")
    }
}


; Test if 'Select Additional Tasks' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, mIRC Setup, Select Additional Tasks, 3
    if ErrorLevel
        TestsFailed("'mIRC Setup (Select Additional Tasks)' window failed to appear.")
    else
    {
        Control, Uncheck,, Button6, mIRC Setup, Select Additional Tasks ; Uncheck 'Backup Current Files'
        if ErrorLevel
            TestsFailed("Unable to uncheck 'Backup Current Files' checkbox in 'mIRC Setup (Select Additional Tasks)' window.")
        else
        {
            Control, Uncheck,, Button7, mIRC Setup, Select Additional Tasks ; Uncheck 'Automatically Check for Updates'
            if ErrorLevel
                TestsFailed("Unable to uncheck 'Automatically Check for Updates' checkbox in 'mIRC Setup (Select Additional Tasks)' window. ")
            else
            {
                ControlClick, Button2, mIRC Setup, Select Additional Tasks
                if ErrorLevel
                    TestsFailed("Unable to click 'Next' in 'mIRC Setup (Select Additional Tasks)' window.")
                else
                    TestsOK("'mIRC Setup (Select Additional Tasks)' window appeared, 'Automatically Check for Updates', 'Backup Current Files' checkboxes unchecked and 'Next' was clicked.")
            }
        }   
    }
}


; Test if 'Ready to Install' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, mIRC Setup, Ready to Install, 3
    if ErrorLevel
        TestsFailed("'mIRC Setup (Ready to Install)' window failed to appear.")
    else
    {
        ControlClick, Button2, mIRC Setup, Ready to Install ; Hit 'Install'
        if ErrorLevel
            TestsFailed("Unable to click 'Install' in 'mIRC Setup (Ready to Install)' window.")
        else
            TestsOK("'mIRC Setup (Ready to Install)' window appeared and 'Install' was clicked.")
    }
}


; Skip 'mIRC Setup (Installing)' window


; Test if 'mIRC has been installed' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, mIRC Setup, mIRC has been installed, 7 ; We skipped one window
    if ErrorLevel
        TestsFailed("'mIRC Setup (mIRC has been installed)' window failed to appear.")
    else
    {
        ; There are two checkboxes, but unchecked by default. 
        ControlClick, Button2, mIRC Setup, mIRC has been installed ; Hit 'Finish'
        if ErrorLevel
            TestsFailed("Unable to click 'Finish' in 'mIRC Setup (mIRC has been installed)' window.")
        else
        {
            WinWaitClose, mIRC Setup, mIRC has been installed, 3
            if ErrorLevel
                TestsFailed("'mIRC Setup (mIRC has been installed)' window failed to close despite 'Finish' button being clicked.")
            else
                TestsOK("'mIRC Setup (mIRC has been installed)' window appeared, 'Finish' clicked and window closed.")
        }
    }
}


; Check if program exists
TestsTotal++
if bContinue
{
    RegRead, InstalledDir, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\mIRC, InstallLocation
    if ErrorLevel
        TestsFailed("Either we can't read from registry or data doesn't exist.")
    else
    {
        IfNotExist, %InstalledDir%\%MainAppFile%
            TestsFailed("Something went wrong, can't find '" InstalledDir "\" MainAppFile "'.")
        else
            TestsOK("The application has been installed, because '" InstalledDir "\" MainAppFile "' was found.")
    }
}
