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
            IfNotExist, %A_ProgramFiles%\TuxPaint
                bContinue := true ; No previous versions detected in hardcoded path
            else
            {
                bHardcoded := true ; To know if we got path from registry or not
                IfExist, %A_ProgramFiles%\TuxPaint\unins000.exe
                {
                    RunWait, %A_ProgramFiles%\TuxPaint\unins000.exe /silent ; Silently uninstall it
                    Sleep, 7000
                }

                IfNotExist, %A_ProgramFiles%\TuxPaint ; Uninstaller might delete the dir
                    bContinue := true
                {
                    FileRemoveDir, %A_ProgramFiles%\TuxPaint, 1
                    if ErrorLevel
                        TestsFailed("Unable to delete hardcoded path '" A_ProgramFiles "\TuxPaint' ('" MainAppFile "' process is reported as terminated).'")
                    else
                        bContinue := true
                }
            }
        }
        else
        {
            StringReplace, UninstallerPath, UninstallerPath, `",, All ; TuxPaint data is quoted
            SplitPath, UninstallerPath,, InstalledDir
            IfNotExist, %InstalledDir%
                bContinue := true
            else
            {
                IfExist, %UninstallerPath%
                {
                    RunWait, %UninstallerPath% /silent ; Silently uninstall it
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
    WinWaitActive, Select Setup Language, Select the language, 15
    if ErrorLevel
        TestsFailed("'Select Setup Language (Select the language')' window failed to appear.")
    else
    {
        Sleep, 700
        SendInput, {ENTER} ; Hit 'OK' button
        WinWaitClose, Select Setup Language, Select the language, 5
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
    WinWaitActive, Setup - Tux Paint, Welcome to the Tux Paint, 15
    if ErrorLevel
        TestsFailed("'Setup - Tux Paint (Welcome to the Tux Paint)' window failed to appear.")
    else
    {
        Sleep, 700
        SendInput, !n ; Hit 'Next' button
        TestsOK("'Setup - Tux Paint (Welcome to the Tux Paint)' window appeared, Alt+N was sent.")
    }
}


; Test if 'License Agreement' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Setup - Tux Paint, License Agreement, 7
    if ErrorLevel
        TestsFailed("'Setup - Tux Paint (License Agreement)' window failed to appear.")
    else
    {
        Sleep, 700
        SendInput, !a ; Check 'I accept' radiobutton (Fails to check? Bug 7215)
        Sleep, 1000 ; Wait until 'Next' button is enabled
        SendInput, !n ; Hit 'Next' button
        TestsOK("'Setup - Tux Paint (License Agreement)' window appeared, Alt+A and Alt+N were sent.")
    }
}


; Test if 'Choose Installation Type' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Setup - Tux Paint, Choose Installation Type, 7
    if ErrorLevel
        TestsFailed("'Setup - Tux Paint (Choose Installation Type)' window failed to appear (bug 7215?).")
    else
    {
        Sleep, 700
        SendInput, !n ; Hit 'Next' button
        TestsOK("'Setup - Tux Paint (Choose Installation Type)' window appeared, Alt+N was sent.")
    }
}


; Test if 'Select Destination Location' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Setup - Tux Paint, Select Destination Location, 7
    if ErrorLevel
        TestsFailed("'Setup - Tux Paint (Select Destination Location)' window failed to appear.")
    else
    {
        Sleep, 700
        SendInput, !n ; Hit 'Next' button
        TestsOK("'Setup - Tux Paint (Select Destination Location)' window appeared, Alt+N was sent.")
    }
}


; Test if 'Select Start Menu Folder' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Setup - Tux Paint, Select Start Menu Folder, 7
    if ErrorLevel
        TestsFailed("'Setup - Tux Paint (Select Start Menu Folder)' window failed to appear.")
    else
    {
        Sleep, 700
        SendInput, !n ; Hit 'Next' button
        TestsOK("'Setup - Tux Paint (Select Start Menu Folder)' window appeared, Alt+N was sent.")
    }
}


; Test if 'Select Additional Tasks' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Setup - Tux Paint, Select Additional Tasks, 7
    if ErrorLevel
        TestsFailed("'Setup - Tux Paint (Select Additional Tasks)' window failed to appear.")
    else
    {
        Sleep, 700
        SendInput, !n ; Hit 'Next' button
        TestsOK("'Setup - Tux Paint (Select Additional Tasks)' window appeared, Alt+N was sent.")
    }
}


; Test if 'Ready to Install' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Setup - Tux Paint, Ready to Install, 7
    if ErrorLevel
        TestsFailed("'Setup - Tux Paint (Ready to Install)' window failed to appear.")
    else
    {
        Sleep, 700
        SendInput, !i ; Hit 'Install' button
        TestsOK("'Setup - Tux Paint (Ready to Install)' window appeared, Alt+I was sent.")
    }
}


; Test if can get thru 'Installing'
TestsTotal++
if bContinue
{
    WinWaitActive, Setup - Tux Paint, Installing, 7
    if ErrorLevel
        TestsFailed("'Setup - Tux Paint (Installing)' window failed to appear.")
    else
    {
        Sleep, 700
        OutputDebug, OK: %TestName%:%A_LineNumber%: 'Setup - Tux Paint (Installing)' window appeared, waiting for it to close.`n
        WinWaitClose, Setup - Tux Paint, Installing, 25
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
    WinWaitActive, Setup - Tux Paint, Completing, 7
    if ErrorLevel
        TestsFailed("'Setup - Tux Paint (Completing)' window failed to appear.")
    else
    {
        Sleep, 700
        SendInput, {SPACE}{DOWN}{SPACE} ; FIXME: Find better solution. AHK 'Control, Uncheck' won't work here!
        Sleep, 500
        SendInput, !f ; Hit 'Finish' button
        WinWaitClose, Setup - Tux Paint, Completing, 5
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
    Sleep, 2000
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
