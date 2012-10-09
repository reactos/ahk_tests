/*
 * Designed for Python 3.2.3
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

ModuleExe = %A_WorkingDir%\Apps\Python 3.2.3 Setup.msi
TestName = 1.install
MainAppFile = python.exe ; Mostly this is going to be process we need to look for

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
        ; v3.2.3 does not provide InstallLocation, but it gives path to exe in DisplayIcon
        RegRead, InstallLocation, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{789C9644-9F82-44d3-B4CA-AC31F46F5882}, DisplayIcon
        if ErrorLevel
        {
            ; There was a problem (such as a nonexistent key or value). 
            ; That probably means we have not installed this app before.
            ; Check in default directory to be extra sure
            bHardcoded := true ; To know if we got path from registry or not
            szDefaultDir = C:\Python32
            IfNotExist, %szDefaultDir%
            {
                TestsInfo("No previous versions detected in hardcoded path: '" szDefaultDir "'.")
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
        else
        {
            SplitPath, InstallLocation,, InstalledDir
            IfNotExist, %InstalledDir%
            {
                TestsInfo("Got '" InstalledDir "' from registry and such path does not exist.")
                bContinue := true
            }
            else
            {
                FileRemoveDir, %InstalledDir%, 1 ; Silent switch 'msiexec.exe /x' shows dialogs and 'msiexec.exe /qn /x' does nothing
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

    if bContinue
    {
        RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\MicroSoft\Windows\CurrentVersion\Uninstall\{789C9644-9F82-44d3-B4CA-AC31F46F5882}
        RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\Python
        RegDelete, HKEY_CLASSES_ROOT, Installer\Products\4469C98728F93D444BACCA134FF68528
        RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\Classes\Installer\Products\4469C98728F93D444BACCA134FF68528
        if bHardcoded
            TestsOK("Either there was no previous versions or we succeeded removing it using hardcoded path.")
        else
            TestsOK("Either there was no previous versions or we succeeded removing it using data from registry.")
        Run %ModuleExe%
    }
}


; Test if 'Windows Installer (Preparing to install...)' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Windows Installer, Preparing to install..., 7
    if ErrorLevel
        TestsFailed("'Windows Installer (Preparing to install...)' window failed to appear.")
    else
    {
        TestsInfo("'Windows Installer (Preparing to install...)' window appeared, waiting for it to close.")
        
        iTimeOut := 45
        while iTimeOut > 0
        {
            IfWinActive, Windows Installer, Preparing to install...
            {
                WinWaitClose, Windows Installer, Preparing to install..., 1
                iTimeOut--
            }
            else
                break ; exit the loop if something poped-up
        }
        
        WinWaitClose, Windows Installer, Preparing to install..., 1
        if ErrorLevel
            TestsFailed("'Windows Installer (Preparing to install...)' window failed to close (iTimeOut=" iTimeOut ").")
        else
            TestsOK("'Windows Installer (Preparing to install...)' window closed (iTimeOut=" iTimeOut ").")
    }
}


; Tests if 'Python 3.2.3 Setup (Select whether)' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Python 3.2.3 Setup, Select whether, 7
    if ErrorLevel
        TestsFailed("'Python 3.2.3 Setup (Select whether)' window failed to appear.")
    else
    {
        ControlClick, Button4 ; Hit 'Next' button
        if ErrorLevel
            TestsFailed("Unable to hit 'Next' button in 'Python 3.2.3 Setup (Select whether)' window.")
        else
        {
            WinWaitClose, Python 3.2.3 Setup, Select whether, 3
            if ErrorLevel
                TestsFailed("'Python 3.2.3 Setup (Select whether)' window failed to close despite 'Next' button being clicked.")
            else
                TestsOK("'Python 3.2.3 Setup (Select whether)' window appeared, 'Next' button clicked and window closed.")
        }
    }
}


; Tests if 'Python 3.2.3 Setup (Select Destination)' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Python 3.2.3 Setup, Select Destination, 3
    if ErrorLevel
        TestsFailed("'Python 3.2.3 Setup (Select Destination)' window failed to appear.")
    else
    {
        ControlClick, Button1 ; Hit 'Next' button
        if ErrorLevel
            TestsFailed("Unable to hit 'Next' button in 'Python 3.2.3 Setup (Select Destination)' window.")
        else
            TestsOK("'Python 3.2.3 Setup (Select Destination)' window appeared and 'Next' button clicked.")
    }
}


; Tests if 'Python 3.2.3 Setup (Customize)' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Python 3.2.3 Setup, Customize, 3
    if ErrorLevel
        TestsFailed("'Python 3.2.3 Setup (Customize)' window failed to appear.")
    else
    {
        ControlClick, Button2 ; Hit 'Next' button
        if ErrorLevel
            TestsFailed("Unable to hit 'Next' button in 'Python 3.2.3 Setup (Customize)' window.")
        else
            TestsOK("'Python 3.2.3 Setup (Customize)' window appeared and 'Next' button clicked.")
    }
}


; Test if 'Python 3.2.3 Setup (Install Python)' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Python 3.2.3 Setup, Install Python, 3
    if ErrorLevel
        TestsFailed("'Python 3.2.3 Setup (Install Python)' window failed to appear.")
    else
    {
        TestsInfo("'Python 3.2.3 Setup (Install Python)' window appeared, waiting for it to close.")
        
        iTimeOut := 20
        while iTimeOut > 0
        {
            IfWinActive, Python 3.2.3 Setup, Install Python
            {
                WinWaitClose, Python 3.2.3 Setup, Install Python, 1
                iTimeOut--
            }
            else
                break ; exit the loop if something poped-up
        }
        
        WinWaitClose, Python 3.2.3 Setup, Install Python, 1
        if ErrorLevel
            TestsFailed("'Python 3.2.3 Setup (Install Python)' window failed to close (iTimeOut=" iTimeOut ").")
        else
            TestsOK("'Python 3.2.3 Setup (Install Python)' window closed (iTimeOut=" iTimeOut ").")
    }
}


; Tests if 'Python 3.2.3 Setup (Complete)' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Python 3.2.3 Setup, Complete, 3
    if ErrorLevel
        TestsFailed("'Python 3.2.3 Setup (Complete)' window failed to appear.")
    else
    {
        ControlClick, Button1 ; Hit 'Finish' button
        if ErrorLevel
            TestsFailed("Unable to hit 'Finish' button in 'Python 3.2.3 Setup (Complete)' window.")
        else
        {
            WinWaitClose, Python 3.2.3 Setup, Complete, 3
            if ErrorLevel
                TestsFailed("'Python 3.2.3 Setup (Complete)' window failed to close despite 'Finish' button being clicked.")
            else
                TestsOK("'Python 3.2.3 Setup (Complete)' window appeared, 'Finish' button clicked and window closed.")
        }
    }
}


; Check if program exists
TestsTotal++
if bContinue
{
    ; No need to sleep, because we already waited for process to appear
    RegRead, DisplayIcon, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{789C9644-9F82-44d3-B4CA-AC31F46F5882}, DisplayIcon
    if ErrorLevel
        TestsFailed("Either we can't read from registry or data doesn't exist.")
    else
    {
        SplitPath, DisplayIcon,, InstallLocation
        IfNotExist, %InstallLocation%\%MainAppFile% ; Registry path contains trailing backslash
            TestsFailed("Something went wrong, can't find '" InstallLocation "\" MainAppFile "'.")
        else
            TestsOK("The application has been installed, because '" InstallLocation "\" MainAppFile "' was found.")
    }
}
