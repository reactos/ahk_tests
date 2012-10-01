/*
 * Designed for mIRC 7.25
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

ModuleExe = %A_WorkingDir%\Apps\mIRC_7.25_Setup.exe
TestName = 1.install
MainAppFile = mirc.exe ; Mostly this is going to be process we need to look for

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
        RegRead, UninstallerPath, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\mIRC, UninstallString
        if ErrorLevel
        {
            ; There was a problem (such as a nonexistent key or value). 
            ; That probably means we have not installed this app before.
            ; Check in default directory to be extra sure
            bHardcoded := true ; To know if we got path from registry or not
            szDefaultDir = %A_ProgramFiles%\mIRC
            IfNotExist, %szDefaultDir%
            {
                TestsInfo("No previous versions detected in hardcoded path: '" szDefaultDir "'.")
                bContinue := true
            }
            else
            {   
                UninstallerPath = %szDefaultDir%\Uninstall.exe /S
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
                UninstallerPath = %UninstallerPath% /S
                WaitUninstallDone(UninstallerPath, 3) ; Reported child name is 'Au_.exe'
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
        RegDelete, HKEY_CURRENT_USER, SOFTWARE\mIRC
        RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\MicroSoft\Windows\CurrentVersion\Uninstall\mIRC
        IfExist, %A_AppData%\mIRC
        {
            FileRemoveDir, %A_AppData%\mIRC, 1
            if ErrorLevel
                TestsFailed("Unable to delete '" A_AppData "\mIRC'.")
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



; Test if 'Welcome to the mIRC' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, mIRC Setup, Welcome to the mIRC, 7
    if ErrorLevel
        TestsFailed("'mIRC Setup (Welcome to the mIRC)' window failed to appear.")
    else
    {
        SendInput, !n ; Hit 'Next' button
        WinWaitClose, mIRC Setup, Welcome to the mIRC, 3
        if ErrorLevel
            TestsFailed("'mIRC Setup (Welcome to the mIRC)' window failed to close despite Alt+N was sent.")
        else
            TestsOK("'mIRC Setup (Welcome to the mIRC)' window appeared, Alt+N sent and window closed.")
    }
}


; Test if 'License Agreement' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, mIRC Setup, License Agreement, 3
    if ErrorLevel
        TestsFailed("'mIRC Setup (License Agreement)' window failed to appear.")
    else
    {
        SendInput, !a ; Hit 'I Agree' button
        TestsOK("'mIRC Setup (License Agreement)' window appeared, Alt+A was sent.")
    }
}


; Test if 'Choose Install Location' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, mIRC Setup, Choose Install Location, 3
    if ErrorLevel
        TestsFailed("'mIRC Setup (Choose Install Location)' window failed to appear.")
    else
    {
        SendInput, !n ; Hit 'Next' button
        TestsOK("'mIRC Setup (Choose Install Location)' window appeared, Alt+N was sent.")
    }
}


; Test if 'Choose Components' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, mIRC Setup, Choose Components, 3
    if ErrorLevel
        TestsFailed("'mIRC Setup(Choose Components)' window failed to appear")
    else
    {
        SendInput, !n ; Hit 'Next' button
        TestsOK("'mIRC Setup(Choose Components)' window appeared, Alt+N was sent.")
    }
}


; Test if 'Select Additional Tasks' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, mIRC Setup, Select Additional Tasks, 3
    if ErrorLevel
        TestsFailed("'mIRC Setup (Select Additional Tasks)' window failed to appear.")
    else
    {
        SendInput, {TAB}{TAB}{SPACE}{TAB}{SPACE} ; Uncheck 'Backup Current Files' and 'Automatically Check for Updates'
        SendInput, !n ; Hit 'Next' button
        TestsOK("'mIRC Setup (Select Additional Tasks)' window appeared, checkboxes 'Backup Current Files' and 'Automatically Check for Updates' unchecked, Alt+N was sent.")
    }
}


; Test if 'Ready to Install' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, mIRC Setup, Ready to Install, 3
    if ErrorLevel
        TestsFailed("'mIRC Setup (Ready to Install)' window failed to appear.")
    else
    {
        SendInput, {ALTDOWN}i{ALTUP} ; Hit 'Install' button
        TestsOK("'mIRC Setup (Ready to Install)' window appeared, Alt+I was sent.")
    }
}


; Test if can get thru 'Installing'
TestsTotal++
if bContinue
{
    WinWaitActive, mIRC Setup, Installing, 3
    if ErrorLevel
        TestsFailed("'mIRC Setup (Installing)' window failed to appear.")
    else
    {
        TestsInfo("'Installing' window appeared, waiting for it to close.")
        WinWaitClose, mIRC Setup, Installing, 10
        if ErrorLevel
            TestsFailed("'mIRC Setup (Installing)' window failed to close.")
        else
            TestsOK("'mIRC Setup (Installing)' window went away.")
    } 
}


; Test if 'Completing' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, mIRC Setup, Completing, 3
    if ErrorLevel
        TestsFailed("'mIRC Setup (Completing)' window failed to appear.")
    else
    {
        TestsInfo("In a sec will send '{ALT DOWN}f' (note: no '{ALT UP}' event).")
        SendInput, {ALT DOWN}f ; Hit 'Finish' button
        WinWaitClose, mIRC Setup, Completing, 3
        if ErrorLevel
            TestsFailed("'mIRC Setup (Completing)' window failed to close.")
        else
        {
            TestsOK("'mIRC Setup (Completing)' window appeared, '{ALT DOWN}f' was sent (note: no '{ALT UP}' event) and window was closed (will send '{ALT UP}' in a sec).")
            SendInput, {ALT UP} ; We have to send it anyway
        }
    }
}


; Check if program exists
TestsTotal++
if bContinue
{
    RegRead, InstalledDir, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\mIRC, InstallLocation
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
