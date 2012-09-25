/*
 * Designed for Diablo II 1.4
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

ModuleExe = %A_WorkingDir%\Apps\Diablo 2 Shareware 1.4.exe
TestName = 1.install
MainAppFile = Diablo II.exe ; Mostly this is going to be process we need to look for

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
        RegRead, InstalledDir, HKEY_LOCAL_MACHINE, SOFTWARE\Blizzard Entertainment\Diablo II Shareware, InstallPath
        if ErrorLevel
        {
            ; There was a problem (such as a nonexistent key or value). 
            ; That probably means we have not installed this app before.
            ; Check in default directory to be extra sure
            bHardcoded := true ; To know if we got path from registry or not
            IfNotExist, %A_ProgramFiles%\Diablo II Shareware
                bContinue := true ; No previous versions detected in hardcoded path
            else
            {
                FileRemoveDir, %A_ProgramFiles%\Diablo II Shareware, 1
                if ErrorLevel
                    TestsFailed("Unable to delete hardcoded path '" A_ProgramFiles "\Diablo II Shareware' ('" MainAppFile "' process is reported as terminated).'")
                else
                    bContinue := true
            }
        }
        else
        {
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

    if bContinue
    {
        RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\MicroSoft\Windows\CurrentVersion\Uninstall\Diablo II Shareware
        RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\Blizzard Entertainment

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


; Test if 'Diablo II Shareware Setup' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Diablo II Shareware Setup,, 15
    if ErrorLevel
        TestsFailed("'Diablo II Shareware Setup' window failed to appear.")
    else
    {
        SendInput, i ; Hit 'Install Diablo Shareware' button
        TestsOK("'Diablo II Shareware Setup' appeared and 'i' was sent.")
    }
}


; Test if 'License Agreement (Do you agree)' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, License Agreement, Do you agree, 3
    if ErrorLevel
        TestsFailed("'License Agreement (Do you agree)' window failed to appear.")
    else
    {
        ControlClick, Button2, License Agreement, Do you agree ; Hit 'Agree' button
        if ErrorLevel
            TestsFailed("Unable to hit 'Agree' button in 'License Agreement (Do you agree)' window.")
        else
            TestsOK("'License Agreement (Do you agree)' window appeared and 'Agree' button was clicked.")
    }
}


; Test if 'Diablo II - choose install directory (Select an install)' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Diablo II - choose install directory, &Select an install, 3
    if ErrorLevel
        TestsFailed("'Diablo II - choose install directory (Select an install)' window failed to appear.")
    else
    {
        ControlClick, Button1, Diablo II - choose install directory, &Select an install ; Hit 'OK' button
        if ErrorLevel
            TestsFailed("Unable to hit 'OK' button in 'Diablo II - choose install directory (Select an install)' window.")
        else
            TestsOK("'Diablo II - choose install directory (Select an install)' window appeared and 'OK' button was clicked.")
    }
}


; Test if 'Desktop Shortcut? (Would you like)' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Desktop Shortcut?, Would you like, 3
    if ErrorLevel
        TestsFailed("'Desktop Shortcut? (Would you like)' window failed to appear.")
    else
    {
        ControlClick, Button1, Desktop Shortcut?, Would you like ; Hit 'Yes' button
        if ErrorLevel
            TestsFailed("Unable to hit 'Yes' button in 'Desktop Shortcut? (Would you like)' window.")
        else
            TestsOK("'Desktop Shortcut? (Would you like)' window appeared and 'Yes' button was clicked.")
    }
}



; Test if can get thru 'Installing  Diablo II' window
TestsTotal++
if bContinue
{
    WinWaitActive,, Installing Diablo II, 3 ; Window haves no caption bar
    if ErrorLevel
        TestsFailed("'Installing Diablo II' window failed to appear.")
    else
    {
        WinWaitClose,, Installing Diablo II, 50
        if ErrorLevel
            TestsFailed("'Installing Diablo II' window appeared, but failed to close.")
        else
            TestsOK("'Installing Diablo II' window appeared and closed.")
    }
}


; Test if 'Diablo II Setup - Video Test (Diablo II Setup will)' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Diablo II Setup - Video Test, Diablo II Setup will, 3
    if ErrorLevel
        TestsFailed("'Diablo II Setup - Video Test (Diablo II Setup will)' window failed to appear.")
    else
    {
        ControlClick, Button3, Diablo II Setup - Video Test, Diablo II Setup will ; Hit 'Cancel' button
        if ErrorLevel
            TestsFailed("Unable to hit 'Cancel' button in 'Diablo II Setup - Video Test (Diablo II Setup will)' window.")
        else
            TestsOK("'Diablo II Setup - Video Test (Diablo II Setup will)' window appeared and 'Cancel' button was clicked.")
    }
}


; Test if 'View ReadMe? (Would you like)' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, View ReadMe?, Would you like, 3
    if ErrorLevel
        TestsFailed("'View ReadMe? (Would you like)' window failed to appear.")
    else
    {
        ControlClick, Button2, View ReadMe?, Would you like ; Hit 'No' button
        if ErrorLevel
            TestsFailed("Unable to hit 'No' button in 'View ReadMe? (Would you like)' window.")
        else
            TestsOK("'View ReadMe? (Would you like)' window appeared and 'No' button was clicked.")
    }
}


; Test if 'Diablo II Shareware Setup' window appeared
TestsTotal++
if bContinue
{
    IfWinNotExist, Diablo II Shareware Setup
        TestsFailed("'Diablo II Shareware Setup' window does not exist.")
    else
    {
        WinWaitActive, Diablo II Shareware Setup,, 3
        if ErrorLevel
            TestsFailed("'Diablo II Shareware Setup' window is not an active window.")
        else
        {
            SendInput, x ; Hit 'Exit installer' button
            WinWaitClose, Diablo II Shareware Setup,, 3
            if ErrorLevel
                TestsFailed("'Diablo II Shareware Setup' window failed to close despite 'x' was sent.")
            else
                TestsOK("'Diablo II Shareware Setup' appeared, 'x' sent and window closed.")
        }
    }
}


; Check if program exists
TestsTotal++
if bContinue
{
    RegRead, InstalledDir, HKEY_LOCAL_MACHINE, SOFTWARE\Blizzard Entertainment\Diablo II Shareware, InstallPath
    if ErrorLevel
        TestsFailed("Either we can't read from registry or data doesn't exist.")
    else
    {
        IfNotExist, %InstalledDir%\%MainAppFile%
            TestsFailed("Something went wrong, can't find '" InstalledDir "\" MainAppFile "'.")
        else
            TestsOK("The application has been installed, because '" InstalledDir "\" MainAppFile "' was found.")
    }
}
