/*
 * Designed for TuxPaint 0.9.21c
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

ModuleExe = %A_WorkingDir%\Apps\TuxPaint 0.9.21c Setup.exe
TestName = 1.install
MainAppFile = tuxpaint.exe ; Mostly this is going to be process we need to look for

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
        RegRead, UninstallerPath, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Tux Paint_is1, UninstallString
        if ErrorLevel
        {
            ; There was a problem (such as a nonexistent key or value). 
            ; That probably means we have not installed this app before.
            ; Check in default directory to be extra sure
            bHardcoded := true ; To know if we got path from registry or not
            szDefaultDir = %A_ProgramFiles%\TuxPaint
            IfNotExist, %szDefaultDir%
            {
                TestsInfo("No previous versions detected in hardcoded path: '" szDefaultDir "'.")
                bContinue := true
            }
            else
            {   
                UninstallerPath = %szDefaultDir%\unins000.exe /silent
                WaitUninstallDone(UninstallerPath, 3)
                if bContinue
                {
                    IfNotExist, %szDefaultDir% ; Uninstaller might delete the dir
                    {
                        TestsInfo("Uninstaller deleted hardcoded path: '" szDefaultDir "'.")
                        bContinue := true
                    }
                    else
                    {
                        FileRemoveDir, %szDefaultDir%, 1
                        if ErrorLevel
                            TestsFailed("Unable to delete hardcoded path '" szDefaultDir "' ('" MainAppFile "' process is reported as terminated).'")
                        else
                        {
                            TestsInfo("Succeeded deleting hardcoded path, because uninstaller did not: '" szDefaultDir "'.")
                            bContinue := true
                        }
                    }
                }
            }
        }
        else
        {
            UninstallerPath := ExeFilePathNoParam(UninstallerPath)
            SplitPath, UninstallerPath,, InstalledDir
            IfNotExist, %InstalledDir%
            {
                TestsInfo("Got '" InstalledDir "' from registry and such path does not exist.")
                bContinue := true
            }
            else
            {
                UninstallerPath = %UninstallerPath% /silent
                WaitUninstallDone(UninstallerPath, 3) ; Child process '*.tmp'
                if bContinue
                {
                    IfNotExist, %InstalledDir%
                    {
                        TestsInfo("Uninstaller deleted path (registry data): '" InstalledDir "'.")
                        bContinue := true
                    }
                    else
                    {
                        FileRemoveDir, %InstalledDir%, 1 ; Uninstaller leaved the path for us to delete, so, do it
                        if ErrorLevel
                            TestsFailed("Unable to delete existing '" InstalledDir "' ('" MainAppFile "' process is reported as terminated).")
                        else
                        {
                            TestsInfo("Succeeded deleting path (registry data), because uninstaller did not: '" InstalledDir "'.")
                            bContinue := true
                        }
                    }
                }
            }
        }
    }

    if bContinue
    {
        RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\MicroSoft\Windows\CurrentVersion\Uninstall\Tux Paint_is1
        IfExist, %A_AppData%\TuxPaint
        {
            FileRemoveDir, %A_AppData%\TuxPaint, 1
            if ErrorLevel
                TestsFailed("Unable to delete '" A_AppData "\TuxPaint'.")
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


; Test if 'Select Setup Language' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Select Setup Language, Select the language, 10
    if ErrorLevel
        TestsFailed("'Select Setup Language (Select the language')' window failed to appear.")
    else
    {
        SendInput, {ENTER} ; Hit 'OK' button
        WinWaitClose, Select Setup Language, Select the language, 3
        if ErrorLevel
            TestsFailed("'Select Setup Language (Select the language')' window failed to close despite 'ENTER' was sent to it.")
        else
            TestsOK("'Select Setup Language (Select the language')' window appeared and 'ENTER' was sent.")
    }
}


; Test if 'Welcome to the Tux Paint' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Setup - Tux Paint, Welcome to the Tux Paint, 10
    if ErrorLevel
        TestsFailed("'Setup - Tux Paint (Welcome to the Tux Paint)' window failed to appear.")
    else
    {
        SendInput, !n ; Hit 'Next' button
        TestsOK("'Setup - Tux Paint (Welcome to the Tux Paint)' window appeared, Alt+N was sent.")
    }
}


; Test if 'License Agreement' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Setup - Tux Paint, License Agreement, 3
    if ErrorLevel
        TestsFailed("'Setup - Tux Paint (License Agreement)' window failed to appear.")
    else
    {
        SendInput, !a ; Check 'I accept' radiobutton (Fails to check? CORE-6542)
        SendInput, !n ; Hit 'Next' button
        TestsOK("'Setup - Tux Paint (License Agreement)' window appeared, Alt+A and Alt+N were sent.")
    }
}


; Test if 'Choose Installation Type' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Setup - Tux Paint, Choose Installation Type, 3
    if ErrorLevel
        TestsFailed("'Setup - Tux Paint (Choose Installation Type)' window failed to appear (CORE-6542?).")
    else
    {
        SendInput, !n ; Hit 'Next' button
        TestsOK("'Setup - Tux Paint (Choose Installation Type)' window appeared, Alt+N was sent.")
    }
}


; Test if 'Select Destination Location' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Setup - Tux Paint, Select Destination Location, 3
    if ErrorLevel
        TestsFailed("'Setup - Tux Paint (Select Destination Location)' window failed to appear.")
    else
    {
        SendInput, !n ; Hit 'Next' button
        TestsOK("'Setup - Tux Paint (Select Destination Location)' window appeared, Alt+N was sent.")
    }
}


; Test if 'Select Start Menu Folder' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Setup - Tux Paint, Select Start Menu Folder, 3
    if ErrorLevel
        TestsFailed("'Setup - Tux Paint (Select Start Menu Folder)' window failed to appear.")
    else
    {
        SendInput, !n ; Hit 'Next' button
        TestsOK("'Setup - Tux Paint (Select Start Menu Folder)' window appeared, Alt+N was sent.")
    }
}


; Test if 'Select Additional Tasks' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Setup - Tux Paint, Select Additional Tasks, 3
    if ErrorLevel
        TestsFailed("'Setup - Tux Paint (Select Additional Tasks)' window failed to appear.")
    else
    {
        SendInput, !n ; Hit 'Next' button
        TestsOK("'Setup - Tux Paint (Select Additional Tasks)' window appeared, Alt+N was sent.")
    }
}


; Test if 'Ready to Install' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Setup - Tux Paint, Ready to Install, 3
    if ErrorLevel
        TestsFailed("'Setup - Tux Paint (Ready to Install)' window failed to appear.")
    else
    {
        SendInput, !i ; Hit 'Install' button
        TestsOK("'Setup - Tux Paint (Ready to Install)' window appeared, Alt+I was sent.")
    }
}


; Test if can get thru 'Installing'
TestsTotal++
if bContinue
{
    WinWaitActive, Setup - Tux Paint, Installing, 3
    if ErrorLevel
        TestsFailed("'Setup - Tux Paint (Installing)' window failed to appear.")
    else
    {
        TestsInfo("'Setup - Tux Paint (Installing)' window appeared, waiting for it to close.")
        WinWaitClose, Setup - Tux Paint, Installing, 15
        if ErrorLevel
            TestsFailed("'Setup - Tux Paint (Installing)' window failed to close.")
        else
            TestsOK("'Setup - Tux Paint (Installing)' window went away.")
    }
}


; Test if 'Completing' window appeared and all checkboxes were unchecked correctly
TestsTotal++
if bContinue
{
    WinWaitActive, Setup - Tux Paint, Completing, 3
    if ErrorLevel
        TestsFailed("'Setup - Tux Paint (Completing)' window failed to appear.")
    else
    {
        SendInput, {SPACE}{DOWN}{SPACE} ; FIXME: Find better solution. AHK 'Control, Uncheck' won't work here!
        SendInput, !f ; Hit 'Finish' button
        WinWaitClose, Setup - Tux Paint, Completing, 3
        if ErrorLevel
            TestsFailed("'Setup - Tux Paint (Completing)' window failed to close despite Alt+F was sent.")
        else
        {
            Process, wait, tuxpaint-config.exe, 4
            NewPID = %ErrorLevel%  ; Save the value immediately since ErrorLevel is often changed.
            if NewPID <> 0
            {
                Process, Close, tuxpaint-config.exe
                Process, WaitClose, tuxpaint-config.exe, 4
                if ErrorLevel
                    TestsFailed("Process 'tuxpaint-config.exe' detected (failed to terminate it), so failed to uncheck checkboxes in 'Setup - Tux Paint (Completing)' window.")
                else
                    TestsFailed("Process 'tuxpaint-config.exe' detected, so failed to uncheck checkboxes in 'Setup - Tux Paint (Completing)' window.")
            }
            else
                TestsOK("'Setup - Tux Paint (Completing)' window appeared, checkbox 'Launch Tux Paint Config' unchecked, 'Finish' button clicked.")
        }
    }
}


; Check if program exists
TestsTotal++
if bContinue
{
    RegRead, UninstallerPath, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Tux Paint_is1, UninstallString
    if ErrorLevel
        TestsFailed("Either we can't read from registry or data doesn't exist.")
    else
    {
        StringReplace, UninstallerPath, UninstallerPath, `",, All ; TuxPaint data is quoted
        SplitPath, UninstallerPath,, InstalledDir
        IfNotExist, %InstalledDir%\%MainAppFile%
            TestsFailed("Something went wrong, can't find '" InstalledDir "\" MainAppFile "'.")
        else
            TestsOK("The application has been installed, because '" InstalledDir "\" MainAppFile "' was found.")
    }
}
