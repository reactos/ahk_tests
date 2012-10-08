/*
 * Designed for Total Commander 8.0
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

ModulEExe = %A_WorkingDir%\Apps\Total Commander 8.0 Setup.exe
TestName = 1.install
InstallToDir = %A_ProgramFiles%\Total Commander ; This is where we are going to install
MainAppFile = TOTALCMD.exe ; Mostly this is going to be process we need to look for

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
        RegRead, UninstallerPath, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Totalcmd, UninstallString
        if ErrorLevel
        {
            ; There was a problem (such as a nonexistent key or value). 
            ; That probably means we have not installed this app before.
            ; Check in default directory to be extra sure
            bHardcoded := true ; To know if we got path from registry or not
            szDefaultDir = %InstallToDir%
            IfNotExist, %szDefaultDir%
            {
                TestsInfo("No previous versions detected in hardcoded path: '" szDefaultDir "'.")
                bContinue := true
            }
            else
            {   
                UninstallerPath = %szDefaultDir%\tcuninst.exe /7
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
                UninstallerPath = %UninstallerPath% /7
                WaitUninstallDone(UninstallerPath, 3) ; Reported child name is 'cmd.exe'
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
        RegDelete, HKEY_CURRENT_USER, SOFTWARE\Ghisler
        RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\MicroSoft\Windows\CurrentVersion\Uninstall\Totalcmd
        IfExist, %A_AppData%\GHISLER
        {
            FileRemoveDir, %A_AppData%\GHISLER, 1
            if ErrorLevel
                TestsFailed("Unable to delete '" A_AppData "\GHISLER'.")
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


; Test if 'Please select a language' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Installation Total Commander 32+64bit 8.0, Please select a language, 7
    if ErrorLevel
        TestsFailed("'Installation Total Commander 32+64bit 8.0 (Please select a language)' window failed to appear.")
    else
    {
        ; Hit 'Next' button. Specify all params in case some other window will pop up
        ControlClick, Button3, Installation Total Commander 32+64bit 8.0, Please select a language 
        if ErrorLevel
            TestsFailed("Unable to click 'Next' in 'Installation Total Commander 32+64bit 8.0 (Please select a language)' window.")
        else
        {
            WinWaitClose, Installation Total Commander 32+64bit 8.0, Please select a language, 3
            if ErrorLevel
                TestsFailed("")
            else
                TestsOK("'Installation Total Commander 32+64bit 8.0 (Please select a language)' window appeared, 'Next' button clicked and window closed.")
        }
    }
}


; Test if 'Do you also' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Installation Total Commander 32+64bit 8.0, Do you also, 5
    if ErrorLevel
        TestsFailed("'Installation Total Commander 32+64bit 8.0 (Do you also)' window failed to appear.")
    else
    {
        ControlClick, Button3, Installation Total Commander 32+64bit 8.0, Do you also
        if ErrorLevel
            TestsFailed("Unable to click 'Next' in 'Installation Total Commander 32+64bit 8.0 (Do you also)' window.")
        else
            TestsOK("'Installation Total Commander 32+64bit 8.0 (Do you also)' window appeared and 'Next' button was clicked.")
    }
}


; Test if 'Please enter target directory' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Installation Total Commander 32+64bit 8.0, Please enter target directory, 3
    if ErrorLevel
        TestsFailed("'Installation Total Commander 32+64bit 8.0 (Please enter target directory)' window failed to appear.")
    else
    {
        ControlSetText, Edit1, %InstallToDir%, Installation Total Commander 32+64bit 8.0, Please enter target directory
        if ErrorLevel
            TestsFailed("Unable to enter '" InstallToDir "' in 'Installation Total Commander 32+64bit 8.0 (Please enter target directory)' window.")
        else
        {
            ControlClick, Button2, Installation Total Commander 32+64bit 8.0, Please enter target directory
            if ErrorLevel
                TestsFailed("Unable to click 'Next' in 'Installation Total Commander 32+64bit 8.0 (Please enter target directory)' window.")
            else
                TestsOK("'Installation Total Commander 32+64bit 8.0 (Please enter target directory)' window appeared, dir changed, 'Next' button was clicked.")
        }
    }
}


; Test if 'You can define' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Installation Total Commander 32+64bit 8.0, You can define, 3
    if ErrorLevel
        TestsFailed("'Installation Total Commander 32+64bit 8.0 (You can define)' window failed to appear.")
    else
    {
        ControlClick, Button1, Installation Total Commander 32+64bit 8.0, You can define
        if ErrorLevel
            TestsFailed("Unable to click 'Next' in 'Installation Total Commander 32+64bit 8.0 (You can define)' window.")
        else
            TestsOK("'Installation Total Commander 32+64bit 8.0 (You can define)' window appeared and 'Next' button was clicked.")
    }
}


; Test if 'Create shortcut' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Installation Total Commander 32+64bit 8.0, Create shortcut, 5
    if ErrorLevel
        TestsFailed("'Installation Total Commander 32+64bit 8.0 (Create shortcut)' window failed to appear.")
    else
    {
        ControlClick, Button1, Installation Total Commander 32+64bit 8.0, Create shortcut
        if ErrorLevel
            TestsFailed("Unable to click 'Next' in 'Installation Total Commander 32+64bit 8.0 (Create shortcut)' window.")
        else
            TestsOK("'Installation Total Commander 32+64bit 8.0 (Create shortcut)' window appeared and 'Next' button was clicked.")
    }
}


; Test if 'Installation successful' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Installation Total Commander 32+64bit 8.0, Installation successful, 3
    if ErrorLevel
        TestsFailed("'Installation Total Commander 32+64bit 8.0 (Installation successful)' window failed to appear.")
    else
    {
        ControlClick, Button1, Installation Total Commander 32+64bit 8.0, Installation successful
        if ErrorLevel
            TestsFailed("Unable to click 'OK' in 'Installation Total Commander 32+64bit 8.0 (Installation successful)' window. ")
        else
        {
            WinWaitClose, Installation Total Commander 32+64bit 8.0,, 3
            if ErrorLevel
                TestsFailed("'Installation Total Commander 32+64bit 8.0' window failed to close.")
            else
                TestsOK("'Installation Total Commander 32+64bit 8.0 (Installation successful)' window appeared, 'OK' button was clicked and window closed.")
        }
    }
}


; Check if program exists
TestsTotal++
if bContinue
{
    RegRead, UninstallerPath, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Totalcmd, UninstallString
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
