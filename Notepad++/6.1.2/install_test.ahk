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
TestName = install

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
        TestsOK++
        ControlClick, Button1, Installer Language ; Use ControlClick instead of ControlFocus due to bug no.7098
;        Sleep, 2500 ; Commented out due to bug no.7098

;        ControlFocus, OK, Installer Language ; Send focus to 'OK' button
;        if not ErrorLevel
;        {
;            TestsOK++
;            OutputDebug, OK: %TestName%:%A_LineNumber%: 'Installer Language' window appeared and 'OK' button was focused.`n
;            SendInput, {ENTER} ; We know for sure where do we send Enter 
;            bContinue := true
;        }
;        else
;        {
;            TestsFailed++
;            WinGetTitle, title, A
;            OutputDebug, %TestName%:%A_LineNumber%: Test failed: Failed to focus 'OK' button in 'Installer Language' window. Active window caption: '%title%'.`n
;            bContinue := false
;        } 
    }
    else
    {
        TestsFailed++
        WinGetTitle, title, A
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'Installer Language' window failed to appear. Active window caption: '%title%'.`n
        bContinue := false
    }
}


; Test if 'Welcome to the Notepad++ v 6.1.2 Setup' window appeared
TestsTotal++
if bContinue
{
    SetTitleMatchMode, 1
    WinWaitActive, Notepad, Welcome to the Notepad, 15
    if not ErrorLevel
    {
        Sleep, 250

        TestsOK++
        OutputDebug, OK: %TestName%:%A_LineNumber%: 'Notepad++ v6.1.2 Setup' window with 'Welcome to the Notepad++ v 6.1.2 Setup' appeared.`n
        SendInput, {ALTDOWN}n{ALTUP} ; Hit 'Next' button
        bContinue := true
    }
    else
    {
        TestsFailed++
        WinGetTitle, title, A
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'Notepad++ v6.1.2 Setup' window with 'Welcome to the Notepad++ v 6.1.2 Setup' failed to appear. Active window caption: '%title%'.`n
        bContinue := false
    }
}


; Test if 'License Agreement' window appeared
TestsTotal++
if bContinue
{
    SetTitleMatchMode, 1
    WinWaitActive, Notepad, License Agreement, 15
    if not ErrorLevel
    {
        Sleep, 250

        TestsOK++
        OutputDebug, OK: %TestName%:%A_LineNumber%: 'Notepad++ v6.1.2 Setup' window with 'License Agreement' appeared.`n
        SendInput, {ALTDOWN}a{ALTUP} ; Hit 'I Agree' button
        bContinue := true
    }
    else
    {
        TestsFailed++
        WinGetTitle, title, A
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'Notepad++ v6.1.2 Setup' window with 'License Agreement' failed to appear. Active window caption: '%title%'.`n
        bContinue := false
    }
}


; Test if 'Choose Install Location' window appeared
TestsTotal++
if bContinue
{
    SetTitleMatchMode, 1
    WinWaitActive, Notepad, Choose Install Location, 15
    if not ErrorLevel
    {
        Sleep, 250

        TestsOK++
        OutputDebug, OK: %TestName%:%A_LineNumber%: 'Notepad++ v6.1.2 Setup' window with 'Choose Install Location' appeared.`n
        SendInput, {ALTDOWN}n{ALTUP} ; Hit 'Next' button
        bContinue := true
    }
    else
    {
        TestsFailed++
        WinGetTitle, title, A
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'Notepad++ v6.1.2 Setup' window with 'Choose Install Location' failed to appear. Active window caption: '%title%'.`n
        bContinue := false
    }
}


; Test if 'Check the components' window appeared
TestsTotal++
if bContinue
{
    SetTitleMatchMode, 1
    WinWaitActive, Notepad, Choose Install Location, 15
    if not ErrorLevel
    {
        Sleep, 250

        TestsOK++
        OutputDebug, OK: %TestName%:%A_LineNumber%: 'Notepad++ v6.1.2 Setup' window with 'Check the components' appeared.`n
        SendInput, {ALTDOWN}n{ALTUP} ; Hit 'Next' button
        bContinue := true
    }
    else
    {
        TestsFailed++
        WinGetTitle, title, A
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'Notepad++ v6.1.2 Setup' window with 'Check the components' failed to appear. Active window caption: '%title%'.`n
        bContinue := false
    }
}


; Test if 'Create Shortcut on Desktop' window appeared
TestsTotal++
if bContinue
{
    SetTitleMatchMode, 1
    WinWaitActive, Notepad, Create Shortcut on Desktop, 15
    if not ErrorLevel
    {
        Sleep, 250

        TestsOK++
        OutputDebug, OK: %TestName%:%A_LineNumber%: 'Notepad++ v6.1.2 Setup' window with 'Create Shortcut on Desktop' appeared.`n

        Control, Check, , Button5, Notepad ; Check 'Allow plugins'
        Control, Check, , Button6, Notepad ; Check 'Create Shortcut'
        SendInput, {ALTDOWN}i{ALTUP} ; Hit 'Install' button
        bContinue := true
    }
    else
    {
        TestsFailed++
        WinGetTitle, title, A
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'Notepad++ v6.1.2 Setup' window with 'Create Shortcut on Desktop' failed to appear. Active window caption: '%title%'.`n
        bContinue := false
    }
}


; Test if 'Completing' window appeared
TestsTotal++
if bContinue
{
    SetTitleMatchMode, 1
    WinWaitActive, Notepad, Completing, 20
    if not ErrorLevel
    {
        Sleep, 250

        TestsOK++
        OutputDebug, OK: %TestName%:%A_LineNumber%: 'Notepad++ v6.1.2 Setup' window with 'Completing' appeared.`n

        SendInput, {ALTDOWN}r{ALTUP} ; Uncheck 'Run Notepad'
        SendInput, {ALTDOWN}f{ALTUP} ; Hit 'Finish' button
        bContinue := true
    }
    else
    {
        TestsFailed++
        WinGetTitle, title, A
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'Notepad++ v6.1.2 Setup' window with 'Completing' failed to appear. Active window caption: '%title%'.`n
        bContinue := false
    }
}

;Check if program exists in program files
TestsTotal++
if bContinue
{
    Sleep, 250
    AppExe = %A_ProgramFiles%\Notepad++\notepad++.exe
    IfExist, %AppExe%
    {
        TestsOK++
        OutputDebug, OK: %TestName%:%A_LineNumber%: Should be installed, because '%AppExe%' was found.`n
        bContinue := true
    }
    else
    {
        TestsFailed++
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: Can NOT find '%AppExe%'.`n
        bContinue := false
    }
}
