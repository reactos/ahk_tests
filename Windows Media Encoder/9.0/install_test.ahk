/*
 * Designed for Windows Media Encoder 9.0
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

ModuleExe = %A_WorkingDir%\Apps\Windows Media Encoder 9.0 Setup.exe
TestName = 1.install
MainAppFile = wmenc.exe ; Mostly this is going to be process we need to look for

; Test if Setup file exists, if so, delete installed files, and run Setup
TestsTotal++
IfNotExist, %ModuleExe%
    TestsFailed("'" ModuleExe "' not found.")
else
{
    Process, Close, %MainAppFile% ; Teminate process
    Process, WaitClose, %MainAppFile%, 4
    if ErrorLevel ; The PID still exists.
        TestsFailed("Unable to terminate '" MainAppFile "' process.") ; So, process still exists
    else
    {
        szDefaultDir = %A_ProgramFiles%\Windows Media Components
        RegRead, InstallLocation, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{E38C00D0-A68B-4318-A8A6-F7D4B5B1DF0E}, InstallLocation
        if ErrorLevel
        {
            ; There was a problem (such as a nonexistent key or value). 
            ; That probably means we have not installed this app before.
            ; Check in default directory to be extra sure
            bHardcoded := true ; To know if we got path from registry or not
            IfNotExist, %szDefaultDir%
            {
                TestsInfo("No previous versions detected in hardcoded path: '" szDefaultDir "'.")
                bContinue := true
            }
            else
            {   
                UninstallerPath = %A_WinDir%\System32\MsiExec.exe /X{E38C00D0-A68B-4318-A8A6-F7D4B5B1DF0E} /norestart /qb-!
                WaitUninstallDone(UninstallerPath, 7)
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
                UninstallerPath = %A_WinDir%\System32\MsiExec.exe /X{E38C00D0-A68B-4318-A8A6-F7D4B5B1DF0E} /norestart /qb-!
                WaitUninstallDone(UninstallerPath, 7)
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
        RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\MicroSoft\Windows\CurrentVersion\Uninstall\{E38C00D0-A68B-4318-A8A6-F7D4B5B1DF0E}
        IfExist, %A_AppData%\Microsoft\Windows Media Encoder
        {
            FileRemoveDir, %A_AppData%\Microsoft\Windows Media Encoder, 1
            if ErrorLevel
                TestsFailed("Unable to delete '" A_AppData "\Microsoft\Windows Media Encoder'.")
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


; Test if 'Welcome' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Windows Media Encoder 9 Series Setup, Welcome, 7
    if ErrorLevel
        TestsFailed("'Windows Media Encoder 9 Series Setup (Welcome)' window failed to appear.")
    else
    {
        ControlClick, Button1 ; Hit 'Next' button
        if ErrorLevel
            TestsFailed("Unable to hit 'Next' button in 'Windows Media Encoder 9 Series Setup (Welcome)' window.")
        else
        {
            WinWaitClose, Windows Media Encoder 9 Series Setup, Welcome, 3
            if ErrorLevel
                TestsFailed("'Windows Media Encoder 9 Series Setup (Welcome)' window failed to close despite 'Next' button being clicked.")
            else
                TestsOK("'Windows Media Encoder 9 Series Setup (Welcome)' window appeared, 'Next' button clicked and window closed.")
        }
    }
}


; Test if 'License Agreement' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Windows Media Encoder 9 Series Licence Agreement, License Agreement, 3
    if ErrorLevel
        TestsFailed("'Windows Media Encoder 9 Series Licence Agreement (License Agreement)' window failed to appear.")
    else
    {
        Control, Check, , Button2, Windows Media Encoder 9 Series Licence Agreement, License Agreement ; Check 'I accept...' radiobutton
        if ErrorLevel
            TestsFailed("Unable to check 'I accept...' radiobutton in 'Windows Media Encoder 9 Series Licence Agreement (License Agreement)' window.")
        else
        {
            ControlClick, Button5 ; Hit 'Next' button
            if ErrorLevel
                TestsFailed("Unable to hit 'Next' button in 'Windows Media Encoder 9 Series Licence Agreement (License Agreement)' window.")
            else
                TestsOK("'Windows Media Encoder 9 Series Licence Agreement (License Agreement)' window appeared, 'I accept...' radiobutton chekced, 'Next' button clicked.")
        }
    }
}


; Test if 'Installation Folder' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Windows Media Encoder 9 Series Setup, Installation Folder, 3
    if ErrorLevel
        TestsFailed("'Windows Media Encoder 9 Series Setup (Installation Folder)' window failed to appear.")
    else
    {
        ControlClick, Button1 ; Hit 'Next' button
        if ErrorLevel
            TestsFailed("Unable to hit 'Next' button in 'Windows Media Encoder 9 Series Setup (Installation Folder)' window.")
        else
            TestsOK("'Windows Media Encoder 9 Series Setup (Installation Folder)' window appeared, 'Next' button clicked.")
    }
}


; Test if 'Ready to Install' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Windows Media Encoder 9 Series Setup, Ready to Install, 3
    if ErrorLevel
        TestsFailed("'Windows Media Encoder 9 Series Setup (Ready to Install)' window failed to appear.")
    else
    {
        ControlClick, Button1 ; Hit 'Install' button
        if ErrorLevel
            TestsFailed("Unable to hit 'Install' button in 'Windows Media Encoder 9 Series Setup (Ready to Install)' window.")
        else
            TestsOK("'Windows Media Encoder 9 Series Setup (Ready to Install)' window appeared, 'Install' button clicked.")
    }
}


; Test if can get thru 'Installing' window
TestsTotal++
if bContinue
{
    WinWaitActive, Windows Media Encoder 9 Series Setup, Installing, 3
    if ErrorLevel
        TestsFailed("'Windows Media Encoder 9 Series Setup (Installing)' window failed to appear.")
    else
    {
        TestsInfo("'Windows Media Encoder 9 Series Setup (Installing)' window appeared, waiting for it to close.")
        
        iTimeOut := 40
        while iTimeOut > 0
        {
            IfWinActive, Windows Media Encoder 9 Series Setup, Installing
            {
                WinWaitClose, Windows Media Encoder 9 Series Setup, Installing, 1
                iTimeOut--
            }
            else
            {
                WinGetActiveTitle, ActiveWndTitle
                TestsInfo("'" ActiveWndTitle "' window poped-up.")
                break ; exit the loop if something poped-up
            }
        }
        
        WinWaitClose, Windows Media Encoder 9 Series Setup, Installing, 1
        if ErrorLevel
            TestsFailed("'Windows Media Encoder 9 Series Setup (Installing)' window failed to close (iTimeOut=" iTimeOut ").")
        else
            TestsOK("'Windows Media Encoder 9 Series Setup (Installing)' window closed (iTimeOut=" iTimeOut ").")
    }
}


; Test if 'Completing' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Windows Media Encoder 9 Series Setup, Completing, 3
    if ErrorLevel
        TestsFailed("'Windows Media Encoder 9 Series Setup (Completing)' window failed to appear.")
    else
    {
        ControlClick, Button1 ; Hit 'Finish' button
        if ErrorLevel
            TestsFailed("Unable to hit 'Finish' button in 'Windows Media Encoder 9 Series Setup (Completing)' window.")
        else
        {
            WinWaitClose, Windows Media Encoder 9 Series Setup, Completing, 3
            if ErrorLevel
                TestsFailed("'Windows Media Encoder 9 Series Setup (Completing)' window failed to close despite 'Finish' button being closed.")
            else
                TestsOK("'Windows Media Encoder 9 Series Setup (Completing)' window appeared, 'Finish' button clicked, window closed.")
        }
    }
}


; Check if program exists
TestsTotal++
if bContinue
{
    ; Installer writes no data in InstallLocation in registry, we could do it to make things easier for ourselves
    RegWrite, REG_SZ, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{E38C00D0-A68B-4318-A8A6-F7D4B5B1DF0E}, InstallLocation, %szDefaultDir%
    if ErrorLevel
        TestsFailed("Unable to write registry.")
    else
    {
        RegRead, InstallLocation, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{E38C00D0-A68B-4318-A8A6-F7D4B5B1DF0E}, InstallLocation
        if ErrorLevel
            TestsFailed("Either we can't read from registry or data doesn't exist.")
        else
        {
            IfNotExist, %InstallLocation%\Encoder\%MainAppFile%
                TestsFailed("Something went wrong, can't find '" InstallLocation "\Encoder\" MainAppFile "'.")
            else
                TestsOK("The application has been installed, because '" InstallLocation "\Encoder\" MainAppFile "' was found.")
        }
    }
}
