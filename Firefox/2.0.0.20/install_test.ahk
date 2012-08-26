/*
 * Designed for Firefox 2.0.0.20
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

ModuleExe = %A_WorkingDir%\Apps\Firefox 2.0.0.20 Setup.exe
bContinue := false
TestName = 1.install

TestsFailed := 0
TestsOK := 0
TestsTotal := 0

; Test if Setup file exists, if so, delete installed files, and run Setup
IfExist, %ModuleExe%
{
    ; Get rid of other versions
    RegRead, UninstallerPath, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Mozilla Firefox (2.0.0.20), UninstallString
    if not ErrorLevel
    {   
        IfExist, %UninstallerPath%
        {
            Process, Close, firefox.exe ; Teminate process
            Sleep, 1500
            RunWait, %UninstallerPath% /S ; Silently uninstall it
            Sleep, 2500
            ; Delete everything just in case
            RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\Mozilla
            RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\mozilla.org
            RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\MozillaPlugins
            RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\MicroSoft\Windows\CurrentVersion\Uninstall\Mozilla Firefox (2.0.0.20)
            SplitPath, UninstallerPath,, InstalledDir
            FileRemoveDir, %InstalledDir%, 1
            FileRemoveDir, %A_AppData%\Mozilla, 1
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
        IfExist, %A_ProgramFiles%\Mozilla Firefox\uninstall\helper.exe
        {
            Process, Close, firefox.exe ; Teminate process
            Sleep, 1500
            RunWait, %A_ProgramFiles%\Mozilla Firefox\uninstall.exe /S ; Silently uninstall it
            Sleep, 2500
            FileRemoveDir, %A_ProgramFiles%\Mozilla Firefox, 1
            FileRemoveDir, %A_AppData%\Mozilla, 1
            Sleep, 1000
            IfExist, %A_ProgramFiles%\Mozilla Firefox
            {
                OutputDebug, %TestName%:%A_LineNumber%: Test failed: Previous version detected and failed to delete '%A_ProgramFiles%\Mozilla Firefox'.`n
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


; Test if can start setup
TestsTotal++
if bContinue
{
    SetTitleMatchMode, 1
    WinWaitActive, Extracting, Cancel, 10 ; Wait 10 secs for window to appear
    if not ErrorLevel ;Window is found and it is active
    {
        OutputDebug, OK: %TestName%:%A_LineNumber%: 'Extracting' window appeared, waiting for it to close.`n
        WinWaitClose, Extracting, Cancel, 15
        if not ErrorLevel
            TestsOK("'Extracting' window appeared and went away.")
        else
            TestsFailed("'Extracting' window failed to dissapear.")
    }
    else
        TestsFailed("'Extracting' window failed to appear.")
}


; Test if 'Welcome to the Mozilla Firefox' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Mozilla Firefox Setup, Welcome to the Mozilla Firefox, 15
    if not ErrorLevel
    {
        Sleep, 250
        ControlClick, Button2, Mozilla Firefox Setup, Welcome to the Mozilla Firefox
        if not ErrorLevel
            TestsOK("'Mozilla Firefox Setup (Welcome to the Mozilla Firefox)' window appeared and 'Next' button was clicked.")
        else
            TestsFailed("Unable to hit 'Next' in 'Mozilla Firefox Setup (Welcome to the Mozilla Firefox)' window.")
    }
    else
        TestsFailed("'Mozilla Firefox Setup (Welcome to the Mozilla Firefox)' window failed to appear.")
}


; Test if 'License Agreement' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Mozilla Firefox Setup, License Agreement, 15
    if not ErrorLevel
    {
        Sleep, 250
        ControlClick, Button4, Mozilla Firefox Setup, License Agreement ; check 'I accept' radio button
        if not ErrorLevel
        {
            Sleep, 1500 ; Give some time for 'Next' to get enabled
            ControlGet, OutputVar, Enabled,, Button2, Mozilla Firefox Setup, License Agreement
            if %OutputVar%
            {
                ControlClick, Button2, Mozilla Firefox Setup, License Agreement
                if not ErrorLevel
                    TestsOK("'Mozilla Firefox Setup (License Agreement)' window appeared and 'Next' button was clicked.")
                else
                    TestsFailed("Unable to hit 'Next' button in 'Mozilla Firefox Setup (License Agreement)' window despite it is enabled.")
            }
            else
                TestsFailed("'I agree' radio button is checked in 'License Agreement', but 'Next' button is disabled.")
        }
        else
            TestsFailed("Unable to check 'I agree' radio button in 'License Agreement' window.")
    }
    else
        TestsFailed("'Mozilla Firefox Setup (License Agreement)' window failed to appear.")
}


; Test if 'Setup Type' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Mozilla Firefox Setup, Setup Type, 7
    if not ErrorLevel
    {
        Sleep, 250
        ControlClick, Button2, Mozilla Firefox Setup, Setup Type
        if not ErrorLevel
            TestsOK("'Mozilla Firefox Setup (Setup Type)' window appeared and 'Next' button was clicked.")
        else
            TestsFailed("Unable to hit 'Next' in 'Mozilla Firefox Setup (Setup Type)' window.")
    }
    else
        TestsFailed("'Mozilla Firefox Setup (Setup Type)' window failed to appear.")
}


; Test if can get thru 'Installing'
TestsTotal++
if bContinue
{
    WinWaitActive, Mozilla Firefox Setup, Installing, 7
    if not ErrorLevel
    {
        Sleep, 250
        OutputDebug, OK: %TestName%:%A_LineNumber%: 'Mozilla Firefox Setup (Installing)' window appeared, waiting for it to close.`n
        WinWaitClose, Mozilla Firefox Setup, Installing, 25
        if not ErrorLevel
            TestsOK("'Mozilla Firefox Setup (Installing)' window went away.")
        else
            TestsFailed("'Mozilla Firefox Setup (Installing)' window failed to dissapear.")
    }
    else
        TestsFailed("'Mozilla Firefox Setup (Installing)' window failed to appear.")
}


; Test if 'Completing' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Mozilla Firefox Setup, Completing, 7
    if not ErrorLevel
    {
        Sleep, 250
        ControlClick, Button4, Mozilla Firefox Setup, Completing ; Uncheck 'Launch Mozilla Firefox now'
        if not ErrorLevel
        {
            ControlClick, Button2, Mozilla Firefox Setup, Completing ; Hit 'Finish'
            if not ErrorLevel
                TestsOK("'Mozilla Firefox Setup (Completing)' window appeared and 'Finish' was clicked.")
            else
                TestsFailed("Unable to hit 'Finish' in 'Mozilla Firefox Setup (Completing)' window.")
        }
        else
        {
            TestsFailed("Unable to uncheck 'Launch Mozilla Firefox now' in 'Completing' window.")
            Process, Close, firefox.exe
        }
    }
    else
        TestsFailed("'Mozilla Firefox Setup (Completing)' window failed to appear.")
}


;Check if program exists
TestsTotal++
if bContinue
{
    Sleep, 2000
    RegRead, UninstallerPath, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Mozilla Firefox (2.0.0.20), UninstallString
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
