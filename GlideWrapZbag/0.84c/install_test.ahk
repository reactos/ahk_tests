/*
 * Designed for GlideWrapZbag 0.84c
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

ModuleExe = %A_WorkingDir%\Apps\GlideWrapZbag 0.84c Setup.exe
TestName = 1.install
MainAppFile = configurator.exe ; Mostly this is going to be process we need to look for

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
        RegRead, UninstallerPath, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\GlidewrapZbag, UninstallString
        if ErrorLevel
        {
            ; There was a problem (such as a nonexistent key or value). 
            ; That probably means we have not installed this app before.
            ; Check in default directory to be extra sure
            bHardcoded := true ; To know if we got path from registry or not
            szDefaultDir = %A_ProgramFiles%\GlideWrapper
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
                WaitUninstallDone(UninstallerPath, 3) ; Reported child name is 'A~NSISu_.exe'
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
        RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\MicroSoft\Windows\CurrentVersion\Uninstall\GlidewrapZbag
        IfExist, %A_AppData%\glide_wrapper.zbag.ini
        {
            FileDelete, %A_AppData%\glide_wrapper.zbag.ini
            if ErrorLevel
                TestsFailed("Unable to delete '" A_AppData "\glide_wrapper.zbag.ini'.")
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


; Test if 'zeckensack's Glide wrapper 0.84c Setup: Installation Options (This will install)' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, zeckensack's Glide wrapper 0.84c Setup: Installation Options, This will install, 7
    if ErrorLevel
        TestsFailed("'zeckensack's Glide wrapper 0.84c Setup: Installation Options (This will install)' window failed to appear.")
    else
    {
        ControlClick, Button2, zeckensack's Glide wrapper 0.84c Setup: Installation Options, This will install ; Hit 'Next' button
        if ErrorLevel
            TestsFailed("Unable to hit 'Next' button in 'zeckensack's Glide wrapper 0.84c Setup: Installation Options (This will install)' window.")
        else
        {
            WinWaitClose, zeckensack's Glide wrapper 0.84c Setup: Installation Options, This will install, 3
            if ErrorLevel
                TestsFailed("'zeckensack's Glide wrapper 0.84c Setup: Installation Options (This will install)' window failed to close despite 'Next' button being clicked.")
            else
                TestsOK("'zeckensack's Glide wrapper 0.84c Setup: Installation Options (This will install)' window appeared, 'Next' button clicked and window closed.")
        }
    }
}


; Test if 'zeckensack's Glide wrapper 0.84c Setup: Installation Folder (Choose a directory)' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, zeckensack's Glide wrapper 0.84c Setup: Installation Folder, Choose a directory, 3
    if ErrorLevel
        TestsFailed("'zeckensack's Glide wrapper 0.84c Setup: Installation Folder (Choose a directory)' window failed to appear.")
    else
    {
        ControlClick, Button2, zeckensack's Glide wrapper 0.84c Setup: Installation Folder, Choose a directory ; Hit 'Next' button
        if ErrorLevel
            TestsFailed("Unable to hit 'Next' button in 'zeckensack's Glide wrapper 0.84c Setup: Installation Folder (Choose a directory)' window.")
        else
            TestsOK("'zeckensack's Glide wrapper 0.84c Setup: Installation Folder (Choose a directory)' window appeared and 'Next' button was clicked.")
    }
}


; Test if 'zeckensack's Glide wrapper 0.84c Setup: Start Menu Folder (Select the Start)' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, zeckensack's Glide wrapper 0.84c Setup: Start Menu Folder, Select the Start, 3
    if ErrorLevel
        TestsFailed("'zeckensack's Glide wrapper 0.84c Setup: Start Menu Folder (Select the Start)' window failed to appear.")
    else
    {
        ControlClick, Button2, zeckensack's Glide wrapper 0.84c Setup: Start Menu Folder, Select the Start ; Hit 'Install' button
        if ErrorLevel
            TestsFailed("Unable to hit 'Install' button in 'zeckensack's Glide wrapper 0.84c Setup: Start Menu Folder (Select the Start)' window.")
        else
            TestsOK("'zeckensack's Glide wrapper 0.84c Setup: Start Menu Folder (Select the Start)' window appeared and 'Install' button was clicked.")
    }
}


; Skip installing window


; Test if 'zeckensack's Glide wrapper 0.84c Setup: Completed (Select the Start)' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, zeckensack's Glide wrapper 0.84c Setup: Completed, Completed, 10 ; we skipped one window
    if ErrorLevel
        TestsFailed("'zeckensack's Glide wrapper 0.84c Setup: Completed (Completed)' window failed to appear.")
    else
    {
        ControlClick, Button2, zeckensack's Glide wrapper 0.84c Setup: Completed, Completed ; Hit 'Close' button
        if ErrorLevel
            TestsFailed("Unable to hit 'Close' button in 'zeckensack's Glide wrapper 0.84c Setup: Completed (Completed)' window.")
        else
        {
            WinWaitClose, zeckensack's Glide wrapper 0.84c Setup: Completed, Completed, 3
            if ErrorLevel
                TestsFailed("'zeckensack's Glide wrapper 0.84c Setup: Completed (Completed)' window failed to close despite 'Close' button being clicked.")
            else
            {
                if not TerminateDefaultBrowser(20)
                    TestsFailed("Either default browser process failed to appear of we failed to terminate it.")
                else
                    TestsOK("'zeckensack's Glide wrapper 0.84c Setup: Completed (Completed)' window appeared, 'Close' button clicked and window closed.")
            }
        }
    }
}


; Check if program exists
TestsTotal++
if bContinue
{
    RegRead, UninstallerPath, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\GlidewrapZbag, UninstallString
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
