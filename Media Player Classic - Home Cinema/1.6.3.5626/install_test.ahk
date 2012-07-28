/*
 * Designed for Media Player Classic - Home Cinema 1.6.3.5626
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

SetupExe = %A_WorkingDir%\Apps\MPC-HC.1.6.3.5626.x86_Setup.exe
bContinue := false
TestName = 1.install

TestsFailed := 0
TestsOK := 0
TestsTotal := 0

; Test if Setup file exists, if so, delete installed files, and run Setup
IfExist, %SetupExe%
{
    ; Get rid of other versions
    IfExist, %A_ProgramFiles%\MPC-HC\mpc-hc.exe
    {
        Process, Close, mpc-hc.exe ; Teminate process
        Sleep, 1000
        RunWait, %A_ProgramFiles%\MPC-HC\mpc-hc.exe /unregall ; Unregister all file associations
        Sleep, 2500
        RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\MicroSoft\Windows\CurrentVersion\Uninstall\{2624B969-7135-4EB1-B0F6-2D8C397B45F7}_is1
        FileRemoveDir, %A_ProgramFiles%\MPC-HC, 1
        FileRemoveDir, %A_AppData%\Media Player Classic, 1
        Sleep, 1000
        IfExist, %A_ProgramFiles%\MPC-HC
        {
            OutputDebug, %TestName%:%A_LineNumber%: Test failed: Failed to delete '%A_ProgramFiles%\MPC-HC'.`n
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


; Test if 'Setup - MPC-HC' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Setup - MPC-HC, This will install, 8
    if not ErrorLevel
    {
        Sleep, 250

        TestsOK++
        OutputDebug, OK: %TestName%:%A_LineNumber%: 'Setup - MPC-HC' window with 'This will install' appeared.`n
        SendInput, {ALTDOWN}n{ALTUP} ; Hit 'Next' button
        bContinue := true
    }
    else
    {
        TestsFailed++
        WinGetTitle, title, A
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'Setup - MPC-HC' window with 'This will install' failed to appear. Active window caption: '%title%'.`n
        bContinue := false
    }
}

; Test if 'License Agreement' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Setup - MPC-HC, License Agreement, 7
    if not ErrorLevel
    {
        Sleep, 250

        TestsOK++
        OutputDebug, OK: %TestName%:%A_LineNumber%: 'Setup - MPC-HC' window with 'License Agreement' appeared.`n
        SendInput, {ALTDOWN}a{ALTUP} ; Check 'I accept' radiobutton
        SendInput, {ALTDOWN}n{ALTUP} ; Hit 'Next' button
        bContinue := true
    }
    else
    {
        TestsFailed++
        WinGetTitle, title, A
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'Setup - MPC-HC' window with 'License Agreement' failed to appear. Active window caption: '%title%'.`n
        bContinue := false
    }
}


; Test if 'Select Destination Location' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Setup - MPC-HC, Select Destination Location, 7
    if not ErrorLevel
    {
        Sleep, 250

        TestsOK++
        OutputDebug, OK: %TestName%:%A_LineNumber%: 'Setup - MPC-HC' window with 'Select Destination Location' appeared.`n
        SendInput, {ALTDOWN}n{ALTUP} ; Hit 'Next' button
        bContinue := true
    }
    else
    {
        TestsFailed++
        WinGetTitle, title, A
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'Setup - MPC-HC' window with 'Select Destination Location' failed to appear. Active window caption: '%title%'.`n
        bContinue := false
    }
}


; Test if 'Select Components' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Setup - MPC-HC, Select Components, 7
    if not ErrorLevel
    {
        Sleep, 250

        TestsOK++
        OutputDebug, OK: %TestName%:%A_LineNumber%: 'Setup - MPC-HC' window with 'Select Components' appeared.`n
        SendInput, {ALTDOWN}n{ALTUP} ; Hit 'Next' button
        bContinue := true
    }
    else
    {
        TestsFailed++
        WinGetTitle, title, A
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'Setup - MPC-HC' window with 'Select Components' failed to appear. Active window caption: '%title%'.`n
        bContinue := false
    }
}


; Test if 'Select Start Menu Folder' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Setup - MPC-HC, Select Start Menu Folder, 7
    if not ErrorLevel
    {
        Sleep, 250

        TestsOK++
        OutputDebug, OK: %TestName%:%A_LineNumber%: 'Setup - MPC-HC' window with 'Select Start Menu Folder' appeared.`n
        SendInput, {ALTDOWN}n{ALTUP} ; Hit 'Next' button
        bContinue := true
    }
    else
    {
        TestsFailed++
        WinGetTitle, title, A
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'Setup - MPC-HC' window with 'Select Start Menu Folder' failed to appear. Active window caption: '%title%'.`n
        bContinue := false
    }
}


; Test if 'Select Additional Tasks' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Setup - MPC-HC, Select Additional Tasks, 7
    if not ErrorLevel
    {
        Sleep, 250

        TestsOK++
        OutputDebug, OK: %TestName%:%A_LineNumber%: 'Setup - MPC-HC' window with 'Select Additional Tasks' appeared.`n
        SendInput, {ALTDOWN}q{ALTUP} ; Check 'Create a Quick Launch icon' checkbox //We want to test more things
        SendInput, {ALTDOWN}n{ALTUP} ; Hit 'Next' button
        bContinue := true
    }
    else
    {
        TestsFailed++
        WinGetTitle, title, A
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'Setup - MPC-HC' window with 'Select Additional Tasks' failed to appear. Active window caption: '%title%'.`n
        bContinue := false
    }
}


; Test if 'Ready to Install' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Setup - MPC-HC, Ready to Install, 7
    if not ErrorLevel
    {
        Sleep, 250

        TestsOK++
        OutputDebug, OK: %TestName%:%A_LineNumber%: 'Setup - MPC-HC' window with 'Ready to Install' appeared.`n
        SendInput, {ALTDOWN}i{ALTUP} ; Hit 'Install' button
        bContinue := true
    }
    else
    {
        TestsFailed++
        WinGetTitle, title, A
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'Setup - MPC-HC' window with 'Ready to Install' failed to appear. Active window caption: '%title%'.`n
        bContinue := false
    }
}


; Test if can get thru 'Installing'
TestsTotal++
if bContinue
{
    WinWaitActive, Setup - MPC-HC, Installing, 7
    if not ErrorLevel
    {
        Sleep, 250
        OutputDebug, OK: %TestName%:%A_LineNumber%: 'Installing' window appeared, waiting for it to close.`n
        WinWaitClose, Setup - MPC-HC, Installing, 25
        if not ErrorLevel
        {
            TestsOK++
            OutputDebug, OK: %TestName%:%A_LineNumber%: 'Setup - MPC-HC' window with 'Installing' went away.`n
            bContinue := true
        }
        else
        {
            TestsFailed++
            WinGetTitle, title, A
            OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'Setup - MPC-HC' window with 'Installing' failed to dissapear. Active window caption: '%title%'.`n
            bContinue := false
        }
    }
    else
    {
        TestsFailed++
        WinGetTitle, title, A
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'Setup - MPC-HC' window with 'Installing' failed to appear. Active window caption: '%title%'.`n
        bContinue := false
    }
}

; Test if 'Completing' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Setup - MPC-HC, Completing, 7
    if not ErrorLevel
    {
        Sleep, 250

        TestsOK++
        OutputDebug, OK: %TestName%:%A_LineNumber%: 'Setup - MPC-HC' window with 'Completing' appeared.`n
        SendInput, {ALTDOWN}f{ALTUP} ; Hit 'Finish' button
        bContinue := true
    }
    else
    {
        TestsFailed++
        WinGetTitle, title, A
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'Setup - MPC-HC' window with 'Completing' failed to appear. Active window caption: '%title%'.`n
        bContinue := false
    }
}


;Check if program exists in program files
TestsTotal++
if bContinue
{
    Sleep, 1500
    AppExe = %A_ProgramFiles%\MPC-HC\mpc-hc.exe
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
