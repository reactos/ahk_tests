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
    Sleep, 2000
    Process, Exist, %MainAppFile%
    if ErrorLevel <> 0
        TestsFailed("Unable to terminate '" MainAppFile "' process.") ; So, process still exists
    else
    {
        RegRead, UninstallerPath, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Mozilla Thunderbird (2.0.0.18), UninstallString
        if ErrorLevel
        {
            ; There was a problem (such as a nonexistent key or value). 
            ; That probably means we have not installed this app before.
            ; Check in default directory to be extra sure
            IfNotExist, %A_ProgramFiles%\Mozilla Thunderbird
                bContinue := true ; No previous versions detected in hardcoded path
            else
            {
                bHardcoded := true ; To know if we got path from registry or not
                IfExist, %A_ProgramFiles%\Mozilla Thunderbird\uninstall\helper.exe
                {
                    RunWait, %A_ProgramFiles%\Mozilla Thunderbird\uninstall\helper.exe /S ; Silently uninstall it
                    Sleep, 7000
                }

                IfNotExist, %A_ProgramFiles%\Mozilla Thunderbird ; Uninstaller might delete the dir
                    bContinue := true
                {
                    FileRemoveDir, %A_ProgramFiles%\Mozilla Thunderbird, 1
                    if ErrorLevel
                        TestsFailed("Unable to delete existing '" A_ProgramFiles "\Mozilla Thunderbird' ('" MainAppFile "' process is reported as terminated).'")
                    else
                        bContinue := true
                }
            }
        }
        else
        {
            SplitPath, UninstallerPath,, InstalledDir
            SplitPath, InstalledDir,, InstalledDir ; Split once more, since installer was in subdir (Thunderbird specific)
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
    SetTitleMatchMode, 2 ; A window's title can contain WinTitle anywhere inside it to be a match.
    WinWaitActive, Extracting, Cancel, 10 ; Wait 10 secs for window to appear
    if ErrorLevel ; Window is found and it is active
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
        Sleep, 700
        ControlClick, Button2, Mozilla Thunderbird Setup, Welcome to the Mozilla Thunderbird
        if ErrorLevel
            TestsFailed("Unable to click 'Next' in 'Mozilla Thunderbird Setup (Welcome to the Mozilla Thunderbird)' window.")
        else
            TestsOK("'Mozilla Thunderbird Setup (Welcome to the Mozilla Thunderbird)' window appeared and 'Next' was clicked.")
    }
}


ThunderbirdWnd := "Mozilla Thunderbird Setup " ; There is space at the end of the title
; Test if 'License Agreement' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, %ThunderbirdWnd%, License Agreement, 7
    if ErrorLevel
        TestsFailed("'Mozilla Thunderbird Setup (License Agreement)' window failed to appear.")
    else
    {
        Sleep, 700
        ControlClick, Button4, %ThunderbirdWnd%, License Agreement ; check 'I accept' radio button
        if ErrorLevel
            TestsFailed("Unable to check 'I agree' radio button in 'Mozilla Thunderbird Setup (License Agreement)' window.")
        else
        {
            Sleep, 1500 ; Give some time for 'Next' to get enabled
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
    WinWaitActive, Mozilla Thunderbird Setup, Setup Type, 7
    if ErrorLevel
        TestsFailed("'Mozilla Thunderbird Setup (Setup Type)' window failed to appear.")
    else
    {
        Sleep, 700
        ControlClick, Button2, Mozilla Thunderbird Setup, Setup Type
        if ErrorLevel
            TestsFailed("Unable to click 'Next' in 'Mozilla Thunderbird Setup (Setup Type)' window.")
        else
            TestsOK("'Mozilla Thunderbird Setup (Setup Type)' window appeared and 'Next' was clicked.")
    }
}


; Test if 'Completing' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, %ThunderbirdWnd%, Completing, 7
    if ErrorLevel
        TestsFailed("'Mozilla Thunderbird Setup (Completing)' window failed to appear.")
    else
    {
        Sleep, 700
        ControlClick, Button4, %ThunderbirdWnd%, Completing ; Uncheck 'Launch Mozilla Thunderbird now'
        if ErrorLevel
        {
            TestsFailed("Unable to uncheck 'Launch Mozilla Thunderbird now' in 'Mozilla Thunderbird Setup (Completing)' window.")
            Process, Close, %MainAppFile% ; Just in case
        }
        else
        {
            ControlClick, Button2, %ThunderbirdWnd%, Completing ; Hit 'Finish'
            if ErrorLevel
                TestsFailed("Unable to click 'Finish' in 'Mozilla Thunderbird Setup (Completing)' window.")
            else
            {
                WinWaitClose, %ThunderbirdWnd%, Completing, 10
                if ErrorLevel
                    TestsFailed("'Mozilla Thunderbird Setup (Completing)' failed to close despite 'Finish' was clicked.")
                else
                {
                    Process, Wait, %MainAppFile%, 4
                    NewPID = %ErrorLevel%  ; Save the value immediately since ErrorLevel is often changed.
                    if NewPID <> 0
                    {
                        TestsFailed("Process '" MainAppFile "' appeared despite 'Launch Mozilla Thunderbird now' being reported as unchecked.")
                        Process, Close, %MainAppFile%
                    }
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
    Sleep, 2000
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
