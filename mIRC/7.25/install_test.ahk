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
        RegRead, InstallLocation, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\mIRC, InstallLocation
        if ErrorLevel
        {
            ; There was a problem (such as a nonexistent key or value). 
            ; That probably means we have not installed this app before.
            ; Check in default directory to be extra sure
            IfNotExist, %A_ProgramFiles%\mIRC
                bContinue := true ; No previous versions detected in hardcoded path
            else
            {
                bHardcoded := true ; To know if we got path from registry or not
                IfExist, %A_ProgramFiles%\mIRC\Uninstall.exe
                {
                    RunWait, %A_ProgramFiles%\mIRC\Uninstall.exe /S ; Silently uninstall it
                    Sleep, 7000
                }

                IfNotExist, %A_ProgramFiles%\mIRC ; Uninstaller might delete the dir
                    bContinue := true
                {
                    FileRemoveDir, %A_ProgramFiles%\mIRC, 1
                    if ErrorLevel
                        TestsFailed("Unable to delete existing '" A_ProgramFiles "\mIRC' ('" MainAppFile "' process is reported as terminated).'")
                    else
                        bContinue := true
                }
            }
        }
        else
        {
            IfNotExist, %InstallLocation%
                bContinue := true
            else
            {
                IfExist, %InstallLocation%\Uninstall.exe
                {
                    RunWait, %InstallLocation%\Uninstall.exe /S ; Silently uninstall it
                    Sleep, 7000
                }

                IfNotExist, %InstallLocation%
                    bContinue := true
                else
                {
                    FileRemoveDir, %InstallLocation%, 1 ; Delete just in case
                    if ErrorLevel
                        TestsFailed("Unable to delete existing '" InstallLocation "' ('" MainAppFile "' process is reported as terminated).")
                    else
                        bContinue := true
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
    WinWaitActive, mIRC Setup, Welcome to the mIRC, 15
    if ErrorLevel
        TestsFailed("'mIRC Setup (Welcome to the mIRC)' window failed to appear.")
    else
    {
        Sleep, 700
        SendInput, !n ; Hit 'Next' button
        TestsOK("'mIRC Setup (Welcome to the mIRC)' window appeared, Alt+N was sent.")
    }
}


; Test if 'License Agreement' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, mIRC Setup, License Agreement, 7
    if ErrorLevel
        TestsFailed("'mIRC Setup (License Agreement)' window failed to appear.")
    else
    {
        Sleep, 700
        SendInput, !a ; Hit 'I Agree' button
        TestsOK("'mIRC Setup (License Agreement)' window appeared, Alt+A was sent.")
    }
}


; Test if 'Choose Install Location' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, mIRC Setup, Choose Install Location, 7
    if ErrorLevel
        TestsFailed("'mIRC Setup (Choose Install Location)' window failed to appear.")
    else
    {
        Sleep, 700
        SendInput, !n ; Hit 'Next' button
        TestsOK("'mIRC Setup (Choose Install Location)' window appeared, Alt+N was sent.")
    }
}


; Test if 'Choose Components' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, mIRC Setup, Choose Components, 7
    if ErrorLevel
        TestsFailed("'mIRC Setup(Choose Components)' window failed to appear")
    else
    {
        Sleep, 700
        SendInput, !n ; Hit 'Next' button
        TestsOK("'mIRC Setup(Choose Components)' window appeared, Alt+N was sent.")
    }
}


; Test if 'Select Additional Tasks' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, mIRC Setup, Select Additional Tasks, 7
    if ErrorLevel
        TestsFailed("'mIRC Setup (Select Additional Tasks)' window failed to appear.")
    else
    {
        Sleep, 700
        SendInput, {TAB}{TAB}{SPACE}{TAB}{SPACE} ; Uncheck 'Backup Current Files' and 'Automatically Check for Updates'
        Sleep, 500
        SendInput, !n ; Hit 'Next' button
        TestsOK("'mIRC Setup (Select Additional Tasks)' window appeared, checkboxes 'Backup Current Files' and 'Automatically Check for Updates' unchecked, Alt+N was sent.")
    }
}


; Test if 'Ready to Install' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, mIRC Setup, Ready to Install, 7
    if ErrorLevel
        TestsFailed("'mIRC Setup (Ready to Install)' window failed to appear.")
    else
    {
        Sleep, 700
        SendInput, {ALTDOWN}i{ALTUP} ; Hit 'Install' button
        TestsOK("'mIRC Setup (Ready to Install)' window appeared, Alt+I was sent.")
    }
}


; Test if can get thru 'Installing'
TestsTotal++
if bContinue
{
    WinWaitActive, mIRC Setup, Installing, 7
    if ErrorLevel
        TestsFailed("'mIRC Setup (Installing)' window failed to appear.")
    else
    {
        Sleep, 700
        OutputDebug, OK: %TestName%:%A_LineNumber%: 'Installing' window appeared, waiting for it to close.`n
        WinWaitClose, mIRC Setup, Installing, 25
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
    WinWaitActive, mIRC Setup, Completing, 7
    if ErrorLevel
        TestsFailed("'mIRC Setup (Completing)' window failed to appear.")
    else
    {
        Sleep, 700
        OutputDebug, OK: %TestName%:%A_LineNumber%: In a sec will send '{ALT DOWN}f' (note: no '{ALT UP}' event).`n
        SendInput, {ALT DOWN}f ; Hit 'Finish' button
        WinWaitClose, mIRC Setup, Completing, 7
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
    Sleep, 2000
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
