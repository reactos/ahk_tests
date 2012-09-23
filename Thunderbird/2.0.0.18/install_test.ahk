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

ModuleExe = %A_WorkingDir%\Apps\Thunderbird 2.0.0.18 Setup.exe
TestName = 1.install
MainAppFile = thunderbird.exe ; Mostly this is going to be process we need to look for

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
        RegRead, UninstallerPath, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Mozilla Thunderbird (2.0.0.18), UninstallString
        if ErrorLevel
        {
            ; There was a problem (such as a nonexistent key or value). 
            ; That probably means we have not installed this app before.
            ; Check in default directory to be extra sure
            bHardcoded := true ; To know if we got path from registry or not
            szDefaultDir = %A_ProgramFiles%\Mozilla Thunderbird
            IfNotExist, %szDefaultDir%
            {
                TestsInfo("No previous versions detected in hardcoded path: '" szDefaultDir "'.")
                bContinue := true
            }
            else
            {   
                UninstallerPath = %szDefaultDir%\uninstall\helper.exe /S
                WaitUninstallDone(UninstallerPath, 3)
                if bContinue
                {
                    Process, WaitClose, Au_.exe, 7
                    if ErrorLevel ; The PID still exists
                    {
                        TestsInfo("'Au_.exe' process failed to close.")
                        Process, Close, Au_.exe
                        Process, WaitClose, Au_.exe, 3
                        if ErrorLevel ; The PID still exists
                            TestsFailed("Unable to terminate 'Au_.exe' process.")
                    }
                    else
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
        }
        else
        {
            SplitPath, UninstallerPath,, InstalledDir
            SplitPath, InstalledDir,, InstalledDir ; Split once more, since installer was in subdir (Thunderbird specific)
            IfNotExist, %InstalledDir%
            {
                TestsInfo("Got '" InstalledDir "' from registry and such path does not exist.")
                bContinue := true
            }
            else
            {
                UninstallerPath = %UninstallerPath% /S
                WaitUninstallDone(UninstallerPath, 3)
                if bContinue
                {
                    ; There is child process, but seems we can not detect it
                    ; Process Explorer shows that 'Au_.exe' was started by 'Non-existent Process' and we start 'helper.exe'
                    Process, WaitClose, Au_.exe, 7
                    if ErrorLevel ; The PID still exists
                    {
                        TestsInfo("'Au_.exe' process failed to close.")
                        Process, Close, Au_.exe
                        Process, WaitClose, Au_.exe, 3
                        if ErrorLevel ; The PID still exists
                            TestsFailed("Unable to terminate 'Au_.exe' process.")
                    }
                    else
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
        RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\Mozilla
        RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\mozilla.org
        RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\MicroSoft\Windows\CurrentVersion\Uninstall\Mozilla Thunderbird (2.0.0.18)
        IfExist, %A_AppData%\Mozilla
        {
            FileRemoveDir, %A_AppData%\Mozilla, 1
            if ErrorLevel
                TestsFailed("Unable to delete '" A_AppData "\Mozilla'.")
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
    SetTitleMatchMode, 2 ; A window's title can contain WinTitle anywhere inside it to be a match.
    WinWaitActive, Extracting, Cancel, 10 ; Wait 10 secs for window to appear
    if ErrorLevel ; Window is found and it is active
        TestsFailed("'Extracting' window failed to appear.")
    else
    {
        TestsInfo("'Extracting' window appeared, waiting for it to close.")
        WinWaitClose, Extracting, Cancel, 15
        if ErrorLevel
            TestsFailed("'Extracting' window failed to close.")
        else
            TestsOK("'Extracting' window went away.")
    }
}


; Test if 'Welcome to the Mozilla Thunderbird' window appeared
TestsTotal++
if bContinue
{
    SetTitleMatchMode, 3 ; A window's title must exactly match WinTitle to be a match.
    WinWaitActive, Mozilla Thunderbird Setup, Welcome to the Mozilla Thunderbird, 15
    if ErrorLevel
        TestsFailed("'Mozilla Thunderbird Setup (Welcome to the Mozilla Thunderbird)' window failed to appear.")
    else
    {
        ControlClick, Button2, Mozilla Thunderbird Setup, Welcome to the Mozilla Thunderbird
        if ErrorLevel
            TestsFailed("Unable to click 'Next' in 'Mozilla Thunderbird Setup (Welcome to the Mozilla Thunderbird)' window.")
        else
        {
            WinWaitClose, Mozilla Thunderbird Setup, Welcome to the Mozilla Thunderbird, 3
            if ErrorLevel
                TestsFailed("'Mozilla Thunderbird Setup (Welcome to the Mozilla Thunderbird)' window failed to close despite 'Next' button being clicked.")
            else
                TestsOK("'Mozilla Thunderbird Setup (Welcome to the Mozilla Thunderbird)' window appeared, 'Next' button clicked, window closed.")
        }
    }
}


ThunderbirdWnd := "Mozilla Thunderbird Setup " ; There is space at the end of the title
; Test if 'License Agreement' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, %ThunderbirdWnd%, License Agreement, 3
    if ErrorLevel
        TestsFailed("'Mozilla Thunderbird Setup (License Agreement)' window failed to appear.")
    else
    {
        ControlClick, Button4, %ThunderbirdWnd%, License Agreement ; check 'I accept' radio button
        if ErrorLevel
            TestsFailed("Unable to check 'I agree' radio button in 'Mozilla Thunderbird Setup (License Agreement)' window.")
        else
        {
            ControlGet, OutputVar, Enabled,, Button2, %ThunderbirdWnd%, License Agreement
            if not %OutputVar%
                TestsFailed("'I agree' radio button is checked in 'Mozilla Thunderbird Setup (License Agreement)', but 'Next' button is disabled.")
            else
            {
                ControlClick, Button2, %ThunderbirdWnd%, License Agreement
                if ErrorLevel
                    TestsFailed("Unable to hit 'Next' button in 'Mozilla Thunderbird Setup (License Agreement)' window despite the button is enabled.")
                else
                    TestsOK("'Mozilla Thunderbird Setup (License Agreement)' window appeared and 'Next' was clicked.")
            }
        }
    }   
}



; Test if 'Setup Type' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Mozilla Thunderbird Setup, Setup Type, 3
    if ErrorLevel
        TestsFailed("'Mozilla Thunderbird Setup (Setup Type)' window failed to appear.")
    else
    {
        ControlClick, Button2, Mozilla Thunderbird Setup, Setup Type
        if ErrorLevel
            TestsFailed("Unable to click 'Next' in 'Mozilla Thunderbird Setup (Setup Type)' window.")
        else
            TestsOK("'Mozilla Thunderbird Setup (Setup Type)' window appeared and 'Next' was clicked.")
    }
}


; Test if 'Installing' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, %ThunderbirdWnd%, Installing, 3
    if ErrorLevel
        TestsFailed("'Mozilla Thunderbird Setup (Installing)' window failed to appear.")
    else
    {
        TestsInfo("'Mozilla Thunderbird Setup (Installing)' window appeared, waiting for it to close.")
        WinWaitClose, %ThunderbirdWnd%, Installing, 10
        if ErrorLevel
            TestsFailed("'Mozilla Thunderbird Setup (Installing)' window window failed to close.")
        else
            TestsOK("'Mozilla Thunderbird Setup (Installing)' window went away.")
    }
}
 

; Test if 'Completing' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, %ThunderbirdWnd%, Completing, 3
    if ErrorLevel
        TestsFailed("'Mozilla Thunderbird Setup (Completing)' window failed to appear.")
    else
    {
        ControlClick, Button4, %ThunderbirdWnd%, Completing ; Uncheck 'Launch Mozilla Thunderbird now'
        if ErrorLevel
        {
            TestsFailed("Unable to uncheck 'Launch Mozilla Thunderbird now' in 'Mozilla Thunderbird Setup (Completing)' window.")
            Process, Close, %MainAppFile% ; Just in case
        }
        else
        {
            ControlGet, bChecked, Checked, Button4
            if bChecked = 1
                TestsFailed("'Launch Mozilla Thunderbird now' checkbox in 'Mozilla Thunderbird Setup (Completing)' window reported as unchecked, but further inspection proves that it was still checked.")
            else
            {
                ControlClick, Button2, %ThunderbirdWnd%, Completing ; Hit 'Finish'
                if ErrorLevel
                    TestsFailed("Unable to click 'Finish' in 'Mozilla Thunderbird Setup (Completing)' window.")
                else
                {
                    WinWaitClose, %ThunderbirdWnd%, Completing, 3
                    if ErrorLevel
                        TestsFailed("'Mozilla Thunderbird Setup (Completing)' failed to close despite 'Finish' was clicked.")
                    else
                        TestsOK("'Mozilla Thunderbird Setup (Completing)' window appeared, 'Launch Mozilla Thunderbird now' unchecked, 'Finish' button was clicked and window closed.")
                }
            }
        }
    }
}


; Check if program exists in program files
TestsTotal++
if bContinue
{
    RegRead, UninstallerPath, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Mozilla Thunderbird (2.0.0.18), UninstallString
    if ErrorLevel
        TestsFailed("Either we can't read from registry or data doesn't exist.")
    else
    {
        SplitPath, UninstallerPath,, InstalledDir
        SplitPath, InstalledDir,, InstalledDir ; Split once more, since installer was in subdir (Thunderbird specific)
        IfNotExist, %InstalledDir%\%MainAppFile%
            TestsFailed("Something went wrong, can't find '" InstalledDir "\" MainAppFile "'.")
        else
            TestsOK("The application has been installed, because '" InstalledDir "\" MainAppFile "' was found.")
    }
}
