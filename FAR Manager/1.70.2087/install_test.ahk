/*
 * Designed for FAR Manager 1.70.2087
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

ModuleExe = %A_WorkingDir%\Apps\FAR Manager 1.70.2087 Setup.exe
TestName = 1.install
MainAppFile = Far.exe ; Mostly this is going to be process we need to look for


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
        ; Silent uninstall is broken (at least /S shows dialog)
        RegRead, UninstallerPath, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Far manager, UninstallString
        if ErrorLevel
        {
            ; There was a problem (such as a nonexistent key or value). 
            ; That probably means we have not installed this app before.
            ; Check in default directory to be extra sure
            IfNotExist, %A_ProgramFiles%\Far
                bContinue := true ; No previous versions detected in hardcoded path
            else
            {
                bHardcoded := true ; To know if we got path from registry or not
                FileRemoveDir, %A_ProgramFiles%\Far, 1
                if ErrorLevel
                    TestsFailed("Unable to delete existing '" A_ProgramFiles "\Far' ('" MainAppFile "' process is reported as terminated).'")
                else
                    bContinue := true
            }
        }
        else
        {
            SplitPath, UninstallerPath,, InstalledDir
            IfNotExist, %InstalledDir%
                bContinue := true
            else
            {
                FileRemoveDir, %InstalledDir%, 1 ; Delete it
                if ErrorLevel
                    TestsFailed("Unable to delete existing '" InstalledDir "' ('" MainAppFile "' process is reported as terminated).")
                else
                    bContinue := true
            }
        }
    }

    if bContinue
    {
        FileRemoveDir, %A_StartMenu%\Programs\Far Manager, 1
        FileDelete, %A_Desktop%\Far Manager.lnk
        RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\MicroSoft\Windows\CurrentVersion\Uninstall\Far manager

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


; Test if 'Installer Language' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Installer Language, Please select, 10
    if ErrorLevel
        TestsFailed("'Installer Language (Please select)' window failed to appear.")
    else
    {
        ControlClick, Button1, Installer Language, Please select
        if ErrorLevel
            TestsFailed("Unable to hit 'OK' button in 'Installer Language (Please select)' window.")
        else
        {
            WinWaitClose, Installer Language, Please select, 3
            if ErrorLevel
                TestsFailed("'Installer Language (Please select)' window failed to close despite 'OK' button being clicked.")
            else
                TestsOK("'Installer Language (Please select)' window appeared, 'OK' button clicked and window closed.")
        }
    }
}


; Test if 'This program will install' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Far Manager v1.70 Setup, This program will install, 10
    if ErrorLevel
        TestsFailed("'Far Manager v1.70 Setup (This program will install')' window failed to appear.")
    else
    {
        ControlClick, Button2, Far Manager v1.70 Setup, This program will install
        if ErrorLevel
            TestsFailed("Unable to hit 'Next' button in 'Far Manager v1.70 Setup (This program will install)' window.")
        else
            TestsOK("'Far Manager v1.70 Setup (This program will install)' window appeared and 'Next' button was clicked.")
    }
}


; Test if 'License Agreement' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Far Manager v1.70 Setup, License Agreement, 3
    if ErrorLevel
        TestsFailed("'Far Manager v1.70 Setup (License Agreement)' window failed to appear.")
    else
    {
        ControlClick, Button4, Far Manager v1.70 Setup, License Agreement ; check 'I accept' checkbox
        if ErrorLevel
            TestsFailed("Unable to check 'I agree' radio button in 'Far Manager v1.70 Setup (License Agreement)' window.")
        else
        {
            ControlGet, OutputVar, Enabled,, Button2, Far Manager v1.70 Setup, License Agreement
            if not %OutputVar%
                TestsFailed("'I agree' radio button is checked in 'Far Manager v1.70 Setup (License Agreement)' window, but 'Next' button is disabled.")
            else
            {
                ControlClick, Button2, Far Manager v1.70 Setup, License Agreement
                if ErrorLevel
                    TestsFailed("Unable to hit 'Next' button in 'Far Manager v1.70 Setup (License Agreement)' window despite it is enabled.")
                else
                    TestsOK("'Far Manager v1.70 Setup (License Agreement)' window appeared and 'Next' button was clicked.")
            }
        }
    }
}


; Test if 'Choose Install Location' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Far Manager v1.70 Setup, Choose Install Location, 3
    if ErrorLevel
        TestsFailed("'Far Manager v1.70 Setup (Choose Install Location)' window failed to appear.")
    else
    {
        ControlClick, Button2, Far Manager v1.70 Setup, Choose Install Location
        if ErrorLevel
            TestsFailed("Unable to hit 'Next' button in 'Far Manager v1.70 Setup (Choose Install Location)' window.")
        else
            TestsOK("'Far Manager v1.70 Setup (Choose Install Location)' window appeared and 'Next' was clicked.")
    }
}


; Test if 'Choose Components' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Far Manager v1.70 Setup, Choose Components, 3
    if ErrorLevel
        TestsFailed("'Far Manager v1.70 Setup (Choose Components)' window failed to appear.")
    else
    {
        ControlClick, Button2, Far Manager v1.70 Setup, Choose Components
        if ErrorLevel
            TestsFailed("Unable to hit 'Next' button in 'Far Manager v1.70 Setup (Choose Components)' window.")
        else
            TestsOK("'Far Manager v1.70 Setup (Choose Components)' window appeared and 'Next' button was clicked.")
    }
}


; Test if 'Choose Start Menu Folder' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Far Manager v1.70 Setup, Choose Start Menu Folder, 3
    if ErrorLevel
        TestsFailed("'Far Manager v1.70 Setup (Choose Start Menu Folder)' window failed to appear.")
    else
    {
        ControlClick, Button2, Far Manager v1.70 Setup, Choose Start Menu Folder ; Hit 'Install' button
        if ErrorLevel
            TestsFailed("Unable to hit 'Install' button in 'Far Manager v1.70 Setup (Choose Start Menu Folder)' window.")
        else
            TestsOK("'Far Manager v1.70 Setup (Choose Start Menu Folder)' window appeared and 'Install' button was clicked.")
    }
}


; Test if can get thru 'Installing'
TestsTotal++
if bContinue
{
    WinWaitActive, Far Manager v1.70 Setup, Installing, 3
    if ErrorLevel
        TestsFailed("'Far Manager v1.70 Setup (Installing)' window failed to appear.")
    else
    {
        TestsInfo("'Installing' window appeared, waiting for it to close.")
        WinWaitClose, Far Manager v1.70 Setup, Installing, 35
        if ErrorLevel
            TestsFailed("'Far Manager v1.70 Setup (Installing)' window failed to dissapear.")
        else
        {
            WinWaitActive, Far Manager v1.70 Setup, Installation Complete, 3
            if ErrorLevel
                TestsFailed("'Far Manager v1.70 Setup (Installation Complete)' window failed to appear.")
            else
            {
                ControlClick, Button2, Far Manager v1.70 Setup, Installation Complete
                if ErrorLevel
                    TestsFailed("Unable to hit 'Next' button in 'Far Manager v1.70 Setup (Installation Complete)' window.")
                else
                    TestsOK("'Installing' went away, 'Next' button was clicked in 'Far Manager v1.70 Setup (Installation Complete)' window.")
            }
        }
    }
}


; Test if 'Additional tasks' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Far Manager v1.70 Setup, Additional tasks, 3
    if ErrorLevel
        TestsFailed("'Far Manager v1.70 Setup (Additional tasks)' window failed to appear.")
    else
    {
        ControlClick, Button2, Far Manager v1.70 Setup, Additional tasks
        if ErrorLevel
            TestsFailed("Unable to hit 'Next' button in 'Far Manager v1.70 Setup (Additional tasks)' window.")
        else
            TestsOK("'Far Manager v1.70 Setup (Additional tasks)' window appeared and 'Next' button was clicked.")
    } 
}


; Test if 'Completing' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Far Manager v1.70 Setup, Completing, 3
    if ErrorLevel
        TestsFailed("'Far Manager v1.70 Setup (Completing)' window failed to appear.")
    else
    {
        ControlClick, Button4, Far Manager v1.70 Setup, Completing ; Uncheck 'Run Far Manager v1.70'
        if ErrorLevel
        {
            TestsFailed("Unable to uncheck 'Run Far Manager v1.70' in 'Far Manager v1.70 Setup (Completing)' window.")
            Process, Close, Far.exe ; Just in case
        }
        else
        {
            ControlGet, bChecked, Checked,, Button4
            if bChecked = 1
                TestsFailed("'Run Far Manager v1.70' checkbox in 'Far Manager v1.70 Setup (Completing)' window reported as unchecked, but further inspection proves that it was still checked.")
            else
            {
                ControlClick, Button5, Far Manager v1.70 Setup, Completing ; Uncheck 'Show whats new'
                if ErrorLevel
                    TestsFailed("Unable to uncheck 'Show whats new' checkbox in 'Far Manager v1.70 Setup (Completing)' window.")
                else
                {
                    ControlClick, Button2, Far Manager v1.70 Setup, Completing ; Hit 'Finish'
                    if ErrorLevel
                        TestsFailed("Unable to hit 'Finish' button in 'Far Manager v1.70 Setup (Completing)' window.")
                    else
                    {
                        WinWaitClose, Far Manager v1.70 Setup, Completing, 3
                        if ErrorLevel
                            TestsFailed("'Far Manager v1.70 Setup (Completing)' window failed to close despite 'Finish' button being clicked.")
                        else
                            TestsOK("'Far Manager v1.70 Setup (Completing)' window appeared, 'Finish' button clicked and window closed.")
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
    RegRead, UninstallerPath, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Far manager, UninstallString
    if not ErrorLevel
    {
        SplitPath, UninstallerPath,, InstalledDir
        IfExist, %InstalledDir%\%MainAppFile%
            TestsOK("The application has been installed, because '" InstalledDir "\" MainAppFile "' was found.")
        else
            TestsFailed("Something went wrong, can't find '" InstalledDir "\" MainAppFile "'.")
    }
    else
        TestsFailed("Either we can't read from registry or data doesn't exist.")
}
