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
TestName = 1.install
MainAppFile = sunbird.exe ; Mostly this is going to be process we need to look for

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
        RegRead, UninstallerPath, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Mozilla Sunbird (0.9), UninstallString
        if ErrorLevel
        {
            ; There was a problem (such as a nonexistent key or value). 
            ; That probably means we have not installed this app before.
            ; Check in default directory to be extra sure
            IfNotExist, %A_ProgramFiles%\Mozilla Sunbird
                bContinue := true ; No previous versions detected in hardcoded path
            else
            {
                bHardcoded := true ; To know if we got path from registry or not
                IfExist, %A_ProgramFiles%\Mozilla Sunbird\uninstall\helper.exe
                {
                    RunWait, %A_ProgramFiles%\Mozilla Sunbird\uninstall\helper.exe /S ; Silently uninstall it
                    Sleep, 7000
                }

                IfNotExist, %A_ProgramFiles%\Mozilla Sunbird ; Uninstaller might delete the dir
                    bContinue := true
                {
                    FileRemoveDir, %A_ProgramFiles%\Mozilla Sunbird, 1
                    if ErrorLevel
                        TestsFailed("Unable to delete hardcoded path '" A_ProgramFiles "\Mozilla Sunbird' ('" MainAppFile "' process is reported as terminated).'")
                    else
                        bContinue := true
                }
            }
        }
        else
        {
            SplitPath, UninstallerPath,, InstalledDir
            IfNotExist, %InstalledDir%
                bContinue := true
            else
            {
                IfExist, %UninstallerPath%
                {
                    RunWait, %UninstallerPath% /S ; Silently uninstall it
                    Sleep, 7000
                }

                IfNotExist, %InstalledDir%
                    bContinue := true
                else
                {
                    FileRemoveDir, %InstalledDir%, 1 ; Delete just in case
                    if ErrorLevel
                        TestsFailed("Unable to delete existing '" InstalledDir "' ('" MainAppFile "' process is reported as terminated).")
                    else
                        bContinue := true
                }
            }
        }
    }

    if bContinue
    {
        RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\Mozilla\Mozilla Sunbird
        RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\Mozilla Sunbird 9.0
        RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\MicroSoft\Windows\CurrentVersion\Uninstall\Mozilla Sunbird (0.9)
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
    SetTitleMatchMode, 2
    WinWaitActive, Extracting, Cancel, 10 ; Wait 10 secs for window to appear
    if ErrorLevel
        TestsFailed("'Extracting' window failed to appear.")
    else
    {
        OutputDebug, OK: %TestName%:%A_LineNumber%: 'Extracting' window appeared, waiting for it to close.`n
        WinWaitClose, Extracting, Cancel, 20
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
    WinWaitActive, Mozilla Sunbird Setup, This wizard, 20
    if ErrorLevel
        TestsFailed("'Mozilla Sunbird Setup (This wizard)' window failed to appear.")
    else
    {
        Sleep, 700
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
        Sleep, 700
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
        Sleep, 700
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
        Sleep, 700
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
        Sleep, 700
        ControlClick, Button4, Mozilla Sunbird Setup, Completing ; Uncheck 'Launch Mozilla Sunbird now'
        if ErrorLevel
        {
            TestsFailed("Unable to uncheck 'Launch Mozilla Sunbird now' in 'Completing' window.")
            Process, Wait, thunderbird.exe, 5
            Process, Close, thunderbird.exe
        }
        else
        {
            Sleep, 700
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
        SplitPath, UninstallerPath,, InstalledDir
        SplitPath, InstalledDir,, InstalledDir ; Split once more
        IfNotExist, %InstalledDir%\%MainAppFile%
            TestsFailed("Something went wrong, can't find '" InstalledDir "\" MainAppFile "'.")
        else
            TestsOK("The application has been installed, because '" InstalledDir "\" MainAppFile "' was found.")
    }
}
