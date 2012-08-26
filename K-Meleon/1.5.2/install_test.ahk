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
bContinue := false
TestName = 1.install

TestsFailed := 0
TestsOK := 0
TestsTotal := 0

; Test if Setup file exists, if so, delete installed files, and run Setup
IfExist, %ModuleExe%
{
    ; Get rid of other versions
    RegRead, UninstallerPath, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\K-Meleon, UninstallString
    if not ErrorLevel
    {   
        IfExist, %UninstallerPath%
        {
            Process, Close, k-meleon.exe ; Teminate process
            Sleep, 1500
            FileRemoveDir, %A_AppData%\K-Meleon, 1 ; Delete this before uninstalling
            RunWait, %UninstallerPath% /S ; Silently uninstall it
            Sleep, 2500
            ; Delete everything just in case
            RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\K-Meleon
            RegDelete, HKEY_CURRENT_USER, SOFTWARE\K-Meleon
            RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\MicroSoft\Windows\CurrentVersion\Uninstall\K-Meleon
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
        IfExist, %A_ProgramFiles%\K-Meleon\uninstall.exe
        {
            Process, Close, k-meleon.exe ; Teminate process
            Sleep, 1500
            RunWait, %A_ProgramFiles%\K-Meleon\uninstall.exe /S ; Silently uninstall it
            Sleep, 2500
            FileRemoveDir, %A_ProgramFiles%\K-Meleon, 1
            FileRemoveDir, %A_AppData%\K-Meleon, 1
            Sleep, 1000
            IfExist, %A_ProgramFiles%\K-Meleon
            {
                OutputDebug, %TestName%:%A_LineNumber%: Test failed: Previous version detected and failed to delete '%A_ProgramFiles%\K-Meleon'.`n
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
        Run %ModuleExe%
    }
}
else
{
    OutputDebug, %TestName%:%A_LineNumber%: Test failed: '%ModuleExe%' not found.`n
    bContinue := false
}


; Test if 'K-Meleon 1.5.2 Install Wizard' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, K-Meleon 1.5.2 en-US Setup, K-Meleon 1.5.2 Install Wizard, 15
    if not ErrorLevel
    {
        Sleep, 250
        ControlClick, Button2, K-Meleon 1.5.2 en-US Setup, K-Meleon 1.5.2 Install Wizard
        if not ErrorLevel
            TestsOK("'K-Meleon 1.5.2 en-US Setup (K-Meleon 1.5.2 Install Wizard)' window appeared and 'Next' was clicked.")
        else
            TestsFailed("Unable to click 'Next' in 'K-Meleon 1.5.2 en-US Setup (K-Meleon 1.5.2 Install Wizard)' window.")
    }
    else
        TestsFailed("'K-Meleon 1.5.2 en-US Setup (K-Meleon 1.5.2 Install Wizard)' window failed to appear.")
}


; Test if 'License Agreement' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, K-Meleon 1.5.2 en-US Setup, License Agreement, 7
    if not ErrorLevel
    {
        Sleep, 250
        ControlClick, Button2, K-Meleon 1.5.2 en-US Setup, License Agreement ; Hit 'I Agree' button
        if not ErrorLevel
            TestsOK("'K-Meleon 1.5.2 en-US Setup (License Agreement)' window appeared and 'I Agree' button was clicked.")
        else
            TestsFailed("Unable to click 'Next' in 'K-Meleon 1.5.2 en-US Setup (License Agreement)' window.")
    }
    else
        TestsFailed("'K-Meleon 1.5.2 en-US Setup (License Agreement)' window failed to appear.")
}


; Test if 'Choose Components' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, K-Meleon 1.5.2 en-US Setup, Choose Components, 7
    if not ErrorLevel
    {
        Sleep, 250
        ControlClick, Button2, K-Meleon 1.5.2 en-US Setup, Choose Components
        if not ErrorLevel
            TestsOK("'K-Meleon 1.5.2 en-US Setup (Choose Components)' window appeared and 'Next' was clicked.")
        else
            TestsFailed("Unable to click 'Next' in 'K-Meleon 1.5.2 en-US Setup (Choose Components)' window.")
    }
    else
        TestsFailed("'K-Meleon 1.5.2 en-US Setup (Choose Components)' window failed to appear.")
}


; Test if 'Choose Install Location' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, K-Meleon 1.5.2 en-US Setup, Choose Install Location, 7
    if not ErrorLevel
    {
        Sleep, 250
        ControlClick, Button2, K-Meleon 1.5.2 en-US Setup, Choose Install Location ; Hit 'Install' button
        if not ErrorLevel
            TestsOK("'K-Meleon 1.5.2 en-US Setup (Choose Install Location)' window appeared and 'Next' was clicked.")
        else
            TestsFailed("Unable to click 'Next' in 'K-Meleon 1.5.2 en-US Setup (Choose Install Location)' window.")
    }
    else
        TestsFailed("'K-Meleon 1.5.2 en-US Setup (Choose Install Location)' window failed to appear.")
}


; Test if can get thru 'Installing'
TestsTotal++
if bContinue
{
    WinWaitActive, K-Meleon 1.5.2 en-US Setup, Installing, 7
    if not ErrorLevel
    {
        Sleep, 250
        OutputDebug, OK: %TestName%:%A_LineNumber%: 'Installing' window appeared, waiting for it to close.`n
        WinWaitClose, K-Meleon 1.5.2 en-US Setup, Installing, 35
        if not ErrorLevel
        {
            WinWaitActive, K-Meleon 1.5.2 en-US Setup, Installation Complete, 7
            if not ErrorLevel
            {
                ControlClick, Button2, K-Meleon 1.5.2 en-US Setup, Installation Complete
                if not ErrorLevel
                    TestsOK("'Installing' went away, 'Installation Complete' appeared, and 'Next' was clicked.")
                else
                    TestsFailed("Unable to hit 'Next' button in 'K-Meleon 1.5.2 en-US Setup (Installation Complete)' window.")
            }
            else
                TestsFailed("'K-Meleon 1.5.2 en-US Setup (Installation Complete)' window failed to appear.")
        }
        else
            TestsFailed("'K-Meleon 1.5.2 en-US Setup (Installing)' window failed to close.")
    }
    else
        TestsFailed("'K-Meleon 1.5.2 en-US Setup (Installing)' window failed to appear.")
}


; Test if 'Completing' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, K-Meleon 1.5.2 en-US Setup, Completing, 7
    if not ErrorLevel
    {
        Sleep, 250
        ControlClick, Button4, K-Meleon 1.5.2 en-US Setup, Completing ; Uncheck 'Run K-Meleon 1.5.2'
        if not ErrorLevel
        {
            ControlClick, Button2, K-Meleon 1.5.2 en-US Setup, Completing ; Hit 'Finish'
            if not ErrorLevel
                TestsOK("'K-Meleon 1.5.2 en-US Setup (Completing)' window appeared, 'Run K-Meleon 1.5.2' unchecked and 'Finish' was clicked.")
            else
                TestsFailed("Unable to click 'Finish' in 'K-Meleon 1.5.2 en-US Setup (Completing)' window.")
        }
        else
            TestsFailed("Unable to uncheck 'Run K-Meleon 1.5.2' in 'K-Meleon 1.5.2 en-US Setup (Completing)' window.")
    }
    else
        TestsFailed("'K-Meleon 1.5.2 en-US Setup (Completing)' window failed to appear.")
}


; Check if program exists
TestsTotal++
if bContinue
{
    Sleep, 2000
    RegRead, UninstallerPath, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\K-Meleon, UninstallString
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
