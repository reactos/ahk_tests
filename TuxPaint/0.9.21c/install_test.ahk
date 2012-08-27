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
        SendInput, {ENTER} ; Hit 'OK' button
        TestsOK("'Select Setup Language (Select the language')' window appeared and 'ENTER' was sent.")
    }
    else
        TestsFailed("'Select Setup Language (Select the language')' window failed to appear.")
}

; Test if 'Welcome to the Tux Paint' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Setup - Tux Paint, Welcome to the Tux Paint, 15
    if not ErrorLevel
    {
        Sleep, 250
        SendInput, !n ; Hit 'Next' button
        TestsOK("'Setup - Tux Paint (Welcome to the Tux Paint)' window appeared, Alt+N was sent.")
    }
    else
        TestsFailed("'Setup - Tux Paint (Welcome to the Tux Paint)' window failed to appear.")
}


; Test if 'License Agreement' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Setup - Tux Paint, License Agreement, 7
    if not ErrorLevel
    {
        Sleep, 250
        SendInput, !a ; Check 'I accept' radiobutton (Fails to check? Bug 7215)
        Sleep, 1000 ; Wait until 'Next' button is enabled
        SendInput, !n ; Hit 'Next' button
        TestsOK("'Setup - Tux Paint (License Agreement)' window appeared, Alt+A and Alt+N were sent.")
    }
    else
        TestsFailed("'Setup - Tux Paint (License Agreement)' window failed to appear.")
}


; Test if 'Choose Installation Type' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Setup - Tux Paint, Choose Installation Type, 7
    if not ErrorLevel
    {
        Sleep, 250
        SendInput, !n ; Hit 'Next' button
        TestsOK("'Setup - Tux Paint (Choose Installation Type)' window appeared, Alt+N was sent.")
    }
    else
        TestsFailed("'Setup - Tux Paint (Choose Installation Type)' window failed to appear (bug 7215?).")
}


; Test if 'Select Destination Location' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Setup - Tux Paint, Select Destination Location, 7
    if not ErrorLevel
    {
        Sleep, 250
        SendInput, !n ; Hit 'Next' button
        TestsOK("'Setup - Tux Paint (Select Destination Location)' window appeared, Alt+N was sent.")
    }
    else
        TestsFailed("'Setup - Tux Paint (Select Destination Location)' window failed to appear.")
}


; Test if 'Select Start Menu Folder' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Setup - Tux Paint, Select Start Menu Folder, 7
    if not ErrorLevel
    {
        Sleep, 250
        SendInput, !n ; Hit 'Next' button
        TestsOK("'Setup - Tux Paint (Select Start Menu Folder)' window appeared, Alt+N was sent.")
    }
    else
        TestsFailed("'Setup - Tux Paint (Select Start Menu Folder)' window failed to appear.")
}


; Test if 'Select Additional Tasks' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Setup - Tux Paint, Select Additional Tasks, 7
    if not ErrorLevel
    {
        Sleep, 250
        SendInput, !n ; Hit 'Next' button
        TestsOK("'Setup - Tux Paint (Select Additional Tasks)' window appeared, Alt+N was sent.")
    }
    else
        TestsFailed("'Setup - Tux Paint (Select Additional Tasks)' window failed to appear.")
}


; Test if 'Ready to Install' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Setup - Tux Paint, Ready to Install, 7
    if not ErrorLevel
    {
        Sleep, 250
        SendInput, !i ; Hit 'Install' button
        TestsOK("'Setup - Tux Paint (Ready to Install)' window appeared, Alt+I was sent.")
    }
    else
        TestsFailed("'Setup - Tux Paint (Ready to Install)' window failed to appear.")
}


; Test if can get thru 'Installing'
TestsTotal++
if bContinue
{
    WinWaitActive, Setup - Tux Paint, Installing, 7
    if not ErrorLevel
    {
        Sleep, 250
        OutputDebug, OK: %TestName%:%A_LineNumber%: 'Setup - Tux Paint (Installing)' window appeared, waiting for it to close.`n
        WinWaitClose, Setup - Tux Paint, Installing, 25
        if not ErrorLevel
            TestsOK("'Setup - Tux Paint (Installing)' window went away.")
        else
            TestsFailed("'Setup - Tux Paint (Installing)' window failed to close.")
    }
    else
        TestsFailed("'Setup - Tux Paint (Installing)' window failed to appear.")
}

; Test if 'Completing' window appeared and all checkboxes were unchecked correctly
TestsTotal++
if bContinue
{
    WinWaitActive, Setup - Tux Paint, Completing, 7
    if not ErrorLevel
    {
        Sleep, 250
        SendInput, {SPACE}{DOWN}{SPACE} ; FIXME: Find better solution. AHK 'Control, Uncheck' won't work here!
        Sleep, 500
        SendInput, !f ; Hit 'Finish' button
        Sleep, 2000
        
        Process, Exist, tuxpaint-config.exe
        if not ErrorLevel
            TestsOK("'Setup - Tux Paint (Completing)' window appeared, checkbox 'Launch Tux Paint Config' unchecked, 'Finish' button clicked.")
        else
        {
            TestsFailed("Process 'tuxpaint-config.exe' detected, so failed to uncheck checkboxes in 'Setup - Tux Paint (Completing)' window.")
            Process, Close, tuxpaint-config.exe
        }
    }
    else
        TestsFailed("'Setup - Tux Paint (Completing)' window failed to appear.")
}


;Check if program exists in program files
TestsTotal++
if bContinue
{
    Sleep, 250
    AppExe = %A_ProgramFiles%\TuxPaint\tuxpaint.exe
    IfExist, %AppExe%
        TestsOK("Should be installed, because '" AppExe "' was found.")
    else
        TestsFailed("Can NOT find '" AppExe "'.")
}
