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
                IfNotExist, %A_ProgramFiles%\Notepad++
                    bContinue := true ; No previous versions detected in hardcoded path
                else
                {
                    bHardcoded := true ; To know if we got path from registry or not
                    Run, regsvr32 /s /u "%A_ProgramFiles%\NppShell_04.dll"
                    IfExist, %A_ProgramFiles%\Notepad++\uninstall.exe
                    {
                        RunWait, %A_ProgramFiles%\Notepad++\uninstall.exe /S ; Silently uninstall it
                        Sleep, 7000
                    }

                    IfNotExist, %A_ProgramFiles%\Notepad++ ; Uninstaller might delete the dir
                        bContinue := true
                    {
                        FileRemoveDir, %A_ProgramFiles%\Notepad++, 1
                        if ErrorLevel
                            TestsFailed("Unable to delete existing '" A_ProgramFiles "\Notepad++' ('" MainAppFile "' process is reported as terminated).'")
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
                    Run, regsvr32 /s /u "%InstalledDir%\NppShell_04.dll"
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
            Sleep, 7000 ; Let shell to load desktop
            Run %ModuleExe%
        }
    }
}


; Test if can start setup
TestsTotal++
if bContinue
{
    WinWait, Installer Language, Please select a language, 15
    if ErrorLevel
        TestsFailed("'Installer Language (Please select a language)' - there is no such window.")
    else
    {
        WinActivate, Installer Language, Please select a language ; Bring the window to front
        WinWaitActive, Installer Language, Please select a language, 5 ; Wait 5 secs for window to appear
        if ErrorLevel ; Window is found and it is active
            TestsFailed("'Installer Language (Please select a language)' window exist, but it is not an active.")
        else
        {
            Sleep, 1000
            SendInput, {ENTER} ; Hit 'OK' button
            TestsOK("'Installer Language' window appeared and 'OK' button was clicked (Sent 'ENTER' to window).")
        }
    }
}


; Test if 'Welcome to the Notepad++ v 6.1.2 Setup' window appeared
TestsTotal++
if bContinue
{
    SetTitleMatchMode, 1 ; A window's title must start with the specified WinTitle to be a match.
    WinWaitActive, Notepad, Welcome to the Notepad, 15
    if ErrorLevel
        TestsFailed("'Notepad++ v6.1.2 Setup (Welcome to the Notepad++ v 6.1.2 Setup)' window failed to appear.")
    else
    {
        Sleep, 700
        SendInput, !n ; Hit 'Next' button
        TestsOK("'Notepad++ v6.1.2 Setup (Welcome to the Notepad++ v 6.1.2 Setup)' window appeared, Alt+N sent.")
    }
}


; Test if 'License Agreement' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Notepad, License Agreement, 5
    if ErrorLevel
        TestsFailed("'Notepad++ v6.1.2 Setup (License Agreement)' window failed to appear.")
    else
    {
        Sleep, 700
        SendInput, !a ; Hit 'I Agree' button
        TestsOK("'Notepad++ v6.1.2 Setup (License Agreement)' window appeared and Alt+A was sent.`")
    }
}


; Test if 'Choose Install Location' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Notepad, Choose Install Location, 5
    if ErrorLevel
        TestsFailed("'Notepad++ v6.1.2 Setup (Choose Install Location)' window failed to appear.")
    else
    {
        Sleep, 700
        SendInput, !n ; Hit 'Next' button
        TestsOK("'Notepad++ v6.1.2 Setup (Choose Install Location)' window appeared and Alt+N was sent.")
    }
}


; Test if 'Check the components' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Notepad, Check the components, 5
    if ErrorLevel
        TestsFailed("'Notepad++ v6.1.2 Setup (Check the components)' window failed to appear.")
    else
    {
        Sleep, 700
        SendInput, !n ; Hit 'Next' button
        TestsOK("'Notepad++ v6.1.2 Setup (Check the components)' window appeared and Alt+N was sent.")
    }
}


; Test if 'Create Shortcut on Desktop' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Notepad, Create Shortcut on Desktop, 5
    if ErrorLevel
        TestsFailed("'Notepad++ v6.1.2 Setup (Create Shortcut on Desktop)' window failed to appear.")
    else
    {
        Sleep, 700
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
                Sleep, 700
                SendInput, !i ; Hit 'Install' button
                TestsOK("'Notepad++ v6.1.2 Setup (Create Shortcut on Desktop)' window appeared, 'Allow plugins', 'Create Shortcut' checkboxes were checked and Alt+I was sent.")
            }
        }
    }
}

; Test if can get thru 'Installing' window
TestsTotal++
if bContinue
{
    WinWaitActive, Notepad, Installing, 7
    if ErrorLevel
        TestsFailed("'Notepad++ v6.1.2 Setup (Installing)' window failed to appear.")
    else
    {
        OutputDebug, OK: %TestName%:%A_LineNumber%: 'Installing' window appeared, waiting for it to close.`n
        WinWaitClose, Notepad, Installing, 25
        if ErrorLevel
            TestsFailed("'Notepad++ v6.1.2 Setup (Installing)' window failed to dissapear.")
        else
            TestsOK("'Notepad++ v6.1.2 Setup (Installing)' went away.")
    }
}


; Test if 'Completing' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Notepad, Completing, 5
    if ErrorLevel
        TestsFailed("'Notepad++ v6.1.2 Setup (Completing)' window failed to appear.")
    else
    {
        Sleep, 700
        SendInput, !r ; Uncheck 'Run Notepad'
        Sleep, 1000
        SendInput, !f ; Hit 'Finish' button
        WinWaitClose, Notepad, Completing, 10
        if ErrorLevel
            TestsFailed("'Notepad++ v6.1.2 Setup (Completing)' window failed to close despite Alt+F was sent.")
        else
        {
            Process, Wait, notepad++.exe, 4
            NewPID = %ErrorLevel%  ; Save the value immediately since ErrorLevel is often changed.
            if NewPID <> 0
            {
                TestsFailed("Process 'notepad++.exe' appeared despite Alt+R was sent to setup window.")
                Process, Close, notepad++.exe
            }
            else
                TestsOK("'Notepad++ v6.1.2 Setup (Completing)' window appeared, Alt+R and Alt+F were sent and window closed.")
        }
    }
}

; Check if program exists
TestsTotal++
if bContinue
{
    Sleep, 2000
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
