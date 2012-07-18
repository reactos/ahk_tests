/*
 * Designed for Opera 9.64
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

Module = Opera_9.64:%1%
bContinue := false

if StrLen(A_WorkingDir) = 3 ;No need percent sign here
    SetupExe = %A_WorkingDir%Opera Setup.exe ;We are working in root dir, no need to append slash
else
    SetupExe = %A_WorkingDir%\Opera Setup.exe

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

; Test if can start setup
TestsTotal++
if bContinue
{
    WinWaitActive, Choose Setup Language, Select the language, 15 ; Wait 15 secs for window to appear
    if not ErrorLevel ;Window is found and it is active
    {
        TestsOK++
        OutputDebug, OK: %Module%:%A_LineNumber%: 'Choose Setup Language' window appeared.`n
        Sleep, 2500

        SendInput, {ENTER} ;Hit 'OK' button in 'Choose Setup Language' window
        bContinue := true
    }
    else
    {
        TestsFailed++
        WinGetTitle, title, A
        OutputDebug, FAILED: %Module%:%A_LineNumber%: 'Choose Setup Language' window failed to appear. Active window caption: '%title%'.`n
        bContinue := false
    }
}

; Test if window with 'Start Setup' button can appear
TestsTotal++
if bContinue
{
    WinWaitActive, Opera 9.64 - InstallShield Wizard, Start, 25 ; Same exe: 'Start set-up' in ROS, 'Start Setup' in Windows
    if not ErrorLevel
    {
        TestsOK++
        OutputDebug, OK: %Module%:%A_LineNumber%: 'Opera 9.64 - InstallShield Wizard' window with 'Start Setup' button appeared.`n

        Sleep, 2500 ; window flashes, so let it to appear correctly
        SendInput, {ALTDOWN)
        Sleep, 500 ; Opera setup requires those sleeps
        SendInput, s
        Sleep, 500
        SendInput, {ALTUP} ;Hit 'Start Setup' button in 'Opera 9.64 - InstallShield Wizard' window
        bContinue := true
    }
    else
    {
        TestsFailed++
        WinGetTitle, title, A
        OutputDebug, FAILED: %Module%:%A_LineNumber%: 'Opera 9.64 - InstallShield Wizard' window with 'Start Setup' button failed to appear. Active window caption: '%title%'.`n
        bContinue := false
    }
}

; Test if 'Opera Browser Licence Agreement' window can appear
TestsTotal++
if bContinue
{
    WinWaitActive, Opera 9.64 - InstallShield Wizard, Installation of Opera requires, 20
    if not ErrorLevel
    {
        TestsOK++
        OutputDebug, OK: %Module%:%A_LineNumber%: 'Opera 9.64 - InstallShield Wizard' with 'Installation of Opera requires' appeared.`n

        Sleep, 2500
        SendInput, {ALTDOWN}a{ALTUP} ;Hit 'I Accept' button in 'Opera Browser Licence Agreement' window
        bContinue := true
    }
    else
    {
        TestsFailed++
        WinGetTitle, title, A
        OutputDebug, FAILED: %Module%:%A_LineNumber%: 'Opera 9.64 - InstallShield Wizard' with 'Installation of Opera requires' failed to appear. Active window caption: '%title%'.`n
        bContinue := false
    }
}

; Test if 'Welcome to the Opera installer' can appear
TestsTotal++
if bContinue
{
    WinWaitActive, Opera 9.64 - InstallShield Wizard, Welcome to the Opera, 15
    if not ErrorLevel
    {
        TestsOK++
        OutputDebug, OK: %Module%:%A_LineNumber%: 'Opera 9.64 - InstallShield Wizard' window with 'Welcome to the Opera' appeared.`n

        SendInput, {ALDOWN}n{ALTUP} ;Hit 'Next' button in 'Welcome to the Opera installer' window
        bContinue := true
    }
    else
    {
        TestsFailed++
        WinGetTitle, title, A
        OutputDebug, FAILED: %Module%:%A_LineNumber%: 'Opera 9.64 - InstallShield Wizard' window with 'Welcome to the Opera' failed to appear. Active window caption: '%title%'.`n
        bContinue := false
    }
}

; Test if 'Ready to install the program' can appear
TestsTotal++
if bContinue
{
    WinWaitActive, Opera 9.64 - InstallShield Wizard, Ready to install the program, 15
    if not ErrorLevel
    {
        TestsOK++
        OutputDebug, OK: %Module%:%A_LineNumber%: 'Opera 9.64 - InstallShield Wizard' window with 'Ready to install the program' appeared.`n

        Sleep, 2500
        SendInput, {ALTDOWN}i{ALTUP} ;Hit 'Install' button in 'Ready to install the program' window
        bContinue := true
    }
    else
    {
        TestsFailed++
        WinGetTitle, title, A
        OutputDebug, FAILED: %Module%:%A_LineNumber%: 'Opera 9.64 - InstallShield Wizard' window with 'Ready to install the program' failed to appear. Active window caption: '%title%'.`n
        bContinue := false
    }
}

; Test if 'InstallShield Wizard Completed' can appear
TestsTotal++
if bContinue
{
    WinWaitActive, Opera 9.64 - InstallShield Wizard, InstallShield Wizard Completed, 30
    if not ErrorLevel
    {
        TestsOK++
        OutputDebug, OK: %Module%:%A_LineNumber%: 'Opera 9.64 - InstallShield Wizard' window with 'InstallShield Wizard Completed' appeared.`n

        SendInput, {TAB} ;Focus 'Run Opera when I press Finish'
        Sleep, 500
        SendInput, {SPACE}
        Sleep, 500
        SendInput, {ALTDOWN}f{ALTUP} ;Hit 'Finish' button in 'InstallShield Wizard Completed' window
        bContinue := true
    }
    else
    {
        TestsFailed++
        WinGetTitle, title, A ;A is for the active window
        OutputDebug, FAILED: %Module%:%A_LineNumber%: 'Opera 9.64 - InstallShield Wizard' window with 'InstallShield Wizard Completed' failed to appear. Active window caption: '%title%'.`n
        bContinue := false
    }
}

;Check if Opera.exe exists in program files
TestsTotal++
if bContinue
{
    Sleep, 2500
    IfExist, %A_ProgramFiles%\Opera\opera.exe
    {
        TestsOK++
        OutputDebug, OK: %Module%:%A_LineNumber%: Should be installed, because '%A_ProgramFiles%\Opera\opera.exe' was found.`n
        bContinue := true
    }
    else
    {
        TestsFailed++
        OutputDebug, FAILED: %Module%:%A_LineNumber%: Can NOT find '%A_ProgramFiles%\Opera\opera.exe'.`n
        bContinue := false
    }
}
