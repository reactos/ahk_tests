/*
 * Designed for ReMooD 0.8a
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

ModuleExe = %A_WorkingDir%\Apps\ReMooD 0.8a Setup.exe
TestName = 1.install
MainAppFile = remood.exe ; Mostly this is going to be process we need to look for

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
        RegRead, UninstallerPath, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\ReMooD, UninstallString
        if ErrorLevel
        {
            ; There was a problem (such as a nonexistent key or value). 
            ; That probably means we have not installed this app before.
            ; Check in default directory to be extra sure
            bHardcoded := true ; To know if we got path from registry or not
            szDefaultDir = %A_ProgramFiles%\ReMooD
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
                    TestsInfo("Succeeded deleting hardcoded path: '" szDefaultDir "'.")
                    bContinue := true
                }
            }
        }
        else
        {
            UninstallerPath := ExeFilePathNoParam(UninstallerPath)
            SplitPath, UninstallerPath,, InstalledDir
            FileRemoveDir, %InstalledDir%, 1 ; Couldn't find silent uninstall switch
            if ErrorLevel
                TestsFailed("Unable to delete existing '" InstalledDir "' ('" MainAppFile "' process is reported as terminated).")
            else
            {
                TestsInfo("Succeeded deleting path (registry data): '" InstalledDir "'.")
                bContinue := true
            }
        }
    }

    if bContinue
    {
        RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\MicroSoft\Windows\CurrentVersion\Uninstall\ReMooD
        if bHardcoded
            TestsOK("Either there was no previous versions or we succeeded removing it using hardcoded path.")
        else
            TestsOK("Either there was no previous versions or we succeeded removing it using data from registry.")
        Run %ModuleExe%
    }
}


; Test if 'ReMooD 0.8a Setup (This wizard)' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, ReMooD 0.8a Setup, This wizard, 5
    if ErrorLevel
        TestsFailed("'ReMooD 0.8a Setup (This wizard)' window failed to appear.")
    else
    {
        ControlClick, Button2 ; Hit 'Next' button
        if ErrorLevel
            TestsFailed("Unable to hit 'Next' button in 'ReMooD 0.8a Setup (This wizard)' window.")
        else
        {
            WinWaitClose, ReMooD 0.8a Setup, This wizard, 3
            if ErrorLevel
                TestsFailed("'ReMooD 0.8a Setup (This wizard)' window failed to close despite 'Next' button being clicked.")
            else
                TestsOK("'ReMooD 0.8a Setup (This wizard)' window appeared, 'Next' button clicked and window closed.")
        }
    }
}


; Test if 'ReMooD 0.8a Setup (License Agreement)' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, ReMooD 0.8a Setup, License Agreement, 3
    if ErrorLevel
        TestsFailed("'ReMooD 0.8a Setup (License Agreement)' window failed to appear.")
    else
    {
        ControlClick, Button2 ; Hit 'I Agree' button
        if ErrorLevel
            TestsFailed("Unable to hit 'I Agree' button in 'ReMooD 0.8a Setup (License Agreement)' window.")
        else
            TestsOK("'ReMooD 0.8a Setup (License Agreement)' window appeared, 'I Agree' button clicked.")
    }
}


; Test if 'ReMooD 0.8a Setup (Choose Install Location)' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, ReMooD 0.8a Setup, Choose Install Location, 3
    if ErrorLevel
        TestsFailed("'ReMooD 0.8a Setup (Choose Install Location)' window failed to appear.")
    else
    {
        ControlClick, Button2 ; Hit 'Install' button
        if ErrorLevel
            TestsFailed("Unable to hit 'Install' button in 'ReMooD 0.8a Setup (Choose Install Location)' window.")
        else
            TestsOK("'ReMooD 0.8a Setup (Choose Install Location)' window appeared, 'Install' button clicked.")
    }
}


; Skip 'Installing' window


; Test if 'ReMooD 0.8a Setup (Click Finish)' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, ReMooD 0.8a Setup, Click Finish, 5 ; We skipped one window
    if ErrorLevel
        TestsFailed("'ReMooD 0.8a Setup (Click Finish)' window failed to appear.")
    else
    {
        SendInput, !r ; Alt+R to uncheck 'Run ReMooD 0.8a' checkbox
        SendInput, !s ; Alt+S to uncheck 'Show Readme' checkbox

        ControlGet, bChecked, Checked,, Button4
        if bChecked = 1
            TestsFailed("Alt+R was sent to uncheck 'Run ReMooD 0.8a' checkbox in 'ReMooD 0.8a Setup (Click Finish)' window, but further inspection proves that it was still checked.")
        else
        {
            ControlGet, bChecked, Checked,, Button5
            if bChecked = 1
                TestsFailed("Alt+S was sent to uncheck 'Show Readme' checkbox in 'ReMooD 0.8a Setup (Click Finish)' window, but further inspection proves that it was still checked.")
            else
            {
                ControlClick, Button2 ; Hit 'Finish' button
                if ErrorLevel
                    TestsFailed("Unable to hit 'Finish' button in 'ReMooD 0.8a Setup (Click Finish)' window.")
                else
                {
                    WinWaitClose, ReMooD 0.8a Setup, Click Finish, 3
                    if ErrorLevel
                        TestsFailed("'ReMooD 0.8a Setup (Click Finish)' window failed to close despite 'Finish' button being clicked.")
                    else
                        TestsOK("'ReMooD 0.8a Setup (Click Finish)' window appeared, 'Run ReMooD 0.8a' and 'Show Readme' checkboxes unchecked, 'Finish' button clicked and window closed.")
                }
            }
        }
    }
}


; Check if program exists
TestsTotal++
if bContinue
{
    ; No need to sleep, because we already waited for process to appear
    RegRead, UninstallerPath, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\ReMooD, UninstallString
    if ErrorLevel
        TestsFailed("Either we can't read from registry or data doesn't exist.")
    else
    {
        UninstallerPath := ExeFilePathNoParam(UninstallerPath)
        SplitPath, UninstallerPath,, InstalledDir
        IfNotExist, %InstalledDir%\%MainAppFile%
            TestsFailed("Something went wrong, can't find '" InstalledDir "\" MainAppFile "'.")
        else
            TestsOK("The application has been installed, because '" InstalledDir "\" MainAppFile "' was found.")
    }
}
