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

SetupExe = %A_WorkingDir%\Apps\Notepad++_6.1.2_Setup.exe
bContinue := false
TestName = 1.install

TestsFailed := 0
TestsOK := 0
TestsTotal := 0

; Test if Setup file exists, if so, delete installed files, and run Setup
IfExist, %SetupExe%
{

    ; Get rid of other versions
    IfExist, %A_ProgramFiles%\Notepad++
    {
        RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\Notepad++
        RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\MicroSoft\Windows\CurrentVersion\Uninstall\Notepad++
        FileRemoveDir, %A_ProgramFiles%\Notepad++, 1
        Sleep, 1000
        IfExist, %A_ProgramFiles%\Notepad++
        {
            OutputDebug, %TestName%:%A_LineNumber%: Test failed: Failed to delete '%A_ProgramFiles%\Notepad++'.`n
            bContinue := false
        }
    }
    Run %SetupExe%
    bContinue := true

}
else
{
    OutputDebug, %TestName%:%A_LineNumber%: Test failed: '%SetupExe%' not found.`n
    bContinue := false
}


; Test if can start setup
TestsTotal++
if bContinue
{
    WinWaitActive, Installer Language, Please select a language, 15 ; Wait 15 secs for window to appear
    if not ErrorLevel ;Window is found and it is active
    {
        Sleep, 1000
        SendInput, {ENTER} ; Hit 'OK' button
        TestsOK("'Installer Language' window appeared and 'OK' button was clicked (Sent 'ENTER' to window).")
    }
    else
        TestsFailed("'Installer Language (Please select a language)' window failed to appear.")
}


; Test if 'Welcome to the Notepad++ v 6.1.2 Setup' window appeared
TestsTotal++
if bContinue
{
    SetTitleMatchMode, 1
    WinWaitActive, Notepad, Welcome to the Notepad, 15
    if not ErrorLevel
    {
        Sleep, 700
        SendInput, !n ; Hit 'Next' button
        TestsOK("'Notepad++ v6.1.2 Setup (Welcome to the Notepad++ v 6.1.2 Setup)' window appeared, Alt+N sent.")
    }
    else
        TestsFailed("'Notepad++ v6.1.2 Setup (Welcome to the Notepad++ v 6.1.2 Setup)' window failed to appear.")
}


; Test if 'License Agreement' window appeared
TestsTotal++
if bContinue
{
    SetTitleMatchMode, 1
    WinWaitActive, Notepad, License Agreement, 5
    if not ErrorLevel
    {
        Sleep, 700
        SendInput, !a ; Hit 'I Agree' button
        TestsOK("'Notepad++ v6.1.2 Setup (License Agreement)' window appeared and Alt+A was sent.`")
    }
    else
        TestsFailed("'Notepad++ v6.1.2 Setup (License Agreement)' window failed to appear.")
}


; Test if 'Choose Install Location' window appeared
TestsTotal++
if bContinue
{
    SetTitleMatchMode, 1
    WinWaitActive, Notepad, Choose Install Location, 5
    if not ErrorLevel
    {
        Sleep, 700
        SendInput, !n ; Hit 'Next' button
        TestsOK("'Notepad++ v6.1.2 Setup (Choose Install Location)' window appeared and Alt+N was sent.")
    }
    else
        TestsFailed("'Notepad++ v6.1.2 Setup (Choose Install Location)' window failed to appear.")
}


; Test if 'Check the components' window appeared
TestsTotal++
if bContinue
{
    SetTitleMatchMode, 1
    WinWaitActive, Notepad, Check the components, 5
    if not ErrorLevel
    {
        Sleep, 700
        SendInput, !n ; Hit 'Next' button
        TestsOK("'Notepad++ v6.1.2 Setup (Check the components)' window appeared and Alt+N was sent.")
    }
    else
        TestsFailed("'Notepad++ v6.1.2 Setup (Check the components)' window failed to appear.")
}


; Test if 'Create Shortcut on Desktop' window appeared
TestsTotal++
if bContinue
{
    SetTitleMatchMode, 1
    WinWaitActive, Notepad, Create Shortcut on Desktop, 5
    if not ErrorLevel
    {
        Sleep, 700
        Control, Check, , Button5, Notepad ; Check 'Allow plugins'
        if not ErrorLevel
        {
            Control, Check, , Button6, Notepad ; Check 'Create Shortcut'
            if not ErrorLevel
            {
                SendInput, !i ; Hit 'Install' button
                TestsOK("'Notepad++ v6.1.2 Setup (Create Shortcut on Desktop)' window appeared, 'Allow plugins', 'Create Shortcut' checkboxes were checked and Alt+I was sent.")
            }
            else
                TestsFailed("Unable to check 'Create Shortcut' checkbox in 'Notepad++ v6.1.2 Setup (Create Shortcut on Desktop)' window.")
        }
        else
            TestsFailed("Unable to check 'Allow plugins' checkbox in 'Notepad++ v6.1.2 Setup (Create Shortcut on Desktop)' window.")
    }
    else
        TestsFailed("'Notepad++ v6.1.2 Setup (Create Shortcut on Desktop)' window failed to appear.")
}

; Test if can get thru 'Installing' window
TestsTotal++
if bContinue
{
    WinWaitActive, Notepad, Installing, 7
    if not ErrorLevel
    {
        OutputDebug, OK: %TestName%:%A_LineNumber%: 'Installing' window appeared, waiting for it to close.`n
        WinWaitClose, Notepad, Installing, 25
        if not ErrorLevel
        {
            TestsOK("'Notepad++ v6.1.2 Setup (Installing)' went away.")
        }
        else
            TestsFailed("'Notepad++ v6.1.2 Setup (Installing)' window failed to dissapear.")
    }
    else
        TestsFailed("'Notepad++ v6.1.2 Setup (Installing)' window failed to appear.")
}


; Test if 'Completing' window appeared
TestsTotal++
if bContinue
{
    SetTitleMatchMode, 1
    WinWaitActive, Notepad, Completing, 5
    if not ErrorLevel
    {
        Sleep, 700
        SendInput, !r ; Uncheck 'Run Notepad'
        Sleep, 1000
        SendInput, !f ; Hit 'Finish' button
        TestsOK("'Notepad++ v6.1.2 Setup (Completing)' window appeared, Alt+R and Alt+F were sent.")
    }
    else
        TestsFailed("'Notepad++ v6.1.2 Setup (Completing)' window failed to appear.")
}

; Check if program exists
TestsTotal++
if bContinue
{
    Sleep, 700
    AppExe = %A_ProgramFiles%\Notepad++\notepad++.exe
    IfExist, %AppExe%
        TestsOK("Should be installed, because '" AppExe "' was found.")
    else
        TestsFailed("Can NOT find '" AppExe "'.")
}
