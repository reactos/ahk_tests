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
bContinue := false
TestName = 1.install

TestsFailed := 0
TestsOK := 0
TestsTotal := 0

; Test if Setup file exists, if so, delete installed files, and run Setup
IfExist, %ModuleExe%
{
    ; Get rid of other versions
    RegRead, UninstallerPath, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Far manager, UninstallString
    if not ErrorLevel
    {   
        IfExist, %UninstallerPath%
        {
            Process, Close, Far.exe ; Teminate process
            Sleep, 1500
            ; Silent uninstall is broken (at least /S shows dialog)
            ; Delete everything just in case
            RegDelete, HKEY_CURRENT_USER, SOFTWARE\Far
            RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\MicroSoft\Windows\CurrentVersion\Uninstall\Far manager
            SplitPath, UninstallerPath,, InstalledDir
            FileRemoveDir, %InstalledDir%, 1
            Sleep, 1000
            IfExist, %InstalledDir%
            {
                OutputDebug, %TestName%:%A_LineNumber%: Test failed: Failed to delete '%InstalledDir%'.`n
                bContinue := false
            }
            else
            {
                bContinue := true
            }
        }
    }
    else
    {
        ; There was a problem (such as a nonexistent key or value). 
        ; That probably means we have not installed this app before.
        ; Check in default directory to be extra sure
        IfExist, %A_ProgramFiles%\Far
        {
            Process, Close, Far.exe ; Teminate process
            Sleep, 1500
            FileRemoveDir, %A_ProgramFiles%\Far, 1
            RegDelete, HKEY_CURRENT_USER, SOFTWARE\Far
            RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\MicroSoft\Windows\CurrentVersion\Uninstall\Far manager
            IfExist, %A_ProgramFiles%\Far
            {
                OutputDebug, %TestName%:%A_LineNumber%: Test failed: Previous version detected and failed to delete '%A_ProgramFiles%\Far'.`n
                bContinue := false
            }
            else
            {
                bContinue := true
            }
        }
        else
        {
            ; No previous versions detected.
            bContinue := true
        }
    }
    if bContinue
    {
        FileRemoveDir, %A_StartMenu%\Programs\Far Manager, 1
        FileDelete, %A_Desktop%\Far Manager.lnk
        Sleep, 1000
        Run %ModuleExe%
    }
}
else
{
    OutputDebug, %TestName%:%A_LineNumber%: Test failed: '%ModuleExe%' not found.`n
    bContinue := false
}


; Test if 'Installer Language' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Installer Language, Please select, 15
    if not ErrorLevel
    {
        Sleep, 250
        ControlClick, Button1, Installer Language, Please select
        if not ErrorLevel
            TestsOK("'Installer Language (Please select)' window appeared and 'OK' button was clicked.")
        else
            TestsFailed("Unable to hit 'OK' button in 'Installer Language (Please select)' window.")
    }
    else
        TestsFailed("'Installer Language (Please select)' window failed to appear.")
}


; Test if 'This program will install' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Far Manager v1.70 Setup, This program will install, 15
    if not ErrorLevel
    {
        Sleep, 250
        ControlClick, Button2, Far Manager v1.70 Setup, This program will install
        if not ErrorLevel
            TestsOK("'Far Manager v1.70 Setup (This program will install)' window appeared and 'Next' button was clicked.")
        else
            TestsFailed("Unable to hit 'Next' button in 'Far Manager v1.70 Setup (This program will install)' window.")
    }
    else
        TestsFailed("'Far Manager v1.70 Setup (This program will install')' window failed to appear.")
}


; Test if 'License Agreement' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Far Manager v1.70 Setup, License Agreement, 15
    if not ErrorLevel
    {
        Sleep, 250
        ControlClick, Button4, Far Manager v1.70 Setup, License Agreement ; check 'I accept' checkbox
        if not ErrorLevel
        {
            Sleep, 1500 ; Give some time for 'Next' to get enabled
            ControlGet, OutputVar, Enabled,, Button2, Far Manager v1.70 Setup, License Agreement
            if %OutputVar%
            {
                ControlClick, Button2, Far Manager v1.70 Setup, License Agreement
                if not ErrorLevel
                    TestsOK("'Far Manager v1.70 Setup (License Agreement)' window appeared and 'Next' button was clicked.")
                else
                    TestsFailed("Unable to hit 'Next' button in 'Far Manager v1.70 Setup (License Agreement)' window despite it is enabled.")
            }
            else
                TestsFailed("'I agree' radio button is checked in 'Far Manager v1.70 Setup (License Agreement)' window, but 'Next' button is disabled.")
        }
        else
            TestsFailed("Unable to check 'I agree' radio button in 'Far Manager v1.70 Setup (License Agreement)' window.")
    }
    else
        TestsFailed("'Far Manager v1.70 Setup (License Agreement)' window failed to appear.")
}


; Test if 'Choose Install Location' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Far Manager v1.70 Setup, Choose Install Location, 7
    if not ErrorLevel
    {
        Sleep, 250
        ControlClick, Button2, Far Manager v1.70 Setup, Choose Install Location
        if not ErrorLevel
            TestsOK("'Far Manager v1.70 Setup (Choose Install Location)' window appeared and 'Next' was clicked.")
        else
            TestsFailed("Unable to hit 'Next' button in 'Far Manager v1.70 Setup (Choose Install Location)' window.")
    }
    else
        TestsFailed("'Far Manager v1.70 Setup (Choose Install Location)' window failed to appear.")
}


; Test if 'Choose Components' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Far Manager v1.70 Setup, Choose Components, 7
    if not ErrorLevel
    {
        Sleep, 250
        ControlClick, Button2, Far Manager v1.70 Setup, Choose Components
        if not ErrorLevel
            TestsOK("'Far Manager v1.70 Setup (Choose Components)' window appeared and 'Next' button was clicked.")
        else
            TestsFailed("Unable to hit 'Next' button in 'Far Manager v1.70 Setup (Choose Components)' window.")
    }
    else
        TestsFailed("'Far Manager v1.70 Setup (Choose Components)' window failed to appear.")
}


; Test if 'Choose Start Menu Folder' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Far Manager v1.70 Setup, Choose Start Menu Folder, 7
    if not ErrorLevel
    {
        Sleep, 250
        ControlClick, Button2, Far Manager v1.70 Setup, Choose Start Menu Folder ; Hit 'Install' button
        if not ErrorLevel
            TestsOK("'Far Manager v1.70 Setup (Choose Start Menu Folder)' window appeared and 'Install' button was clicked.")
        else
            TestsFailed("Unable to hit 'Install' button in 'Far Manager v1.70 Setup (Choose Start Menu Folder)' window.")
    }
    else
        TestsFailed("'Far Manager v1.70 Setup (Choose Start Menu Folder)' window failed to appear.")
}


; Test if can get thru 'Installing'
TestsTotal++
if bContinue
{
    WinWaitActive, Far Manager v1.70 Setup, Installing, 7
    if not ErrorLevel
    {
        Sleep, 250
        OutputDebug, OK: %TestName%:%A_LineNumber%: 'Installing' window appeared, waiting for it to close.`n
        WinWaitClose, Far Manager v1.70 Setup, Installing, 35
        if not ErrorLevel
        {
            WinWaitActive, Far Manager v1.70 Setup, Installation Complete, 5
            if not ErrorLevel
            {
                ControlClick, Button2, Far Manager v1.70 Setup, Installation Complete
                if not ErrorLevel
                    TestsOK("'Installing' went away, 'Next' button was clicked in 'Far Manager v1.70 Setup (Installation Complete)' window.")
                else
                    TestsFailed("Unable to hit 'Next' button in 'Far Manager v1.70 Setup (Installation Complete)' window.")
            }
            else
                TestsFailed("'Far Manager v1.70 Setup (Installation Complete)' window failed to appear.")
        }
        else
            TestsFailed("'Far Manager v1.70 Setup (Installing)' window failed to dissapear.")
    }
    else
        TestsFailed("'Far Manager v1.70 Setup (Installing)' window failed to appear.")
}


