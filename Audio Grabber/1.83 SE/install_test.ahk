/*
 * Designed for Audio Grabber 1.83 SE
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

ModuleExe = %A_WorkingDir%\Apps\Audio Grabber 1.83 SE Setup.exe
TestName = 1.install
MainAppFile = audiograbber.exe ; Mostly this is going to be process we need to look for

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
        RegRead, UninstallerPath, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Audiograbber, UninstallString
        if ErrorLevel
        {
            ; There was a problem (such as a nonexistent key or value). 
            ; That probably means we have not installed this app before.
            ; Check in default directory to be extra sure
            bHardcoded := true ; To know if we got path from registry or not
            szDefaultDir = %A_ProgramFiles%\Audiograbber
            IfNotExist, %szDefaultDir%
            {
                TestsInfo("No previous versions detected in hardcoded path: '" szDefaultDir "'.")
                bContinue := true
            }
            else
            {   
                UninstallerPath = %szDefaultDir%\Uninstall.exe /S
                WaitUninstallDone(UninstallerPath, 3)
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
                WaitUninstallDone(UninstallerPath, 3) ; Child process 'Au_.exe'
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
        RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\MicroSoft\Windows\CurrentVersion\Uninstall\Audiograbber
        ; Application stores its settings in installation directory

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


; Test if 'Installer Language (Please select)' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Installer Language, Please select, 10
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
                TestsOK("'Installer Language (Please select)' window appeared, 'OK' button clicked and window closed.")
        }
    }
}


; Test if 'Audiograbber 1.83 SE Setup (This wizard)' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Audiograbber 1.83 SE Setup, This wizard, 7
    if ErrorLevel
        TestsFailed("'Audiograbber 1.83 SE Setup (This wizard)' window failed to appear.")
    else
    {
        ControlClick, Button2, Audiograbber 1.83 SE Setup, This wizard ; Hit 'Next' button
        if ErrorLevel
            TestsFailed("Unable to hit 'Next' button in 'Audiograbber 1.83 SE Setup (This wizard)' window.")
        else
        {
            WinWaitClose, Audiograbber 1.83 SE Setup, This wizard, 3
            if ErrorLevel
                TestsFailed("'Audiograbber 1.83 SE Setup (This wizard)' window failed to close despite 'Next' button being clicked.")
            else
                TestsOK("'Audiograbber 1.83 SE Setup (This wizard)' window appeared, 'Next' button clicked and window closed.")
        }
    }
}


; Test if 'Audiograbber 1.83 SE Setup (License Agreement)' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Audiograbber 1.83 SE Setup, License Agreement, 3
    if ErrorLevel
        TestsFailed("'Audiograbber 1.83 SE Setup (License Agreement)' window failed to appear.")
    else
    {
        ControlClick, Button2, Audiograbber 1.83 SE Setup, License Agreement ; Hit 'I Agree' button
        if ErrorLevel
            TestsFailed("Unable to hit 'I Agree' button in 'Audiograbber 1.83 SE Setup (License Agreement)' window.")
        else
            TestsOK("'Audiograbber 1.83 SE Setup (License Agreement)' window appeared and 'I Agree' button was clicked.")
    }
}


; Test if 'Audiograbber 1.83 SE Setup (Choose Install Location)' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Audiograbber 1.83 SE Setup, Choose Install Location, 3
    if ErrorLevel
        TestsFailed("'Audiograbber 1.83 SE Setup (Choose Install Location)' window failed to appear.")
    else
    {
        ControlClick, Button2, Audiograbber 1.83 SE Setup, Choose Install Location ; Hit 'Next' button
        if ErrorLevel
            TestsFailed("Unable to hit 'Next' button in 'Audiograbber 1.83 SE Setup (Choose Install Location)' window.")
        else
            TestsOK("'Audiograbber 1.83 SE Setup (Choose Install Location)' window appeared and 'Next' button was clicked.")
    }
}


; Test if 'Audiograbber 1.83 SE Setup (Additional options)' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Audiograbber 1.83 SE Setup, Additional options, 3
    if ErrorLevel
        TestsFailed("'Audiograbber 1.83 SE Setup (Additional options)' window failed to appear.")
    else
    {
        ControlClick, Button3, Audiograbber 1.83 SE Setup, Additional options ; Hit 'Skip' button
        if ErrorLevel
            TestsFailed("Unable to hit 'Skip' button in 'Audiograbber 1.83 SE Setup (Additional options)' window.")
        else
            TestsOK("'Audiograbber 1.83 SE Setup (Additional options)' window appeared and 'Skip' button was clicked.")
    }
}



; Test if 'Audiograbber 1.83 SE Setup (Completing)' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Audiograbber 1.83 SE Setup, Completing, 10
    if ErrorLevel
        TestsFailed("'Audiograbber 1.83 SE Setup (Completing)' window failed to appear.")
    else
    {
        Control, Uncheck,, Button4, Audiograbber 1.83 SE Setup, Completing ; Uncheck 'Start Audiograbber 1.83 SE'
        if ErrorLevel
            TestsFailed("Unable to uncheck 'Start Audiograbber 1.83 SE' checkbox in 'Audiograbber 1.83 SE Setup (Completing)' window.")
        else
        {
            ControlGet, bChecked, Checked,, Button4
            if bChecked = 1
                TestsFailed("'Start Audiograbber 1.83 SE' checkbox in 'Audiograbber 1.83 SE Setup (Completing)' window reported as unchecked, but further inspection proves that it was still checked.")
            else
            {
                ControlClick, Button2, Audiograbber 1.83 SE Setup, Completing ; Hit 'Finish' button
                if ErrorLevel
                    TestsFailed("Unable to hit 'Finish' button in 'Audiograbber 1.83 SE Setup (Completing)' window.")
                else
                {
                    WinWaitClose, Audiograbber 1.83 SE Setup, Completing, 3
                    if ErrorLevel
                        TestsFailed("'Audiograbber 1.83 SE Setup (Completing)' window failed to close despite the 'Finish' button being reported as clicked .")
                    else
                        TestsOK("'Audiograbber 1.83 SE Setup (Completing)' window appeared, 'Start Audiograbber 1.83 SE' unchecked and 'Finish' button clicked and window closed.")
                }
            }
        }
    }
}


; Check if program exists
TestsTotal++
if bContinue
{
    RegRead, UninstallerPath, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Audiograbber, UninstallString
    if ErrorLevel
        TestsFailed("Either we can't read from registry or data doesn't exist.")
    else
    {
        StringReplace, UninstallerPath, UninstallerPath, `", , All
        SplitPath, UninstallerPath,, InstalledDir
        IfNotExist, %InstalledDir%\%MainAppFile%
            TestsFailed("Something went wrong, can't find '" InstalledDir "\" MainAppFile "'.")
        else
            TestsOK("The application has been installed, because '" InstalledDir "\" MainAppFile "' was found.")
    }
}
