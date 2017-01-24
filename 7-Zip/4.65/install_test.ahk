/*
 * Designed for 7-Zip 4.65
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

SetControlDelay, -1 ; Suppress the global control delay, some windows come fast.
ModuleExe = %A_WorkingDir%\Apps\7-Zip 4.65 Setup.exe
TestName = 1.install
MainAppFile = 7zFM.exe ; Mostly this is going to be process we need to look for

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
        RegRead, UninstallerPath, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\7-Zip, UninstallString
        if ErrorLevel
        {
            ; There was a problem (such as a nonexistent key or value). 
            ; That probably means we have not installed this app before.
            ; Check in default directory to be extra sure
            bHardcoded := true ; To know if we got path from registry or not
            szDefaultDir = %A_ProgramFiles%\7-Zip
            IfNotExist, %szDefaultDir%
            {
                TestsInfo("No previous versions detected in hardcoded path: '" szDefaultDir "'.")
                bContinue := true
            }
            else
            {
                Run, regsvr32 /s /u "%szDefaultDir%\7-zip.dll"
                Process, Close, explorer.exe
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
                Run, regsvr32 /s /u "%InstalledDir%\7-zip.dll"
                Process, Close, explorer.exe
                UninstallerPath = %UninstallerPath% /S
                WaitUninstallDone(UninstallerPath, 3) ; Child 'Au_.exe'
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
        Process, wait, explorer.exe, 5
        NewPID = %ErrorLevel%  ; Save the value immediately since ErrorLevel is often changed
        if NewPID = 0
            TestsFailed("'explorer.exe' process failed to start.")
        else
        {
            RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\7-Zip
            RegDelete, HKEY_CURRENT_USER, SOFTWARE\7-Zip
            RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\MicroSoft\Windows\CurrentVersion\Uninstall\7-Zip
            IfExist, %A_AppData%\7-Zip
            {
                FileRemoveDir, %A_AppData%\7-Zip, 1
                if ErrorLevel
                    TestsFailed("Unable to delete '" A_AppData "\7-Zip'.")
            }
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


; Test if '7-Zip 4.65 Setup (Choose Install Location)' window appeared, if so, hit 'Install' button
TestsTotal++
if bContinue
{
    WinWait, 7-Zip 4.65 Setup, Choose Install Location, 10
    if ErrorLevel
        TestsFailed("'7-Zip 4.65 Setup (Choose Install Location)' window does not exist.")
    else
    {
        ; We had to kill explorer, so, make sure 7-Zip window is active
        WinActivate, 7-Zip 4.65 Setup, Choose Install Location
        WinWaitActive, 7-Zip 4.65 Setup, Choose Install Location, 3
        if ErrorLevel
            TestsFailed("Unable to activate existing '7-Zip 4.65 Setup (Choose Install Location)' window.")
        else
        {
            ControlClick, Button2, 7-Zip 4.65 Setup, Choose Install Location ; Hit 'Install' button
            if ErrorLevel
                TestsFailed("Unable to hit 'Install' button in '7-Zip 4.65 Setup (Choose Install Location)' window.")
            else
            {
                WinWaitClose, 7-Zip 4.65 Setup, Choose Install Location, 3
                if ErrorLevel
                    TestsFailed("'7-Zip 4.65 Setup (Choose Install Location)' window failed to close despite 'Next' button being clicked.")
                else
                    TestsOK("'7-Zip 4.65 Setup (Choose Install Location)' window appeared, 'Install' button clicked and window closed.")
            }
        }
    }
}


; Test if can get thru '7-Zip 4.65 Setup (Installing)' window
TestsTotal++
if bContinue
{
    WinWait, 7-Zip 4.65 Setup, Installing, 3
    if ErrorLevel
        TestsFailed("'7-Zip 4.65 Setup (Installing)' window failed to appear.")
    else
    {
        TestsInfo("'7-Zip 4.65 Setup (Installing)' window appeared, waiting for it to close.")
        
        iTimeOut := 20
        while iTimeOut > 0
        {
            IfWinActive, 7-Zip 4.65 Setup, Installing
            {
                WinWaitClose, 7-Zip 4.65 Setup, Installing, 1
                iTimeOut--
            }
            else
                break ; exit the loop if something poped-up
        }
        
        WinWaitClose, 7-Zip 4.65 Setup, Installing, 1
        if ErrorLevel
            TestsFailed("'7-Zip 4.65 Setup (Installing)' window failed to close (iTimeOut=" iTimeOut ").")
        else
            TestsOK("'7-Zip 4.65 Setup (Installing)' window closed (iTimeOut=" iTimeOut ").")
    }
}


; Test if '7-Zip 4.65 Setup (Completing)' window appeared, if so
; check 'I want to reboot manually' radio button (if exist) and hit 'Finish' button
TestsTotal++
if bContinue
{
    WinWait, 7-Zip 4.65 Setup, Completing, 3
    if ErrorLevel
        TestsFailed("'7-Zip 4.65 Setup (Completing)' window doesn't exist.")
    else
    {
        WinActivate ; 7-Zip 4.65 Setup, Completing
        WinWaitActive, 7-Zip 4.65 Setup, Completing, 3
        if ErrorLevel
            TestsFailed("Unable to activate existing '7-Zip 4.65 Setup (Completing)' window.")
        else
        {
            ControlGet, bVisible, Visible,, 7-Zip 4.65 Setup, Completing
            if bVisible = 1 ; Control is visible
            {
                Control, Check, , Button5, 7-Zip 4.65 Setup, Completing ; Check 'I want to reboot manually' radiobutton
                if ErrorLevel
                    TestsFailed("Unable to check 'I want to reboot manually' radiobutton in '7-Zip 4.65 Setup (Completing)' window.")
                else
                {
                    ControlClick, Button2, 7-Zip 4.65 Setup, Completing ; Hit 'Finish' button
                    if ErrorLevel
                        TestsFailed("Unable to hit 'Finish' button in '7-Zip 4.65 Setup (Completing)' window.")
                    else
                    {
                        WinWaitClose, 7-Zip 4.65 Setup, Completing, 3
                        if ErrorLevel
                            TestsFailed("'7-Zip 4.65 Setup (Completing)' window failed to close after clicking on 'Finish' button.")
                        else
                            TestsOK("'I want to reboot manually' radiobutton was checked and 'Finish' button was clicked in '7-Zip 4.65 Setup (Completing)' window and it closed.")
                    }
                }
            }
            else
            {
                ControlClick, Button2, 7-Zip 4.65 Setup, Completing ; Hit 'Finish' button
                if ErrorLevel
                    TestsFailed("Unable to hit 'Finish' button in '7-Zip 4.65 Setup (Completing)' window.")
                else
                {
                    WinWaitClose, 7-Zip 4.65 Setup, Completing, 3
                    if ErrorLevel
                        TestsFailed("'7-Zip 4.65 Setup (Completing)' window failed to close after clicking on 'Finish' button.")
                    else
                        TestsOK("'Finish' button was clicked in '7-Zip 4.65 Setup (Completing)' window and it closed.")
                }
            }
        }
    }
}


; Check if program exists
TestsTotal++
if bContinue
{
    RegRead, UninstallerPath, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\7-Zip, UninstallString
    if ErrorLevel
        TestsFailed("Either we can't read from registry or data doesn't exist.")
    else
    {
        StringReplace, UninstallerPath, UninstallerPath, `",, All ; String contains quotes, replace em
        SplitPath, UninstallerPath,, InstalledDir
        IfNotExist, %InstalledDir%\%MainAppFile%
            TestsFailed("Something went wrong, can't find '" InstalledDir "\" MainAppFile "'.")
        else
            TestsOK("The application has been installed, because '" InstalledDir "\" MainAppFile "' was found.")
    }
}
