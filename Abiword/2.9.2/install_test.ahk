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
    Sleep, 2000
    Process, Exist, %MainAppFile%
    if ErrorLevel <> 0
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
            IfNotExist, %A_ProgramFiles%\AbiWord
                bContinue := true ; No previous versions detected in hardcoded path
            else
            {
                bHardcoded := true ; To know if we got path from registry or not
                FileRemoveDir, %A_ProgramFiles%\AbiWord, 1
                if ErrorLevel
                    TestsFailed("Unable to delete existing '" A_ProgramFiles "\AbiWord' ('" MainAppFile "' process is reported as terminated).'")
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
    WinWaitActive, Installer Language, Please select, 15
    if ErrorLevel
        TestsFailed("'Installer Language (Please select)' window failed to appear. Unable to delete 'HKLM\SOFTWARE\AbiWord'?")
    else
    {
        Sleep, 700
        ControlClick, Button1, Installer Language, Please select
        if ErrorLevel
            TestsFailed("Unable to hit 'OK' button in 'Installer Language (Please select)' window.")
        else
        {
            WinWaitClose, Installer Language, Please select, 7
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
    WinWaitActive, AbiWord 2.9.2 Setup, This wizard, 15
    if ErrorLevel
        TestsFailed("'AbiWord 2.9.2 Setup (This wizard)' window failed to appear.")
    else
    {
        Sleep, 700
        ControlClick, Button2, AbiWord 2.9.2 Setup, This wizard ; Hit 'Next' button
        if ErrorLevel
            TestsFailed("Unable to hit 'Next' button in 'AbiWord 2.9.2 Setup (This wizard)' window.")
        else
            TestsOK("'AbiWord 2.9.2 Setup (This wizard)' window appeared and 'Next' button was clicked.")
    }
}


; Test if 'AbiWord 2.9.2 Setup (License Agreement)' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, AbiWord 2.9.2 Setup, License Agreement, 5
    if ErrorLevel
        TestsFailed("'AbiWord 2.9.2 Setup (License Agreement)' window failed to appear.")
    else
    {
        Sleep, 700
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
    WinWaitActive, AbiWord 2.9.2 Setup, Choose Components, 5
    if ErrorLevel
        TestsFailed("'AbiWord 2.9.2 Setup (Choose Components)' window failed to appear.")
    else
    {
        Sleep, 700
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
    WinWaitActive, AbiWord 2.9.2 Setup, Choose Install Location, 5
    if ErrorLevel
        TestsFailed("'AbiWord 2.9.2 Setup (Choose Install Location)' window failed to appear.")
    else
    {
        Sleep, 700
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
    WinWaitActive, AbiWord 2.9.2 Setup, Choose Start Menu Folder, 5
    if ErrorLevel
        TestsFailed("'AbiWord 2.9.2 Setup (Choose Start Menu Folder)' window failed to appear.")
    else
    {
        Sleep, 700
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
    WinWaitActive, AbiWord 2.9.2 Setup, Installing, 5
    if ErrorLevel
        TestsFailed("'AbiWord 2.9.2 Setup (Installing)' window failed to appear.")
    else
    {
        Sleep, 700
        OutputDebug, OK: %TestName%: 'Installing' window appeared, waiting for it to close.`n
        WinWaitClose, AbiWord 2.9.2 Setup, Installing, 45
        if ErrorLevel
            TestsFailed("'AbiWord 2.9.2 Setup (Installing)' window failed to disappear.")
        else
        {
            WinWaitActive, AbiWord 2.9.2 Setup, Installation Complete, 7
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
    WinWaitActive, AbiWord 2.9.2 Setup, Completing, 7
    if ErrorLevel
        TestsFailed("'AbiWord 2.9.2 Setup (Completing)' window failed to appear.")
    else
    {
        Sleep, 700
        ControlClick, Button4, AbiWord 2.9.2 Setup, Completing ; Uncheck 'Run AbiWord 2.9.2'
        if ErrorLevel
        {
            TestsFailed("Unable to uncheck 'Run AbiWord 2.9.2' checkbox in 'AbiWord 2.9.2 Setup (Completing)' window.")
            Process, Close, AbiWord.exe ; Just in case
        }
        else
        {
            Sleep, 700
            ControlClick, Button2, AbiWord 2.9.2 Setup, Completing ; Hit 'Finish'
            if ErrorLevel
                TestsFailed("Unable to hit 'Finish' button in 'AbiWord 2.9.2 Setup (Completing)' window.")
            else
            {
                WinWaitClose, AbiWord 2.9.2 Setup, Completing, 7
                if ErrorLevel
                    TestsFailed("'AbiWord 2.9.2 Setup (Completing)' window failed to close despite 'Finish' button being clicked.")
                else
                {
                    Process, Wait, AbiWord.exe, 4
                    NewPID = %ErrorLevel%  ; Save the value immediately since ErrorLevel is often changed.
                    if NewPID != 0
                        TestsFailed("Process 'AbiWord.exe' appeared despite 'Run AbiWord 2.9.2' checkbox reported as unchecked in 'AbiWord 2.9.2 Setup (Completing)' window.")
                    else
                        TestsOK("'AbiWord 2.9.2 Setup (Completing)' window appeared, 'Finish' button clicked and window closed.")
                }
            }
        }
    }
}


; Check if program exists
TestsTotal++
if bContinue
{
    Sleep, 2000
    RegRead, UninstallerPath, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\AbiWord2, UninstallString
    if ErrorLevel
        TestsFailed("Either we can't read from registry or data doesn't exist.")
    else
    {
        SplitPath, UninstallerPath,, InstalledDir
        msgbox, %InstalledDir%
        IfNotExist, %InstalledDir%\bin\%MainAppFile%
            TestsFailed("Something went wrong, can't find '" InstalledDir "\bin\" MainAppFile "'.")
        else
            TestsOK("The application has been installed, because '" InstalledDir "\bin\" MainAppFile "' was found.")
    }
}
