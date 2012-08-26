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
        SendInput, {ENTER} ; Hit 'OK' button
        TestsOK("'Select Setup Language (Select the language)' window appeared, 'ENTER' was sent.")
    }
    else
        TestsFailed("'Select Setup Language (Select the language)' window failed to appear.")
}


; Test if 'Setup - MPC-HC' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Setup - MPC-HC, This will install, 8
    if not ErrorLevel
    {
        Sleep, 250
        SendInput, !n ; Hit 'Next' button
        TestsOK("'Setup - MPC-HC (This will install)' window appeared, Alt+N was sent.")
    }
    else
        TestsFailed("'Setup - MPC-HC (This will install)' window failed to appear.")
}

; Test if 'License Agreement' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Setup - MPC-HC, License Agreement, 7
    if not ErrorLevel
    {
        Sleep, 250
        SendInput, !a ; Check 'I accept' radiobutton
        SendInput, !n ; Hit 'Next' button
        TestsOK("'Setup - MPC-HC (License Agreement)' window appeared, Alt+A and Alt+N was sent.")
    }
    else
        TestsFailed("'Setup - MPC-HC (License Agreement)' window failed to appear.")
}


; Test if 'Select Destination Location' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Setup - MPC-HC, Select Destination Location, 7
    if not ErrorLevel
    {
        Sleep, 250
        SendInput, !n ; Hit 'Next' button
        TestsOK("'Setup - MPC-HC (Select Destination Location)' window appeared, Alt+N was sent.")
    }
    else
        TestsFailed("'Setup - MPC-HC (Select Destination Location)' window failed to appear.")
}


; Test if 'Select Components' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Setup - MPC-HC, Select Components, 7
    if not ErrorLevel
    {
        Sleep, 250
        SendInput, !n ; Hit 'Next' button
        TestsOK("'Setup - MPC-HC (Select Components)' window appeared, Alt+N was sent.")
    }
    else
        TestsFailed("'Setup - MPC-HC (Select Components)' window failed to appear.")
}


; Test if 'Select Start Menu Folder' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Setup - MPC-HC, Select Start Menu Folder, 7
    if not ErrorLevel
    {
        Sleep, 250
        SendInput, !n ; Hit 'Next' button
        TestsOK("'Setup - MPC-HC (Select Start Menu Folder)' window appeared, Alt+N was sent.")
    }
    else
        TestsFailed("'Setup - MPC-HC (Select Start Menu Folder)' window failed to appear.")
}


; Test if 'Select Additional Tasks' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Setup - MPC-HC, Select Additional Tasks, 7
    if not ErrorLevel
    {
        Sleep, 250
        SendInput, !q ; Check 'Create a Quick Launch icon' checkbox //We want to test more things
        SendInput, !n ; Hit 'Next' button
        TestsOK("'Setup - MPC-HC (Select Additional Tasks)' window appeared, Alt+Q and Alt+N was sent.")
    }
    else
        TestsFailed("'Setup - MPC-HC (Select Additional Tasks)' window failed to appear.")
}


; Test if 'Ready to Install' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Setup - MPC-HC, Ready to Install, 7
    if not ErrorLevel
    {
        Sleep, 250
        SendInput, !i ; Hit 'Install' button
        TestsOK("'Setup - MPC-HC (Ready to Install)' window appeared and Alt+I was sent.")
    }
    else
        TestsFailed("'Setup - MPC-HC (Ready to Install)' window failed to appear.")
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
            TestsOK("'Setup - MPC-HC (Installing)' window went away.")
        else
            TestsFailed("'Setup - MPC-HC (Installing)' window failed to dissapear.")
    }
    else
        TestsFailed("'Setup - MPC-HC (Installing)' window failed to appear.")
}

; Test if 'Completing' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Setup - MPC-HC, Completing, 7
    if not ErrorLevel
    {
        Sleep, 250
        SendInput, !f ; Hit 'Finish' button
        TestsOK("'Setup - MPC-HC (Completing)' window appeared, Alt+F was sent.")
    }
    else
        TestsFailed("'Setup - MPC-HC (Completing)' window failed to appear.")
}


; Check if program exists
TestsTotal++
if bContinue
{
    Sleep, 1500
    AppExe = %A_ProgramFiles%\MPC-HC\mpc-hc.exe
    IfExist, %AppExe%
        TestsOK("Should be installed, because '" AppExe "' was found.")
    else
        TestsFailed("Can NOT find '" AppExe "'.")
}
