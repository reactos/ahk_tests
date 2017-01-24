/*
 * Designed for Sunbird 0.9
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

SetControlDelay, -1
ModuleExe = %A_WorkingDir%\Apps\Sunbird 0.9 Setup.exe
TestName = 1.install
MainAppFile = sunbird.exe ; Mostly this is going to be process we need to look for

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
        RegRead, UninstallerPath, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Mozilla Sunbird (0.9), UninstallString
        if ErrorLevel
        {
            ; There was a problem (such as a nonexistent key or value). 
            ; That probably means we have not installed this app before.
            ; Check in default directory to be extra sure
            bHardcoded := true ; To know if we got path from registry or not
            szDefaultDir = %A_ProgramFiles%\Mozilla Sunbird
            IfNotExist, %szDefaultDir%
            {
                TestsInfo("No previous versions detected in hardcoded path: '" szDefaultDir "'.")
                bContinue := true
            }
            else
            {   
                UninstallerPath = %szDefaultDir%\uninstall\uninst.exe /S
                ; There is child process, but seems we can not detect it
                WaitUninstallDone(UninstallerPath, 3)
                if bContinue
                {
                    Process, WaitClose, Au_.exe, 7
                    if ErrorLevel ; The PID still exists
                    {
                        TestsInfo("'Au_.exe' process failed to close.")
                        Process, Close, Au_.exe
                        Process, WaitClose, Au_.exe, 3
                        if ErrorLevel ; The PID still exists
                            TestsFailed("Unable to terminate 'Au_.exe' process.")
                    }
                    else
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
        }
        else
        {
            SplitPath, UninstallerPath,, InstalledDir
            SplitPath, InstalledDir,, InstalledDir ; Split once more, since installer was in subdir (v12.0 specific)
            IfNotExist, %InstalledDir%
            {
                TestsInfo("Got '" InstalledDir "' from registry and such path does not exist.")
                bContinue := true
            }
            else
            {
                UninstallerPath = %UninstallerPath% /S
                WaitUninstallDone(UninstallerPath, 3)
                if bContinue
                {
                    Process, WaitClose, Au_.exe, 7
                    if ErrorLevel ; The PID still exists
                    {
                        TestsInfo("'Au_.exe' process failed to close.")
                        Process, Close, Au_.exe
                        Process, WaitClose, Au_.exe, 3
                        if ErrorLevel ; The PID still exists
                            TestsFailed("Unable to terminate 'Au_.exe' process.")
                    }
                    else
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
    }

    if bContinue
    {
        RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\Mozilla\Mozilla Sunbird
        RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\Mozilla Sunbird 9.0
        RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\MicroSoft\Windows\CurrentVersion\Uninstall\Mozilla Sunbird (0.9)
        IfExist, %A_AppData%\Mozilla
        {
            FileRemoveDir, %A_AppData%\Mozilla, 1
            if ErrorLevel
                TestsFailed("Unable to delete '" A_AppData "\Mozilla'.")
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
    SetTitleMatchMode, 2
    WinWaitActive, Extracting, Cancel, 10 ; Wait 10 secs for window to appear
    if ErrorLevel
        TestsFailed("'Extracting' window failed to appear.")
    else
    {
        TestsInfo("'Extracting' window appeared, waiting for it to close.")
		
		iTimeOut := 20
        while iTimeOut > 0
        {
            IfWinActive, Extracting, Cancel
            {
                WinWaitClose, Extracting, Cancel, 1
                iTimeOut--
            }
            else
                break ; exit the loop if something poped-up
        }

        WinWaitClose, Extracting, Cancel, 1
        if ErrorLevel 
            TestsFailed("'Extracting' window failed to dissapear (iTimeOut=" iTimeOut ").")
        else
            TestsOK("'Extracting' window appeared and went away (iTimeOut=" iTimeOut ").")
    }
}


; Test if 'This wizard' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Mozilla Sunbird Setup, This wizard, 7
    if ErrorLevel
        TestsFailed("'Mozilla Sunbird Setup (This wizard)' window failed to appear.")
    else
    {
        ControlClick, Button2, Mozilla Sunbird Setup, This wizard
        if ErrorLevel
            TestsFailed("Unable to click 'Next' in 'Mozilla Sunbird Setup (This wizard)' window.")
        else
            TestsOK("'Mozilla Sunbird Setup (This wizard)' window appeared and 'Next' was clicked.")
    }  
}


; Test if 'License Agreement' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Mozilla Sunbird Setup, License Agreement, 3
    if ErrorLevel
        TestsFailed("'Mozilla Sunbird Setup' window with 'Mozilla Sunbird Setup (License Agreement)' failed to appear.")
    else
    {
        ControlClick, Button4, Mozilla Sunbird Setup, License Agreement ; check 'I accept' radio button
        if ErrorLevel
            TestsFailed("Unable to check 'I agree' radio button in 'Mozilla Sunbird Setup (License Agreement)' window.")
        else
        {
            ControlGet, OutputVar, Enabled,, Button2, Mozilla Sunbird Setup, License Agreement
            if not %OutputVar%
                TestsFailed("'I agree' radio button is checked in 'Mozilla Sunbird Setup (License Agreement)', but 'Next' button is disabled.")
            else
            {
                ControlClick, Button2, Mozilla Sunbird Setup, License Agreement
                if ErrorLevel
                    TestsFailed("Unable to hit 'Next' button in 'Mozilla Sunbird Setup (License Agreement)' window despite it is enabled.")
                else
                    TestsOK("'Mozilla Sunbird Setup (License Agreement)' window appeared and 'Next' was clicked.")
            }
        }
    }
}



; Test if 'Setup Type' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Mozilla Sunbird Setup, Setup Type, 3
    if ErrorLevel
        TestsFailed("'Mozilla Sunbird Setup (Setup Type)' window failed to appear.")
    else
    {
        ControlClick, Button2, Mozilla Sunbird Setup, Setup Type
        if ErrorLevel
            TestsFailed("Unable to click 'Next' in 'Mozilla Sunbird Setup (Setup Type)' window.")
        else
            TestsOK("'Mozilla Sunbird Setup (Setup Type)' window appeared and 'Next' was clicked.")
    }
}


; Test if can get thru 'Installing'
TestsTotal++
if bContinue
{
    WinWaitActive, Mozilla Sunbird Setup, Installing, 3
    if ErrorLevel
        TestsFailed("'Mozilla Sunbird Setup (Installing)' window failed to appear.")
    else
    {
        TestsInfo("'Mozilla Sunbird Setup (Installing)' window appeared, waiting for it to close.")
		
		iTimeOut := 25
        while iTimeOut > 0
        {
            IfWinActive, Mozilla Sunbird Setup, Installing
            {
                WinWaitClose, Mozilla Sunbird Setup, Installing, 1
                iTimeOut--
            }
            else
                break ; exit the loop if something poped-up
        }
		
        WinWaitClose, Mozilla Sunbird Setup, Installing, 1
        if ErrorLevel
            TestsFailed("'Mozilla Sunbird Setup (Installing)' window failed to dissapear (iTimeOut=" iTimeOut ").")
        else
            TestsOK("'Mozilla Sunbird Setup (Installing)' window went away (iTimeOut=" iTimeOut ").")
    }
}


; Test if 'Completing' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Mozilla Sunbird Setup, Completing, 3
    if ErrorLevel
        TestsFailed("'Mozilla Sunbird Setup (Completing)' window failed to appear.")
    else
    {
        ControlClick, Button4, Mozilla Sunbird Setup, Completing ; Uncheck 'Launch Mozilla Sunbird now'
        if ErrorLevel
        {
            TestsFailed("Unable to uncheck 'Launch Mozilla Sunbird now' in 'Completing' window.")
            Process, Wait, thunderbird.exe, 5
            Process, Close, thunderbird.exe
        }
        else
        {
            ControlClick, Button2, Mozilla Sunbird Setup, Completing ; Hit 'Finish'
            if ErrorLevel
                TestsFailed("Unable to click 'Finish' in 'Mozilla Sunbird Setup (Completing)' window.")
            else
            {
                WinWaitClose, Mozilla Sunbird Setup, Completing, 3
                if ErrorLevel
                    TestsFailed("'Mozilla Sunbird Setup (Completing)' window failed to close despite 'Finish' button was clicked.")
                else
                    TestsOK("'Mozilla Sunbird Setup (Completing)' window appeared, 'Finish' button was clicked and window closed.")
            }
        }
    }
}


; Check if program exists
TestsTotal++
if bContinue
{
    RegRead, UninstallerPath, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Mozilla Sunbird (0.9), UninstallString
    if ErrorLevel
        TestsFailed("Either we can't read from registry or data doesn't exist.")
    else
    {
        SplitPath, UninstallerPath,, InstalledDir
        SplitPath, InstalledDir,, InstalledDir ; Split once more
        IfNotExist, %InstalledDir%\%MainAppFile%
            TestsFailed("Something went wrong, can't find '" InstalledDir "\" MainAppFile "'.")
        else
            TestsOK("The application has been installed, because '" InstalledDir "\" MainAppFile "' was found.")
    }
}
