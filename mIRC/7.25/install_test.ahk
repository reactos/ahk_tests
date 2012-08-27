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
bContinue := false
TestName = 1.install

TestsFailed := 0
TestsOK := 0
TestsTotal := 0

; Test if Setup file exists, if so, delete installed files, and run Setup
IfExist, %ModuleExe%
{
    ; Get rid of other versions
    RegRead, UninstallerPath, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\mIRC, UninstallString
    if not ErrorLevel
    {
        Process, Close, mirc.exe ; Teminate process
        Sleep, 1500
        RegRead, InstallLocation, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\mIRC, InstallLocation
        RunWait, %UninstallerPath% /S ; Silently uninstall it
        Sleep, 2500
        ; Delete everything just in case
        RegDelete, HKEY_CURRENT_USER, SOFTWARE\mIRC
        RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\MicroSoft\Windows\CurrentVersion\Uninstall\mIRC
        FileRemoveDir, %InstallLocation%, 1
        Sleep, 1000
        IfExist, %InstallLocation%
        {
            OutputDebug, %TestName%:%A_LineNumber%: Test failed: Failed to delete '%InstallLocation%'.`n
            bContinue := false
        }
        else
        {
            bContinue := true
        }
    }
    else
    {
        ; There was a problem (such as a nonexistent key or value). 
        ; That probably means we have not installed this app before.
        ; Check in default directory to be extra sure
        IfExist, %A_ProgramFiles%\mIRC\Uninstall.exe
        {
            Process, Close, mirc.exe ; Teminate process
            Sleep, 1500
            RunWait, %A_ProgramFiles%\mIRC\Uninstall.exe /S ; Silently uninstall it
            Sleep, 2500
            FileRemoveDir, %A_ProgramFiles%\mIRC, 1
            Sleep, 1000
            IfExist, %A_ProgramFiles%\mIRC
            {
                OutputDebug, %TestName%:%A_LineNumber%: Test failed: Previous version detected and failed to delete '%A_ProgramFiles%\mIRC'.`n
                bContinue := false
            }
            else
            {
                bContinue := true
            }
        }
        else
        {
            ; No previous versions detected.
            bContinue := true
        }
    }
    if bContinue
    {
        FileRemoveDir, %A_AppData%\mIRC, 1
        Run %ModuleExe%
    }
}
else
{
    OutputDebug, %TestName%:%A_LineNumber%: Test failed: '%ModuleExe%' not found.`n
    bContinue := false
}

; Test if 'Welcome to the mIRC' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, mIRC Setup, Welcome to the mIRC, 15
    if not ErrorLevel
    {
        Sleep, 250
        SendInput, !n ; Hit 'Next' button
        TestsOK("'mIRC Setup (Welcome to the mIRC)' window appeared, Alt+N was sent.")
    }
    else
        TestsFailed("'mIRC Setup (Welcome to the mIRC)' window failed to appear.")
}


; Test if 'License Agreement' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, mIRC Setup, License Agreement, 7
    if not ErrorLevel
    {
        Sleep, 250
        SendInput, !a ; Hit 'I Agree' button
        TestsOK("'mIRC Setup (License Agreement)' window appeared, Alt+A was sent.")
    }
    else
        TestsFailed("'mIRC Setup (License Agreement)' window failed to appear.")
}


; Test if 'Choose Install Location' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, mIRC Setup, Choose Install Location, 7
    if not ErrorLevel
    {
        Sleep, 250
        SendInput, !n ; Hit 'Next' button
        TestsOK("'mIRC Setup (Choose Install Location)' window appeared, Alt+N was sent.")
    }
    else
        TestsFailed("'mIRC Setup (Choose Install Location)' window failed to appear.")
}


; Test if 'Choose Components' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, mIRC Setup, Choose Components, 7
    if not ErrorLevel
    {
        Sleep, 250
        SendInput, !n ; Hit 'Next' button
        TestsOK("'mIRC Setup(Choose Components)' window appeared, Alt+N was sent.")
    }
    else
        TestsFailed("'mIRC Setup(Choose Components)' window failed to appear")
}


; Test if 'Select Additional Tasks' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, mIRC Setup, Select Additional Tasks, 7
    if not ErrorLevel
    {
        Sleep, 250
        SendInput, !n ; Hit 'Next' button
        TestsOK("'mIRC Setup (Select Additional Tasks)' window appeared, Alt+N was sent.")
    }
    else
        TestsFailed("'mIRC Setup (Select Additional Tasks)' window failed to appear.")
}


; Test if 'Ready to Install' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, mIRC Setup, Ready to Install, 7
    if not ErrorLevel
    {
        Sleep, 250
        SendInput, {ALTDOWN}i{ALTUP} ; Hit 'Install' button
        TestsOK("'mIRC Setup (Ready to Install)' window appeared, Alt+I was sent.")
    }
    else
        TestsFailed("'mIRC Setup (Ready to Install)' window failed to appear.")
}


; Test if can get thru 'Installing'
TestsTotal++
if bContinue
{
    WinWaitActive, mIRC Setup, Installing, 7
    if not ErrorLevel
    {
        Sleep, 250
        OutputDebug, OK: %TestName%:%A_LineNumber%: 'Installing' window appeared, waiting for it to close.`n
        WinWaitClose, mIRC Setup, Installing, 25
        if not ErrorLevel
            TestsOK("'mIRC Setup (Installing)' window went away.")
        else
            TestsFailed("'mIRC Setup (Installing)' window failed to close.")
    }
    else
        TestsFailed("'mIRC Setup (Installing)' window failed to appear.")
}

; Test if 'Completing' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, mIRC Setup, Completing, 7
    if not ErrorLevel
    {
        Sleep, 250
        OutputDebug, OK: %TestName%:%A_LineNumber%: In a sec will send '{ALT DOWN}f' (note: no '{ALT UP}' event).`n
        SendInput, {ALT DOWN}f ; Hit 'Finish' button
        WinWaitClose, mIRC Setup, Completing, 7
        if not ErrorLevel
        {
            TestsOK("'mIRC Setup (Completing)' window appeared, '{ALT DOWN}f' was sent (note: no '{ALT UP}' event) and window was closed (will send '{ALT UP}' in a sec).")
            SendInput, {ALT UP} ; We have to send it anyway
        }
        else
            TestsFailed("'mIRC Setup (Completing)' window failed to close.")
    }
    else
        TestsFailed("'mIRC Setup (Completing)' window failed to appear.")
}


; Check if program exists
TestsTotal++
if bContinue
{
    Sleep, 2000
    RegRead, InstallLocation, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\mIRC, InstallLocation
    if not ErrorLevel
    {
        StringReplace, InstallLocation, InstallLocation, `",, All
        IfExist, %InstallLocation%
            TestsOK("The application has been installed, because '" InstallLocation "' was found.")
        else
            TestsFailed("Something went wrong, can't find '" InstallLocation "'.")
    }
    else
        TestsFailed("Either we can't read from registry or data doesn't exist.")
}
