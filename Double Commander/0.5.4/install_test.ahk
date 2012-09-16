/*
 * Designed for Double Commander 0.5.4
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

ModuleExe = %A_WorkingDir%\Apps\Double Commander 0.5.4 Setup.exe
TestName = 1.install
MainAppFile = doublecmd.exe ; Mostly this is going to be process we need to look for

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
        RegRead, UninstallerPath, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Double Commander_is1, UninstallString
        if ErrorLevel
        {
            ; There was a problem (such as a nonexistent key or value). 
            ; That probably means we have not installed this app before.
            ; Check in default directory to be extra sure
            bHardcoded := true ; To know if we got path from registry or not
            IfNotExist, %A_ProgramFiles%\Double Commander
                bContinue := true ; No previous versions detected in hardcoded path
            else
            {
                IfExist, %A_ProgramFiles%\Double Commander\unins000.exe
                {
                    RunWait, %A_ProgramFiles%\Double Commander\unins000.exe /SILENT ; Silently uninstall it
                    Sleep, 7000
                }

                IfNotExist, %A_ProgramFiles%\Double Commander ; Uninstaller might delete the dir
                    bContinue := true
                {
                    FileRemoveDir, %A_ProgramFiles%\Double Commander, 1
                    if ErrorLevel
                        TestsFailed("Unable to delete hardcoded path '" A_ProgramFiles "\Double Commander' ('" MainAppFile "' process is reported as terminated).'")
                    else
                        bContinue := true
                }
            }
        }
        else
        {
            StringReplace, UninstallerPath, UninstallerPath, `", , All
            SplitPath, UninstallerPath,, InstalledDir
            IfNotExist, %InstalledDir%
                bContinue := true
            else
            {
                IfExist, %UninstallerPath%
                {
                    RunWait, %UninstallerPath% /SILENT ; Silently uninstall it
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
        RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\MicroSoft\Windows\CurrentVersion\Uninstall\Double Commander_is1
        IfExist, %A_AppData%\doublecmd
        {
            FileRemoveDir, %A_AppData%\doublecmd, 1
            if ErrorLevel
                TestsFailed("Unable to delete '" A_AppData "\doublecmd'.")
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


; Test if 'Select Setup Language (Select the language)' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Select Setup Language, Select the language, 15
    if ErrorLevel
        TestsFailed("'Select Setup Language (Select the language)' window failed to appear.")
    else
    {
        Sleep, 700
        ControlClick, TNewButton1, Select Setup Language, Select the language ; Hit 'OK' button
        if ErrorLevel
            TestsFailed("Unable to hit 'OK' button in 'Select Setup Language (Select the language)' window.")
        else
        {
            WinWaitClose, Select Setup Language, Select the language, 5
            if ErrorLevel
                TestsFailed("'Select Setup Language (Select the language)' window failed to close despite 'OK' button being clicked.")
            else
                TestsOK("'Select Setup Language (Select the language)' window appeared, 'OK' button clicked and window closed.")
        }
    }
}


; Test if 'Setup - Double Commander (Welcome)' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Setup - Double Commander, Welcome, 15
    if ErrorLevel
        TestsFailed("'Setup - Double Commander (Welcome)' window failed to appear.")
    else
    {
        Sleep, 700
        ControlClick, TNewButton1, Setup - Double Commander, Welcome ; Hit 'Next' button
        if ErrorLevel
            TestsFailed("Unable to hit 'Next' button in 'Setup - Double Commander (Welcome)' window.")
        else
            TestsOK("'Setup - Double Commander (Welcome)' window appeared and 'Next' button was clicked.")
    }
}


; Test if 'Setup - Double Commander (License Agreement)' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Setup - Double Commander, License Agreement, 5
    if ErrorLevel
        TestsFailed("'Setup - Double Commander (License Agreement)' window failed to appear.")
    else
    {
        Sleep, 700
        Control, Check,, TNewRadioButton1, Setup - Double Commander, License Agreement ; Check 'I accept the agreement' radiobutton
        if ErrorLevel
            TestsFailed("Unable to check 'I accept' radiobutton in 'Setup - Double Commander (License Agreement)' window.")
        else
        {
            TimeOut := 0
            while (not %bNextEnabled%) and (TimeOut < 6) ; Sleep while 'Next' button is disabled
            {
                ControlGet, bNextEnabled, Enabled,, TNewButton2, Setup - Double Commander, License Agreement
                Sleep, 300
                TimeOut++
            }
            
            if not %bNextEnabled%
                TestsFailed("'Next' button did not get enabled in 'Setup - Double Commander (License Agreement)' window after checking 'I accept' radiobutton.")
            else
            {
                Sleep, 700
                ControlClick, TNewButton2, Setup - Double Commander, License Agreement ; Hit 'Next' button
                if ErrorLevel
                    TestsFailed("Unable to hit 'Next' button in 'Setup - Double Commander (License Agreement)' window.")
                else
                    TestsOK("'Setup - Double Commander (License Agreement)' window appeared and 'Next' button was clicked.")
            }
        }
    }
}


; Test if 'Setup - Double Commander (Select Destination Location)' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Setup - Double Commander, Select Destination Location, 5
    if ErrorLevel
        TestsFailed("'Setup - Double Commander (Select Destination Location)' window failed to appear.")
    else
    {
        Sleep, 700
        ControlClick, TNewButton3, Setup - Double Commander, Select Destination Location ; Hit 'Next' button
        if ErrorLevel
            TestsFailed("Unable to hit 'Next' button in 'Setup - Double Commander (Select Destination Location)' window.")
        else
            TestsOK("'Setup - Double Commander (Select Destination Location)' window appeared and 'Next' button was clicked.")
    }
}



; Test if 'Setup - Double Commander (Select Start Menu Folder)' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Setup - Double Commander, Select Start Menu Folder, 5
    if ErrorLevel
        TestsFailed("'Setup - Double Commander (Select Start Menu Folder)' window failed to appear.")
    else
    {
        Sleep, 700
        ControlClick, TNewButton4, Setup - Double Commander, Select Start Menu Folder ; Hit 'Next' button
        if ErrorLevel
            TestsFailed("Unable to hit 'Next' button in 'Setup - Double Commander (Select Start Menu Folder)' window.")
        else
            TestsOK("'Setup - Double Commander (Select Start Menu Folder)' window appeared and 'Next' button was clicked.")
    }
}


; Test if 'Setup - Double Commander (Select Additional Tasks)' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Setup - Double Commander, Select Additional Tasks, 5
    if ErrorLevel
        TestsFailed("'Setup - Double Commander (Select Additional Tasks)' window failed to appear.")
    else
    {
        Sleep, 700
        ControlClick, TNewButton4, Setup - Double Commander, Select Additional Tasks ; Hit 'Next' button
        if ErrorLevel
            TestsFailed("Unable to hit 'Next' button in 'Setup - Double Commander (Select Additional Tasks)' window.")
        else
            TestsOK("'Setup - Double Commander (Select Additional Tasks)' window appeared and 'Next' button was clicked.")
    }
}


; Test if 'Setup - Double Commander (Ready to Install)' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Setup - Double Commander, Ready to Install, 5
    if ErrorLevel
        TestsFailed("'Setup - Double Commander (Ready to Install)' window failed to appear.")
    else
    {
        Sleep, 700
        ControlClick, TNewButton4, Setup - Double Commander, Ready to Install ; Hit 'Install' button
        if ErrorLevel
            TestsFailed("Unable to hit 'Install' button in 'Setup - Double Commander (Ready to Install)' window.")
        else
            TestsOK("'Setup - Double Commander (Ready to Install)' window appeared and 'Install' button was clicked.")
    }
}


; Test if can get thru 'Setup - Double Commander (Installing)' window
TestsTotal++
if bContinue
{
    WinWaitActive, Setup - Double Commander, Installing, 5
    if ErrorLevel
        TestsFailed("'Setup - Double Commander (Installing)' window failed to appear.")
    else
    {
        OutputDebug, OK: %TestName%:%A_LineNumber%: 'Setup - Double Commander (Installing)' window appeared, waiting for it to close.`n
        WinWaitClose, Setup - Double Commander, Installing, 30
        if ErrorLevel
            TestsFailed("'Setup - Double Commander (Installing)' window failed to close.")
        else
            TestsOK("'Setup - Double Commander (Installing)' window closed.")
    }
}


; Test if 'Setup - Double Commander (Completing)' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Setup - Double Commander, Completing, 5
    if ErrorLevel
        TestsFailed("'Setup - Double Commander (Completing)' window failed to appear.")
    else
    {
        Sleep, 700
        SendInput, {SPACE} ; Uncheck 'Launch Double Commander' checkbox. 'Control, uncheck' won't work here
        Sleep, 700
        ControlClick, TNewButton4, Setup - Double Commander, Completing ; Hit 'Finish' button
        if ErrorLevel
            TestsFailed("Unable to hit 'Finish' button in 'Setup - Double Commander (Completing)' window.")
        else
        {
            WinWaitClose, Setup - Double Commander, Completing, 5
            if ErrorLevel
                TestsFailed("'Setup - Double Commander (Completing)' window failed to close despite 'Finish' button being clicked.")
            else
            {
                Process, Wait, %MainAppFile%, 4
                NewPID = %ErrorLevel%  ; Save the value immediately since ErrorLevel is often changed.
                if NewPID <> 0
                    TestsFailed("'" MainAppFile "' process appeared despite 'Launch Double Commander' checkbox being unchecked in 'Setup - Double Commander (Completing)' window.")
                else
                    TestsOK("'Setup - Double Commander (Completing)' window appeared, 'Launch Double Commander' checkbox unchecked, 'Finish' clicked and window closed.")
            }
        }
    }
}


; Check if program exists
TestsTotal++
if bContinue
{
    Sleep, 2000
    RegRead, UninstallerPath, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Double Commander_is1, UninstallString
    if ErrorLevel
        TestsFailed("Either we can't read from registry or data doesn't exist.")
    else
    {
        StringReplace, UninstallerPath, UninstallerPath, `", , All
        SplitPath, UninstallerPath,, InstalledDir
        IfNotExist, %InstalledDir%\%MainAppFile%
            TestsFailed("Something went wrong, can't find '" InstalledDir "\" MainAppFile "'.")
        else
            TestsOK("The application has been installed, because '" InstalledDir "\" MainAppFile "' was found.")
    }
}
