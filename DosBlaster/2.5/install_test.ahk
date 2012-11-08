/*
 * Designed for DosBlaster 2.5 Setup
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

ModuleExe = %A_WorkingDir%\Apps\DosBlaster 2.5 Setup.exe
TestName = 1.install
MainAppFile = dosbox.exe ; Mostly this is going to be process we need to look for

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
        RegRead, UninstallerPath, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\DosBlaster_is1, UninstallString
        if ErrorLevel
        {
            ; There was a problem (such as a nonexistent key or value). 
            ; That probably means we have not installed this app before.
            ; Check in default directory to be extra sure
            bHardcoded := true ; To know if we got path from registry or not
            IfNotExist, %A_ProgramFiles%\DosBlaster
                bContinue := true ; No previous versions detected in hardcoded path
            else
            {   
                UninstallerPath = %A_ProgramFiles%\DosBlaster\2.5\unins000.exe /SILENT
                WaitUninstallDone(UninstallerPath, 3) ; There is one child process
                if bContinue
                {
                    IfNotExist, %A_ProgramFiles%\DosBlaster ; Uninstaller might delete the dir
                    {
                        bContinue := true
                        TestsInfo("Uninstaller deleted hardcoded path '" A_ProgramFiles "\DosBlaster'.")
                    }
                    else
                    {
                        FileRemoveDir, %A_ProgramFiles%\DosBlaster, 1
                        if ErrorLevel
                            TestsFailed("Unable to delete hardcoded path '" A_ProgramFiles "\DosBlaster' ('" MainAppFile "' process is reported as terminated).'")
                        else
                            bContinue := true
                    }
                }
            }
        }
        else
        {
            StringReplace, UninstallerPath, UninstallerPath, `", , All
            SplitPath, UninstallerPath,, InstalledDir
            IfNotExist, %InstalledDir%
                bContinue := true
            else
            {
                UninstallerPath = %UninstallerPath% /SILENT
                WaitUninstallDone(UninstallerPath, 3) ; There is one child process
                if bContinue
                {
                    IfNotExist, %InstalledDir%
                    {
                        TestsInfo("Uninstaller deleted '" InstalledDir "'.")
                        bContinue := true
                    }
                    else
                    {
                        FileRemoveDir, %InstalledDir%, 1 ; Delete just in case
                        if ErrorLevel
                            TestsFailed("Unable to delete existing '" InstalledDir "' ('" MainAppFile "' process is reported as terminated).")
                        else
                            bContinue := true
                    }
                }
            }
        }
    }

    if bContinue
    {
        if not TerminateTmpProcesses() ; Silent uninstall switch left us one window, so, terminate its process
            TestsFailed("Unable to terminate some '*.tmp' processes.")
        else
            bContinue := true

        if bContinue
        {
            RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\MicroSoft\Windows\CurrentVersion\Uninstall\DosBlaster_is1

            if bHardcoded
                TestsOK("Either there was no previous versions or we succeeded removing it using hardcoded path.")
            else
                TestsOK("Either there was no previous versions or we succeeded removing it using data from registry.")
            Run %ModuleExe%
        }
    }
}


; Test if 'Setup - DosBlaster (Welcome)' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Setup - DosBlaster, Welcome, 7
    if ErrorLevel
        TestsFailed("'Setup - DosBlaster (Welcome)' window failed to appear.")
    else
    {
        ControlClick, TButton1, Setup - DosBlaster, Welcome ; Hit 'Next' button
        if ErrorLevel
            TestsFailed("Unable to hit 'Next' button in 'Setup - DosBlaster (Welcome)' window.")
        else
        {
            WinWaitClose, Setup - DosBlaster, Welcome, 3
            if ErrorLevel
                TestsFailed("'Setup - DosBlaster (Welcome)' window failed to close despite 'Next' button being clicked.")
            else
                TestsOK("'Setup - DosBlaster (Welcome)' window appeared and 'Next' button was clicked.")
        }
    }
}


; Test if 'Setup - DosBlaster (Select Destination Location)' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Setup - DosBlaster, Select Destination Location, 3
    if ErrorLevel
        TestsFailed("'Setup - DosBlaster (Select Destination Location)' window failed to appear.")
    else
    {
        ControlClick, TButton3, Setup - DosBlaster, Select Destination Location ; Hit 'Next' button
        if ErrorLevel
            TestsFailed("Unable to hit 'Next' button in 'Setup - DosBlaster (Select Destination Location)' window.")
        else
            TestsOK("'Setup - DosBlaster (Select Destination Location)' window appeared and 'Next' button was clicked.")
    }
}


; Test if 'Setup - DosBlaster (Select Start Menu Folder)' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Setup - DosBlaster, Select Start Menu Folder, 3
    if ErrorLevel
        TestsFailed("'Setup - DosBlaster (Select Start Menu Folder)' window failed to appear.")
    else
    {
        ControlClick, TButton4, Setup - DosBlaster, Select Start Menu Folder ; Hit 'Next' button
        if ErrorLevel
            TestsFailed("Unable to hit 'Next' button in 'Setup - DosBlaster (Select Start Menu Folder)' window.")
        else
            TestsOK("'Setup - DosBlaster (Select Start Menu Folder)' window appeared and 'Next' button was clicked.")
    }
}


; Test if 'Setup - DosBlaster (Select Additional Tasks)' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Setup - DosBlaster, Select Additional Tasks, 3
    if ErrorLevel
        TestsFailed("'Setup - DosBlaster (Select Additional Tasks)' window failed to appear.")
    else
    {
        ControlClick, TButton4, Setup - DosBlaster, Select Additional Tasks ; Hit 'Next' button
        if ErrorLevel
            TestsFailed("Unable to hit 'Next' button in 'Setup - DosBlaster (Select Additional Tasks)' window.")
        else
            TestsOK("'Setup - DosBlaster (Select Additional Tasks)' window appeared and 'Next' button was clicked.")
    }
}


; Test if 'Setup - DosBlaster (Ready to Install)' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Setup - DosBlaster, Ready to Install, 3
    if ErrorLevel
        TestsFailed("'Setup - DosBlaster (Ready to Install)' window failed to appear.")
    else
    {
        ControlClick, TButton4, Setup - DosBlaster, Ready to Install ; Hit 'Install' button
        if ErrorLevel
            TestsFailed("Unable to hit 'Install' button in 'Setup - DosBlaster (Ready to Install)' window.")
        else
            TestsOK("'Setup - DosBlaster (Ready to Install)' window appeared and 'Install' button was clicked.")
    }
}


; 'Setup - DosBlaster (Installing)' window appears for a split of second on 5400RPM HDD, so, skip such window checking


; Test if 'Setup - DosBlaster (Completing)' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Setup - DosBlaster, Completing, 10 ; We skipped one window
    if ErrorLevel
        TestsFailed("'Setup - DosBlaster (Completing)' window failed to appear.")
    else
    {
        if (LeftClickControl("TNewCheckListBox1") != 1) ; Helper function
            TestsFailed("Unable to uncheck 'Launch DosBlaster' checkbox in 'Setup - DosBlaster, Completing' window.")
        else
        {
            ControlClick, TButton4, Setup - DosBlaster, Completing ; Hit 'Finish' button
            if ErrorLevel
                TestsFailed("Unable to hit 'Finish' button in 'Setup - DosBlaster (Completing)' window.")
            else
            {
                WinWaitClose, Setup - DosBlaster, Completing, 3
                if ErrorLevel
                    TestsFailed("'Setup - DosBlaster (Completing)' window failed to close despite 'Finish' button being clicked.")
                else
                    TestsOK("'Setup - DosBlaster (Completing)' window appeared, 'Finish' button clicked and window closed.")
            }
        }
    }
}


; Check if program exists
TestsTotal++
if bContinue
{
    RegRead, UninstallerPath, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\DosBlaster_is1, UninstallString
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
