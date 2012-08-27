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

ModuleExe = %A_WorkingDir%\Apps\Opera Setup.exe
bContinue := false
TestName = 1.install

TestsFailed := 0
TestsOK := 0
TestsTotal := 0

Process, Close, Opera.exe
FileRemoveDir, %A_ProgramFiles%\Opera 
RunWait, MsiExec.exe /X{E1BBBAC5-2857-4155-82A6-54492CE88620} /qn
Sleep, 3000
RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\MicroSoft\Windows\CurrentVersion\Uninstall\{E1BBBAC5-2857-4155-82A6-54492CE88620}

; Test if Setup file exists
TestsTotal++
IfExist, %ModuleExe%
{
    TestsOK("")
    Run %ModuleExe%
}
else
    TestsFailed("'" ModuleExe "' not found.")

; Test if can start setup
TestsTotal++
if bContinue
{
    WinWaitActive, Choose Setup Language, Select the language, 15 ; Wait 15 secs for window to appear
    if not ErrorLevel ;Window is found and it is active
    {
        Sleep, 250
        SendInput, {ENTER} ;Hit 'OK' button in 'Choose Setup Language' window
        TestsOK("'Choose Setup Language (Select the language)' window appeared and 'ENTER' was sent.")
    }
    else
        TestsFailed("'Choose Setup Language (Select the language)' window failed to appear.")
}

; Test if window with 'Start Setup' button can appear
TestsTotal++
if bContinue
{
    WinWaitActive, Opera 9.64 - InstallShield Wizard, Start, 25 ; Same exe: 'Start set-up' in ROS, 'Start Setup' in Windows
    if not ErrorLevel
    {
        Sleep, 2500 ; window flashes, so let it to appear correctly
        SendInput, {ALTDOWN)
        Sleep, 500 ; Opera setup requires those sleeps
        SendInput, s
        Sleep, 500
        SendInput, {ALTUP} ;Hit 'Start Setup' button in 'Opera 9.64 - InstallShield Wizard' window
        TestsOK("'Opera 9.64 - InstallShield Wizard' window with 'Start Setup' button appeared, Alt+S was sent.")
    }
    else
        TestsFailed("'Opera 9.64 - InstallShield Wizard' window with 'Start Setup' button failed to appear.")
}

; Test if 'Opera Browser Licence Agreement' window can appear
TestsTotal++
if bContinue
{
    WinWaitActive, Opera 9.64 - InstallShield Wizard, Installation of Opera requires, 20
    if not ErrorLevel
    {
        Sleep, 250
        SendInput, {ALTDOWN}a{ALTUP} ;Hit 'I Accept' button in 'Opera Browser Licence Agreement' window
        TestsOK("'Opera 9.64 - InstallShield Wizard (Installation of Opera requires)' window appeared, Alt+A was sent.")
    }
    else
        TestsFailed("'Opera 9.64 - InstallShield Wizard (Installation of Opera requires)' window failed to appear.")
}

; Test if 'Welcome to the Opera installer' can appear
TestsTotal++
if bContinue
{
    WinWaitActive, Opera 9.64 - InstallShield Wizard, Welcome to the Opera, 15
    if not ErrorLevel
    {
        SendInput, {ALDOWN}n{ALTUP} ;Hit 'Next' button in 'Welcome to the Opera installer' window
        TestsOK("'Opera 9.64 - InstallShield Wizard (Welcome to the Opera)' window appeared, Alt+N was sent")
    }
    else
        TestsFailed("'Opera 9.64 - InstallShield Wizard (Welcome to the Opera)' window failed to appear.")
}

; Test if 'Ready to install the program' can appear
TestsTotal++
if bContinue
{
    WinWaitActive, Opera 9.64 - InstallShield Wizard, Ready to install the program, 15
    if not ErrorLevel
    {
        Sleep, 250
        SendInput, {ALTDOWN}i{ALTUP} ;Hit 'Install' button in 'Ready to install the program' window
        TestsOK("'Opera 9.64 - InstallShield Wizard (Ready to install the program)' window appeared, Alt+I was sent.")
    }
    else
        TestsFailed("'Opera 9.64 - InstallShield Wizard (Ready to install the program)' window failed to appear.")
}

; Test if 'InstallShield Wizard Completed' can appear
TestsTotal++
if bContinue
{
    WinWaitActive, Opera 9.64 - InstallShield Wizard, InstallShield Wizard Completed, 30
    if not ErrorLevel
    {
        Sleep, 250
        SendInput, {TAB} ; Focus 'Run Opera when I press Finish'
        Sleep, 500
        SendInput, {SPACE}
        Sleep, 500
        SendInput, {ALTDOWN}f{ALTUP} ;Hit 'Finish' button in 'InstallShield Wizard Completed' window
        WinWaitClose, Opera 9.64 - InstallShield Wizard, InstallShield Wizard Completed, 7
        if ErrorLevel
            TestsFailed("'Opera 9.64 - InstallShield Wizard (InstallShield Wizard Completed)' window failed to close after Alt+F was sent.")
        else
            TestsOK("'Opera 9.64 - InstallShield Wizard (InstallShield Wizard Completed)' window appeared, TAB, SPACE, Alt+F were sent, window was closed.")
    }
    else
        TestsFailed("'Opera 9.64 - InstallShield Wizard (InstallShield Wizard Completed)' window failed to appear.")
}

; Check if Opera.exe exists
TestsTotal++
if bContinue
{
    Sleep, 2500
    IfExist, %A_ProgramFiles%\Opera\opera.exe
        TestsOK("Should be installed, because '" A_ProgramFiles "\Opera\opera.exe' was found.")
    else
        TestsFailed("Can NOT find '" A_ProgramFiles "\Opera\opera.exe'.")
}

Process, Close, msiexec.exe ; Just in case we failed