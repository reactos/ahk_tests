/*
 * Designed for Mozilla Firefox 12.0
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

SetupExe = %A_WorkingDir%\Apps\Mozilla Firefox 12.0 Setup.exe
bContinue := false
TestName = 1.install

TestsFailed := 0
TestsOK := 0
TestsTotal := 0

; Test if Setup file exists, if so, delete installed files, and run Setup
IfExist, %SetupExe%
{

    ; Get rid of other versions
    IfExist, %A_ProgramFiles%\Mozilla Firefox\uninstall\helper.exe
    {
        Process, Close, firefox.exe ; Teminate process
        Run, %A_ProgramFiles%\Mozilla Firefox\uninstall\helper.exe /S ; Silently uninstall it
        RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\Mozilla
        RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\mozilla.org
        RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\MicroSoft\Windows\CurrentVersion\Uninstall\Mozilla Firefox
        FileRemoveDir, %A_ProgramFiles%\Mozilla Firefox, 1
        FileRemoveDir, %A_AppData%\Mozilla, 1
        Sleep, 1000
        IfExist, %A_ProgramFiles%\Mozilla Firefox
        {
            OutputDebug, %TestName%:%A_LineNumber%: Test failed: Failed to delete '%A_ProgramFiles%\Mozilla Firefox'.`n
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
    SetTitleMatchMode, 1
    WinWaitActive, Extracting, Cancel, 7 ; Wait 7 secs for window to appear
    if not ErrorLevel ;Window is found and it is active
    {
        OutputDebug, OK: %TestName%:%A_LineNumber%: 'Extracting' window appeared, waiting for it to close.`n
        WinWaitClose, Extracting, Cancel, 15
        if not ErrorLevel
        {
            
            TestsOK++
            OutputDebug, OK: %TestName%:%A_LineNumber%: 'Extracting' window appeared and went away.`n
            bContinue := true
        }
        else
        {
            TestsFailed++
            WinGetTitle, title, A
            OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'Extracting' window failed to dissapear. Active window caption: '%title%'.`n
            bContinue := false
        }
    }
    else
    {
        TestsFailed++
        WinGetTitle, title, A
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'Extracting' window failed to appear. Active window caption: '%title%'.`n
        bContinue := false
    }
}


; Test if 'Welcome to the Mozilla Firefox' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Mozilla Firefox Setup, Welcome to the Mozilla Firefox, 15
    if not ErrorLevel
    {
        Sleep, 250

        TestsOK++
        OutputDebug, OK: %TestName%:%A_LineNumber%: 'Mozilla Firefox Setup' window with 'Welcome to the Mozilla Firefox' appeared.`n
        SendInput, {ALTDOWN}n{ALTUP} ; Hit 'Next' button
        bContinue := true
    }
    else
    {
        TestsFailed++
        WinGetTitle, title, A
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'Mozilla Firefox Setup' window with 'Welcome to the Mozilla Firefox' failed to appear. Active window caption: '%title%'.`n
        bContinue := false
    }
}


; Test if 'Setup Type' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Mozilla Firefox Setup, Setup Type, 7
    if not ErrorLevel
    {
        Sleep, 250

        TestsOK++
        OutputDebug, OK: %TestName%:%A_LineNumber%: 'Mozilla Firefox Setup' window with 'Setup Type' appeared.`n
        SendInput, {ALTDOWN}n{ALTUP} ; Hit 'Next' button
        bContinue := true
    }
    else
    {
        TestsFailed++
        WinGetTitle, title, A
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'Mozilla Firefox Setup' window with 'Setup Type' failed to appear. Active window caption: '%title%'.`n
        bContinue := false
    }
}


; Test if 'Summary' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Mozilla Firefox Setup, Summary, 7
    if not ErrorLevel
    {
        Sleep, 250

        TestsOK++
        OutputDebug, OK: %TestName%:%A_LineNumber%: 'Mozilla Firefox Setup' window with 'Summary' appeared.`n
        SendInput, {ALTDOWN}i{ALTUP} ; Hit 'Install' button
        bContinue := true
    }
    else
    {
        TestsFailed++
        WinGetTitle, title, A
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'Mozilla Firefox Setup' window with 'Summary' failed to appear. Active window caption: '%title%'.`n
        bContinue := false
    }
}


; Test if can get thru 'Installing'
TestsTotal++
if bContinue
{
    WinWaitActive, Mozilla Firefox Setup, Installing, 7
    if not ErrorLevel
    {
        Sleep, 250
        OutputDebug, OK: %TestName%:%A_LineNumber%: 'Extracting' window appeared, waiting for it to close.`n
        WinWaitClose, Mozilla Firefox Setup, Installing, 25
        if not ErrorLevel
        {
            TestsOK++
            OutputDebug, OK: %TestName%:%A_LineNumber%: 'Mozilla Firefox Setup' window with 'Installing' went away.`n
            bContinue := true
        }
        else
        {
            TestsFailed++
            WinGetTitle, title, A
            OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'Mozilla Firefox Setup' window with 'Installing' failed to dissapear. Active window caption: '%title%'.`n
            bContinue := false
        }
    }
    else
    {
        TestsFailed++
        WinGetTitle, title, A
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'Mozilla Firefox Setup' window with 'Summary' failed to appear. Active window caption: '%title%'.`n
        bContinue := false
    }
}


; Test if 'Completing' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Mozilla Firefox Setup, Completing, 7
    if not ErrorLevel
    {
        Sleep, 250

        TestsOK++
        OutputDebug, OK: %TestName%:%A_LineNumber%: 'Mozilla Firefox Setup' window with 'Completing' appeared.`n
        SendInput, {ALTDOWN}l{ALTUP} ; Uncheck 'Lounch Firefox now'
        SendInput, {ALTDOWN}f{ALTUP} ; Hit 'Finish' button
        bContinue := true
    }
    else
    {
        TestsFailed++
        WinGetTitle, title, A
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'Mozilla Firefox Setup' window with 'Completing' failed to appear. Active window caption: '%title%'.`n
        bContinue := false
    }
}


;Check if program exists in program files
TestsTotal++
if bContinue
{
    Sleep, 250
    AppExe = %A_ProgramFiles%\Mozilla Firefox\firefox.exe
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
