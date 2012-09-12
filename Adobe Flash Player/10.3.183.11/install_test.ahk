/*
 * Designed for Flash Player 10.3.183.11
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

ModuleExe = %A_WorkingDir%\Apps\Flash Player 10.3.183.11 Setup.exe
TestName = 1.install
MainAppFile = FlashUtil10y_ActiveX.exe ; Mostly this is going to be process we need to look for

; Test if Setup file exists, if so, delete installed files, and run Setup
TestsTotal++
IfNotExist, %ModuleExe%
    TestsFailed("'" ModuleExe "' not found.")
else
{
    InstallLocation = %A_WinDir%\System32\Macromed\Flash
    Process, Close, %MainAppFile% ; Teminate process
    Sleep, 2000
    Process, Exist, %MainAppFile%
    if ErrorLevel <> 0
        TestsFailed("Unable to terminate '" MainAppFile "' process.") ; So, process still exists
    else
    {
        RegRead, UninstallerPath, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Adobe Flash Player ActiveX, UninstallString
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
                    Run, %InstallLocation%\%MainAppFile% -maintain activex
                    WinWaitActive, Uninstall Adobe Flash Player,,7
                    if ErrorLevel
                        TestsFailed("'Uninstall Adobe Flash Player' failed to appear.")
                    else
                    {
                        ControlClick, Button3, Uninstall Adobe Flash Player ; Uninstall
                        Sleep, 5000
                        ControlClick, Button3, Uninstall Adobe Flash Player ; Done
                        WinWaitClose, Uninstall Adobe Flash Player,,7
                        if ErrorLevel
                            TestsFailed("'Uninstall Adobe Flash Player' window failed to close.")
                        else
                        {
                            Process, Close, %MainAppFile% ; Teminate process
                            Process, WaitClose, %MainAppFile%, 4
                            if ErrorLevel
                                TestsFailed("Unable to terminate '" MainAppFile "' process.") ; So, process still exists
                        }
                    }
                }

                IfNotExist, %InstallLocation% ; Uninstaller might delete the dir
                    bContinue := true
                {
                    FileRemoveDir, %InstallLocation%, 1
                    if ErrorLevel
                        TestsFailed("Unable to delete existing '" InstallLocation "' ('" MainAppFile "' process is reported as terminated).'")
                    else
                        bContinue := true
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
                        ControlClick, Button3, Uninstall Adobe Flash Player ; Uninstall
                        Sleep, 5000
                        ControlClick, Button3, Uninstall Adobe Flash Player ; Done
                        WinWaitClose, Uninstall Adobe Flash Player,,7
                        if ErrorLevel
                            TestsFailed("'Uninstall Adobe Flash Player' window failed to close.")
                        else
                        {
                            Process, Close, %MainAppFile% ; Teminate process
                            Process, WaitClose, %MainAppFile%, 4
                            if ErrorLevel
                                TestsFailed("Unable to terminate '" MainAppFile "' process.") ; So, process still exists
                        }
                    }
                }

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

    if bContinue
    {
        RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\MicroSoft\Windows\CurrentVersion\Uninstall\Adobe Flash Player ActiveX

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


; Test if can click 'Install' button
TestsTotal++
if bContinue
{
    WinWaitActive, Adobe® Flash® Player 10.3 Installer,, 7
    if ErrorLevel
        TestsFailed("'Adobe® Flash® Player 10.3 Installer' window with 'Install' button failed to appear.")
    else
    {
        Sleep, 250
        Control, Check,,Button6, Adobe® Flash® Player 10.3 Installer ; Check 'I have read and agree' checkbox
        if ErrorLevel
            TestsFailed("Unable to check 'I have read and agree' checkbox in 'Adobe® Flash® Player 10.3 Installer' window.")
        else
        {
            Sleep, 1500 ; Wait until 'Install' button is enabled
            ControlClick, Button3, Adobe® Flash® Player 10.3 Installer ; Hit 'Install' button
            if ErrorLevel
                TestsFailed("Unable to hit 'Install' button in 'Adobe® Flash® Player 10.3 Installer' window.")
            else
                TestsOK("'Adobe® Flash® Player 10.3 Installer' window appeared and 'Install' button was clicked.")
        }
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
        while not %OutputVar% ; Sleep while 'Done' button is disabled
        {
            ControlGet, OutputVar, Enabled,, Button3, Adobe® Flash® Player 10.3 Installer
            Sleep, 1000
        }
        ControlClick, Button3, Adobe® Flash® Player 10.3 Installer ; Hit 'Done' button
        if ErrorLevel
            TestsFailed("Unable to hit 'Done' button in 'Adobe® Flash® Player 10.3 Installer' window.")
        else
        WinWaitClose, Adobe® Flash® Player 10.3 Installer,,7
        if ErrorLevel
            TestsFailed("'Adobe® Flash® Player 10.3 Installer' window failed to close despite 'Done' button being clicked.")
        else
            TestsOK("'Adobe® Flash® Player 10.3 Installer' window appeared, 'Done' button clicked and window closed.")
    }
}


; Check if program exists
TestsTotal++
if bContinue
{
    Sleep, 2000
    RegRead, UninstallerPath, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Adobe Flash Player ActiveX, UninstallString
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
