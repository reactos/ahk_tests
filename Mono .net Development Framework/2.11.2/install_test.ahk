/*
 * Designed for Mono .net Development Framework 2.11.2
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

ModuleExe = %A_WorkingDir%\Apps\Mono .net Development Framework 2.11.2 Setup.exe
TestName = 1.install
MainAppFile = mono.exe ; Mostly this is going to be process we need to look for

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
        RegRead, UninstallerPath, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{ef82ca75-1b51-47b9-9d18-3db1c6f271be}_is1, UninstallString
        if ErrorLevel
        {
            ; There was a problem (such as a nonexistent key or value). 
            ; That probably means we have not installed this app before.
            ; Check in default directory to be extra sure
            bHardcoded := true ; To know if we got path from registry or not
            IfNotExist, %A_ProgramFiles%\Mono-2.11.2
                bContinue := true ; No previous versions detected in hardcoded path
            else
            {
                IfExist, %A_ProgramFiles%\Mono-2.11.2\unins000.exe
                {
                    RunWait, %A_ProgramFiles%\Mono-2.11.2\unins000.exe /SILENT ; Silently uninstall it
                    Sleep, 7000
                }

                IfNotExist, %A_ProgramFiles%\Mono-2.11.2 ; Uninstaller might delete the dir
                    bContinue := true
                {
                    FileRemoveDir, %A_ProgramFiles%\Mono-2.11.2, 1
                    if ErrorLevel
                        TestsFailed("Unable to delete hardcoded path '" A_ProgramFiles "\Mono-2.11.2' ('" MainAppFile "' process is reported as terminated).'")
                    else
                        bContinue := true
                }
            }
        }
        else
        {
            StringReplace, UninstallerPath, UninstallerPath, `",, All ; Remove quotes in case some version quotes the path
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
        RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\MicroSoft\Windows\CurrentVersion\Uninstall\{ef82ca75-1b51-47b9-9d18-3db1c6f271be}_is1
        if bHardcoded
            TestsOK("Either there was no previous versions or we succeeded removing it using hardcoded path.")
        else
            TestsOK("Either there was no previous versions or we succeeded removing it using data from registry.")
        Run %ModuleExe%
    }
}


; Test if 'Setup - Mono 2.11.2 with GTK# 2.12.11 (Welcome)' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Setup - Mono 2.11.2 with GTK# 2.12.11, Welcome, 15
    if ErrorLevel
        TestsFailed("'Setup - Mono 2.11.2 with GTK# 2.12.11 (Welcome)' window failed to appear.")
    else
    {
        Sleep, 700
        ControlClick, TNewButton1, Setup - Mono 2.11.2 with GTK# 2.12.11, Welcome ; Hit 'Next' button
        if ErrorLevel
            TestsFailed("Unable to hit 'Next' button in 'Setup - Mono 2.11.2 with GTK# 2.12.11 (Welcome)' window.")
        else ; WinWaitClose will not work with this setup on win2k3 sp2
            TestsOK("'Setup - Mono 2.11.2 with GTK# 2.12.11 (Welcome)' window appeared and 'Next' button was clicked.")
    }
}


; Test if 'Setup - Mono 2.11.2 with GTK# 2.12.11 (License Agreement)' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Setup - Mono 2.11.2 with GTK# 2.12.11, License Agreement, 7
    if ErrorLevel
        TestsFailed("'Setup - Mono 2.11.2 with GTK# 2.12.11 (License Agreement)' window failed to appear.")
    else
    {
        Sleep, 700
        Control, Check,, TNewRadioButton1, Setup - Mono 2.11.2 with GTK# 2.12.11, License Agreement ; Check 'I accept the agreement' radiobutton
        if ErrorLevel
            TestsFailed("Unable to check 'I accept' radiobutton in 'Setup - Mono 2.11.2 with GTK# 2.12.11 (License Agreement)' window.")
        else
        {
            TimeOut := 0
            while (not %bNextEnabled%) and (TimeOut < 6) ; Sleep while 'Next' button is disabled
            {
                ControlGet, bNextEnabled, Enabled,, TNewButton2, Setup - Mono 2.11.2 with GTK# 2.12.11, License Agreement
                Sleep, 300
                TimeOut++
            }
            
            if not %bNextEnabled%
                TestsFailed("'Next' button did not get enabled in 'Setup - Mono 2.11.2 with GTK# 2.12.11 (License Agreement)' window after checking 'I accept' radiobutton.")
            else
            {
                Sleep, 700
                ControlClick, TNewButton2, Setup - Mono 2.11.2 with GTK# 2.12.11, License Agreement ; Hit 'Next' button
                if ErrorLevel
                    TestsFailed("Unable to hit 'Next' button in 'Setup - Mono 2.11.2 with GTK# 2.12.11 (License Agreement)' window.")
                else
                    TestsOK("'Setup - Mono 2.11.2 with GTK# 2.12.11 (License Agreement)' window appeared, 'I accept' radiobutton checked and 'Next' button was clicked.")
            }
        }
    }
}


; Test if 'Setup - Mono 2.11.2 with GTK# 2.12.11 (Information)' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Setup - Mono 2.11.2 with GTK# 2.12.11, Information, 7
    if ErrorLevel
        TestsFailed("'Setup - Mono 2.11.2 with GTK# 2.12.11 (Information)' window failed to appear.")
    else
    {
        Sleep, 700
        ControlClick, TNewButton2, Setup - Mono 2.11.2 with GTK# 2.12.11, Information ; Hit 'Next' button
        if ErrorLevel
            TestsFailed("Unable to hit 'Next' button in 'Setup - Mono 2.11.2 with GTK# 2.12.11 (Information)' window.")
        else
            TestsOK("'Setup - Mono 2.11.2 with GTK# 2.12.11 (Information)' window appeared and 'Next' button was clicked.")
    }
}


; Test if 'Setup - Mono 2.11.2 with GTK# 2.12.11 (Select Destination Location)' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Setup - Mono 2.11.2 with GTK# 2.12.11, Select Destination Location, 7
    if ErrorLevel
        TestsFailed("'Setup - Mono 2.11.2 with GTK# 2.12.11 (Select Destination Location)' window failed to appear.")
    else
    {
        Sleep, 700
        ControlClick, TNewButton3, Setup - Mono 2.11.2 with GTK# 2.12.11, Select Destination Location ; Hit 'Next' button
        if ErrorLevel
            TestsFailed("Unable to hit 'Next' button in 'Setup - Mono 2.11.2 with GTK# 2.12.11 (Select Destination Location)' window.")
        else
            TestsOK("'Setup - Mono 2.11.2 with GTK# 2.12.11 (Select Destination Location)' window appeared and 'Next' button was clicked.")
    }
}


; Test if 'Setup - Mono 2.11.2 with GTK# 2.12.11 (Select Components)' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Setup - Mono 2.11.2 with GTK# 2.12.11, Select Components, 7
    if ErrorLevel
        TestsFailed("'Setup - Mono 2.11.2 with GTK# 2.12.11 (Select Components)' window failed to appear.")
    else
    {
        Sleep, 700
        ControlClick, TNewButton3, Setup - Mono 2.11.2 with GTK# 2.12.11, Select Components ; Hit 'Next' button
        if ErrorLevel
            TestsFailed("Unable to hit 'Next' button in 'Setup - Mono 2.11.2 with GTK# 2.12.11 (Select Components)' window.")
        else
            TestsOK("'Setup - Mono 2.11.2 with GTK# 2.12.11 (Select Components)' window appeared and 'Next' button was clicked.")
    }
}


; Test if 'Setup - Mono 2.11.2 with GTK# 2.12.11 (Select Start Menu Folder)' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Setup - Mono 2.11.2 with GTK# 2.12.11, Select Start Menu Folder, 7
    if ErrorLevel
        TestsFailed("'Setup - Mono 2.11.2 with GTK# 2.12.11 (Select Start Menu Folder)' window failed to appear.")
    else
    {
        Sleep, 700
        ControlClick, TNewButton4, Setup - Mono 2.11.2 with GTK# 2.12.11, Select Start Menu Folder ; Hit 'Next' button
        if ErrorLevel
            TestsFailed("Unable to hit 'Next' button in 'Setup - Mono 2.11.2 with GTK# 2.12.11 (Select Start Menu Folder)' window.")
        else
            TestsOK("'Setup - Mono 2.11.2 with GTK# 2.12.11 (Select Start Menu Folder)' window appeared and 'Next' button was clicked.")
    }
}


; Test if 'Setup - Mono 2.11.2 with GTK# 2.12.11 (Port Selection)' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Setup - Mono 2.11.2 with GTK# 2.12.11, Port Selection, 7
    if ErrorLevel
        TestsFailed("'Setup - Mono 2.11.2 with GTK# 2.12.11 (Port Selection)' window failed to appear.")
    else
    {
        Sleep, 700
        ControlClick, TNewButton4, Setup - Mono 2.11.2 with GTK# 2.12.11, Port Selection ; Hit 'Next' button
        if ErrorLevel
            TestsFailed("Unable to hit 'Next' button in 'Setup - Mono 2.11.2 with GTK# 2.12.11 (Port Selection)' window.")
        else
            TestsOK("'Setup - Mono 2.11.2 with GTK# 2.12.11 (Port Selection)' window appeared and 'Next' button was clicked.")
    }
}


; Test if 'Setup - Mono 2.11.2 with GTK# 2.12.11 (Ready to Install)' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Setup - Mono 2.11.2 with GTK# 2.12.11, Ready to Install, 7
    if ErrorLevel
        TestsFailed("'Setup - Mono 2.11.2 with GTK# 2.12.11 (Ready to Install)' window failed to appear.")
    else
    {
        Sleep, 700
        ControlClick, TNewButton4, Setup - Mono 2.11.2 with GTK# 2.12.11, Ready to Install ; Hit 'Install' button
        if ErrorLevel
            TestsFailed("Unable to hit 'Install' button in 'Setup - Mono 2.11.2 with GTK# 2.12.11 (Ready to Install)' window.")
        else
            TestsOK("'Setup - Mono 2.11.2 with GTK# 2.12.11 (Ready to Install)' window appeared and 'Install' button was clicked.")
    }
}


; Test if can get thru 'Setup - Mono 2.11.2 with GTK# 2.12.11 (Installing)' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Setup - Mono 2.11.2 with GTK# 2.12.11, Installing, 7
    if ErrorLevel
        TestsFailed("'Setup - Mono 2.11.2 with GTK# 2.12.11 (Installing)' window failed to appear.")
    else
    {
        OutputDebug, %TestName%:%A_LineNumber%: 'Setup - Mono 2.11.2 with GTK# 2.12.11 (Installing)' window appeared, waiting for it to close.`n
        WinWaitClose, Setup - Mono 2.11.2 with GTK# 2.12.11, Installing, 60
        if ErrorLevel
            TestsFailed("'Setup - Mono 2.11.2 with GTK# 2.12.11 (Installing)' window failed to close.")
        else
            TestsOK("'Setup - Mono 2.11.2 with GTK# 2.12.11 (Installing)' window closed.")
    }
}


; Test if 'Setup - Mono 2.11.2 with GTK# 2.12.11 (Completing)' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Setup - Mono 2.11.2 with GTK# 2.12.11, Completing, 7
    if ErrorLevel
        TestsFailed("'Setup - Mono 2.11.2 with GTK# 2.12.11 (Completing)' window failed to appear.")
    else
    {
        Sleep, 700
        ControlClick, TNewButton4, Setup - Mono 2.11.2 with GTK# 2.12.11, Completing ; Hit 'Finish' button
        if ErrorLevel
            TestsFailed("Unable to hit 'Finish' button in 'Setup - Mono 2.11.2 with GTK# 2.12.11 (Completing)' window.")
        else
        {
            WinWaitClose,  Setup - Mono 2.11.2 with GTK# 2.12.11, Completing, 7
            if ErrorLevel
                TestsFailed("'Setup - Mono 2.11.2 with GTK# 2.12.11 (Completing)' window failed to close despite 'Finish' button being clicked.")
            else
                TestsOK("'Setup - Mono 2.11.2 with GTK# 2.12.11 (Completing)' window appeared, 'Finish' button clicked and window closed.")
        }
    }
}


; Check if program exists
TestsTotal++
if bContinue
{
    ; No need to sleep, because we already waited for process to appear
    RegRead, UninstallerPath, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{ef82ca75-1b51-47b9-9d18-3db1c6f271be}_is1, UninstallString
    if ErrorLevel
        TestsFailed("Either we can't read from registry or data doesn't exist.")
    else
    {
        StringReplace, UninstallerPath, UninstallerPath, `",, All
        SplitPath, UninstallerPath,, InstalledDir
        IfNotExist, %InstalledDir%\bin\%MainAppFile%
            TestsFailed("Something went wrong, can't find '" InstalledDir "\bin\" MainAppFile "'.")
        else
            TestsOK("The application has been installed, because '" InstalledDir "\bin\" MainAppFile "' was found.")
    }
}
