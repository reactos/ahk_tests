/*
 * Designed for FreeBASIC 0.24.0
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

ModuleExe = %A_WorkingDir%\Apps\FreeBASIC 0.24.0 Setup.exe
TestName = 1.install
MainAppFile = open-console.exe ; Mostly this is going to be process we need to look for

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
        RegRead, UninstallerPath, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\FreeBASIC, UninstallString
        if ErrorLevel
        {
            ; There was a problem (such as a nonexistent key or value). 
            ; That probably means we have not installed this app before.
            ; Check in default directory to be extra sure
            bHardcoded := true ; To know if we got path from registry or not
            IfNotExist, %A_ProgramFiles%\FreeBASIC
                bContinue := true ; No previous versions detected in hardcoded path
            else
            {
                IfExist, %A_ProgramFiles%\FreeBASIC\uninstall.exe
                {
                    RunWait, %A_ProgramFiles%\FreeBASIC\uninstall.exe /S ; Silently uninstall it
                    Sleep, 7000
                }

                IfNotExist, %A_ProgramFiles%\FreeBASIC ; Uninstaller might delete the dir
                    bContinue := true
                {
                    FileRemoveDir, %A_ProgramFiles%\FreeBASIC, 1
                    if ErrorLevel
                        TestsFailed("Unable to delete hardcoded path '" A_ProgramFiles "\FreeBASIC' ('" MainAppFile "' process is reported as terminated).'")
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
        RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\MicroSoft\Windows\CurrentVersion\Uninstall\uninstall

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


; Test if 'FreeBASIC 0.24.0 Setup (Choose Install Location)' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, FreeBASIC 0.24.0 Setup, Choose Install Location, 7
    if ErrorLevel
        TestsFailed("'FreeBASIC 0.24.0 Setup (Choose Install Location)' window failed to appear.")
    else
    {
        Sleep, 700
        ControlClick, Button2, FreeBASIC 0.24.0 Setup, Choose Install Location ; Hit 'Next' button
        if ErrorLevel
            TestsFailed("Unable to hit 'Next' button in 'FreeBASIC 0.24.0 Setup (Choose Install Location)' window.")
        else
        {
            WinWaitClose, FreeBASIC 0.24.0 Setup, Choose Install Location, 5
            if ErrorLevel
                TestsFailed("'FreeBASIC 0.24.0 Setup (Choose Install Location)' window failed to close despite 'Next' button being clicked.")
            else
                TestsOK("'FreeBASIC 0.24.0 Setup (Choose Install Location)' window appeared, 'Next' button clicked and window closed.")
        }
    }
}


; Test if 'FreeBASIC 0.24.0 Setup (Choose Start Menu Folder)' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, FreeBASIC 0.24.0 Setup, Choose Start Menu Folder, 7
    if ErrorLevel
        TestsFailed("'FreeBASIC 0.24.0 Setup (Choose Start Menu Folder)' window failed to appear.")
    else
    {
        Sleep, 700
        ControlClick, Button2, FreeBASIC 0.24.0 Setup, Choose Start Menu Folder ; Hit 'Install' button
        if ErrorLevel
            TestsFailed("Unable to hit 'Install' button in 'FreeBASIC 0.24.0 Setup (Choose Start Menu Folder)' window.")
        else
            TestsOK("'FreeBASIC 0.24.0 Setup (Choose Start Menu Folder)' window appeared and 'Install' button was clicked.")
    }
}


; Test if can get thru 'FreeBASIC 0.24.0 Setup (Installing)' window
TestsTotal++
if bContinue
{
    WinWaitActive, FreeBASIC 0.24.0 Setup, Installing, 7
    if ErrorLevel
        TestsFailed("'FreeBASIC 0.24.0 Setup (Installing)' window failed to appear.")
    else
    {
        OutputDebug, OK: %TestName%:%A_LineNumber%: 'FreeBASIC 0.24.0 Setup (Installing)' window appeared, waiting for it to close.`n
        WinWaitClose, FreeBASIC 0.24.0 Setup, Installing, 30
        if ErrorLevel
            TestsFailed("'FreeBASIC 0.24.0 Setup (Installing)' window failed to close.")
        else
            TestsOK("'FreeBASIC 0.24.0 Setup (Installing)' window closed.")
    }
}


; Test if 'FreeBASIC 0.24.0 Setup (Installation Complete)' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, FreeBASIC 0.24.0 Setup, Installation Complete, 7
    if ErrorLevel
        TestsFailed("'FreeBASIC 0.24.0 Setup (Installation Complete)' window failed to appear.")
    else
    {
        Sleep, 700
        ControlClick, Button2, FreeBASIC 0.24.0 Setup, Installation Complete ; Hit 'Close' button
        if ErrorLevel
            TestsFailed("Unable to hit 'Close' button in 'FreeBASIC 0.24.0 Setup (Installation Complete)' window.")
        else
        {
            WinWaitClose, FreeBASIC 0.24.0 Setup, Installation Complete, 5
            if ErrorLevel
                TestsFailed("'FreeBASIC 0.24.0 Setup (Installation Complete)' window failed to close despite 'Close' button being clicked.")
            else
             TestsOK("'FreeBASIC 0.24.0 Setup (Installation Complete)' window appeared, 'Close' button clicked and window closed.")
        }
    }
}


; Check if program exists
TestsTotal++
if bContinue
{
    Sleep, 2000
    RegRead, UninstallerPath, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\FreeBASIC, UninstallString
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
