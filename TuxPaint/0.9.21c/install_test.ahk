/*
 * Designed for TuxPaint 0.9.21c
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

SetupExe = %A_WorkingDir%\Apps\TuxPaint 0.9.21c Setup.exe
bContinue := false
TestName = 1.install

TestsFailed := 0
TestsOK := 0
TestsTotal := 0

; Test if Setup file exists, if so, delete installed files, and run Setup
IfExist, %SetupExe%
{
    ; Get rid of other versions
    IfExist, %A_ProgramFiles%\TuxPaint\unins000.exe
    {
        Process, Close, tuxpaint.exe ; Teminate process
        RunWait, %A_ProgramFiles%\TuxPaint\unins000.exe /silent ; Silently uninstall it
        Sleep, 2500
        RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\TuxPaint
        RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\MicroSoft\Windows\CurrentVersion\Uninstall\Tux Paint_is1
        FileRemoveDir, %A_ProgramFiles%\TuxPaint, 1
        FileRemoveDir, %A_AppData%\TuxPaint, 1
        Sleep, 1000
        IfExist, %A_ProgramFiles%\TuxPaint
        {
            OutputDebug, %TestName%:%A_LineNumber%: Test failed: Failed to delete '%A_ProgramFiles%\TuxPaint'.`n
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


; Test if 'Select Setup Language' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Select Setup Language, Select the language, 15
    if not ErrorLevel
    {
        Sleep, 250

        TestsOK++
        OutputDebug, OK: %TestName%:%A_LineNumber%: 'Select Setup Language' window with 'Select the language' appeared.`n
        SendInput, {ENTER} ; Hit 'OK' button
        bContinue := true
    }
    else
    {
        TestsFailed++
        WinGetTitle, title, A
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'Select Setup Language' window with 'Select the language' failed to appear. Active window caption: '%title%'.`n
        bContinue := false
    }
}

; Test if 'Welcome to the Tux Paint' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Setup - Tux Paint, Welcome to the Tux Paint, 15
    if not ErrorLevel
    {
        Sleep, 250

        TestsOK++
        OutputDebug, OK: %TestName%:%A_LineNumber%: 'Setup - Tux Paint' window with 'Welcome to the Tux Paint' appeared.`n
        SendInput, {ALTDOWN}n{ALTUP} ; Hit 'Next' button
        bContinue := true
    }
    else
    {
        TestsFailed++
        WinGetTitle, title, A
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'Setup - Tux Paint' window with 'Welcome to the Tux Paint' failed to appear. Active window caption: '%title%'.`n
        bContinue := false
    }
}


; Test if 'License Agreement' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Setup - Tux Paint, License Agreement, 7
    if not ErrorLevel
    {
        Sleep, 250

        TestsOK++
        OutputDebug, OK: %TestName%:%A_LineNumber%: 'Setup - Tux Paint' window with 'License Agreement' appeared.`n
        SendInput, {ALTDOWN}a{ALTUP} ; Check 'I accept' radiobutton (Fails to check? Bug 7215)
        Sleep, 1000 ; Wait until 'Next' button is enabled
        ; FIXME: check if button is enabled before sending keystroke
        SendInput, {ALTDOWN}n{ALTUP} ; Hit 'Next' button
        bContinue := true
    }
    else
    {
        TestsFailed++
        WinGetTitle, title, A
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'Setup - Tux Paint' window with 'License Agreement' failed to appear. Active window caption: '%title%'.`n
        bContinue := false
    }
}


; Test if 'Choose Installation Type' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Setup - Tux Paint, Choose Installation Type, 7
    if not ErrorLevel
    {
        Sleep, 250

        TestsOK++
        OutputDebug, OK: %TestName%:%A_LineNumber%: 'Setup - Tux Paint' window with 'Choose Installation Type' appeared.`n
        SendInput, {ALTDOWN}n{ALTUP} ; Hit 'Next' button
        bContinue := true
    }
    else
    {
        TestsFailed++
        WinGetTitle, title, A
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'Setup - Tux Paint' window with 'Choose Installation Type' failed to appear (bug 7215?). Active window caption: '%title%'.`n
        bContinue := false
    }
}


; Test if 'Select Destination Location' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Setup - Tux Paint, Select Destination Location, 7
    if not ErrorLevel
    {
        Sleep, 250

        TestsOK++
        OutputDebug, OK: %TestName%:%A_LineNumber%: 'Setup - Tux Paint' window with 'Select Destination Location' appeared.`n
        SendInput, {ALTDOWN}n{ALTUP} ; Hit 'Next' button
        bContinue := true
    }
    else
    {
        TestsFailed++
        WinGetTitle, title, A
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'Setup - Tux Paint' window with 'Select Destination Location' failed to appear. Active window caption: '%title%'.`n
        bContinue := false
    }
}


; Test if 'Select Start Menu Folder' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Setup - Tux Paint, Select Start Menu Folder, 7
    if not ErrorLevel
    {
        Sleep, 250

        TestsOK++
        OutputDebug, OK: %TestName%:%A_LineNumber%: 'Setup - Tux Paint' window with 'Select Start Menu Folder' appeared.`n
        SendInput, {ALTDOWN}n{ALTUP} ; Hit 'Next' button
        bContinue := true
    }
    else
    {
        TestsFailed++
        WinGetTitle, title, A
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'Setup - Tux Paint' window with 'Select Start Menu Folder' failed to appear. Active window caption: '%title%'.`n
        bContinue := false
    }
}


; Test if 'Select Additional Tasks' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Setup - Tux Paint, Select Additional Tasks, 7
    if not ErrorLevel
    {
        Sleep, 250

        TestsOK++
        OutputDebug, OK: %TestName%:%A_LineNumber%: 'Setup - Tux Paint' window with 'Select Additional Tasks' appeared.`n
        SendInput, {ALTDOWN}n{ALTUP} ; Hit 'Next' button
        bContinue := true
    }
    else
    {
        TestsFailed++
        WinGetTitle, title, A
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'Setup - Tux Paint' window with 'Select Additional Tasks' failed to appear. Active window caption: '%title%'.`n
        bContinue := false
    }
}


; Test if 'Ready to Install' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Setup - Tux Paint, Ready to Install, 7
    if not ErrorLevel
    {
        Sleep, 250

        TestsOK++
        OutputDebug, OK: %TestName%:%A_LineNumber%: 'Setup - Tux Paint' window with 'Ready to Install' appeared.`n
        SendInput, {ALTDOWN}i{ALTUP} ; Hit 'Install' button
        bContinue := true
    }
    else
    {
        TestsFailed++
        WinGetTitle, title, A
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'Setup - Tux Paint' window with 'Ready to Install' failed to appear. Active window caption: '%title%'.`n
        bContinue := false
    }
}


; Test if can get thru 'Installing'
TestsTotal++
if bContinue
{
    WinWaitActive, Setup - Tux Paint, Installing, 7
    if not ErrorLevel
    {
        Sleep, 250
        OutputDebug, OK: %TestName%:%A_LineNumber%: 'Installing' window appeared, waiting for it to close.`n
        WinWaitClose, Setup - Tux Paint, Installing, 25
        if not ErrorLevel
        {
            TestsOK++
            OutputDebug, OK: %TestName%:%A_LineNumber%: 'Setup - Tux Paint' window with 'Installing' went away.`n
            bContinue := true
        }
        else
        {
            TestsFailed++
            WinGetTitle, title, A
            OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'Setup - Tux Paint' window with 'Installing' failed to dissapear. Active window caption: '%title%'.`n
            bContinue := false
        }
    }
    else
    {
        TestsFailed++
        WinGetTitle, title, A
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'Setup - Tux Paint' window with 'Installing' failed to appear. Active window caption: '%title%'.`n
        bContinue := false
    }
}

; Test if 'Completing' window appeared and all checkboxes were unchecked correctly
TestsTotal++
if bContinue
{
    WinWaitActive, Setup - Tux Paint, Completing, 7
    if not ErrorLevel
    {
        Sleep, 250

        OutputDebug, OK: %TestName%:%A_LineNumber%: 'Setup - Tux Paint' window with 'Completing' appeared.`n
        SendInput, {SPACE}{DOWN}{SPACE} ; FIXME: Find better solution. AHK 'Control, Uncheck' won't work here!
        Sleep, 500
        SendInput, {ALTDOWN}f{ALTUP} ; Hit 'Finish' button
        Sleep, 2000
        
        Process, Exist, tuxpaint-config.exe
        if not ErrorLevel
        {
            TestsOK++
            OutputDebug, OK: %TestName%:%A_LineNumber%: Unchecking went OK.`n
            bContinue := true
        }
        else
        {
            TestsFailed++
            OutputDebug, %TestName%:%A_LineNumber%: Test failed: Process 'tuxpaint-config.exe' detected, so failed to uncheck checkboxes in 'Completing'.`n
            Process, Close, tuxpaint-config.exe
            bContinue := false
        }
    }
    else
    {
        TestsFailed++
        WinGetTitle, title, A
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'Setup - Tux Paint' window with 'Completing' failed to appear. Active window caption: '%title%'.`n
        bContinue := false
    }
}


;Check if program exists in program files
TestsTotal++
if bContinue
{
    Sleep, 250
    AppExe = %A_ProgramFiles%\TuxPaint\tuxpaint.exe
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
