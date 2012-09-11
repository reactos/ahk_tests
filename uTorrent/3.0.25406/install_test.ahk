/*
 * Designed for uTorrent 3.0.25406
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

ModuleExe = %A_WorkingDir%\Apps\uTorrent 3.0.25406 Setup.exe
TestName = 1.install
MainAppFile = uTorrent.exe ; Mostly this is going to be process we need to look for

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
        RegRead, UninstallerPath, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\uTorrent, UninstallString
        if ErrorLevel
        {
            ; There was a problem (such as a nonexistent key or value). 
            ; That probably means we have not installed this app before.
            ; Check in default directory to be extra sure
            IfNotExist, %A_ProgramFiles%\uTorrent
                bContinue := true ; No previous versions detected in hardcoded path
            else
            {
                bHardcoded := true ; To know if we got path from registry or not
                IfNotExist, %A_ProgramFiles%\uTorrent ; Uninstaller might delete the dir
                    bContinue := true
                {
                    FileRemoveDir, %A_ProgramFiles%\uTorrent, 1
                    if ErrorLevel
                        TestsFailed("Unable to delete hardcoded path '" A_ProgramFiles "\uTorrent' ('" MainAppFile "' process is reported as terminated).'")
                    else
                        bContinue := true
                }
            }
        }
        else
        {
            StringReplace, UninstallerPath, UninstallerPath, `",, All ; uTorrent string contains quotes
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
        RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\MicroSoft\Windows\CurrentVersion\Uninstall\uTorrent
        IfExist, %A_AppData%\uTorrent
        {
            FileRemoveDir, %A_AppData%\uTorrent, 1
            if ErrorLevel
                TestsFailed("Unable to delete '" A_AppData "\uTorrent'.")
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


; Test if 'µTorrent Setup (This wizard)' window appeared, if so, hit 'Next' button
TestsTotal++
if bContinue
{
    WinWaitActive, µTorrent Setup, This wizard, 10
    if ErrorLevel
        TestsFailed("'µTorrent Setup (This wizard)' window failed to appear.")
    else
    {
        Sleep, 700
        ControlClick, Button2, µTorrent Setup, This wizard ; Hit 'Next' button
        if ErrorLevel
            TestsFailed("Unable to hit 'Next' button in 'µTorrent Setup (This wizard)' window.")
        else
            TestsOK("'µTorrent Setup (This wizard)' window appeared and 'Next' button was clicked.")
    }
}


; Test if 'µTorrent Setup (Beware)' window appeared, if so, hit 'Next' button
TestsTotal++
if bContinue
{
    WinWaitActive, µTorrent Setup, Beware, 5
    if ErrorLevel
        TestsFailed("'µTorrent Setup (Beware)' window failed to appear.")
    else
    {
        Sleep, 700
        ControlClick, Button2, µTorrent Setup, Beware ; Hit 'Next' button
        if ErrorLevel
            TestsFailed("Unable to hit 'Next' button in 'µTorrent Setup (Beware)' window.")
        else
            TestsOK("'µTorrent Setup (Beware)' window appeared and 'Next' button was clicked.")
    }
}


; Test if 'µTorrent Setup (Scroll)' window appeared, if so, hit 'I Agree' button
TestsTotal++
if bContinue
{
    WinWaitActive, µTorrent Setup, Scroll, 5
    if ErrorLevel
        TestsFailed("'µTorrent Setup (Scroll)' window failed to appear.")
    else
    {
        Sleep, 700
        ControlClick, Button2, µTorrent Setup, Scroll ; Hit 'I Agree' button
        if ErrorLevel
            TestsFailed("Unable to hit 'I Agree' button in 'µTorrent Setup (Scroll)' window.")
        else
            TestsOK("'µTorrent Setup (Scroll)' window appeared and 'I Agree' button was clicked.")
    }
}


; Test if 'µTorrent Setup (Program Location)' window appeared, if so, hit 'Next' button
TestsTotal++
if bContinue
{
    WinWaitActive, µTorrent Setup, Program Location, 5
    if ErrorLevel
        TestsFailed("'µTorrent Setup (Program Location)' window failed to appear.")
    else
    {
        Sleep, 700
        ControlClick, Button9, µTorrent Setup, Program Location ; Hit 'Next' button
        if ErrorLevel
            TestsFailed("Unable to hit 'Next' button in 'µTorrent Setup (Program Location)' window.")
        else
            TestsOK("'µTorrent Setup (Program Location)' window appeared and 'Next' button was clicked.")
    }
}


; Test if 'µTorrent Setup (The following)' window appeared, if so, hit 'Next' button
TestsTotal++
if bContinue
{
    WinWaitActive, µTorrent Setup, The following, 5
    if ErrorLevel
        TestsFailed("'µTorrent Setup (The following)' window failed to appear.")
    else
    {
        Sleep, 700
        ControlClick, Button16, µTorrent Setup, The following ; Hit 'Next' button
        if ErrorLevel
            TestsFailed("Unable to hit 'Next' button in 'µTorrent Setup (The following)' window.")
        else
            TestsOK("'µTorrent Setup (The following)' window appeared and 'Next' button was clicked.")
    }
}


; Test if 'µTorrent Setup (Check out)' window appeared, if so, uncheck 'Yes, Id love to check out this free download' checkbox and hit 'Next' button
TestsTotal++
if bContinue
{
    WinWaitActive, µTorrent Setup, Check out, 5
    if ErrorLevel
        TestsFailed("'µTorrent Setup (Check out)' window failed to appear.")
    else
    {
        Sleep, 700
        Control, Uncheck,, Button1, µTorrent Setup, Check out ; Uncheck 'Yes, Id love to check out this free download' checkbox
        if ErrorLevel
            TestsFailed("Unable to uncheck 'Yes, Id love to check out this free download' checkbox in 'µTorrent Setup (Check out)' window.")
        else
        {
            Sleep, 500
            ControlClick, Button17, µTorrent Setup, Check out ; Hit 'Next' button
            if ErrorLevel
                TestsFailed("Unable to hit 'Next' button in 'µTorrent Setup (Check out)' window.")
            else
                TestsOK("'µTorrent Setup (Check out)' window appeared and 'Next' button was clicked.")
        }
    }
}


; Test if 'µTorrent Setup (&Install)' window appeared, if so, uncheck:
; 1. 'Set my homepage to µTorrent Web Search',
; 2. 'Make µTorrent Web Search my default search provider',
; 3. 'I accept...and want to install the µTorrent Browser Bar'
; hit 'Install' button, wait for window to close then terminate uTorrent.exe process
TestsTotal++
if bContinue
{
    WinWaitActive, µTorrent Setup, &Install, 5
    if ErrorLevel
        TestsFailed("'µTorrent Setup (Install)' window failed to appear.")
    else
    {
        Sleep, 700
        Control, Uncheck,, Button1, µTorrent Setup, &Install ; Uncheck 'Set my homepage to µTorrent Web Search' checkbox
        if ErrorLevel
            TestsFailed("Unable to uncheck 'Set my homepage to µTorrent Web Search' checkbox in 'µTorrent Setup (Install)' window.")
        else
        {
            Control, Uncheck,, Button3, µTorrent Setup, &Install ; Uncheck 'Make µTorrent Web Search my default search provider' checkbox
            if ErrorLevel
                TestsFailed("Unable to uncheck 'Make µTorrent Web Search my default search provider' checkbox in 'µTorrent Setup (Install)' window.")
            else
            {
                Control, Uncheck,, Button2, µTorrent Setup, &Install ; Uncheck 'I accept...and want to install µTorrent Browser Bar' checkbox
                if ErrorLevel
                    TestsFailed("Unable to uncheck 'I accept...and want to install µTorrent Browser Bar' checkbox in 'µTorrent Setup (Install)' window.")
                else
                {
                    Sleep, 700
                    ControlClick, Button20, µTorrent Setup, &Install ; Hit 'Install' button
                    if ErrorLevel
                        TestsFailed("Unable to hit 'Install' button in 'µTorrent Setup (Install)' window.")
                    else
                    {
                        WinWaitClose, µTorrent Setup, &Install, 10
                        if ErrorLevel
                            TestsFailed("'µTorrent Setup (Install)' window failed to close.")
                        else
                        {
                            Process, wait, %MainAppFile%, 5
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
                                    TestsOK("'µTorrent Setup (Install)' window appeared, 'Install' button clicked, window closed, '" MainAppFile "' process terminated.")
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
    Sleep, 2000
    RegRead, UninstallerPath, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\uTorrent, UninstallString
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