/*
 * Designed for Miranda IM 0.10.0
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

ModuleExe = %A_WorkingDir%\Apps\Miranda IM 0.10.0 unicode Setup.exe
TestName = 1.install
MainAppFile = miranda32.exe ; Mostly this is going to be process we need to look for

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
        RegRead, UninstallerPath, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Miranda IM, UninstallString
        if ErrorLevel
        {
            ; There was a problem (such as a nonexistent key or value). 
            ; That probably means we have not installed this app before.
            ; Check in default directory to be extra sure
            bHardcoded := true ; To know if we got path from registry or not
            szDefaultDir = %A_ProgramFiles%\Miranda IM
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
                WaitUninstallDone(UninstallerPath, 3) ; Reported child name 'Au_.exe'
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
        ; Miranda IM settings are saved in program working dir.
        RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\MicroSoft\Windows\CurrentVersion\Uninstall\Miranda IM
        if bHardcoded
            TestsOK("Either there was no previous versions or we succeeded removing it using hardcoded path.")
        else
            TestsOK("Either there was no previous versions or we succeeded removing it using data from registry.")
        Run %ModuleExe%
    }
}


; Test if 'Miranda IM 0.10.0 Setup (License Agreement)' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Miranda IM 0.10.0 Setup, License Agreement, 7
    if ErrorLevel
        TestsFailed("'Miranda IM 0.10.0 Setup (License Agreement)' window failed to appear.")
    else
    {
        ControlClick, Button2, Miranda IM 0.10.0 Setup, License Agreement ; Hit 'I Agree' button
        if ErrorLevel
            TestsFailed("Unable to hit 'I Agree' button in 'Miranda IM 0.10.0 Setup (License Agreement)' window.")
        else
        {
            WinWaitClose, Miranda IM 0.10.0 Setup, License Agreement, 3
            if ErrorLevel
                TestsFailed("'Miranda IM 0.10.0 Setup (License Agreement)' window failed to close despite 'I Agree' button being clicked.")
            else
                TestsOK("'Miranda IM 0.10.0 Setup (License Agreement)' window appeared, 'I Agree' button clicked and window closed.")
        }
    }
}


; Test if 'Miranda IM 0.10.0 Setup (Installation Mode)' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Miranda IM 0.10.0 Setup, Installation Mode, 3
    if ErrorLevel
        TestsFailed("'Miranda IM 0.10.0 Setup (Installation Mode)' window failed to appear.")
    else
    {
        ControlClick, Button2, Miranda IM 0.10.0 Setup, Installation Mode ; Hit 'Next' button
        if ErrorLevel
            TestsFailed("Unable to hit 'Next' button in 'Miranda IM 0.10.0 Setup (Installation Mode)' window.")
        else
            TestsOK("'Miranda IM 0.10.0 Setup (Installation Mode)' window appeared and 'Next' button was clicked.")
    }
}


; Test if 'Miranda IM 0.10.0 Setup (Choose Install Location)' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Miranda IM 0.10.0 Setup, Choose Install Location, 3
    if ErrorLevel
        TestsFailed("'Miranda IM 0.10.0 Setup (Choose Install Location)' window failed to appear.")
    else
    {
        ControlClick, Button2, Miranda IM 0.10.0 Setup, Choose Install Location ; Hit 'Next' button
        if ErrorLevel
            TestsFailed("Unable to hit 'Next' button in 'Miranda IM 0.10.0 Setup (Choose Install Location)' window.")
        else
            TestsOK("'Miranda IM 0.10.0 Setup (Choose Install Location)' window appeared and 'Next' button was clicked.")
    }
}


; Test if 'Miranda IM 0.10.0 Setup (Choose Components)' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Miranda IM 0.10.0 Setup, Choose Components, 3
    if ErrorLevel
        TestsFailed("'Miranda IM 0.10.0 Setup (Choose Components)' window failed to appear.")
    else
    {
        ControlClick, Button2, Miranda IM 0.10.0 Setup, Choose Components ; Hit 'Install' button
        if ErrorLevel
            TestsFailed("Unable to hit 'Install' button in 'Miranda IM 0.10.0 Setup (Choose Components)' window.")
        else
            TestsOK("'Miranda IM 0.10.0 Setup (Choose Components)' window appeared and 'Install' button was clicked.")
    }
}


; Skip 'Miranda IM 0.10.0 Setup (Installing)' window, because it appears just for a split of second.


; Test if 'Miranda IM 0.10.0 Setup (Click Finish)' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Miranda IM 0.10.0 Setup, Click Finish, 10 ; We skipped one window
    if ErrorLevel
        TestsFailed("'Miranda IM 0.10.0 Setup (Click Finish)' window failed to appear.")
    else
    {
        Control, Uncheck,, Button4, Miranda IM 0.10.0 Setup, Click Finish ; Uncheck 'Start Miranda IM' checkbox
        if ErrorLevel
            TestsFailed("Unable to uncheck 'Start Miranda IM' in 'Miranda IM 0.10.0 Setup (Click Finish)' window.")
        else
        {
            ControlGet, bChecked, Checked, Button4
            if bChecked = 1
                TestsFailed("'Start Miranda IM' checkbox in 'Miranda IM 0.10.0 Setup (Click Finish)' window reported as unchecked, but further inspection proves that it was still checked.")
            else
            {
                ControlClick, Button2, Miranda IM 0.10.0 Setup, Click Finish ; Hit 'Finish' button
                if ErrorLevel
                    TestsFailed("Unable to hit 'Finish' button in 'Miranda IM 0.10.0 Setup (Click Finish)' window.")
                else
                {
                    WinWaitClose, Miranda IM 0.10.0 Setup, Click Finish, 3
                    if ErrorLevel
                        TestsFailed("'Miranda IM 0.10.0 Setup (Click Finish)' window failed to close despite the 'Finish' button being reported as clicked .")
                    else
                    {
                        if not TerminateDefaultBrowser(10)
                            TestsFailed("Either default browser process failed to appear of we failed to terminate it.")
                        else
                            TestsOK("'Miranda IM 0.10.0 Setup (Click Finish)' window appeared, 'Start Miranda IM' unchecked, 'Finish' button clicked and window closed.")
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
    RegRead, UninstallerPath, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Miranda IM, UninstallString
    if ErrorLevel
        TestsFailed("Either we can't read from registry or data doesn't exist.")
    else
    {
        StringReplace, UninstallerPath, UninstallerPath, `",, All
        SplitPath, UninstallerPath,, InstalledDir
        IfNotExist, %InstalledDir%\%MainAppFile%
            TestsFailed("Something went wrong, can't find '" InstalledDir "\" MainAppFile "'.")
        else
            TestsOK("The application has been installed, because '" InstalledDir "\" MainAppFile "' was found.")
    }
}
