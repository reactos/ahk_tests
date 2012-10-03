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
SetTitleMatchMode, 3 ; A window's title must exactly match WinTitle to be a match.

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
                UninstallerPath = %A_ProgramFiles%\mozilla.org\SeaMonkey\uninstall\SeaMonkeyUninstall.exe -ms -ira
                ; running uninstaller manually you can see 'UNINSTALL.EXE' process appeared. Our helper
                ; functions fails to detect parent process name (so, thats why we have '' as parent) and child process in win2k3 sp2
                WaitUninstallDone(UninstallerPath, 3)
                if bContinue
                {
                    IfNotExist, %A_ProgramFiles%\mozilla.org\SeaMonkey ; Uninstaller might delete the dir
                        bContinue := true
                    else
                    {
                        FileRemoveDir, %A_ProgramFiles%\mozilla.org\SeaMonkey, 1
                        if ErrorLevel
                            TestsFailed("Unable to delete existing '" A_ProgramFiles "\mozilla.org\SeaMonkey' ('" MainAppFile "' process is reported as terminated).'")
                        else
                            bContinue := true
                    }
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
    WinWaitActive, Extracting...,, 5
    if ErrorLevel
        TestsFailed("'Extracting...' window failed to appear.")
    else
    {
        TestsInfo("'Extracting...' window appeared, waiting for it to close.")
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
        ControlClick, Button1, SeaMonkey Setup - Welcome ; Hit 'Next' button
        if ErrorLevel
            TestsFailed("Unable to hit 'Next' button in 'SeaMonkey Setup - Welcome' window.")
        else
        {
            WinWaitClose, SeaMonkey Setup - Welcome,, 3
            if ErrorLevel
                TestsFailed("'SeaMonkey Setup - Welcome' window failed to close despite 'Next' button being clicked.")
            else
                TestsOK("'SeaMonkey Setup - Welcome' window appeared and 'Next' was clicked.")
        }
    }
}


; Test if 'SeaMonkey Setup - Software License Agreement' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, SeaMonkey Setup - Software License Agreement,, 3
    if ErrorLevel
        TestsFailed("'SeaMonkey Setup - Software License Agreement' window failed to appear.")
    else
    {
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
    WinWaitActive, SeaMonkey Setup - Setup Type,, 3
    if ErrorLevel
        TestsFailed("'SeaMonkey Setup - Setup Type' window failed to appear.")
    else
    {
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
    WinWaitActive, SeaMonkey Setup - Quick Launch,, 3
    if ErrorLevel
        TestsFailed("'SeaMonkey Setup - Quick Launch' window failed to appear.")
    else
    {
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
    WinWaitActive, SeaMonkey Setup - Start Install,, 3
    if ErrorLevel
        TestsFailed("'SeaMonkey Setup - Start Install' window failed to appear.")
    else
    {
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
    WinWaitActive, SeaMonkey Setup,, 7
    if ErrorLevel
        TestsFailed("'SeaMonkey Setup' window failed to appear.")
    else
    {
        TestsInfo("'SeaMonkey Setup' window appeared, waiting for it to close.")
        
        iTimeOut := 45
        while iTimeOut > 0
        {
            IfWinActive, SeaMonkey Setup
            {
                WinWaitClose, SeaMonkey Setup,, 1
                iTimeOut--
            }
            else
                break ; exit the loop if something poped-up
        }

        WinWaitClose, SeaMonkey Setup,, 1
        if ErrorLevel
            TestsFailed("'SeaMonkey Setup' window failed to close (iTimeOut=" iTimeOut ").")
        else
            TestsOK("'SeaMonkey Setup' window went away (iTimeOut=" iTimeOut ").")
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
        TestsInfo("'SeaMonkey Setup - Install Progress' window appeared, waiting for it to close.")
        
        iTimeOut := 45
        while iTimeOut > 0
        {
            IfWinActive, SeaMonkey Setup - Install Progress
            {
                WinWaitClose, SeaMonkey Setup - Install Progress,, 1
                iTimeOut--
            }
            else
                break ; exit the loop if something poped-up
        }
        
        WinWaitClose, SeaMonkey Setup - Install Progress,, 1
        if ErrorLevel
            TestsFailed("'SeaMonkey Setup - Install Progress' window failed to close (iTimeOut=" iTimeOut ").")
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
                if ErrorLevel ; The PID still exists
                    TestsFailed("Unable to terminate '" MainAppFile "' process.")
                else
                    TestsOK("'SeaMonkey Setup - Install Progress' window went away (iTimeOut=" iTimeOut "), '" MainAppFile "' terminated.")
            }
        }
    }
}


; Check if program exists
TestsTotal++
if bContinue
{
    IfNotExist, %A_ProgramFiles%\mozilla.org\SeaMonkey\%MainAppFile% ; Hardcode, because there are not much info in registry
        TestsFailed("Can NOT find '" A_ProgramFiles "\mozilla.org\SeaMonkey\" MainAppFile "'.")
    else
        TestsOK("The application has been installed, because '" A_ProgramFiles "\mozilla.org\SeaMonkey\" MainAppFile "' was found.")
}
