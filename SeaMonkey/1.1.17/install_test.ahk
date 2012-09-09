/*
 * Designed for SeaMonkey 1.1.17
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

ModuleExe = %A_WorkingDir%\Apps\SeaMonkey 1.1.17 Setup.exe
TestName = 1.install
MainAppFile = seamonkey.exe ; Mostly this is going to be process we need to look for

; Test if Setup file exists, if so, delete installed files, and run Setup
TestsTotal++
IfNotExist, %ModuleExe%
    TestsFailed("'" ModuleExe "' not found.")
else
{
    ; Registry 'UninstallString' contains 'C:\WINDOWS\SeaMonkeyUninstall.exe /ua "1.1.17 (en)"' and there is no 'InstallLocation'
    Process, Close, %MainAppFile% ; Teminate process
    Process, WaitClose, %MainAppFile%, 4
    if ErrorLevel ; The PID still exists.
        TestsFailed("Unable to terminate '" MainAppFile "' process.") ; So, process still exists
    else
    {
            IfNotExist, %A_ProgramFiles%\mozilla.org\SeaMonkey
                bContinue := true ; No previous versions detected in hardcoded path
            else
            {
                bHardcoded := true ; To know if we got path from registry or not
                IfExist, %A_ProgramFiles%\mozilla.org\SeaMonkey\uninstall\SeaMonkeyUninstall.exe
                {
                    RunWait, %A_ProgramFiles%\mozilla.org\SeaMonkey\uninstall\SeaMonkeyUninstall.exe -ms -ira ; Silently uninstall it
                    Sleep, 7000
                }

                IfNotExist, %A_ProgramFiles%\mozilla.org\SeaMonkey ; Uninstaller might delete the dir
                    bContinue := true
                {
                    FileRemoveDir, %A_ProgramFiles%\mozilla.org\SeaMonkey, 1
                    if ErrorLevel
                        TestsFailed("Unable to delete existing '" A_ProgramFiles "\mozilla.org\SeaMonkey' ('" MainAppFile "' process is reported as terminated).'")
                    else
                        bContinue := true
                }
            }
    }

    if bContinue
    {
        RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\Mozilla
        RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\mozilla.org
        RegDelete, HKEY_CURRENT_USER, SOFTWARE\Mozilla
        RegDelete, HKEY_CURRENT_USER, SOFTWARE\mozilla.org
        RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\MicroSoft\Windows\CurrentVersion\Uninstall\SeaMonkey (1.1.17)
        IfExist, %A_AppData%\Mozilla
        {
            FileRemoveDir, %A_AppData%\Mozilla, 1
            if ErrorLevel
                TestsFailed("Unable to delete '" A_AppData "\Mozilla'.")
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



; Test if 'Extracting...' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Extracting...,, 7
    if ErrorLevel
        TestsFailed("'Extracting...' window failed to appear.")
    else
    {
        OutputDebug, OK: %TestName%:%A_LineNumber%: 'Extracting...' window appeared, waiting for it to close.`n
        WinWaitClose, Extracting...,,10
        if ErrorLevel
            TestsFailed("'Extracting...' window failed to close.")
        else
            TestsOK("'Extracting...' window went away.")
    }
}


; Test if 'SeaMonkey Setup - Welcome' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, SeaMonkey Setup - Welcome,, 7
    if ErrorLevel
        TestsFailed("'SeaMonkey Setup - Welcome' window failed to appear.")
    else
    {
        Sleep, 700
        ControlClick, Button1, SeaMonkey Setup - Welcome ; Hit 'Next' button
        if ErrorLevel
            TestsFailed("Unable to hit 'Next' button in 'SeaMonkey Setup - Welcome' window.")
        else
            TestsOK("'SeaMonkey Setup - Welcome' window appeared and 'Next' was clicked.")
    }
}


; Test if 'SeaMonkey Setup - Software License Agreement' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, SeaMonkey Setup - Software License Agreement,, 7
    if ErrorLevel
        TestsFailed("'SeaMonkey Setup - Software License Agreement' window failed to appear.")
    else
    {
        Sleep, 700
        ControlClick, Button1, SeaMonkey Setup - Software License Agreement ; Hit 'Accept' button
        if ErrorLevel
            TestsFailed("Unable to hit 'Accept' button in 'SeaMonkey Setup - Software License Agreement' window.")
        else
            TestsOK("'SeaMonkey Setup - Software License Agreement' window appeared and 'Accept' button was clicked.")
    }
}


; Test if 'SeaMonkey Setup - Setup Type' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, SeaMonkey Setup - Setup Type,, 7
    if ErrorLevel
        TestsFailed("'SeaMonkey Setup - Setup Type' window failed to appear.")
    else
    {
        Sleep, 700
        ControlClick, Button9, SeaMonkey Setup - Setup Type ; Hit 'Next' button
        if ErrorLevel
            TestsFailed("Unable to hit 'Next' button in 'SeaMonkey Setup - Setup Type' window.")
        else
            TestsOK("'SeaMonkey Setup - Setup Type' window appeared and 'Next' was clicked.")
    }
}


; Test if 'SeaMonkey Setup - Quick Launch' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, SeaMonkey Setup - Quick Launch,, 7
    if ErrorLevel
        TestsFailed("'SeaMonkey Setup - Quick Launch' window failed to appear.")
    else
    {
        Sleep, 700
        ControlClick, Button3, SeaMonkey Setup - Quick Launch ; Hit 'Next' button
        if ErrorLevel
            TestsFailed("Unable to hit 'Next' button in 'SeaMonkey Setup - Quick Launch' window.")
        else
            TestsOK("'SeaMonkey Setup - Quick Launch' window appeared and 'Next' was clicked.")
    }
}


; Test if 'SeaMonkey Setup - Start Install' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, SeaMonkey Setup - Start Install,, 7
    if ErrorLevel
        TestsFailed("'SeaMonkey Setup - Start Install' window failed to appear.")
    else
    {
        Sleep, 700
        ControlClick, Button1, SeaMonkey Setup - Start Install ; Hit 'Install' button
        if ErrorLevel
            TestsFailed("Unable to hit 'Install' button in 'SeaMonkey Setup - Start Install' window.")
        else
            TestsOK("'SeaMonkey Setup - Start Install' window appeared and 'Install' was clicked.")
    }
}


; Test if 'SeaMonkey Setup' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, SeaMonkey Setup,, 15
    if ErrorLevel
        TestsFailed("'SeaMonkey Setup' window failed to appear.")
    else
    {
        OutputDebug, OK: %TestName%:%A_LineNumber%: 'SeaMonkey Setup' window appeared, waiting for it to close.`n
        WinWaitClose, SeaMonkey Setup,,35
        if ErrorLevel
            TestsFailed("'SeaMonkey Setup' window failed to disappear.")
        else
            TestsOK("'SeaMonkey Setup' window went away.")
    }
}


; Test if 'SeaMonkey Setup - Install Progress' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, SeaMonkey Setup - Install Progress,, 15
    if ErrorLevel
        TestsFailed("'SeaMonkey Setup - Install Progress' window failed to appear.")
    else
    {
        OutputDebug, OK: %TestName%:%A_LineNumber%: 'SeaMonkey Setup - Install Progress' window appeared, waiting for it to close.`n
        WinWaitClose, SeaMonkey Setup,,25
        if ErrorLevel
            TestsFailed("'SeaMonkey Setup - Install Progress' window failed to disappear.")
        else
        {
            Process, Wait, %MainAppFile%, 5
            NewPID = %ErrorLevel%  ; Save the value immediately since ErrorLevel is often changed.
            if NewPID = 0
                TestsFailed("'" MainAppFile "' process failed to appear.")
            else
            {
                Sleep, 500 ; Sleep or Windows will throw an error on file access
                Process, Close, %MainAppFile%
                Process, WaitClose, %MainAppFile%, 5
                if ErrorLevel ; The PID still exists.
                    TestsFailed("Unable to terminate '" MainAppFile "' process.")
                else
                    TestsOK("'SeaMonkey Setup - Install Progress' window went away, '" MainAppFile "' terminated.")
            }
        }
    }
}


; Check if program exists
TestsTotal++
if bContinue
{
    Sleep, 2000
    IfNotExist, %A_ProgramFiles%\mozilla.org\SeaMonkey\%MainAppFile% ; Hardcode, because there are not much info in registry
        TestsFailed("Can NOT find '" A_ProgramFiles "\mozilla.org\SeaMonkey\" MainAppFile "'.")
    else
        TestsOK("The application has been installed, because '" A_ProgramFiles "\mozilla.org\SeaMonkey\" MainAppFile "' was found.")
}
