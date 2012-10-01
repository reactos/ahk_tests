/*
 * Designed for LGeneral 1.1
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

ModuleExe = %A_WorkingDir%\Apps\LGeneral 1.1 Setup.exe
TestName = 1.install
MainAppFile = lgeneral.exe ; Mostly this is going to be process we need to look for

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
        RegRead, UninstallerPath, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\LGeneral_is1, UninstallString
        if ErrorLevel
        {
            ; There was a problem (such as a nonexistent key or value). 
            ; That probably means we have not installed this app before.
            ; Check in default directory to be extra sure
            bHardcoded := true ; To know if we got path from registry or not
            szDefaultDir = %A_ProgramFiles%\LGeneral
            IfNotExist, %szDefaultDir%
            {
                TestsInfo("No previous versions detected in hardcoded path: '" szDefaultDir "'.")
                bContinue := true
            }
            else
            {   
                UninstallerPath = %szDefaultDir%\unins000.exe /silent
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
                UninstallerPath = %UninstallerPath% /silent
                WaitUninstallDone(UninstallerPath, 3) ; Reported child name is '_iu14D2N.tmp'
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
        RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\MicroSoft\Windows\CurrentVersion\Uninstall\LGeneral_is1

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


; Test if 'Setup (This will)' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Setup, This will, 5
    if ErrorLevel
        TestsFailed("'Setup (This will)' window failed to appear.")
    else
    {
        ControlClick, Button1, Setup, This will ; Hit 'Yes' button
        if ErrorLevel
            TestsFailed("Unable to hit 'Yes' button in 'Setup (This will)' window.")
        else
        {
            WinWaitClose, Setup, This will, 3
            if ErrorLevel
                TestsFailed("'Setup (This will)' window failed to close despite 'Yes' button being clicked.")
            else
                TestsOK("'Setup (This will)' window appeared, 'Yes' button clicked and window closed.")
        }
    }
}


; Test if 'Setup - LGeneral (Welcome)' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Setup - LGeneral, Welcome, 5
    if ErrorLevel
        TestsFailed("'Setup - LGeneral (Welcome)' window failed to appear.")
    else
    {
        ControlClick, TButton2, Setup - LGeneral, Welcome ; Hit 'Next' button
        if ErrorLevel
            TestsFailed("Unable to hit 'Next' button in 'Setup - LGeneral (Welcome)' window.")
        else
            TestsOK("'Setup - LGeneral (Welcome)' window appeared and 'Next' button was clicked.")
    }
}


; Test if 'Setup - LGeneral (SelectDir)' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Setup - LGeneral, SelectDir, 3
    if ErrorLevel
        TestsFailed("'Setup - LGeneral (SelectDir)' window failed to appear.")
    else
    {
        ControlClick, TButton2, Setup - LGeneral, SelectDir ; Hit 'Next' button
        if ErrorLevel
            TestsFailed("Unable to hit 'Next' button in 'Setup - LGeneral (SelectDir)' window.")
        else
            TestsOK("'Setup - LGeneral (SelectDir)' window appeared and 'Next' button was clicked.")
    }
}


; Test if 'Setup - LGeneral (SelectProgramGroup)' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Setup - LGeneral, SelectProgramGroup, 3
    if ErrorLevel
        TestsFailed("'Setup - LGeneral (SelectProgramGroup)' window failed to appear.")
    else
    {
        ControlClick, TButton2, Setup - LGeneral, SelectProgramGroup ; Hit 'Next' button
        if ErrorLevel
            TestsFailed("Unable to hit 'Next' button in 'Setup - LGeneral (SelectProgramGroup)' window.")
        else
            TestsOK("'Setup - LGeneral (SelectProgramGroup)' window appeared and 'Next' button was clicked.")
    }
}


; Test if 'Setup - LGeneral (SelectTasks)' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Setup - LGeneral, SelectTasks, 3
    if ErrorLevel
        TestsFailed("'Setup - LGeneral (SelectTasks)' window failed to appear.")
    else
    {
        ControlClick, TButton2, Setup - LGeneral, SelectTasks ; Hit 'Next' button
        if ErrorLevel
            TestsFailed("Unable to hit 'Next' button in 'Setup - LGeneral (SelectTasks)' window.")
        else
            TestsOK("'Setup - LGeneral (SelectTasks)' window appeared and 'Next' button was clicked.")
    }
}


; Test if 'Setup - LGeneral (Ready)' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Setup - LGeneral, Ready, 3
    if ErrorLevel
        TestsFailed("'Setup - LGeneral (Ready)' window failed to appear.")
    else
    {
        ControlClick, TButton2, Setup - LGeneral, Ready ; Hit 'Install' button
        if ErrorLevel
            TestsFailed("Unable to hit 'Install' button in 'Setup - LGeneral (Ready)' window.")
        else
            TestsOK("'Setup - LGeneral (Ready)' window appeared and 'Install' button was clicked.")
    }
}


; Skip 'Setup - LGeneral (Installing)' window


; Test if 'Setup - LGeneral (Finished)' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Setup - LGeneral, Finished, 7 ; Wait longer, because we skipped one window
    if ErrorLevel
        TestsFailed("'Setup - LGeneral (Finished)' window failed to appear.")
    else
    {
        Control, Uncheck, , TCheckBox1, Setup - LGeneral, Finished ; uncheck 'Launch LBreakout2' checkbox
        if ErrorLevel
            TestsFailed("Unable to uncheck 'Launch LBreakout2' checkbox in 'Setup - LGeneral (Finished)' window.")
        else
        {
            ControlGet, bChecked, Checked, TCheckBox1
            if bChecked = 1
                TestsFailed("'Launch LBreakout2' checkbox in 'Setup - LGeneral (Finished)' window reported as unchecked, but further inspection proves that it was still checked.")
            else
            {
                ControlClick, TButton2, Setup - LGeneral, Finished ; Hit 'Finish' button
                if ErrorLevel
                    TestsFailed("Unable to hit 'Finish' button in 'Setup - LGeneral (Finished)' window.")
                else
                {
                    WinWaitClose, Setup - LGeneral, Finished, 3
                    if ErrorLevel
                        TestsFailed("'Setup - LGeneral (Finished)' window failed to close despite 'Finish' button being clicked.")
                    else
                        TestsOK("'Setup - LGeneral (Finished)' window appeared, 'Launch LBreakout2' checkbox unchecked, 'Finish' button clicked and window closed.")
                }
            }
        }
    }
}


; Check if program exists
TestsTotal++
if bContinue
{
    RegRead, UninstallerPath, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\LGeneral_is1, UninstallString
    if ErrorLevel
        TestsFailed("Either we can't read from registry or data doesn't exist.")
    else
    {
        StringReplace, UninstallerPath, UninstallerPath, `",, All
        SplitPath, UninstallerPath,, InstalledDir
        IfNotExist, %InstalledDir%\%MainAppFile%
            TestsFailed("Something went wrong, can't find '" InstalledDir "\" MainAppFile "'.")
        else
            TestsOK("The application has been installed, because '" InstalledDir "\" MainAppFile "' was found.")
    }
}