; Test if 'Additional tasks' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Far Manager v1.70 Setup, Additional tasks, 7
    if not ErrorLevel
    {
        Sleep, 250
        ControlClick, Button2, Far Manager v1.70 Setup, Additional tasks
        if not ErrorLevel
            TestsOK("'Far Manager v1.70 Setup (Additional tasks)' window appeared and 'Next' button was clicked.")
        else
            TestsFailed("Unable to hit 'Next' button in 'Far Manager v1.70 Setup (Additional tasks)' window.")
    }
    else
        TestsFailed("'Far Manager v1.70 Setup (Additional tasks)' window failed to appear.")
}


; Test if 'Completing' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Far Manager v1.70 Setup, Completing, 7
    if not ErrorLevel
    {
        Sleep, 250
        ControlClick, Button4, Far Manager v1.70 Setup, Completing ; Uncheck 'Run Far Manager v1.70'
        if not ErrorLevel
        {
            ControlClick, Button5, Far Manager v1.70 Setup, Completing ; Uncheck 'Show whats new'
            if not ErrorLevel
            {
                ControlClick, Button2, Far Manager v1.70 Setup, Completing ; Hit 'Finish'
                if not ErrorLevel
                    TestsOK("'Far Manager v1.70 Setup (Completing)' window appeared and 'Finish' button was clicked.")
                else
                    TestsFailed("Unable to hit 'Finish' button in 'Far Manager v1.70 Setup (Completing)' window.")
            }
            else
                TestsFailed("Unable to uncheck 'Show whats new' checkbox in 'Far Manager v1.70 Setup (Completing)' window.")
        }
        else
        {
            TestsFailed("Unable to uncheck 'Run Far Manager v1.70' in 'Far Manager v1.70 Setup (Completing)' window.")
            Process, Close, Far.exe ; Just in case
        }
    }
    else
        TestsFailed("'Far Manager v1.70 Setup (Completing)' window failed to appear.")
}


; Check if program exists
TestsTotal++
if bContinue
{
    Sleep, 2000
    RegRead, UninstallerPath, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Far manager, UninstallString
    if not ErrorLevel
    {
        IfExist, %UninstallerPath%
            TestsOK("The application has been installed, because '" UninstallerPath "' was found.")
        else
            TestsFailed("Something went wrong, can't find '" UninstallerPath "'.")
    }
    else
        TestsFailed("Either we can't read from registry or data doesn't exist.")
}
