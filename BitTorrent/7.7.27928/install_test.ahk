/*
 * Designed for BitTorrent 7.7.27928
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

ModuleExe = %A_WorkingDir%\Apps\BitTorrent 7.7.27928 Setup.exe
TestName = 1.install
MainAppFile = BitTorrent.exe ; Mostly this is going to be process we need to look for

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
        RegRead, UninstallerPath, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\BitTorrent, UninstallString
        if ErrorLevel
        {
            ; There was a problem (such as a nonexistent key or value). 
            ; That probably means we have not installed this app before.
            ; Check in default directory to be extra sure
            IfNotExist, %A_ProgramFiles%\BitTorrent
                bContinue := true ; No previous versions detected in hardcoded path
            else
            {
                bHardcoded := true ; To know if we got path from registry or not
                IfNotExist, %A_ProgramFiles%\BitTorrent ; Uninstaller might delete the dir
                    bContinue := true
                {
                    FileRemoveDir, %A_ProgramFiles%\BitTorrent, 1
                    if ErrorLevel
                        TestsFailed("Unable to delete hardcoded path '" A_ProgramFiles "\BitTorrent' ('" MainAppFile "' process is reported as terminated).'")
                    else
                        bContinue := true
                }
            }
        }
        else
        {
            StringReplace, UninstallerPath, UninstallerPath, `",, All ; BitTorrent string contains quotes
            SplitPath, UninstallerPath,, InstalledDir
            IfNotExist, %InstalledDir%
                bContinue := true
            else
            {
                IfNotExist, %InstalledDir%
                    bContinue := true
                else
                {
                    FileRemoveDir, %InstalledDir%, 1 ; Silent switch '/UNINSTALL' shows dialogs
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
        RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\MicroSoft\Windows\CurrentVersion\Uninstall\BitTorrent
        IfExist, %A_AppData%\BitTorrent
        {
            FileRemoveDir, %A_AppData%\BitTorrent, 1
            if ErrorLevel
                TestsFailed("Unable to delete '" A_AppData "\BitTorrent'.")
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


; Test if 'BitTorrent Setup (This wizard)' window appeared, if so, hit 'Next' button
TestsTotal++
if bContinue
{
    WinWaitActive, BitTorrent Setup, This wizard, 10
    if ErrorLevel
        TestsFailed("'BitTorrent Setup (This wizard)' window failed to appear.")
    else
    {
        ControlClick, Button4, BitTorrent Setup, This wizard ; Hit 'Next' button
        if ErrorLevel
            TestsFailed("Unable to hit 'Next' button in 'BitTorrent Setup (This wizard)' window.")
        else ; Do not use WinWaitClose here, because it fails on win2k3 sp2
            TestsOK("'BitTorrent Setup (This wizard)' window appeared, 'Next' button clicked.")
    }
}


; Test if 'BitTorrent Setup (Beware)' window appeared, if so, hit 'Next' button
TestsTotal++
if bContinue
{
    WinWaitActive, BitTorrent Setup, Beware, 3
    if ErrorLevel
        TestsFailed("'BitTorrent Setup (Beware)' window failed to appear.")
    else
    {
        ControlClick, Button4, BitTorrent Setup, Beware ; Hit 'Next' button
        if ErrorLevel
            TestsFailed("Unable to hit 'Next' button in 'BitTorrent Setup (Beware)' window.")
        else
            TestsOK("'BitTorrent Setup (Beware)' window appeared and 'Next' button was clicked.")
    }
}


; Test if 'BitTorrent Setup (Scroll)' window appeared, if so, hit 'I Agree' button
TestsTotal++
if bContinue
{
    WinWaitActive, BitTorrent Setup, Scroll, 3
    if ErrorLevel
        TestsFailed("'BitTorrent Setup (Scroll)' window failed to appear.")
    else
    {
        ControlClick, Button4, BitTorrent Setup, Scroll ; Hit 'I Agree' button
        if ErrorLevel
            TestsFailed("Unable to hit 'I Agree' button in 'BitTorrent Setup (Scroll)' window.")
        else
            TestsOK("'BitTorrent Setup (Scroll)' window appeared and 'I Agree' button was clicked.")
    }
}


; Test if 'BitTorrent Setup (Program Location)' window appeared, if so, hit 'Next' button
TestsTotal++
if bContinue
{
    WinWaitActive, BitTorrent Setup, Program Location, 3
    if ErrorLevel
        TestsFailed("'BitTorrent Setup (Program Location)' window failed to appear.")
    else
    {
        ControlClick, Button11, BitTorrent Setup, Program Location ; Hit 'Next' button
        if ErrorLevel
            TestsFailed("Unable to hit 'Next' button in 'BitTorrent Setup (Program Location)' window.")
        else
            TestsOK("'BitTorrent Setup (Program Location)' window appeared and 'Next' button was clicked.")
    }
}


; Test if 'BitTorrent Setup (The following)' window appeared, if so, hit 'Next' button
TestsTotal++
if bContinue
{
    WinWaitActive, BitTorrent Setup, The following, 3
    if ErrorLevel
        TestsFailed("'BitTorrent Setup (The following)' window failed to appear.")
    else
    {
        ControlClick, Button18, BitTorrent Setup, The following ; Hit 'Next' button
        if ErrorLevel
            TestsFailed("Unable to hit 'Next' button in 'BitTorrent Setup (The following)' window.")
        else
            TestsOK("'BitTorrent Setup (The following)' window appeared and 'Next' button was clicked.")
    }
}


; Test if 'BitTorrent Setup (&Install)' window appeared, if so, uncheck:
; 1. 'Set my homepage to BitTorrent Web Search',
; 2. 'Make BitTorrent Web Search my default search provider',
; 3. 'I accept...and want to install the µTorrent Browser Bar'
; hit 'Install' button, wait for window to close then terminate uTorrent.exe process
TestsTotal++
if bContinue
{
    WinWaitActive, BitTorrent Setup, &Install, 10 ; It takes some time here
    if ErrorLevel
        TestsFailed("'BitTorrent Setup (Install)' window failed to appear.")
    else
    {
        Control, Uncheck,, Button1, BitTorrent Setup, &Install ; Uncheck 'Set my homepage to BitTorrent Web Search' checkbox
        if ErrorLevel
            TestsFailed("Unable to uncheck 'Set my homepage to BitTorrent Web Search' checkbox in 'BitTorrent Setup (Install)' window.")
        else
        {
            Control, Uncheck,, Button2, BitTorrent Setup, &Install ; Uncheck 'Make BitTorrent Web Search my default search provider' checkbox
            if ErrorLevel
                TestsFailed("Unable to uncheck 'Make BitTorrent Web Search my default search provider' checkbox in 'BitTorrent Setup (Install)' window.")
            else
            {
                Control, Uncheck,, Button3, BitTorrent Setup, &Install ; Uncheck 'I accept...and want to install µTorrent Browser Bar' checkbox
                if ErrorLevel
                    TestsFailed("Unable to uncheck 'I accept...and want to install µTorrent Browser Bar' checkbox in 'BitTorrent Setup (Install)' window.")
                else
                {
                    ControlClick, Button21, BitTorrent Setup, &Install ; Hit 'Install' button
                    if ErrorLevel
                        TestsFailed("Unable to hit 'Install' button in 'BitTorrent Setup (Install)' window.")
                    else
                    {
                        WinWaitClose, BitTorrent Setup, &Install, 10
                        if ErrorLevel
                            TestsFailed("'BitTorrent Setup (Install)' window failed to close.")
                        else
                        {
                            Process, wait, %MainAppFile%, 10 ; Setup starts the process
                            NewPID = %ErrorLevel%  ; Save the value immediately since ErrorLevel is often changed.
                            if NewPID = 0
                                TestsFailed("Process '" MainAppFile "' failed to appear.")
                            else
                            {
                                Process, Close, %MainAppFile%
                                Process, WaitClose, %MainAppFile%, 4
                                if ErrorLevel
                                    TestsFailed("Unable to terminate '" MainAppFile "' process.")
                                else
                                    TestsOK("'BitTorrent Setup (Install)' window appeared, 'Install' button clicked, window closed, '" MainAppFile "' process terminated.")
                            }
                        }
                    }
                }
            }
        }
    }
}


; Check if program exists
TestsTotal++
if bContinue
{
    RegRead, UninstallerPath, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\BitTorrent, UninstallString
    if ErrorLevel
        TestsFailed("Either we can't read from registry or data doesn't exist.")
    else
    {
        StringReplace, UninstallerPath, UninstallerPath, `",, All
        SplitPath, UninstallerPath,, InstalledDir
        IfNotExist, %InstalledDir%\%MainAppFile%
            TestsFailed("Something went wrong, can't find '" InstalledDir "\" MainAppFile "'.")
        else
            TestsOK("The application has been installed, because '" InstalledDir "\" MainAppFile "' was found.")
    }
}