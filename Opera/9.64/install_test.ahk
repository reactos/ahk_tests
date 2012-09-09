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

ModuleExe = %A_WorkingDir%\Apps\Opera 9.64 Setup.exe
TestName = 1.install
MainAppFile = Opera.exe ; Mostly this is going to be process we need to look for


; Test if Setup file exists, if so, delete installed files, and run Setup
TestsTotal++
IfNotExist, %ModuleExe%
    TestsFailed("'" ModuleExe "' not found.")
else
{
    Process, Close, %MainAppFile% ; Teminate process
    Process, WaitClose, %MainAppFile%, 5
    if ErrorLevel ; The PID still exists.
        TestsFailed("Unable to terminate '" MainAppFile "' process.") ; So, process still exists
    else
    {
        RegRead, InstallLocation, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{E1BBBAC5-2857-4155-82A6-54492CE88620}, InstallLocation
        if ErrorLevel
        {
            ; There was a problem (such as a nonexistent key or value). 
            ; That probably means we have not installed this app before.
            ; Check in default directory to be extra sure
            IfNotExist, %A_ProgramFiles%\Opera
                bContinue := true ; No previous versions detected in hardcoded path
            else
            {
                bHardcoded := true ; To know if we got path from registry or not
                IfExist, %A_ProgramFiles%\Opera
                {
                    RunWait, MsiExec.exe /X{E1BBBAC5-2857-4155-82A6-54492CE88620} /qn ; Silently uninstall it
                    Sleep, 7000
                }

                IfNotExist, %A_ProgramFiles%\Opera ; Uninstaller might delete the dir
                    bContinue := true
                {
                    FileRemoveDir, %A_ProgramFiles%\Opera, 1
                    if ErrorLevel
                        TestsFailed("Unable to delete existing '" A_ProgramFiles "\Opera' ('" MainAppFile "' process is reported as terminated).'")
                    else
                        bContinue := true
                }
            }
        }
        else
        {
            IfNotExist, %InstallLocation%
                bContinue := true
            else
            {
                IfExist, %InstallLocation%
                {
                    RunWait, MsiExec.exe /X{E1BBBAC5-2857-4155-82A6-54492CE88620} /qn ; Silently uninstall it
                    Sleep, 7000
                }

                IfNotExist, %InstallLocation%
                    bContinue := true
                else
                {
                    FileRemoveDir, %InstallLocation%, 1 ; Delete just in case
                    if ErrorLevel
                        TestsFailed("Unable to delete existing '" InstallLocation "' ('" MainAppFile "' process is reported as terminated).")
                    else
                        bContinue := true
                }
            }
        }
    }

    if bContinue
    {
        RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\MicroSoft\Windows\CurrentVersion\Uninstall\{E1BBBAC5-2857-4155-82A6-54492CE88620}
        IfExist, %A_AppData%\Opera
        {
            FileRemoveDir, %A_AppData%\Opera, 1
            if ErrorLevel
                TestsFailed("Unable to delete '" A_AppData "\Opera'.")
        }

        if bContinue
        {
            if bHardcoded
                TestsOK("Either there was no previous versions or we succeeded removing it using hardcoded path.")
            else
                TestsOK("Either there was no previous versions or we succeeded removing it using data from registry.")
            Run %ModuleExe%
        }
    }
}


; Test if can start setup
TestsTotal++
if bContinue
{
    WinWaitActive, Choose Setup Language, Select the language, 15 ; Wait 15 secs for window to appear
    if ErrorLevel
        TestsFailed("'Choose Setup Language (Select the language)' window failed to appear.")
    else
    {
        Sleep, 700
        SendInput, {ENTER} ;Hit 'OK' button in 'Choose Setup Language' window
        WinWaitClose, Choose Setup Language, Select the language, 5
        if ErrorLevel
            TestsFailed("'Choose Setup Language (Select the language)' window failed to close despite 'ENTER' was sent to it.")
        else
            TestsOK("'Choose Setup Language (Select the language)' window appeared and 'ENTER' was sent.")
    }
}


; Test if window with 'Start Setup' button can appear
TestsTotal++
if bContinue
{
    WinWaitActive, Opera 9.64 - InstallShield Wizard, Start, 25 ; Same exe: 'Start set-up' in ROS, 'Start Setup' in Windows
    if ErrorLevel
        TestsFailed("'Opera 9.64 - InstallShield Wizard' window with 'Start Setup' button failed to appear.")
    else
    {
        Sleep, 5000 ; window flashes, so let it to appear correctly
        SendInput, {ALTDOWN)
        Sleep, 500 ; Opera setup requires those sleeps
        SendInput, s
        Sleep, 500
        SendInput, {ALTUP} ;Hit 'Start Setup' button in 'Opera 9.64 - InstallShield Wizard' window
        TestsOK("'Opera 9.64 - InstallShield Wizard' window with 'Start Setup' button appeared, Alt+S was sent.")
    }
}


