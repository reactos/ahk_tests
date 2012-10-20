/*
 * Designed for OpenTTD 1.2.2
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

ModuleExe = %A_WorkingDir%\Apps\OpenTTD 1.2.2 Setup.exe
TestName = 1.install
MainAppFile = openttd.exe ; Mostly this is going to be process we need to look for

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
        RegRead, UninstallerPath, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\OpenTTD, UninstallString
        if ErrorLevel
        {
            ; There was a problem (such as a nonexistent key or value). 
            ; That probably means we have not installed this app before.
            ; Check in default directory to be extra sure
            bHardcoded := true ; To know if we got path from registry or not
            szDefaultDir = %A_ProgramFiles%\OpenTTD
            IfNotExist, %szDefaultDir%
            {
                TestsInfo("No previous versions detected in hardcoded path: '" szDefaultDir "'.")
                bContinue := true
            }
            else
            {   
                UninstallerPath = %szDefaultDir%\uninstall.exe /S
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
                WaitUninstallDone(UninstallerPath, 3) ; Reported child name is 'Au_.exe'
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
        RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\MicroSoft\Windows\CurrentVersion\Uninstall\OpenTTD
        IfExist, %A_MyDocuments%\OpenTTD
        {
            FileRemoveDir, %A_MyDocuments%\OpenTTD, 1
            if ErrorLevel
                TestsFailed("Unable to delete '" A_MyDocuments "\OpenTTD'.")
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


; Test if connected to the Internet
TestsTotal++
if bContinue
{
    if not bIsConnectedToInternet()
        TestsFailed("No internet connection detected.")
    else
        TestsOK("Internet connection detected.")
}


; We have comma in window caption, so, use variable
szWindowCaption := "OpenTTD 1.2.2 32-bit for Windows XP SP3, Vista and 7 Setup"


; Test if 'OpenTTD 1.2.2 32-bit for Windows XP SP3, Vista and 7 Setup (Welcome)' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, %szWindowCaption%, Welcome, 5
    if ErrorLevel
        TestsFailed("'" szWindowCaption " (Welcome)' window failed to appear.")
    else
    {
        ControlClick, Button2 ; Hit 'Next' button
        if ErrorLevel
            TestsFailed("Unable to hit 'Next' button in '" szWindowCaption " (Welcome)' window.")
        else
        {
            WinWaitClose, %szWindowCaption%, Welcome, 3
            if ErrorLevel
                TestsFailed("'" szWindowCaption " (Welcome)' window failed to close despite 'Next' button being clicked.")
            else
                TestsOK("'" szWindowCaption " (Welcome)' window appeared, 'Next' button clicked and window closed.")
        }
    }
}


; Test if 'License Agreement' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, %szWindowCaption%, License Agreement, 3
    if ErrorLevel
        TestsFailed("'" szWindowCaption " (License Agreement)' window failed to appear.")
    else
    {
        ControlClick, Button2 ; Hit 'I Agree' button
        if ErrorLevel
            TestsFailed("Unable to hit 'I Agree' button in '" szWindowCaption " (License Agreement)' window.")
        else
            TestsOK("'" szWindowCaption " (License Agreement)' window appeared, 'I Agree' button clicked and window closed.")
    }
}


; Test if 'Choose Components' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, %szWindowCaption%, Choose Components, 3
    if ErrorLevel
        TestsFailed("'" szWindowCaption " (Choose Components)' window failed to appear.")
    else
    {
        ControlClick, Button2 ; Hit 'Next' button
        if ErrorLevel
            TestsFailed("Unable to hit 'Next' button in '" szWindowCaption " (Choose Components)' window.")
        else
            TestsOK("'" szWindowCaption " (Choose Components)' window appeared, 'Next' button clicked and window closed.")
    }
}


; Test if 'Choose Install Location' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, %szWindowCaption%, Choose Install Location, 3
    if ErrorLevel
        TestsFailed("'" szWindowCaption " (Choose Install Location)' window failed to appear.")
    else
    {
        ControlClick, Button2 ; Hit 'Next' button
        if ErrorLevel
            TestsFailed("Unable to hit 'Next' button in '" szWindowCaption " (Choose Install Location)' window.")
        else
            TestsOK("'" szWindowCaption " (Choose Install Location)' window appeared, 'Next' button clicked and window closed.")
    }
}


; Test if 'Choose Start Menu Folder' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, %szWindowCaption%, Choose Start Menu Folder, 3
    if ErrorLevel
        TestsFailed("'" szWindowCaption " (Choose Start Menu Folder)' window failed to appear.")
    else
    {
        ControlClick, Button2 ; Hit 'Install' button
        if ErrorLevel
            TestsFailed("Unable to hit 'Install' button in '" szWindowCaption " (Choose Start Menu Folder)' window.")
        else
            TestsOK("'" szWindowCaption " (Choose Start Menu Folder)' window appeared, 'Install' button clicked and window closed.")
    }
}


; Test if can get thru 'Installing' window
TestsTotal++
if bContinue
{
    WinWaitActive, %szWindowCaption%, Installing, 3
    if ErrorLevel
        TestsFailed("'" szWindowCaption " (Installing)' window failed to appear.")
    else
    {
        TestsInfo("'" szWindowCaption " (Installing)' window appeared, waiting for it to close.")

        iTimeOut := 120
        while iTimeOut > 0
        {
            IfWinActive, %szWindowCaption%, Installing
            {
                WinWaitClose, %szWindowCaption%, Installing, 1
                iTimeOut--
            }
            else
                break ; exit the loop if something poped-up
        }

        ; Static12, Static13
        WinWaitClose, %szWindowCaption%, Installing, 1
        if ErrorLevel
        {
            ControlGetText, szDownloading, Static12, %szWindowCaption%, Installing
            if ErrorLevel
                TestsInfo("Unable to get control (Static12) text from '" szWindowCaption " (Installing)' window.")
            else
            {
                ControlGetText, szStatus, Static13, %szWindowCaption%, Installing
                if ErrorLevel
                    TestsInfo("Unable to get control (Static13) text from '" szWindowCaption " (Installing)' window.")
                else
                    TestsInfo("Failed on: " szDownloading " " szStatus ".")
            }
            TestsFailed("'" szWindowCaption " (Installing)' window failed to close (iTimeOut=" iTimeOut ").")
        }
        else
            TestsOK("'" szWindowCaption " (Installing)' window closed (iTimeOut=" iTimeOut ").")
    }
}


; Test if 'Completing' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, %szWindowCaption%, Completing, 3
    if ErrorLevel
        TestsFailed("'" szWindowCaption " (Completing)' window failed to appear.")
    else
    {
        Control, Uncheck,, Button4, %szWindowCaption%, Completing ; Uncheck 'Run OpenTTD 1.2.2 now!'
        if ErrorLevel
            TestsFailed("Unable to uncheck 'Run OpenTTD 1.2.2 now!' checkbox in '" szWindowCaption " (Completing)' window.")
        else
        {
            ControlGet, bChecked, Checked, Button4
            if bChecked = 1
                TestsFailed("'Run OpenTTD 1.2.2 now!' checkbox in '" szWindowCaption " (Completing)' window reported as unchecked, but further inspection proves that it was still checked.")
            else
            {
                ControlClick, Button2 ; Hit 'Finish' button
                if ErrorLevel
                    TestsFailed("Unable to hit 'Finish' button in '" szWindowCaption " (Completing)' window.")
                else
                {
                    WinWaitClose, %szWindowCaption%, Completing, 3
                    if ErrorLevel
                        TestsFailed("'" szWindowCaption " (Completing)' window failed to close despite 'Finish' button being clicked.")
                    else
                        TestsOK("'" szWindowCaption " (Completing)' window appeared, 'Finish' button clicked and window closed.")
                }
            }
        }
    }
}


; Check if program exists
TestsTotal++
if bContinue
{
    ; No need to sleep, because we already waited for process to appear
    RegRead, UninstallerPath, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\OpenTTD, UninstallString
    if ErrorLevel
        TestsFailed("Either we can't read from registry or data doesn't exist.")
    else
    {
        UninstallerPath := ExeFilePathNoParam(UninstallerPath)
        SplitPath, UninstallerPath,, InstalledDir
        IfNotExist, %InstalledDir%\%MainAppFile%
            TestsFailed("Something went wrong, can't find '" InstalledDir "\" MainAppFile "'.")
        else
            TestsOK("The application has been installed, because '" InstalledDir "\" MainAppFile "' was found.")
    }
}
