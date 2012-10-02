/*
 * Designed for Flash Player 10.3.183.25
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

ModuleExe = %A_WorkingDir%\Apps\Flash Player 10.3.183.25 Setup.exe
TestName = 1.install
MainAppFile = FlashUtil10zg_Plugin.exe ; Mostly this is going to be process we need to look for

; Test if Setup file exists, if so, delete installed files, and run Setup
TestsTotal++
IfNotExist, %ModuleExe%
    TestsFailed("'" ModuleExe "' not found.")
else
{
    InstallLocation = %A_WinDir%\System32\Macromed\Flash
    Process, Close, %MainAppFile% ; Teminate process
    Process, WaitClose, %MainAppFile%, 4
    if ErrorLevel ; The PID still exists.
        TestsFailed("Unable to terminate '" MainAppFile "' process.") ; So, process still exists
    else
    {
        RegRead, UninstallerPath, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Adobe Flash Player Plugin, UninstallString
        if ErrorLevel
        {
            ; There was a problem (such as a nonexistent key or value). 
            ; That probably means we have not installed this app before.
            ; Check in default directory to be extra sure
            IfNotExist, %InstallLocation%
                bContinue := true ; No previous versions detected in hardcoded path
            else
            {
                bHardcoded := true ; To know if we got path from registry or not
                IfExist, %InstallLocation%\%MainAppFile%
                {
                    Run, %InstallLocation%\%MainAppFile% -maintain plugin
                    WinWaitActive, Uninstall Adobe Flash Player,,5
                    if ErrorLevel
                        TestsFailed("'Uninstall Adobe Flash Player' window failed to appear.")
                    else
                    {
                        SendInput, {TAB}{ENTER} ; Focus and hit 'UNINSTALL' button
                        Sleep, 4000 ; FIXME: get rid of hardcoded sleep call
                        IfWinNotActive, Uninstall Adobe Flash Player
                            TestsFailed("'Uninstall Adobe Flash Player' window is not active anymore.")
                        else
                        {
                            SendInput, {TAB}{ENTER} ; Focus and hit 'DONE' button
                            WinWaitClose, Uninstall Adobe Flash Player,,3
                            if ErrorLevel
                                TestsFailed("'Uninstall Adobe Flash Player' window failed to close.")
                            else
                            {
                                Process, Close, %MainAppFile% ; Teminate process
                                Process, WaitClose, %MainAppFile%, 4
                                if ErrorLevel
                                    TestsFailed("Unable to terminate '" MainAppFile "' process.") ; So, process still exists
                                else
                                {
                                    IfNotExist, %InstallLocation% ; Uninstaller might delete the dir
                                        bContinue := true
                                    else
                                    {
                                        FileRemoveDir, %InstallLocation%, 1
                                        if ErrorLevel
                                            TestsFailed("Unable to delete existing '" InstallLocation "' ('" MainAppFile "' process is reported as terminated).'")
                                        else
                                            bContinue := true
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        else
        {
            SplitPath, UninstallerPath,, InstalledDir ; It will get rid of command line options and filename
            IfNotExist, %InstalledDir%
                bContinue := true
            else
            {
                UninstallerPath = %InstalledDir%\%MainAppFile%
                IfExist, %UninstallerPath%
                {
                    Run, %InstalledDir%\%MainAppFile% -maintain activex
                    WinWaitActive, Uninstall Adobe Flash Player,,7
                    if ErrorLevel
                        TestsFailed("'Uninstall Adobe Flash Player' failed to appear.")
                    else
                    {
                        SendInput, {TAB}{ENTER} ; Focus and hit 'UNINSTALL' button
                        Sleep, 4000 ; FIXME: get rid of hardcoded sleep call
                        IfWinNotActive, Uninstall Adobe Flash Player
                            TestsFailed("'Uninstall Adobe Flash Player' window is not active anymore.")
                        else
                        {
                            SendInput, {TAB}{ENTER} ; Focus and hit 'DONE' button
                            WinWaitClose, Uninstall Adobe Flash Player,,3
                            if ErrorLevel
                                TestsFailed("'Uninstall Adobe Flash Player' window failed to close.")
                            else
                            {
                                Process, Close, %MainAppFile% ; Teminate process
                                Process, WaitClose, %MainAppFile%, 4
                                if ErrorLevel
                                    TestsFailed("Unable to terminate '" MainAppFile "' process.") ; So, process still exists
                                else
                                {
                                    IfNotExist, %InstalledDir%
                                        bContinue := true
                                    else
                                    {
                                        FileRemoveDir, %InstalledDir%, 1 ; Delete just in case
                                        if ErrorLevel
                                            TestsFailed("Unable to delete existing '" InstalledDir "' ('" MainAppFile "' process is reported as terminated).")
                                        else
                                            bContinue := true
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    if bContinue
    {
        RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\MicroSoft\Windows\CurrentVersion\Uninstall\Adobe Flash Player Plugin
        if bHardcoded
            TestsOK("Either there was no previous versions or we succeeded removing it using hardcoded path.")
        else
            TestsOK("Either there was no previous versions or we succeeded removing it using data from registry.")
        Run %ModuleExe%
    }
}


; Test if can click 'Install' button
TestsTotal++
if bContinue
{
    WinWaitActive, Adobe® Flash® Player 10.3 Installer,, 7
    if ErrorLevel
        TestsFailed("'Adobe® Flash® Player 10.3 Installer' window with 'Install' button failed to appear.")
    else
    {
        SendInput, {TAB}{SPACE} ; Focus and check 'I have read and agree' checkbox
        SendInput, {TAB}{TAB}{ENTER} ; Focus and hit 'INSTALL' button
    }
}


; Test if can click 'Done' button
TestsTotal++
if bContinue
{
    IfWinNotActive, Adobe® Flash® Player 10.3 Installer
        TestsFailed("'Adobe® Flash® Player 10.3 Installer' is not active window.")
    else
    {
        ; Sleeping while can't focus 'DONE' button won't work here
        Sleep, 4000 ; FIXME: remove hardcoded sleep call
        IfWinNotActive, Adobe® Flash® Player 10.3 Installer
            TestsFailed("'Adobe® Flash® Player 10.3 Installer' window is not active anymore.")
        else
        {
            SendInput, {TAB}{ENTER} ; Focus and hit 'DONE' button
            WinWaitClose, Adobe® Flash® Player 10.3 Installer,,3
            if ErrorLevel
                TestsFailed("Unable to close 'Adobe® Flash® Player 10.3 Installer' window.")
            else
                TestsOK("'Adobe® Flash® Player 10.3 Installer' window closed.")
        }
    }
}


; Check if program exists
TestsTotal++
if bContinue
{
    RegRead, UninstallerPath, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Adobe Flash Player Plugin, UninstallString
    if ErrorLevel
        TestsFailed("Either we can't read from registry or data doesn't exist.")
    else
    {
        SplitPath, UninstallerPath,, InstalledDir
        IfNotExist, %InstalledDir%\%MainAppFile%
            TestsFailed("Something went wrong, can't find '" InstalledDir "\" MainAppFile "'.")
        else
            TestsOK("The application has been installed, because '" InstalledDir "\" MainAppFile "' was found.")
    }
}
