/*
 * Designed for Sunbird 0.9
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

ModuleExe = %A_WorkingDir%\Apps\Sunbird 0.9 Setup.exe
bContinue := false
TestName = 1.install

TestsFailed := 0
TestsOK := 0
TestsTotal := 0

; Test if Setup file exists, if so, delete installed files, and run Setup
IfNotExist, %ModuleExe%
{
    OutputDebug, %TestName%:%A_LineNumber%: Test failed: '%ModuleExe%' not found.`n
    bContinue := false
}
else
{
    ; Get rid of other versions
    RegRead, UninstallerPath, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Mozilla Sunbird (0.9), UninstallString
    if not ErrorLevel
    {   
        IfExist, %UninstallerPath%
        {
            Process, Close, sunbird.exe ; Teminate process
            Sleep, 1500
            RunWait, %UninstallerPath% /S ; Silently uninstall it
            Sleep, 3500
            ; Delete everything just in case
            RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\Mozilla\Mozilla Sunbird
            RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\Mozilla Sunbird 9.0
            RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\MicroSoft\Windows\CurrentVersion\Uninstall\Mozilla Sunbird (2.0.0.18)
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
        IfExist, %A_ProgramFiles%\Mozilla Sunbird\uninstall\helper.exe
        {
            Process, Close, sunbird.exe ; Teminate process
            Sleep, 1500
            RunWait, %A_ProgramFiles%\Mozilla Sunbird\uninstall\helper.exe /S ; Silently uninstall it
            Sleep, 2500
            FileRemoveDir, %A_ProgramFiles%\Mozilla Sunbird, 1
            FileRemoveDir, %A_AppData%\Mozilla, 1
            Sleep, 1000
            IfExist, %A_ProgramFiles%\Mozilla Sunbird
            {
                OutputDebug, %TestName%:%A_LineNumber%: Test failed: Previous version detected and failed to delete '%A_ProgramFiles%\Mozilla Sunbird'.`n
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


; Test if can start setup
TestsTotal++
if bContinue
{
    SetTitleMatchMode, 2
    WinWaitActive, Extracting, Cancel, 10 ; Wait 10 secs for window to appear
    if ErrorLevel
        TestsFailed("'Extracting' window failed to appear.")
    else
    {
        OutputDebug, OK: %TestName%:%A_LineNumber%: 'Extracting' window appeared, waiting for it to close.`n
        WinWaitClose, Extracting, Cancel, 15
        if ErrorLevel 
            TestsFailed("'Extracting' window failed to dissapear.")
        else
            TestsOK("'Extracting' window appeared and went away.")
    }
}


; Test if 'This wizard' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Mozilla Sunbird Setup, This wizard, 15
    if ErrorLevel
        TestsFailed("'Mozilla Sunbird Setup (This wizard)' window failed to appear.")
    else
    {
        Sleep, 250
        ControlClick, Button2, Mozilla Sunbird Setup, This wizard
        if ErrorLevel
            TestsFailed("Unable to click 'Next' in 'Mozilla Sunbird Setup (This wizard)' window.")
        else
            TestsOK("'Mozilla Sunbird Setup (This wizard)' window appeared and 'Next' was clicked.")
    }  
}


; Test if 'License Agreement' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Mozilla Sunbird Setup, License Agreement, 5
    if ErrorLevel
        TestsFailed("'Mozilla Sunbird Setup' window with 'Mozilla Sunbird Setup (License Agreement)' failed to appear.")
    else
    {
        Sleep, 250
        ControlClick, Button4, Mozilla Sunbird Setup, License Agreement ; check 'I accept' radio button
        if ErrorLevel
            TestsFailed("Unable to check 'I agree' radio button in 'Mozilla Sunbird Setup (License Agreement)' window.")
        else
        {
            Sleep, 1500 ; Give some time for 'Next' to get enabled
            ControlGet, OutputVar, Enabled,, Button2, Mozilla Sunbird Setup, License Agreement
            if not %OutputVar%
                TestsFailed("'I agree' radio button is checked in 'Mozilla Sunbird Setup (License Agreement)', but 'Next' button is disabled.")
            else
            {
                ControlClick, Button2, Mozilla Sunbird Setup, License Agreement
                if ErrorLevel
                    TestsFailed("Unable to hit 'Next' button in 'Mozilla Sunbird Setup (License Agreement)' window despite it is enabled.")
                else
                    TestsOK("'Mozilla Sunbird Setup (License Agreement)' window appeared and 'Next' was clicked.")
            }
        }
    }
}



; Test if 'Setup Type' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Mozilla Sunbird Setup, Setup Type, 7
    if ErrorLevel
        TestsFailed("'Mozilla Sunbird Setup (Setup Type)' window failed to appear.")
    else
    {
        Sleep, 250
        ControlClick, Button2, Mozilla Sunbird Setup, Setup Type
        if ErrorLevel
            TestsFailed("Unable to click 'Next' in 'Mozilla Sunbird Setup (Setup Type)' window.")
        else
            TestsOK("'Mozilla Sunbird Setup (Setup Type)' window appeared and 'Next' was clicked.")
    }
}


; Test if can get thru 'Installing'
TestsTotal++
if bContinue
{
    WinWaitActive, Mozilla Sunbird Setup, Installing, 7
    if ErrorLevel
        TestsFailed("'Mozilla Sunbird Setup (Installing)' window failed to appear.")
    else
    {
        Sleep, 250
        OutputDebug, OK: %TestName%:%A_LineNumber%: 'Mozilla Sunbird Setup (Installing)' window appeared, waiting for it to close.`n
        WinWaitClose, Mozilla Sunbird Setup, Installing, 35
        if ErrorLevel
            TestsFailed("'Mozilla Sunbird Setup (Installing)' window failed to dissapear.")
        else
            TestsOK("'Mozilla Sunbird Setup (Installing)' window went away.")
    }
}


; Test if 'Completing' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Mozilla Sunbird Setup, Completing, 7
    if ErrorLevel
        TestsFailed("'Mozilla Sunbird Setup (Completing)' window failed to appear.")
    else
    {
        Sleep, 250
        ControlClick, Button4, Mozilla Sunbird Setup, Completing ; Uncheck 'Launch Mozilla Sunbird now'
        if ErrorLevel
        {
            TestsFailed("Unable to uncheck 'Launch Mozilla Sunbird now' in 'Completing' window.")
            Process, Wait, thunderbird.exe, 5
            Process, Close, thunderbird.exe
        }
        else
        {
            ControlClick, Button2, Mozilla Sunbird Setup, Completing ; Hit 'Finish'
            if ErrorLevel
                TestsFailed("Unable to click 'Finish' in 'Mozilla Sunbird Setup (Completing)' window.")
            else
            {
                WinWaitClose, Mozilla Sunbird Setup, Completing, 5
                if ErrorLevel
                    TestsFailed("'Mozilla Sunbird Setup (Completing)' window failed to close despite 'Finish' button was clicked.")
                else
                    TestsOK("'Mozilla Sunbird Setup (Completing)' window appeared, 'Finish' button was clicked and window closed.")
            }
        }
    }
}


; Check if program exists
TestsTotal++
if bContinue
{
    Sleep, 2000
    RegRead, UninstallerPath, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Mozilla Sunbird (0.9), UninstallString
    if ErrorLevel
        TestsFailed("Either we can't read from registry or data doesn't exist.")
    else
    {
        IfNotExist, %UninstallerPath%
            TestsFailed("Something went wrong, can't find '" UninstallerPath "'.")
        else
            TestsOK("The application has been installed, because '" UninstallerPath "' was found.")
    } 
}
