/*
 * Designed for Word Viewer 2003
 * Copyright (C) 2013 Edijs Kolesnikovics
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

ModuleExe = %A_WorkingDir%\Apps\Word Viewer 2003 Setup.exe
TestName = 1.install
MainAppFile = WORDVIEW.exe ; Mostly this is going to be process we need to look for
bContinue := true


; Test if Setup file exists, if so, delete installed files, and run Setup
TestsTotal++
IfNotExist, %ModuleExe%
    TestsFailed("'" ModuleExe "' not found.")
else
{
    szDefaultDir = %A_ProgramFiles%\MicroSoft Office
    Process, Close, %MainAppFile% ; Teminate process
    Process, WaitClose, %MainAppFile%, 4
    if ErrorLevel ; The PID still exists.
        TestsFailed("Unable to terminate '" MainAppFile "' process.") ; So, process still exists
    else
    {
        RegRead, InstallLocation, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{90850409-6000-11D3-8CFE-0150048383C9}, InstallLocation
        if ErrorLevel
        {
            ; There was a problem (such as a nonexistent key or value). 
            ; That probably means we have not installed this app before.
            ; Check in default directory to be extra sure
            bHardcoded := true ; To know if we got path from registry or not
            IfNotExist, %szDefaultDir%
                TestsInfo("No previous versions detected in hardcoded path: '" szDefaultDir "'.")
            else
            {   
                UninstallerPath = %A_WinDir%\System32\MsiExec.exe /x {90850409-6000-11D3-8CFE-0150048383C9} /qn
                WaitUninstallDone(UninstallerPath, 7)
                if bContinue
                {
                    IfNotExist, %szDefaultDir% ; Uninstaller might delete the dir
                        TestsInfo("Uninstaller deleted hardcoded path: '" szDefaultDir "'.")
                    else
                    {
                        FileRemoveDir, %szDefaultDir%, 1
                        if ErrorLevel
                            TestsFailed("Unable to delete hardcoded path '" szDefaultDir "' ('" MainAppFile "' process is reported as terminated).'")
                        else
                            TestsInfo("Succeeded deleting hardcoded path, because uninstaller did not: '" szDefaultDir "'.")
                    }
                }
            }
        }
        else
        {
            InstalledDir = %InstallLocation%
            IfNotExist, %InstalledDir%
            {
                IfNotExist, %szDefaultDir%
                    TestsInfo("Got '" InstalledDir "' from registry and such path does not exist as well as hard-coded one '" szDefaultDir "'.")
                else
                {
                    TestsInfo("Got '" InstalledDir "' from registry and such path does not exist, but hard-coded one '" szDefaultDir "' does. Lets use it.")
                    InstalledDir = %szDefaultDir% ; Lets use existing hard-coded path
                }
            }
            UninstallerPath = %A_WinDir%\System32\MsiExec.exe /x {90850409-6000-11D3-8CFE-0150048383C9} /qn
            WaitUninstallDone(UninstallerPath, 7)
            if bContinue
            {
                IfNotExist, %InstalledDir%
                    TestsInfo("Uninstaller deleted path (registry data): '" InstalledDir "'.")
                else
                {
                    FileRemoveDir, %InstalledDir%, 1 ; Uninstaller leaved the path for us to delete, so, do it
                    if ErrorLevel
                        TestsFailed("Unable to delete existing '" InstalledDir "' ('" MainAppFile "' process is reported as terminated).")
                    else
                        TestsInfo("Succeeded deleting path (registry data), because uninstaller did not: '" InstalledDir "'.")
                }
            }
        }
    }

    if bContinue
    {
        RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\MicroSoft\Windows\CurrentVersion\Uninstall\{90850409-6000-11D3-8CFE-0150048383C9}
        RegDelete, HKEY_CURRENT_USER, Software\Microsoft\Office

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


; Test if 'Microsoft Office Word Viewer (Click here)' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Microsoft Office Word Viewer, Click here, 3
    if ErrorLevel
        TestsFailed("'Microsoft Office Word Viewer (Click here)' window failed to appear.")
    else
    {
        SendInput, !a ; Alt+A to accept license ; FIXME: check if really checked
        SendInput, !c ; Alt+C to click 'Continue' button ; FIXME: check if button is enabled then send keystroke
        WinWaitClose, Microsoft Office Word Viewer, Click here, 3
        if ErrorLevel
            TestsFailed("'Microsoft Office Word Viewer (Click here)' window failed to close despite Alt+A and Alt+C being sent.")
        else
            TestsOK("'Microsoft Office Word Viewer (Click here)' window appeared, Alt+A, Alt+C were sent and window closed.")
    }
}


; Test if 'Microsoft Office Word Viewer 2003 Setup (End-User)' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Microsoft Office Word Viewer 2003 Setup, End-User, 3
    if ErrorLevel
        TestsFailed("'Microsoft Office Word Viewer 2003 Setup (End-User)' window failed to appear.")
    else
    {
        SendInput, !a ; Alt+A to accept license ; FIXME: check if really checked
        Sleep, 400 ; WinXP wants some delay here.
        SendInput, !n ; Alt+N to click 'Next' button ; FIXME: check if button is enabled then send keystroke
        WinWaitClose, Microsoft Office Word Viewer 2003 Setup, End-User, 3
        if ErrorLevel
            TestsFailed("'Microsoft Office Word Viewer 2003 Setup (End-User)' window failed to close despite Alt+A and Alt+N being sent.")
        else
            TestsOK("'Microsoft Office Word Viewer 2003 Setup (End-User)' window appeared, Alt+A, Alt+N were sent and window closed.")
    }
}


; Test if 'Microsoft Office Word Viewer 2003 Setup (Choose where to install)' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Microsoft Office Word Viewer 2003 Setup, Choose where to install, 3
    if ErrorLevel
        TestsFailed("'Microsoft Office Word Viewer 2003 Setup (Choose where to install)' window failed to appear.")
    else
    {
        SendInput, !i ; Alt+I to click 'Install' button
        WinWaitClose, Microsoft Office Word Viewer 2003 Setup, Choose where to install, 3
        if ErrorLevel
            TestsFailed("'Microsoft Office Word Viewer 2003 Setup (Choose where to install)' window failed to close despite Alt+I being sent.")
        else
            TestsOK("'Microsoft Office Word Viewer 2003 Setup (Choose where to install)' window appeared, sent Alt+I and window closed.")
    }
}


; Test if 'Microsoft Office Word Viewer 2003 Setup (Now Installing)' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Microsoft Office Word Viewer 2003 Setup, Now Installing, 3
    if ErrorLevel
        TestsFailed("'Microsoft Office Word Viewer 2003 Setup (Now Installing)' window failed to appear.")
    else
    {
        TestsInfo("'Microsoft Office Word Viewer 2003 Setup (Now Installing)' window appeared, waiting for it to close.")
        iTimeOut := 20
        while iTimeOut > 0
        {
            IfWinActive, Microsoft Office Word Viewer 2003 Setup, Now Installing
            {
                WinWaitClose, Microsoft Office Word Viewer 2003 Setup, Now Installing, 1
                iTimeOut--
            }
            else
            {
                WinGetActiveTitle, ActiveWndTitle
                TestsInfo("'" ActiveWndTitle "' window poped-up.")
                break ; exit the loop if something poped-up
            }
        }

        WinWaitClose, Microsoft Office Word Viewer 2003 Setup, Now Installing, 1
        if ErrorLevel
            TestsFailed("'Microsoft Office Word Viewer 2003 Setup (Now Installing)' window failed to close.")
        else
            TestsOK("'Microsoft Office Word Viewer 2003 Setup (Now Installing)' window closed.")
    }
}


; Test if 'Microsoft Office Word Viewer 2003 Setup (Setup has completed)' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Microsoft Office Word Viewer 2003 Setup, Setup has completed, 3
    if ErrorLevel
        TestsFailed("'Microsoft Office Word Viewer 2003 Setup (Setup has completed)' window failed to appear.")
    else
    {
        SendInput, {ENTER} ; Click 'OK' button
        WinWaitClose, Microsoft Office Word Viewer 2003 Setup, Setup has completed, 3
        if ErrorLevel
            TestsFailed("'Microsoft Office Word Viewer 2003 Setup (Setup has completed)' window failed to close despite ENTER being sent to click 'OK' button.")
        else
            TestsOK("'Microsoft Office Word Viewer 2003 Setup (Setup has completed)' window appeared, sent ENTER and window closed.")
    }
}


; Test if 'Microsoft Office Word Viewer (Installing update)' window appeared
TestsTotal++
if bContinue
{
    WinWait, Microsoft Office Word Viewer, Installing update, 3 ; It appears in the background
    if ErrorLevel
        TestsFailed("'Microsoft Office Word Viewer (Installing update)' window failed to appear.")
    else
    {
        WinWaitClose, Microsoft Office Word Viewer, Installing update, 7
        if ErrorLevel
            TestsFailed("'Microsoft Office Word Viewer (Installing update)' window failed to close.")
        else
            TestsOK("'Microsoft Office Word Viewer (Installing update)' window appeared and closed.")
    }
}


; Test if 'Microsoft Office Word Viewer (installation is complete)' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Microsoft Office Word Viewer, installation is complete, 3
    if ErrorLevel
        TestsFailed("'Microsoft Office Word Viewer (installation is complete)' window failed to appear.")
    else
    {
        SendInput, {ENTER} ; Click 'OK' button
        WinWaitClose, Microsoft Office Word Viewer, installation is complete, 3
        if ErrorLevel
            TestsFailed("'Microsoft Office Word Viewer (installation is complete)' window failed to close despite ENTER being sent to click 'OK' button.")
        else
            TestsOK("'Microsoft Office Word Viewer (installation is complete)' window appeared, sent ENTER and window closed.")
    }
}


; Check if program exists
TestsTotal++
if bContinue
{
    InstalledDir = %A_ProgramFiles%\Microsoft Office\OFFICE11
    IfNotExist, %InstalledDir%\%MainAppFile%
        TestsFailed("Something went wrong, can't find '" InstalledDir "\" MainAppFile "'.")
    else
        TestsOK("The application has been installed, because '" InstalledDir "\" MainAppFile "' was found.")
}
