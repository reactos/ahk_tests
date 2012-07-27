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

SetupExe = %A_WorkingDir%\Apps\mIRC_7.25_Setup.exe
bContinue := false
TestName = 1.install

TestsFailed := 0
TestsOK := 0
TestsTotal := 0

; Test if Setup file exists, if so, delete installed files, and run Setup
IfExist, %SetupExe%
{
    ; Get rid of other versions
    IfExist, %A_ProgramFiles%\mIRC\uninstall.exe
    {
        Process, Close, mirc.exe ; Teminate process
        RunWait, %A_ProgramFiles%\mIRC\uninstall.exe /S ; Silently uninstall it
        Sleep, 2500
        RegDelete, HKEY_CURRENT_USER, SOFTWARE\mIRC
        RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\MicroSoft\Windows\CurrentVersion\Uninstall\mIRC
        FileRemoveDir, %A_ProgramFiles%\mIRC, 1
        FileRemoveDir, %A_AppData%\mIRC, 1
        Sleep, 1000
        IfExist, %A_ProgramFiles%\mIRC
        {
            OutputDebug, %TestName%:%A_LineNumber%: Test failed: Failed to delete '%A_ProgramFiles%\mIRC'.`n
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


; Test if 'Welcome to the Mozilla Firefox' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, mIRC Setup, Welcome to the mIRC, 15
    if not ErrorLevel
    {
        Sleep, 250

        TestsOK++
        OutputDebug, OK: %TestName%:%A_LineNumber%: 'mIRC Setup' window with 'Welcome to the mIRC' appeared.`n
        SendInput, {ALTDOWN}n{ALTUP} ; Hit 'Next' button
        bContinue := true
    }
    else
    {
        TestsFailed++
        WinGetTitle, title, A
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'mIRC Setup' window with 'Welcome to the mIRC' failed to appear. Active window caption: '%title%'.`n
        bContinue := false
    }
}


; Test if 'License Agreement' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, mIRC Setup, License Agreement, 7
    if not ErrorLevel
    {
        Sleep, 250

        TestsOK++
        OutputDebug, OK: %TestName%:%A_LineNumber%: 'mIRC Setup' window with 'License Agreement' appeared.`n
        SendInput, {ALTDOWN}a{ALTUP} ; Hit 'I Agree' button
        bContinue := true
    }
    else
    {
        TestsFailed++
        WinGetTitle, title, A
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'mIRC Setup' window with 'License Agreement' failed to appear. Active window caption: '%title%'.`n
        bContinue := false
    }
}


; Test if 'Choose Install Location' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, mIRC Setup, Choose Install Location, 7
    if not ErrorLevel
    {
        Sleep, 250

        TestsOK++
        OutputDebug, OK: %TestName%:%A_LineNumber%: 'mIRC Setup' window with 'Choose Install Location' appeared.`n
        SendInput, {ALTDOWN}n{ALTUP} ; Hit 'Next' button
        bContinue := true
    }
    else
    {
        TestsFailed++
        WinGetTitle, title, A
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'mIRC Setup' window with 'Choose Install Location' failed to appear. Active window caption: '%title%'.`n
        bContinue := false
    }
}


; Test if 'Choose Components' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, mIRC Setup, Choose Components, 7
    if not ErrorLevel
    {
        Sleep, 250

        TestsOK++
        OutputDebug, OK: %TestName%:%A_LineNumber%: 'mIRC Setup' window with 'Choose Components' appeared.`n
        SendInput, {ALTDOWN}n{ALTUP} ; Hit 'Next' button
        bContinue := true
    }
    else
    {
        TestsFailed++
        WinGetTitle, title, A
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'mIRC Setup' window with 'Choose Components' failed to appear. Active window caption: '%title%'.`n
        bContinue := false
    }
}


; Test if 'Select Additional Tasks' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, mIRC Setup, Select Additional Tasks, 7
    if not ErrorLevel
    {
        Sleep, 250

        TestsOK++
        OutputDebug, OK: %TestName%:%A_LineNumber%: 'mIRC Setup' window with 'Select Additional Tasks' appeared.`n
        SendInput, {ALTDOWN}n{ALTUP} ; Hit 'Next' button
        bContinue := true
    }
    else
    {
        TestsFailed++
        WinGetTitle, title, A
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'mIRC Setup' window with 'Select Additional Tasks' failed to appear. Active window caption: '%title%'.`n
        bContinue := false
    }
}


; Test if 'Ready to Install' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, mIRC Setup, Ready to Install, 7
    if not ErrorLevel
    {
        Sleep, 250

        TestsOK++
        OutputDebug, OK: %TestName%:%A_LineNumber%: 'mIRC Setup' window with 'Ready to Install' appeared.`n
        SendInput, {ALTDOWN}i{ALTUP} ; Hit 'Install' button
        bContinue := true
    }
    else
    {
        TestsFailed++
        WinGetTitle, title, A
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'mIRC Setup' window with 'Ready to Install' failed to appear. Active window caption: '%title%'.`n
        bContinue := false
    }
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
        {
            TestsOK++
            OutputDebug, OK: %TestName%:%A_LineNumber%: 'mIRC Setup' window with 'Installing' went away.`n
            bContinue := true
        }
        else
        {
            TestsFailed++
            WinGetTitle, title, A
            OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'mIRC Setup' window with 'Installing' failed to dissapear. Active window caption: '%title%'.`n
            bContinue := false
        }
    }
    else
    {
        TestsFailed++
        WinGetTitle, title, A
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'mIRC Setup' window with 'Installing' failed to appear. Active window caption: '%title%'.`n
        bContinue := false
    }
}

; Test if 'Completing' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, mIRC Setup, Completing, 7
    if not ErrorLevel
    {
        Sleep, 250

        TestsOK++
        OutputDebug, OK: %TestName%:%A_LineNumber%: 'mIRC Setup' window with 'Completing' appeared.`n
        SendInput, {ALTDOWN}f{ALTUP} ; Hit 'Finish' button
        bContinue := true
    }
    else
    {
        TestsFailed++
        WinGetTitle, title, A
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'mIRC Setup' window with 'Completing' failed to appear. Active window caption: '%title%'.`n
        bContinue := false
    }
}


;Check if program exists in program files
TestsTotal++
if bContinue
{
    Sleep, 250
    AppExe = %A_ProgramFiles%\mIRC\mirc.exe
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
