/*
 * Designed for LBreakout2 2.4.1
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

ModuleExe = %A_WorkingDir%\Apps\LBreakout2 2.4.1 Setup.exe
TestName = 1.install
MainAppFile = lbreakout2.exe ; Mostly this is going to be process we need to look for

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
        RegRead, UninstallerPath, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\LBreakout2_is1, UninstallString
        if ErrorLevel
        {
            ; There was a problem (such as a nonexistent key or value). 
            ; That probably means we have not installed this app before.
            ; Check in default directory to be extra sure
            bHardcoded := true ; To know if we got path from registry or not
            szDefaultDir = %A_ProgramFiles%\lbreakout2
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
        RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\MicroSoft\Windows\CurrentVersion\Uninstall\LBreakout2_is1

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


; Test if 'Setup - LBreakout2 (Welcome)' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Setup - LBreakout2, Welcome, 5
    if ErrorLevel
        TestsFailed("'Setup - LBreakout2 (Welcome)' window failed to appear.")
    else
    {
        ControlClick, TButton2, Setup - LBreakout2, Welcome ; Hit 'Next' button
        if ErrorLevel
            TestsFailed("Unable to hit 'Next' button in 'Setup - LBreakout2 (Welcome)' window.")
        else
            TestsOK("'Setup - LBreakout2 (Welcome)' window appeared and 'Next' button was clicked.")
    }
}


; Test if 'Setup - LBreakout2 (SelectDir)' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Setup - LBreakout2, SelectDir, 3
    if ErrorLevel
        TestsFailed("'Setup - LBreakout2 (SelectDir)' window failed to appear.")
    else
    {
        ControlClick, TButton2, Setup - LBreakout2, SelectDir ; Hit 'Next' button
        if ErrorLevel
            TestsFailed("Unable to hit 'Next' button in 'Setup - LBreakout2 (SelectDir)' window.")
        else
            TestsOK("'Setup - LBreakout2 (SelectDir)' window appeared and 'Next' button was clicked.")
    }
}


; Test if 'Setup - LBreakout2 (SelectProgramGroup)' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Setup - LBreakout2, SelectProgramGroup, 3
    if ErrorLevel
        TestsFailed("'Setup - LBreakout2 (SelectProgramGroup)' window failed to appear.")
    else
    {
        ControlClick, TButton2, Setup - LBreakout2, SelectProgramGroup ; Hit 'Next' button
        if ErrorLevel
            TestsFailed("Unable to hit 'Next' button in 'Setup - LBreakout2 (SelectProgramGroup)' window.")
        else
            TestsOK("'Setup - LBreakout2 (SelectProgramGroup)' window appeared and 'Next' button was clicked.")
    }
}


; Test if 'Setup - LBreakout2 (SelectTasks)' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Setup - LBreakout2, SelectTasks, 3
    if ErrorLevel
        TestsFailed("'Setup - LBreakout2 (SelectTasks)' window failed to appear.")
    else
    {
        ControlClick, TButton2, Setup - LBreakout2, SelectTasks ; Hit 'Next' button
        if ErrorLevel
            TestsFailed("Unable to hit 'Next' button in 'Setup - LBreakout2 (SelectTasks)' window.")
        else
            TestsOK("'Setup - LBreakout2 (SelectTasks)' window appeared and 'Next' button was clicked.")
    }
}


; Test if 'Setup - LBreakout2 (Ready)' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Setup - LBreakout2, Ready, 3
    if ErrorLevel
        TestsFailed("'Setup - LBreakout2 (Ready)' window failed to appear.")
    else
    {
        ControlClick, TButton2, Setup - LBreakout2, Ready ; Hit 'Install' button
        if ErrorLevel
            TestsFailed("Unable to hit 'Install' button in 'Setup - LBreakout2 (Ready)' window.")
        else
            TestsOK("'Setup - LBreakout2 (Ready)' window appeared and 'Install' button was clicked.")
    }
}


; Skip 'Setup - LBreakout2 (Installing)' window


; Test if 'Setup - LBreakout2 (Finished)' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Setup - LBreakout2, Finished, 7 ; Wait longer, because we skipped one window
    if ErrorLevel
        TestsFailed("'Setup - LBreakout2 (Finished)' window failed to appear.")
    else
    {
        Control, Uncheck, , TCheckBox1, Setup - LBreakout2, Finished ; uncheck 'Launch LBreakout2' checkbox
        if ErrorLevel
            TestsFailed("Unable to uncheck 'Launch LBreakout2' checkbox in 'Setup - LBreakout2 (Finished)' window.")
        else
        {
            ControlGet, bChecked, Checked,, TCheckBox1
            if bChecked = 1
                TestsFailed("'Launch LBreakout2' checkbox in 'Setup - LBreakout2 (Finished)' window reported as unchecked, but further inspection proves that it was still checked.")
            else
            {
                ControlClick, TButton2, Setup - LBreakout2, Finished ; Hit 'Finish' button
                if ErrorLevel
                    TestsFailed("Unable to hit 'Finish' button in 'Setup - LBreakout2 (Finished)' window.")
                else
                {
                    WinWaitClose, Setup - LBreakout2, Finished, 3
                    if ErrorLevel
                        TestsFailed("'Setup - LBreakout2 (Finished)' window failed to close despite 'Finish' button being clicked.")
                    else
                        TestsOK("'Setup - LBreakout2 (Finished)' window appeared, 'Launch LBreakout2' checkbox unchecked, 'Finish' button clicked and window closed.")
                }
            }
        }
    }
}


; Check if program exists
TestsTotal++
if bContinue
{
    RegRead, UninstallerPath, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\LBreakout2_is1, UninstallString
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
