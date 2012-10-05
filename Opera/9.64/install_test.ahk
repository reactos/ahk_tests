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
            bHardcoded := true ; To know if we got path from registry or not
            szDefaultDir = %A_ProgramFiles%\Opera
            IfNotExist, %szDefaultDir%
            {
                TestsInfo("No previous versions detected in hardcoded path: '" szDefaultDir "'.")
                bContinue := true
            }
            else
            {   
                UninstallerPath = %A_WinDir%\System32\MsiExec.exe /X{E1BBBAC5-2857-4155-82A6-54492CE88620} /qn
                WaitUninstallDone(UninstallerPath, 5)
                if bContinue
                {
                    IfNotExist, %szDefaultDir% ; Uninstaller might delete the dir
                    {
                        TestsInfo("Uninstaller deleted hardcoded path: '" szDefaultDir "'.")
                        bContinue := true
                    }
                    else
                    {
                        FileRemoveDir, %szDefaultDir%, 1
                        if ErrorLevel
                            TestsFailed("Unable to delete hardcoded path '" szDefaultDir "' ('" MainAppFile "' process is reported as terminated).'")
                        else
                        {
                            TestsInfo("Succeeded deleting hardcoded path, because uninstaller did not: '" szDefaultDir "'.")
                            bContinue := true
                        }
                    }
                }
            }
        }
        else
        {
            InstalledDir = %InstallLocation%
            IfNotExist, %InstalledDir%
            {
                TestsInfo("Got '" InstalledDir "' from registry and such path does not exist.")
                bContinue := true
            }
            else
            {
                UninstallerPath = %A_WinDir%\System32\MsiExec.exe /X{E1BBBAC5-2857-4155-82A6-54492CE88620} /qn
                WaitUninstallDone(UninstallerPath, 5)
                if bContinue
                {
                    IfNotExist, %InstalledDir%
                    {
                        TestsInfo("Uninstaller deleted path (registry data): '" InstalledDir "'.")
                        bContinue := true
                    }
                    else
                    {
                        FileRemoveDir, %InstalledDir%, 1 ; Uninstaller leaved the path for us to delete, so, do it
                        if ErrorLevel
                            TestsFailed("Unable to delete existing '" InstalledDir "' ('" MainAppFile "' process is reported as terminated).")
                        else
                        {
                            TestsInfo("Succeeded deleting path (registry data), because uninstaller did not: '" InstalledDir "'.")
                            bContinue := true
                        }
                    }
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
    WinWaitActive, Choose Setup Language, Select the language, 7
    if ErrorLevel
        TestsFailed("'Choose Setup Language (Select the language)' window failed to appear.")
    else
    {
        SendInput, {ENTER} ;Hit 'OK' button in 'Choose Setup Language' window
        WinWaitClose, Choose Setup Language, Select the language, 3
        if ErrorLevel
            TestsFailed("'Choose Setup Language (Select the language)' window failed to close despite 'ENTER' was sent to it.")
        else
            TestsOK("'Choose Setup Language (Select the language)' window appeared and 'ENTER' was sent.")
    }
}


; Test if 'InstallShield Wizard (Preparing to Install)' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, InstallShield Wizard, Preparing to Install, 7
    if ErrorLevel
    {
        IfWinNotActive, Opera 9.64 - InstallShield Wizard, Start
            TestsFailed("'InstallShield Wizard (Preparing to Install)' window failed to appear.")
        else
            TestsOK("'Opera 9.64 - InstallShield Wizard (Start)' window appeared.")
    }
    else
    {
        iTimeOut := 20
        while iTimeOut > 0
        {
            IfWinActive, InstallShield Wizard, Preparing to Install
            {
                WinWaitClose, InstallShield Wizard, Preparing to Install, 1
                iTimeOut--
            }
            else
                break ; exit the loop if something poped-up
        }
        
        WinWaitClose, InstallShield Wizard, Preparing to Install, 1
        if ErrorLevel
            TestsFailed("'InstallShield Wizard (Preparing to Install)' window failed to close (iTimeOut=" iTimeOut ").")
        else
            TestsOK("'InstallShield Wizard (Preparing to Install)' window closed (iTimeOut=" iTimeOut ").")
    }
}


; Test if window with 'Start Setup' button can appear
TestsTotal++
if bContinue
{
    WinWaitActive, Windows Installer, Preparing to install..., 4 ; ReactOD doesn't have such window
    if not ErrorLevel
    {
        iTimeOut := 40
        while iTimeOut > 0
        {
            IfWinActive, Windows Installer, Preparing to install...
            {
                WinWaitClose, Windows Installer, Preparing to install..., 1
                iTimeOut--
            }
            else
                break ; exit the loop if something poped-up
        }
    }
        
    WinWaitActive, Opera 9.64 - InstallShield Wizard, Start, 5 ; Same exe: 'Start set-up' in ROS, 'Start Setup' in Windows
    if ErrorLevel
        TestsFailed("'Opera 9.64 - InstallShield Wizard' window with 'Start Setup' button failed to appear.")
    else
    {
        SendInput, !s
        TestsOK("'Opera 9.64 - InstallShield Wizard' window with 'Start Setup' button appeared, Alt+S was sent.")
    }
}


; Test if 'Opera Browser Licence Agreement' window can appear
TestsTotal++
if bContinue
{
    WinWaitActive, Opera 9.64 - InstallShield Wizard, Installation of Opera requires, 3
    if ErrorLevel
        TestsFailed("'Opera 9.64 - InstallShield Wizard (Installation of Opera requires)' window failed to appear.")
    else
    {
        SendInput, {ALTDOWN}a{ALTUP} ;Hit 'I Accept' button in 'Opera Browser Licence Agreement' window
        TestsOK("'Opera 9.64 - InstallShield Wizard (Installation of Opera requires)' window appeared, Alt+A was sent.")
    }
}


; Test if 'Welcome to the Opera installer' can appear
TestsTotal++
if bContinue
{
    WinWaitActive, Opera 9.64 - InstallShield Wizard, Welcome to the Opera, 3
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
    WinWaitActive, Opera 9.64 - InstallShield Wizard, Ready to install the program, 3
    if ErrorLevel
        TestsFailed("'Opera 9.64 - InstallShield Wizard (Ready to install the program)' window failed to appear.")
    else
    {
        SendInput, {ALTDOWN}i{ALTUP} ;Hit 'Install' button in 'Ready to install the program' window
        TestsOK("'Opera 9.64 - InstallShield Wizard (Ready to install the program)' window appeared, Alt+I was sent.")
    }
}


; Test if can get thru 'Opera 9.64 - InstallShield Wizard (Installing)' window
TestsTotal++
if bContinue
{
    WinWaitActive, Opera 9.64 - InstallShield Wizard, Installing, 3
    if ErrorLevel
        TestsFailed("'Opera 9.64 - InstallShield Wizard (Installing)' window failed to appear.")
    else
    {
        iTimeOut := 45
        while iTimeOut > 0
        {
            IfWinActive,  Opera 9.64 - InstallShield Wizard, Installing
            {
                WinWaitClose,  Opera 9.64 - InstallShield Wizard, Installing, 1
                iTimeOut--
            }
            else
                break ; exit the loop if something poped-up
        }
        
        WinWaitClose,  Opera 9.64 - InstallShield Wizard, Installing, 1
        if ErrorLevel
            TestsFailed("'Opera 9.64 - InstallShield Wizard (Installing)' window failed to close (iTimeOut=" iTimeOut ").")
        else
            TestsOK("'Opera 9.64 - InstallShield Wizard (Installing)' window closed (iTimeOut=" iTimeOut ").")
    }
}


; Test if 'InstallShield Wizard Completed' can appear
TestsTotal++
if bContinue
{
    WinWaitActive, Opera 9.64 - InstallShield Wizard, InstallShield Wizard Completed, 3
    if ErrorLevel
        TestsFailed("'Opera 9.64 - InstallShield Wizard (InstallShield Wizard Completed)' window failed to appear.")
    else
    {
        ; SendInput, {TAB} ; Focus 'Run Opera when I press Finish'
        ; SendInput, {SPACE} ; Uncheck the checkbox
        SendMessage, 0x201, 0, 0, Button3
        SendMessage, 0x202, 0, 0, Button3
        ControlGet, bChecked, Checked, Button3
        if bChecked = 1
            TestsFailed("'Run Opera when I press Finish' checkbox in 'Opera 9.64 - InstallShield Wizard (InstallShield Wizard Completed)' window reported as unchecked, but further inspection proves that it was still checked.")
        else
        {
            SendInput, {ALTDOWN}f{ALTUP} ;Hit 'Finish' button in 'InstallShield Wizard Completed' window
            WinWaitClose, Opera 9.64 - InstallShield Wizard, InstallShield Wizard Completed, 3
            if ErrorLevel
                TestsFailed("'Opera 9.64 - InstallShield Wizard (InstallShield Wizard Completed)' window failed to close after Alt+F was sent.")
            else
                TestsOK("'Opera 9.64 - InstallShield Wizard (InstallShield Wizard Completed)' window appeared, TAB, SPACE, Alt+F were sent, window was closed.")
        }
    }
}


; Check if program exists
TestsTotal++
if bContinue
{
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
