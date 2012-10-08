/*
 * Designed for SMPlayer 0.6.9
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

ModuleExe = %A_WorkingDir%\Apps\SMPlayer 0.6.9 Setup.exe
TestName = 1.install
MainAppFile = smplayer.exe ; Mostly this is going to be process we need to look for

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
        RegRead, UninstallerPath, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\SMPlayer, UninstallString
        if ErrorLevel
        {
            ; There was a problem (such as a nonexistent key or value). 
            ; That probably means we have not installed this app before.
            ; Check in default directory to be extra sure
            bHardcoded := true ; To know if we got path from registry or not
            szDefaultDir = %A_ProgramFiles%\SMPlayer
            IfNotExist, %szDefaultDir%
            {
                TestsInfo("No previous versions detected in hardcoded path: '" szDefaultDir "'.")
                bContinue := true
            }
            else
            {   
                UninstallerPath = %szDefaultDir%\uninst.exe /S
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
            UninstallerPath := ExeFilePathNoParam(UninstallerPath)
            SplitPath, UninstallerPath,, InstalledDir
            IfNotExist, %InstalledDir%
            {
                TestsInfo("Got '" InstalledDir "' from registry and such path does not exist.")
                bContinue := true
            }
            else
            {
                UninstallerPath = %UninstallerPath% /S
                WaitUninstallDone(UninstallerPath, 7) ; Reported child name is 'Au_.exe'
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
        RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\SMPlayer
        RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\MicroSoft\Windows\CurrentVersion\Uninstall\SMPlayer

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


; Test if 'Installer Language (Please select)' window appeared, if so, click 'OK' button
TestsTotal++
if bContinue
{
    WinWaitActive, Installer Language, Please select, 7
    if ErrorLevel
        TestsFailed("'Installer Language (Please select)' window failed to appear.")
    else
    {
        ControlClick, Button1, Installer Language, Please select ; Hit 'OK' button
        if ErrorLevel
            TestsFailed("Unable to hit 'OK' button in 'Installer Language (Please select)' window.")
        else
        {
            WinWaitClose, Installer Language, Please select, 3
            if ErrorLevel
                TestsFailed("'Installer Language (Please select)' window failed to close despite 'OK' button being clicked.")
            else
                TestsOK("'Installer Language (Please select)' window appeared, 'OK' button clicked, window closed.")
        }
    }
}


; Test if 'SMPlayer 0.6.9 Setup (Welcome)' window appeared, if so, click 'Next' button
TestsTotal++
if bContinue
{
    WinWaitActive, SMPlayer 0.6.9 Setup, Welcome, 7
    if ErrorLevel
        TestsFailed("'SMPlayer 0.6.9 Setup (Welcome)' window failed to appear.")
    else
    {
        ControlClick, Button2, SMPlayer 0.6.9 Setup, Welcome ; Hit 'Next' button
        if ErrorLevel
            TestsFailed("Unable to hit 'Next' button in 'SMPlayer 0.6.9 Setup (Welcome)' window.")
        else
            TestsOK("'SMPlayer 0.6.9 Setup (Welcome)' window appeared and 'Next' button was clicked.")
    }
}


; Test if 'SMPlayer 0.6.9 Setup (License Agreement)' window appeared, if so, check 'I accept' checkbox and click 'Next' button
TestsTotal++
if bContinue
{
    WinWaitActive, SMPlayer 0.6.9 Setup, License Agreement, 3
    if ErrorLevel
        TestsFailed("'SMPlayer 0.6.9 Setup (License Agreement)' window failed to appear.")
    else
    {
        Control, Check, , Button4, SMPlayer 0.6.9 Setup, License Agreement ; Check 'I accept the terms of the License Agreement' radiobutton
        if ErrorLevel
            TestsFailed("Unable to check 'I accept the terms of the License Agreement' checkbox in 'SMPlayer 0.6.9 Setup (License Agreement)' window.")
        else
        {
            TimeOut := 0
            while (not %bNextEnabled%) and (TimeOut < 6) ; Sleep while 'Next' button is disabled
            {
                ControlGet, bNextEnabled, Enabled,, Button4, SMPlayer 0.6.9 Setup, License Agreement
                Sleep, 300
                TimeOut++
            }
            
            if not %bNextEnabled%
                TestsFailed("'Next' button did not get enabled in 'SMPlayer 0.6.9 Setup (License Agreement)' window after checking 'I accept' checkbox.")
            else
            {
                ControlClick, Button2, SMPlayer 0.6.9 Setup, License Agreement ; Hit 'Next' button
                if ErrorLevel
                    TestsFailed("Unable to hit enabled 'Next' button in 'SMPlayer 0.6.9 Setup (License Agreement)' window ('I accept' radiobutton is checked).")
                else
                    TestsOK("'SMPlayer 0.6.9 Setup (License Agreement)' window appeared, 'I accept' radiobutton checked, 'Next' button was clicked.")
            }
        }
    }
}


; Test if 'SMPlayer 0.6.9 Setup (Choose Components)' window appeared, if so, click 'Next' button
TestsTotal++
if bContinue
{
    WinWaitActive, SMPlayer 0.6.9 Setup, Choose Components, 3
    if ErrorLevel
        TestsFailed("'SMPlayer 0.6.9 Setup (Choose Components)' window failed to appear.")
    else
    {
        ControlClick, Button2, SMPlayer 0.6.9 Setup, Choose Components ; Hit 'Next' button
        if ErrorLevel
            TestsFailed("Unable to hit 'Next' button in 'SMPlayer 0.6.9 Setup (Choose Components)' window.")
        else
            TestsOK("'SMPlayer 0.6.9 Setup (Choose Components)' window appeared and 'Next' button was clicked.")  
    }
}


; Test if 'SMPlayer 0.6.9 Setup (Choose Install Location)' window appeared, if so, click 'Install' button
TestsTotal++
if bContinue
{
    WinWaitActive, SMPlayer 0.6.9 Setup, Choose Install Location, 7
    if ErrorLevel
        TestsFailed("'SMPlayer 0.6.9 Setup (Choose Install Location)' window failed to appear.")
    else
    {
        ControlClick, Button2, SMPlayer 0.6.9 Setup, Choose Install Location ; Hit 'Install' button
        if ErrorLevel
            TestsFailed("Unable to hit 'Install' button in 'SMPlayer 0.6.9 Setup (Choose Install Location)' window.")
        else
            TestsOK("'SMPlayer 0.6.9 Setup (Choose Install Location)' window appeared and 'Install' button was clicked.")
    }
}


; Test if can get thru 'SMPlayer 0.6.9 Setup (Installing)' window
TestsTotal++
if bContinue
{
    WinWaitActive, SMPlayer 0.6.9 Setup, Installing, 3
    if ErrorLevel
        TestsFailed("'SMPlayer 0.6.9 Setup (Installing)' window failed to appear.")
    else
    {
        TestsInfo("'SMPlayer 0.6.9 Setup (Installing)' window appeared, waiting for it to close.")
		
		iTimeOut := 25
        while iTimeOut > 0
        {
            IfWinActive, SMPlayer 0.6.9 Setup, Installing
            {
                WinWaitClose, SMPlayer 0.6.9 Setup, Installing, 1
                iTimeOut--
            }
            else
                break ; exit the loop if something poped-up
        }

        WinWaitClose, SMPlayer 0.6.9 Setup, Installing, 1
        if ErrorLevel
            TestsFailed("'SMPlayer 0.6.9 Setup (Installing)' window failed to go away (iTimeOut=" iTimeOut ").")
        else
            TestsOK("'SMPlayer 0.6.9 Setup (Installing)' window appeared and went away (iTimeOut=" iTimeOut ").")
    }
}


; Test if 'SMPlayer 0.6.9 Setup (Completing)' window appeared, if so, click 'Finish' button
TestsTotal++
if bContinue
{
    WinWaitActive, SMPlayer 0.6.9 Setup, Completing, 3
    if ErrorLevel
        TestsFailed("'SMPlayer 0.6.9 Setup (Completing)' window failed to appear.")
    else
    {
        ; There are 2 checkboxes, but unchecked by default
        ControlClick, Button2, SMPlayer 0.6.9 Setup, Completing ; Hit 'Finish' button
        if ErrorLevel
            TestsFailed("Unable to hit 'Finish' button in 'SMPlayer 0.6.9 Setup (Completing)' window.")
        else
        {
            WinWaitClose, SMPlayer 0.6.9 Setup, Completing, 3
            if ErrorLevel
                TestsFailed("'SMPlayer 0.6.9 Setup (Completing)' window failed to close after hitting 'Finish' button.")
            else
                TestsOK("'SMPlayer 0.6.9 Setup (Completing)' window appeared, 'Finish' button was clicked and window closed.")
        }
    }
}


; Check if program exists
TestsTotal++
if bContinue
{
    RegRead, UninstallerPath, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\SMPlayer, UninstallString
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
