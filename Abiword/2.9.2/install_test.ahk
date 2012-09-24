/*
 * Designed for Abiword 2.9.2
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

ModuleExe = %A_WorkingDir%\Apps\Abiword 2.9.2 Setup.exe
TestName = 1.install
MainAppFile = AbiWord.exe ; Mostly this is going to be process we need to look for

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
        ; There is no silent switch, so, just delete
        RegRead, UninstallerPath, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\AbiWord2, UninstallString
        if ErrorLevel
        {
            ; There was a problem (such as a nonexistent key or value). 
            ; That probably means we have not installed this app before.
            ; Check in default directory to be extra sure
            bHardcoded := true ; To know if we got path from registry or not
            szDefaultDir = %A_ProgramFiles%\AbiWord
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
            IfNotExist, %InstalledDir%
            {
                TestsInfo("Got '" InstalledDir "' from registry and such path does not exist.")
                bContinue := true
            }
            else
            {
                FileRemoveDir, %InstalledDir%, 1 ; There is no silent uninstall switch
                if ErrorLevel
                    TestsFailed("Unable to delete existing '" InstalledDir "' ('" MainAppFile "' process is reported as terminated).")
                else
                {
                    TestsInfo("Succeeded deleting path (registry data): '" InstalledDir "'.")
                    bContinue := true
                }
            }
        }
    }

    if bContinue
    {
        RegDelete, HKEY_CURRENT_USER, SOFTWARE\AbiSuite
        RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\AbiSuite
        RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\AbiWord ; Delete this or it will not show 'Installer Language (Please select)' window
        RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\MicroSoft\Windows\CurrentVersion\Uninstall\AbiWord2

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


; Test if 'Installer Language (Please select)' window appeared, if so, hit 'OK' button
TestsTotal++
if bContinue
{
    WinWaitActive, Installer Language, Please select, 10
    if ErrorLevel
        TestsFailed("'Installer Language (Please select)' window failed to appear. Unable to delete 'HKLM\SOFTWARE\AbiWord'?")
    else
    {
        ControlClick, Button1, Installer Language, Please select
        if ErrorLevel
            TestsFailed("Unable to hit 'OK' button in 'Installer Language (Please select)' window.")
        else
        {
            WinWaitClose, Installer Language, Please select, 3
            if ErrorLevel
                TestsFailed("'Installer Language (Please select)' window failed to close despite 'OK' button being reported as clicked.")
            else
                TestsOK("'Installer Language (Please select)' window appeared, 'OK' button was clicked and window closed.")
        }
    }
}


; Test if 'AbiWord 2.9.2 Setup (This wizard)' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, AbiWord 2.9.2 Setup, This wizard, 10
    if ErrorLevel
        TestsFailed("'AbiWord 2.9.2 Setup (This wizard)' window failed to appear.")
    else
    {
        ControlClick, Button2, AbiWord 2.9.2 Setup, This wizard ; Hit 'Next' button
        if ErrorLevel
            TestsFailed("Unable to hit 'Next' button in 'AbiWord 2.9.2 Setup (This wizard)' window.")
        else
        {
            WinWaitClose, AbiWord 2.9.2 Setup, This wizard, 3
            if ErrorLevel
                TestsFailed("'AbiWord 2.9.2 Setup (This wizard)' window failed to close despite 'Next' button being clicked.")
            else
                TestsOK("'AbiWord 2.9.2 Setup (This wizard)' window appeared, 'Next' button clicked and window closed.")
        }
    }
}


; Test if 'AbiWord 2.9.2 Setup (License Agreement)' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, AbiWord 2.9.2 Setup, License Agreement, 3
    if ErrorLevel
        TestsFailed("'AbiWord 2.9.2 Setup (License Agreement)' window failed to appear.")
    else
    {
        ControlClick, Button2, AbiWord 2.9.2 Setup, License Agreement
        if ErrorLevel
            TestsFailed("Unable to hit 'Next' button in 'AbiWord 2.9.2 Setup (License Agreement)' window.")
        else
            TestsOK("'AbiWord 2.9.2 Setup (License Agreement)' window appeared and 'Next' button was clicked.")
    }
}


; Test if 'AbiWord 2.9.2 Setup (Choose Components)' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, AbiWord 2.9.2 Setup, Choose Components, 3
    if ErrorLevel
        TestsFailed("'AbiWord 2.9.2 Setup (Choose Components)' window failed to appear.")
    else
    {
        ControlClick, Button2, AbiWord 2.9.2 Setup, Choose Components
        if ErrorLevel
            TestsFailed("Unable to hit 'Next' button in 'AbiWord 2.9.2 Setup (Choose Components)' window.")
        else
            TestsOK("'AbiWord 2.9.2 Setup (Choose Components)' window appeared and 'Next' button was clicked.")
    }
}


; Test if 'AbiWord 2.9.2 Setup (Choose Install Location)' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, AbiWord 2.9.2 Setup, Choose Install Location, 3
    if ErrorLevel
        TestsFailed("'AbiWord 2.9.2 Setup (Choose Install Location)' window failed to appear.")
    else
    {
        ControlClick, Button2, AbiWord 2.9.2 Setup, Choose Install Location
        if ErrorLevel
            TestsFailed("Unable to hit 'Next' button in 'AbiWord 2.9.2 Setup (Choose Install Location)' window.")
        else
            TestsOK("'AbiWord 2.9.2 Setup (Choose Install Location)' window appeared and 'Next' button was clicked.")
    }
}


; Test if 'AbiWord 2.9.2 Setup (Choose Start Menu Folder)' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, AbiWord 2.9.2 Setup, Choose Start Menu Folder, 3
    if ErrorLevel
        TestsFailed("'AbiWord 2.9.2 Setup (Choose Start Menu Folder)' window failed to appear.")
    else
    {
        ControlClick, Button2, AbiWord 2.9.2 Setup, Choose Start Menu Folder
        if ErrorLevel
            TestsFailed("Unable to hit 'Next' button in 'AbiWord 2.9.2 Setup (Choose Start Menu Folder)' window.")
        else
            TestsOK("'AbiWord 2.9.2 Setup (Choose Start Menu Folder)' window appeared and 'Next' button was clicked.")
    }
}


; Test if can get thru 'Installing'
TestsTotal++
if bContinue
{
    WinWaitActive, AbiWord 2.9.2 Setup, Installing, 3
    if ErrorLevel
        TestsFailed("'AbiWord 2.9.2 Setup (Installing)' window failed to appear.")
    else
    {
        TestsInfo("'Installing' window appeared, waiting for it to close.")
        WinWaitClose, AbiWord 2.9.2 Setup, Installing, 45
        if ErrorLevel
            TestsFailed("'AbiWord 2.9.2 Setup (Installing)' window failed to disappear.")
        else
        {
            WinWaitActive, AbiWord 2.9.2 Setup, Installation Complete, 3
            if ErrorLevel
                TestsFailed("'AbiWord 2.9.2 Setup (Installation Complete)' window failed to appear.")
            else
            {
                ControlClick, Button2, AbiWord 2.9.2 Setup, Installation Complete
                if ErrorLevel
                    TestsFailed("Unable to hit 'Next' button in 'AbiWord 2.9.2 Setup (Installation Complete)' window.")
                else
                    TestsOK("'AbiWord 2.9.2 Setup (Installing)' went away, and 'Next' button was clicked in 'AbiWord 2.9.2 Setup (Installation Complete)' window.")
            }
        }
    }
}


; Test if 'Completing' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, AbiWord 2.9.2 Setup, Completing, 3
    if ErrorLevel
        TestsFailed("'AbiWord 2.9.2 Setup (Completing)' window failed to appear.")
    else
    {
        ControlClick, Button4, AbiWord 2.9.2 Setup, Completing ; Uncheck 'Run AbiWord 2.9.2'
        if ErrorLevel
        {
            TestsFailed("Unable to uncheck 'Run AbiWord 2.9.2' checkbox in 'AbiWord 2.9.2 Setup (Completing)' window.")
            Process, Close, %MainAppFile% ; Just in case
        }
        else
        {
            ControlGet, bChecked, Checked, Button4
            if bChecked = 1
                TestsFailed("'Run AbiWord 2.9.2' checkbox in 'AbiWord 2.9.2 Setup (Completing)' window reported as unchecked, but further inspection proves that it was still checked.")
            else
            {
                ControlClick, Button2, AbiWord 2.9.2 Setup, Completing ; Hit 'Finish'
                if ErrorLevel
                    TestsFailed("Unable to hit 'Finish' button in 'AbiWord 2.9.2 Setup (Completing)' window.")
                else
                {
                    WinWaitClose, AbiWord 2.9.2 Setup, Completing, 3
                    if ErrorLevel
                        TestsFailed("'AbiWord 2.9.2 Setup (Completing)' window failed to close despite 'Finish' button being clicked.")
                    else
                        TestsOK("'AbiWord 2.9.2 Setup (Completing)' window appeared, checkbox 'Run AbiWord 2.9.2' unchecked, 'Finish' button clicked and window closed.")
                }
            }
        }
    }
}


; Check if program exists
TestsTotal++
if bContinue
{
    RegRead, UninstallerPath, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\AbiWord2, UninstallString
    if ErrorLevel
        TestsFailed("Either we can't read from registry or data doesn't exist.")
    else
    {
        SplitPath, UninstallerPath,, InstalledDir
        IfNotExist, %InstalledDir%\bin\%MainAppFile%
            TestsFailed("Something went wrong, can't find '" InstalledDir "\bin\" MainAppFile "'.")
        else
            TestsOK("The application has been installed, because '" InstalledDir "\bin\" MainAppFile "' was found.")
    }
}
