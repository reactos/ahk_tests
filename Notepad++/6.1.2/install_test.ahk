/*
 * Designed for Notepad++ v6.1.2
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

ModuleExe = %A_WorkingDir%\Apps\Notepad++_6.1.2_Setup.exe
TestName = 1.install
MainAppFile = notepad++.exe ; Mostly this is going to be process we need to look for

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
        Process, Close, explorer.exe ; Terminate explorer.exe before unregistering shell extension and uninstalling
        Process, WaitClose, explorer.exe, 5
        if ErrorLevel
            TestsFailed("Unable to terminate 'explorer.exe' process.")
        else
        {
            RegRead, UninstallerPath, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Notepad++, UninstallString
            if ErrorLevel
            {
                ; There was a problem (such as a nonexistent key or value). 
                ; That probably means we have not installed this app before.
                ; Check in default directory to be extra sure
                bHardcoded := true ; To know if we got path from registry or not
                szDefaultDir = %A_ProgramFiles%\Notepad++
                IfNotExist, %szDefaultDir%
                {
                    TestsInfo("No previous versions detected in hardcoded path: '" szDefaultDir "'.")
                    bContinue := true
                }
                else
                {   
                    Run, regsvr32 /s /u "%szDefaultDir%\NppShell_04.dll"
                    UninstallerPath = %szDefaultDir%\uninstall.exe /S
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
                    Run, regsvr32 /s /u "%InstalledDir%\NppShell_04.dll"
                    UninstallerPath = %UninstallerPath% /S
                    WaitUninstallDone(UninstallerPath, 3) ; Child name 'Au_.exe'
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
    }

    if bContinue
    {
        RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\Notepad++
        RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\MicroSoft\Windows\CurrentVersion\Uninstall\Notepad++
        IfExist, %A_AppData%\Notepad++
        {
            FileRemoveDir, %A_AppData%\Notepad++, 1
            if ErrorLevel
                TestsFailed("Unable to delete '" A_AppData "\Notepad++'.")
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


; Test if can start setup
TestsTotal++
if bContinue
{
    DetectHiddenText, Off ; Hidden text is not detected
    WinWait, Installer Language, Please select a language, 5
    if ErrorLevel
        TestsFailed("'Installer Language (Please select a language)' - there is no such window.")
    else
    {
        WinActivate, Installer Language, Please select a language ; Bring the window to front
        WinWaitActive, Installer Language, Please select a language, 3 ; Wait 3 secs for window to appear
        if ErrorLevel ; Window is found and it is active
            TestsFailed("'Installer Language (Please select a language)' window exist, but it is not an active.")
        else
        {
            SendInput, {ENTER} ; Hit 'OK' button
            WinWaitClose, Installer Language, Please select a language, 3
            if ErrorLevel
                TestsFailed("'Installer Language (Please select a language)' window failed to close despite 'ENTER' being sent.")
            else
                TestsOK("'Installer Language (Please select a language)' window appeared, 'ENTER' sent and window closed.")
        }
    }
}


; Test if 'Welcome to the Notepad++ v 6.1.2 Setup' window appeared
TestsTotal++
if bContinue
{
    SetTitleMatchMode, 1 ; A window's title must start with the specified WinTitle to be a match.
    WinWait, Notepad, Welcome to the Notepad, 5
    if ErrorLevel
        TestsFailed("'Notepad++ v6.1.2 Setup (Welcome to the Notepad++ v 6.1.2 Setup)' window doesn't exist.")
    else
    {
        WinActivate ; Notepad, Welcome to the Notepad
        WinWaitActive, Notepad, Welcome to the Notepad, 3
        if ErrorLevel
            TestsFailed("Unable to activate existing 'Notepad++ v6.1.2 Setup (Welcome to the Notepad++ v 6.1.2 Setup)' window.")
        else
        {
            SendInput, !n ; Hit 'Next' button
            TestsOK("'Notepad++ v6.1.2 Setup (Welcome to the Notepad++ v 6.1.2 Setup)' window appeared, Alt+N sent.")
        }
    }
}


; Test if 'License Agreement' window appeared
TestsTotal++
if bContinue
{
    WinWait, Notepad, License Agreement, 3
    if ErrorLevel
        TestsFailed("'Notepad++ v6.1.2 Setup (License Agreement)' window doesn't exist.")
    else
    {
        WinActivate ; Notepad, License Agreement
        WinWaitActive, Notepad, License Agreement, 3
        if ErrorLevel
            TestsFailed("Unable to activate existing 'Notepad++ v6.1.2 Setup (License Agreement)' window.")
        else
        {
            SendInput, !a ; Hit 'I Agree' button
            TestsOK("'Notepad++ v6.1.2 Setup (License Agreement)' window appeared and Alt+A was sent.`")
        }
    }
}


; Test if 'Choose Install Location' window appeared
TestsTotal++
if bContinue
{
    WinWait, Notepad, Choose Install Location, 3
    if ErrorLevel
        TestsFailed("'Notepad++ v6.1.2 Setup (Choose Install Location)' window doesn't exist.")
    else
    {
        WinActivate ; Notepad, Choose Install Location
        WinWaitActive, Notepad, Choose Install Location, 3
        if ErrorLevel
            TestsFailed("Unable to activate existing 'Notepad++ v6.1.2 Setup (Choose Install Location)' window.")
        else
        {
            SendInput, !n ; Hit 'Next' button
            TestsOK("'Notepad++ v6.1.2 Setup (Choose Install Location)' window appeared and Alt+N was sent.")
        }
    }
}


; Test if 'Check the components' window appeared
TestsTotal++
if bContinue
{
    WinWait, Notepad, Check the components, 3
    if ErrorLevel
        TestsFailed("'Notepad++ v6.1.2 Setup (Check the components)' window doesn't exist.")
    else
    {
        WinActivate ; Notepad, Check the components
        WinWaitActive, Notepad, Check the components, 3
        if ErrorLevel
            TestsFailed("Unable to activate existing 'Notepad++ v6.1.2 Setup (Check the components)' window.")
        else
        {
            SendInput, !n ; Hit 'Next' button
            TestsOK("'Notepad++ v6.1.2 Setup (Check the components)' window appeared and Alt+N was sent.")
        }
    }
}


; Test if 'Create Shortcut on Desktop' window appeared
TestsTotal++
if bContinue
{
    WinWait, Notepad, Create Shortcut on Desktop, 3
    if ErrorLevel
        TestsFailed("'Notepad++ v6.1.2 Setup (Create Shortcut on Desktop)' window doesn't exist.")
    else
    {
        WinActivate ; Notepad, Create Shortcut on Desktop
        WinWaitActive, Notepad, Create Shortcut on Desktop, 3
        if ErrorLevel
            TestsFailed("Unable to activate existing 'Notepad++ v6.1.2 Setup (Create Shortcut on Desktop)' window.")
        else
        {
            Control, Check, , Button5, Notepad ; Check 'Allow plugins'
            if ErrorLevel
                TestsFailed("Unable to check 'Allow plugins' checkbox in 'Notepad++ v6.1.2 Setup (Create Shortcut on Desktop)' window.")
            else
            {
                Control, Check, , Button6, Notepad ; Check 'Create Shortcut'
                if ErrorLevel
                    TestsFailed("Unable to check 'Create Shortcut' checkbox in 'Notepad++ v6.1.2 Setup (Create Shortcut on Desktop)' window.")
                else
                {
                    SendInput, !i ; Hit 'Install' button
                    TestsOK("'Notepad++ v6.1.2 Setup (Create Shortcut on Desktop)' window appeared, 'Allow plugins', 'Create Shortcut' checkboxes were checked and Alt+I was sent.")
                }
            }
        }
    }
}

; Test if can get thru 'Installing' window
TestsTotal++
if bContinue
{
    WinWait, Notepad, Installing, 3
    if ErrorLevel
        TestsFailed("'Notepad++ v6.1.2 Setup (Installing)' window doesn't exist.")
    else
    {
        WinActivate ; Notepad, Installing
        WinWaitActive, Notepad, Installing, 3
        if ErrorLevel
            TestsFailed("'Notepad++ v6.1.2 Setup (Installing)' window failed to appear.")
        else
        {
            TestsInfo("'Installing' window appeared, waiting for it to close.")
            WinWaitClose, Notepad, Installing, 12
            if ErrorLevel
                TestsFailed("'Notepad++ v6.1.2 Setup (Installing)' window failed to dissapear.")
            else
                TestsOK("'Notepad++ v6.1.2 Setup (Installing)' went away.")
        }
    }
}


; Test if 'Completing' window appeared
TestsTotal++
if bContinue
{
    WinWait, Notepad, Completing, 3
    if ErrorLevel
        TestsFailed("'Notepad++ v6.1.2 Setup (Completing)' window doesn't exist.")
    else
    {
        WinActivate ; Notepad, Completing
        WinWaitActive, Notepad, Completing, 3
        if ErrorLevel
            TestsFailed("'Notepad++ v6.1.2 Setup (Completing)' window failed to appear.")
        else
        {
            SendInput, !r ; Uncheck 'Run Notepad'
            ControlGet, bChecked, Checked, Button4
            if bChecked = 1
                TestsFailed("Alt+R was sent to uncheck 'Run Notepad' checkbox in 'Notepad++ v6.1.2 Setup (Completing)' window, but further inspection proves that it was still checked.")
            else
            {
                SendInput, !f ; Hit 'Finish' button
                WinWaitClose, Notepad, Completing, 3
                if ErrorLevel
                    TestsFailed("'Notepad++ v6.1.2 Setup (Completing)' window failed to close despite Alt+F was sent.")
                else
                    TestsOK("'Notepad++ v6.1.2 Setup (Completing)' window appeared, Alt+R and Alt+F were sent and window closed.")
            }
        }
    }
}


; Check if program exists
TestsTotal++
if bContinue
{
    RegRead, UninstallerPath, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Notepad++, UninstallString
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
