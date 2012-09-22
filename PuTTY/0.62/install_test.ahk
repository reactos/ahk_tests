/*
 * Designed for PuTTY 0.62
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

ModuleExe = %A_WorkingDir%\Apps\PuTTY 0.62 Setup.exe
TestName = 1.install
MainAppFile = putty.exe ; Mostly this is going to be process we need to look for

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
        RegRead, UninstallerPath, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\PuTTY_is1, UninstallString
        if ErrorLevel
        {
            ; There was a problem (such as a nonexistent key or value). 
            ; That probably means we have not installed this app before.
            ; Check in default directory to be extra sure
            bHardcoded := true ; To know if we got path from registry or not
            szDefaultDir = %A_ProgramFiles%\PuTTY
            IfNotExist, %szDefaultDir%
            {
                TestsInfo("No previous versions detected in hardcoded path: '" szDefaultDir "'.")
                bContinue := true
            }
            else
            {   
                ; '/SILENT' and '/VERYSILENT' witches shows dialogs
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
                FileRemoveDir, %InstalledDir%, 1
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

    if bContinue
    {
        RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\MicroSoft\Windows\CurrentVersion\Uninstall\PuTTY_is1
        if bHardcoded
            TestsOK("Either there was no previous versions or we succeeded removing it using hardcoded path.")
        else
            TestsOK("Either there was no previous versions or we succeeded removing it using data from registry.")
        Run %ModuleExe%
    }
}


; Test if 'Setup - PuTTY (Welcome)' window appeared
TestsTotal++
if bContinue
{
    DetectHiddenText, Off ; Hidden text is not detected
    WinWaitActive, Setup - PuTTY, Welcome, 15
    if ErrorLevel
        TestsFailed("'Setup - PuTTY (Welcome)' window failed to appear.")
    else
    {
        ControlClick, TNewButton1, Setup - PuTTY, Welcome ; Hit 'Next' button
        if ErrorLevel
            TestsFailed("Unable to hit 'Next' button in 'Setup - PuTTY (Welcome)' window.")
        else
        {
            WinWaitClose, Setup - PuTTY, Welcome, 3
            if ErrorLevel
                TestsFailed("'Setup - PuTTY (Welcome)' window failed to close despite 'Next' button being clicked.")
            else
                TestsOK("'Setup - PuTTY (Welcome)' window appeared, 'Next' button clicked and window closed.")
        }
    }
}


; Test if 'Setup - PuTTY (Select Destination Location)' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Setup - PuTTY, Select Destination Location, 3
    if ErrorLevel
        TestsFailed("'Setup - PuTTY (Select Destination Location)' window failed to appear.")
    else
    {
        ControlClick, TNewButton3, Setup - PuTTY, Select Destination Location ; Hit 'Next' button
        if ErrorLevel
            TestsFailed("Unable to hit 'Next' button in 'Setup - PuTTY (Select Destination Location)' window.")
        else
            TestsOK("'Setup - PuTTY (Select Destination Location)' window appeared and 'Next' button was clicked.")
    }
}


; Test if 'Setup - PuTTY (Select Start Menu Folder)' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Setup - PuTTY, Select Start Menu Folder, 3
    if ErrorLevel
        TestsFailed("'Setup - PuTTY (Select Start Menu Folder)' window failed to appear.")
    else
    {
        ControlClick, TNewButton4, Setup - PuTTY, Select Start Menu Folder ; Hit 'Next' button
        if ErrorLevel
            TestsFailed("Unable to hit 'Next' button in 'Setup - PuTTY (Select Start Menu Folder)' window.")
        else
            TestsOK("'Setup - PuTTY (Select Start Menu Folder)' window appeared and 'Next' button was clicked.")
    }
}


; Test if 'Setup - PuTTY (Select Additional Tasks)' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Setup - PuTTY, Select Additional Tasks, 3
    if ErrorLevel
        TestsFailed("'Setup - PuTTY (Select Additional Tasks)' window failed to appear.")
    else
    {
        ControlClick, TNewButton4, Setup - PuTTY, Select Additional Tasks ; Hit 'Next' button
        if ErrorLevel
            TestsFailed("Unable to hit 'Next' button in 'Setup - PuTTY (Select Additional Tasks)' window.")
        else
            TestsOK("'Setup - PuTTY (Select Additional Tasks)' window appeared and 'Next' button was clicked.")
    }
}


; Test if 'Setup - PuTTY (Ready to Install)' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Setup - PuTTY, Ready to Install, 3
    if ErrorLevel
        TestsFailed("'Setup - PuTTY (Ready to Install)' window failed to appear.")
    else
    {
        ControlClick, TNewButton4, Setup - PuTTY, Ready to Install ; Hit 'Install' button
        if ErrorLevel
            TestsFailed("Unable to hit 'Install' button in 'Setup - PuTTY (Ready to Install)' window.")
        else
            TestsOK("'Setup - PuTTY (Ready to Install)' window appeared and 'Install' button was clicked.")
    }
}


; Skip 'Setup - PuTTY (Installing)' window, because it appears only for a split of second


; Test if 'Setup - PuTTY (Completing)' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Setup - PuTTY, Completing, 10 ; We skipped window, so, wait longer
    if ErrorLevel
        TestsFailed("'Setup - PuTTY (Completing)' window failed to appear.")
    else
    {
        SendInput, {SPACE} ; Uncheck 'View README.txt' ; FIXME: Control, Uncheck will not work here
        ControlClick, TNewButton4, Setup - PuTTY, Completing ; Hit 'Finish' button
        if ErrorLevel
            TestsFailed("Unable to hit 'Finish' button in 'Setup - PuTTY (Completing)' window.")
        else
        {
            WinWaitClose, Setup - PuTTY, Completing, 3 ; All params are required
            if ErrorLevel
                TestsFailed("'Setup - PuTTY (Completing)' window failed to close despite 'Finish' button being clicked.")
            else
                TestsOK("'Setup - PuTTY (Completing)' window appeared, 'Finish' button clicked and window closed.")
        }
    }
}


; Check if program exists
TestsTotal++
if bContinue
{
    ; No need to sleep, because we already waited for process to appear
    RegRead, UninstallerPath, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\PuTTY_is1, UninstallString
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
