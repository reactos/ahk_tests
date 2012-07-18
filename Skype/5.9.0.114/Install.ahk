/*
 * Designed for Skype v5.9 (5.9.0.114)
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

#Include ..\helper_functions.ahk

Module = Skype5.9.0.114:%1%
bContinue := false

if StrLen(A_WorkingDir) = 3 ;No need percent sign here
    SetupExe = %A_WorkingDir%Skype Setup.exe ;We are working in root dir, no need to append slash
else
    SetupExe = %A_WorkingDir%\Skype Setup.exe    

TestsFailed := 0
TestsOK := 0
TestsTotal := 0

; Test if Setup file exists
TestsTotal++
IfExist, %SetupExe%
{
    TestsOK++
    Run %SetupExe%
    bContinue := true
}
else
{
    TestsFailed++
    OutputDebug, FAILED: %Module%:%A_LineNumber%: '%SetupExe%' not found.`n
    bContinue := false
}

; Test if 'Installing Skype' window with 'I agree - next' button can appear
TestsTotal++
if bContinue
{
    WinWaitActive, Installing Skype, &I agree - next, 20
    if not ErrorLevel ;Window is found and it is active
    {
        TestsOK++
        OutputDebug, OK: %Module%:%A_LineNumber%: 'Installing Skype' window with 'I agree - next' button appeared.`n

        Sleep, 1500 ; Sometimes windows flashes 
        SendInput, {ENTER} ; Click 'I agree - next' button
        bContinue := true
    }
    else
    {
        TestsFailed++
        WinGetTitle, title, A
        OutputDebug, FAILED: %Module%:%A_LineNumber%: 'Installing Skype' window with 'I agree - next' button failed to appear. Active window caption: '%title%'.`n
        bContinue := false
    }
}


; Test if 'Install Skype Click to Call' window can appear
TestsTotal++
if bContinue
{
    WinWaitActive, Installing Skype, Install Skype Click to Call, 15
    if not ErrorLevel
    {
        TestsOK++
        OutputDebug, OK: %Module%:%A_LineNumber%: 'Skype Click to Call' window appeared.`n

        Sleep, 1500
        SendInput, {ENTER} ; Hit 'Continue' button
        bContinue := true
    }
    else
    {
        TestsFailed++
        WinGetTitle, title, A
        OutputDebug, FAILED: %Module%:%A_LineNumber%: 'Skype Click to Call' window with 'Continue' button failed to appear. Active window caption: '%title%'.`n
        bContinue := false
    }
}

; Test if 'Skype' window with 'Sign me in' button can appear
TestsTotal++
if bContinue
{
    WinWaitActive, Skype, Close, 180 ; Installing process takes some time
    if not ErrorLevel
    {
        TestsOK++
        OutputDebug, OK: %Module%:%A_LineNumber%: 'Skype' window with 'Sign me in' button appeared.`n

        Process, close, Skype.exe ; Terminate Skype application
        bContinue := true
    }
    else
    {
        TestsFailed++
        WinGetTitle, title, A
        OutputDebug, FAILED: %Module%:%A_LineNumber%: 'Skype' window with 'Sign me in' button failed to appear. Active window caption: '%title%'.`n
        bContinue := false
    }
}

; Test if application is installed
TestsTotal++
if bContinue
{
    Sleep, 2500
    IfExist, %A_ProgramFiles%\Skype\Phone\Skype.exe
    {
        TestsOK++
        OutputDebug, OK: %Module%:%A_LineNumber%: Should be installed, because '%A_ProgramFiles%\Skype\Phone\Skype.exe' was found.`n
    }
    else
    {
        TestsFailed++
        OutputDebug, FAILED: %Module%:%A_LineNumber%: Can NOT find '%A_ProgramFiles%\Skype\Phone\Skype.exe'.`n
    }
}
