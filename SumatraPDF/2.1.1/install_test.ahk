/*
 * Designed for SumatraPDF 2.1.1
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

ModuleExe = %A_WorkingDir%\Apps\SumatraPDF 2.1.1 Setup.exe
TestName = 1.install
MainAppFile = SumatraPDF.exe ; Mostly this is going to be process we need to look for

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
        RegRead, UninstallerPath, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\SumatraPDF, UninstallString
        if ErrorLevel
        {
            ; There was a problem (such as a nonexistent key or value). 
            ; That probably means we have not installed this app before.
            ; Check in default directory to be extra sure
            bHardcoded := true ; To know if we got path from registry or not
            szDefaultDir = %A_ProgramFiles%\SumatraPDF
            IfNotExist, %szDefaultDir%
            {
                TestsInfo("No previous versions detected in hardcoded path: '" szDefaultDir "'.")
                bContinue := true
            }
            else
            {   
                UninstallerPath = %szDefaultDir%\uninstall.exe /s
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
                UninstallerPath = %UninstallerPath% /s
                WaitUninstallDone(UninstallerPath, 3) ; Reported child name is 'sum~inst.exe'
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
        RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\MicroSoft\Windows\CurrentVersion\Uninstall\SumatraPDF
        IfExist, %A_AppData%\SumatraPDF
        {
            FileRemoveDir, %A_AppData%\SumatraPDF, 1
            if ErrorLevel
                TestsFailed("Unable to delete '" A_AppData "\SumatraPDF'.")
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


; Test if 'Install SumatraPDF' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, SumatraPDF 2.1.1 Installer, Install SumatraPDF, 5
    if ErrorLevel
        TestsFailed("'SumatraPDF 2.1.1 Installer (Install SumatraPDF)' window failed to appear.")
    else
    {
        ControlClick, Button1 ; Hit 'Install SumatraPDF' button
        if ErrorLevel
            TestsFailed("Unable to hit 'Install SumatraPDF' button in 'SumatraPDF 2.1.1 Installer (Install SumatraPDF)' window.")
        else
        {
            WinWaitClose, SumatraPDF 2.1.1 Installer, Install SumatraPDF, 3
            if ErrorLevel
                TestsFailed("'SumatraPDF 2.1.1 Installer (Install SumatraPDF)' window failed to close despite 'Install SumatraPDF' button being clicked.")
            else
                TestsOK("'SumatraPDF 2.1.1 Installer (Install SumatraPDF)' window appeared, 'Install SumatraPDF' button clicked and window closed.")
        }
    }
}


; Skip 'Installation in progress' window


; Test if 'Start SumatraPDF' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, SumatraPDF 2.1.1 Installer, Start SumatraPDF, 5 ; We skipped one window
    if ErrorLevel
        TestsFailed("'SumatraPDF 2.1.1 Installer (Start SumatraPDF)' window failed to appear.")
    else
    {
        WinClose, SumatraPDF 2.1.1 Installer, Start SumatraPDF
        WinWaitClose, SumatraPDF 2.1.1 Installer, Start SumatraPDF, 5
        if ErrorLevel
            TestsFailed("'SumatraPDF 2.1.1 Installer (Install SumatraPDF)' window failed to close.")
        else
            TestsOK("'SumatraPDF 2.1.1 Installer (Install SumatraPDF)' window appeared and we closed it.")
    }
}


; Check if program exists
TestsTotal++
if bContinue
{
    ; No need to sleep, because we already waited for process to appear
    RegRead, UninstallerPath, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\SumatraPDF, UninstallString
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
