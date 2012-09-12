/*
 * Designed for VLC Media Player 2.0.3
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

ModuleExe = %A_WorkingDir%\Apps\VLC_Media_Player_2.0.3_Setup.exe
TestName = 1.install
MainAppFile = vlc.exe ; Mostly this is going to be process we need to look for

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
        RegRead, UninstallerPath, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\VLC media player, UninstallString
        if ErrorLevel
        {
            ; There was a problem (such as a nonexistent key or value). 
            ; That probably means we have not installed this app before.
            ; Check in default directory to be extra sure
            IfNotExist, %A_ProgramFiles%\VideoLAN
                bContinue := true ; No previous versions detected in hardcoded path
            else
            {
                bHardcoded := true ; To know if we got path from registry or not
                IfExist, %A_ProgramFiles%\VideoLAN\VLC\uninstall.exe
                {
                    RunWait, %A_ProgramFiles%\VideoLAN\VLC\uninstall.exe /S ; Silently uninstall it
                    Sleep, 7000
                }

                IfNotExist, %A_ProgramFiles%\VideoLAN ; Uninstaller might delete the dir
                    bContinue := true
                {
                    FileRemoveDir, %A_ProgramFiles%\VideoLAN, 1
                    if ErrorLevel
                        TestsFailed("Unable to delete hardcoded path '" A_ProgramFiles "\VideoLAN' ('" MainAppFile "' process is reported as terminated).'")
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
        RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\VideoLAN
        RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\MicroSoft\Windows\CurrentVersion\Uninstall\VLC media player
        IfExist, %A_AppData%\vlc
        {
            FileRemoveDir, %A_AppData%\vlc, 1
            if ErrorLevel
                TestsFailed("Unable to delete '" A_AppData "\vlc'.")
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
    WinWaitActive, Installer Language, Please select a language, 15 ; Wait 15 secs for window to appear
    if ErrorLevel
        TestsFailed("'Installer Language (Please select a language)' window failed to appear.")
    else
    {
        Sleep, 700
        SendInput, {ENTER}
        WinWaitClose, Installer Language, Please select a language, 5
        if ErrorLevel
            TestsFailed("Failed to hit 'OK' button in 'Installer Language (Please select a language)' window.")
        else
            TestsOK("'Installer Language (Please select a language)' window appeared, 'OK' button clicked, window closed.")
    }
}


; Test if 'VLC media player 2.0.3 Setup' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, VLC media player 2.0.3 Setup, Welcome to the VLC, 15
    if ErrorLevel
        TestsFailed("'VLC media player 2.0.3 Setup (Welcome to the VLC)' failed to appear.")
    else
    {
        Sleep, 700
        SendInput, {ALTDOWN}n{ALTUP} ; Hit 'Next' button
        TestsOK("'VLC media player 2.0.3 Setup (Welcome to the VLC)' window appeared and Alt+N was sent.")
    }
}


; Test if 'License Agreement' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, VLC media player 2.0.3 Setup, License Agreement, 7
    if ErrorLevel
        TestsFailed("'VLC media player 2.0.3 Setup (License Agreement)' window failed to appear.")
    else
    {
        Sleep, 700
        SendInput, {ALTDOWN}n{ALTUP} ; Hit 'I Agree' button
        TestsOK("'VLC media player 2.0.3 Setup (License Agreement)' window appeared and Alt+N was sent.")
    }
}


; Test if 'Choose Components' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, VLC media player 2.0.3 Setup, Choose Components, 7
    if ErrorLevel
        TestsFailed("'VLC media player 2.0.3 Setup (Choose Components)' window failed to appear.")
    else
    {
        Sleep, 700
        SendInput, {ALTDOWN}n{ALTUP} ; Hit 'Next' button
        TestsOK("'VLC media player 2.0.3 Setup (Choose Components)' window appeared and Alt+N was sent.")
    }
}


; Test if 'Choose Install Location' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, VLC media player 2.0.3 Setup, Choose Install Location, 7
    if ErrorLevel
        TestsFailed("'VLC media player 2.0.3 Setup (Choose Install Location)' window failed to appear.")
    else
    {
        Sleep, 700
        SendInput, {ALTDOWN}i{ALTUP} ; Hit 'Install' button
        TestsOK("'VLC media player 2.0.3 Setup (Choose Install Location)' window appeared and Alt+I was sent.")
    }
}


; Test if 'Installing' window can popup and go away
TestsTotal++
if bContinue
{
    WinWaitActive, VLC media player 2.0.3 Setup, Installing, 7
    if ErrorLevel
        TestsFailed("'VLC media player 2.0.3 Setup (Installing)' failed to appear.")
    else
    {
        OutputDebug, OK: %TestName%:%A_LineNumber%: 'VLC media player 2.0.3 Setup (Installing)' appeared, waiting for it to dissapear.`n
        
        WinWaitClose, VLC media player 2.0.3 Setup, Installing, 150
        if ErrorLevel
            TestsFailed("'VLC media player 2.0.3 Setup (Installing)' window failed to close.")
        else
            TestsOK("'VLC media player 2.0.3 Setup (Installing)' window went away.")
    }
}


; Test if 'Completing' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, VLC media player 2.0.3 Setup, Completing, 7
    if ErrorLevel
        TestsFailed("'VLC media player 2.0.3 Setup (Completing)' window failed to appear.")
    else
    {
        Sleep, 700
        SendInput, {ALTDOWN}r{ALTUP} ; Uncheck 'Run VLC'
        Sleep, 700
        SendInput, {ALTDOWN}f{ALTUP} ; Hit 'Finish' button
        WinWaitClose, VLC media player 2.0.3 Setup, Completing, 5
        if ErrorLevel
            TestsFailed("'VLC media player 2.0.3 Setup (Completing)' window failed to close.")
        else
        {
            Process, wait, %MainAppFile%, 4
            NewPID = %ErrorLevel%  ; Save the value immediately since ErrorLevel is often changed.
            if NewPID <> 0
            {
                Process, Close, %MainAppFile%
                Process, WaitClose, %MainAppFile%, 4
                if ErrorLevel
                    TestsFailed("'" MainAppFile "' process appeared (and unable to terminate it) despite 'Run VLC' checkbox being unchecked in 'VLC media player 2.0.3 Setup (Completing)' window.")
                else
                    TestsFailed("'" MainAppFile "' process appeared despite 'Run VLC' checkbox being unchecked in 'VLC media player 2.0.3 Setup (Completing)' window.")
            }
            else
                TestsOK("'Run VLC' checkbox unchecked in 'VLC media player 2.0.3 Setup (Completing)' window and the window closed.")
        }
    }
}


; Check if program exists
TestsTotal++
if bContinue
{
    Sleep, 2000
    RegRead, UninstallerPath, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\VLC media player, UninstallString
    if ErrorLevel
        TestsFailed("Either we can't read from registry or data doesn't exist.")
    else
    {
        SplitPath, UninstallerPath,, InstalledDir
        IfNotExist, %InstalledDir%\%MainAppFile%
            TestsFailed("Something went wrong, can't find '" InstalledDir "\" MainAppFile "'.")
        else
            TestsOK("The application has been installed, because '" InstalledDir "\" MainAppFile "' was found.")
    }
}