; Test if 'Opera Browser Licence Agreement' window can appear
TestsTotal++
if bContinue
{
    WinWaitActive, Opera 9.64 - InstallShield Wizard, Installation of Opera requires, 20
    if ErrorLevel
        TestsFailed("'Opera 9.64 - InstallShield Wizard (Installation of Opera requires)' window failed to appear.")
    else
    {
        Sleep, 700
        SendInput, {ALTDOWN}a{ALTUP} ;Hit 'I Accept' button in 'Opera Browser Licence Agreement' window
        TestsOK("'Opera 9.64 - InstallShield Wizard (Installation of Opera requires)' window appeared, Alt+A was sent.")
    }
}


; Test if 'Welcome to the Opera installer' can appear
TestsTotal++
if bContinue
{
    WinWaitActive, Opera 9.64 - InstallShield Wizard, Welcome to the Opera, 15
    if ErrorLevel
        TestsFailed("'Opera 9.64 - InstallShield Wizard (Welcome to the Opera)' window failed to appear.")
    else
    {
        SendInput, {ALDOWN}n{ALTUP} ;Hit 'Next' button in 'Welcome to the Opera installer' window
        TestsOK("'Opera 9.64 - InstallShield Wizard (Welcome to the Opera)' window appeared, Alt+N was sent")
    }
}


; Test if 'Ready to install the program' can appear
TestsTotal++
if bContinue
{
    WinWaitActive, Opera 9.64 - InstallShield Wizard, Ready to install the program, 15
    if ErrorLevel
        TestsFailed("'Opera 9.64 - InstallShield Wizard (Ready to install the program)' window failed to appear.")
    else
    {
        Sleep, 700
        SendInput, {ALTDOWN}i{ALTUP} ;Hit 'Install' button in 'Ready to install the program' window
        TestsOK("'Opera 9.64 - InstallShield Wizard (Ready to install the program)' window appeared, Alt+I was sent.")
    }
}


; Test if 'InstallShield Wizard Completed' can appear
TestsTotal++
if bContinue
{
    WinWaitActive, Opera 9.64 - InstallShield Wizard, InstallShield Wizard Completed, 30
    if ErrorLevel
        TestsFailed("'Opera 9.64 - InstallShield Wizard (InstallShield Wizard Completed)' window failed to appear.")
    else
    {
        Sleep, 700
        SendInput, {TAB} ; Focus 'Run Opera when I press Finish'
        Sleep, 500
        SendInput, {SPACE}
        Sleep, 500
        SendInput, {ALTDOWN}f{ALTUP} ;Hit 'Finish' button in 'InstallShield Wizard Completed' window
        WinWaitClose, Opera 9.64 - InstallShield Wizard, InstallShield Wizard Completed, 7
        if ErrorLevel
            TestsFailed("'Opera 9.64 - InstallShield Wizard (InstallShield Wizard Completed)' window failed to close after Alt+F was sent.")
        else
        {
            Process, wait, %MainAppFile%, 4
            NewPID = %ErrorLevel%  ; Save the value immediately since ErrorLevel is often changed.
            if NewPID != 0
                TestsFailed("'" MainAppFile "' process appeared despite 'Run Opera when I press Finish' checkbox unchecked in 'Opera 9.64 - InstallShield Wizard (InstallShield Wizard Completed)' window.")
            else
                TestsOK("'Opera 9.64 - InstallShield Wizard (InstallShield Wizard Completed)' window appeared, TAB, SPACE, Alt+F were sent, window was closed.")
        }
    }
}


; Check if program exists
TestsTotal++
if bContinue
{
    Sleep, 2000
    RegRead, InstallLocation, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{E1BBBAC5-2857-4155-82A6-54492CE88620}, InstallLocation
    if ErrorLevel
        TestsFailed("Either we can't read from registry or data doesn't exist.")
    else
    {
        IfNotExist, %InstallLocation%%MainAppFile% ; Registry path contains trailing backslash
            TestsFailed("Something went wrong, can't find '" InstallLocation MainAppFile "'.")
        else
            TestsOK("The application has been installed, because '" InstallLocation MainAppFile "' was found.")
    }
}
