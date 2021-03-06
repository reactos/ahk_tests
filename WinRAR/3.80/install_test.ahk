/*
 * Designed for WinRAR 3.80
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

ModuleExe = %A_WorkingDir%\Apps\WinRAR 3.80 Setup.exe
TestName = 1.install
MainAppFile = WinRAR.exe ; Mostly this is going to be process we need to look for

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
        RegRead, UninstallerPath, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\WinRAR archiver, UninstallString
        if ErrorLevel
        {
            ; There was a problem (such as a nonexistent key or value). 
            ; That probably means we have not installed this app before.
            ; Check in default directory to be extra sure
            bHardcoded := true ; To know if we got path from registry or not
            szDefaultDir = %A_ProgramFiles%\WinRAR
            IfNotExist, %szDefaultDir%
            {
                TestsInfo("No previous versions detected in hardcoded path: '" szDefaultDir "'.")
                bContinue := true
            }
            else
            {
                Run, regsvr32 /s /u "%szDefaultDir%\RarExt.dll"
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
                Run, regsvr32 /s /u "%InstalledDir%\RarExt.dll"
                Process, Close, explorer.exe ; Explorer restart is required
                UninstallerPath = %UninstallerPath% /S
                WaitUninstallDone(UninstallerPath, 3) ; Child process 'cmd.exe'

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
        RegDelete, HKEY_CURRENT_USER, SOFTWARE\WinRAR
        RegDelete, HKEY_CURRENT_USER, SOFTWARE\WinRAR SFX
        RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\MicroSoft\Windows\CurrentVersion\Uninstall\WinRAR archiver
        IfExist, %A_AppData%\WinRAR
        {
            FileRemoveDir, %A_AppData%\WinRAR, 1
            if ErrorLevel
                TestsFailed("Unable to delete '" A_AppData "\WinRAR'.")
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



; Test if window with 'Install' button appeared
TestsTotal++
if bContinue
{
    WinWait, WinRAR 3.80, Install, 15
    if ErrorLevel
        TestsFailed("'WinRAR 3.80 (Install)' window doesn't exist.")
    else
    {
        WinActivate ; WinRAR 3.80, Install
        WinWaitActive, WinRAR 3.80, Install, 3
        if ErrorLevel
            TestsFailed("Unable to activate existing 'WinRAR 3.80 (Install)' window.")
        else
        {
            ControlClick, Button2, WinRAR 3.80, Install
            if ErrorLevel
                TestsFailed("Unable to click 'Install' button in 'WinRAR 3.80 (Install)' window.")
            else
            {
                WinWaitClose, WinRAR 3.80, Install, 3
                if ErrorLevel
                    TestsFailed("'WinRAR 3.80 (Install)' window failed to close despite 'Install' button being clicked.")
                else
                    TestsOK("'WinRAR 3.80' window appeared, 'Install' button clicked and window closed.")
            }
        }
    }
}


; Test if 'Shell integration' window appeared
TestsTotal++
if bContinue
{
    WinWait, WinRAR Setup, Shell integration, 5
    if ErrorLevel
        TestsFailed("'WinRAR Setup (Shell integration)' window doesn't exist.")
    else
    {
        WinActivate ; WinRAR Setup, Shell integration
        WinWaitActive, WinRAR Setup, Shell integration, 5
        if ErrorLevel
            TestsFailed("Unable to activate existing 'WinRAR Setup (Shell integration)' window.")
        else
        {
            ControlClick, Button27, WinRAR Setup, Shell integration
            if ErrorLevel
                TestsFailed("Unable to click 'OK' in 'WinRAR Setup (Shell integration)' window.")
            else
                TestsOK("'WinRAR Setup (Shell integration)' window appeared and 'OK' was clicked.")
        }
    }
}


; Test if 'WinRAR has been successfully' window appeared
TestsTotal++
if bContinue
{
    WinWait, WinRAR Setup, WinRAR has been successfully, 5
    if ErrorLevel
        TestsFailed("'WinRAR Setup (WinRAR has been successfully)' window doesn't exist.")
    else
    {
        WinActivate ; WinRAR Setup, WinRAR has been successfully
        WinWaitActive, WinRAR Setup, WinRAR has been successfully, 3
        if ErrorLevel
            TestsFailed("Unable to activate existing 'WinRAR Setup (WinRAR has been successfully)' window.")
        else
        {
            ControlClick, Button1, WinRAR Setup, WinRAR has been successfully
            if ErrorLevel
                TestsFailed("Unable to click 'Done' button in 'WinRAR Setup (WinRAR has been successfully)' window.")
            else
            {
                WinWaitClose, WinRAR Setup, WinRAR has been successfully, 3
                if ErrorLevel
                    TestsFailed("'WinRAR Setup (WinRAR has been successfully)' window failed to close despite 'Done' button being clicked.")
                else
                {
                    TestsInfo("'WinRAR Setup (WinRAR has been successfully)' window closed.")
                    SetTitleMatchMode, 2 ; A window's title can contain WinTitle anywhere inside it to be a match.
                    ; WinRAR will open explorer window, close it
                    WinWait, WinRAR ahk_class CabinetWClass,, 22
                    if ErrorLevel
                        TestsFailed("Explorer window 'WinRAR' (SetTitleMatchMode=" A_TitleMatchMode ") failed to appear.")
                    else
                    {
                        WinClose, WinRAR ahk_class CabinetWClass
                        WinWaitClose, WinRAR ahk_class CabinetWClass,, 5
                        if ErrorLevel
                            TestsFailed("Unable to close explorer window 'WinRAR' (SetTitleMatchMode=" A_TitleMatchMode ").")
                        else
                            TestsOK("'WinRAR Setup (WinRAR has been successfully)' window appeared, 'Done' button clicked and window closed.")
                    }
                }
            }
        }
    }
}


; Check if program exists
TestsTotal++
if bContinue
{
    RegRead, UninstallerPath, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\WinRAR archiver, UninstallString
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
