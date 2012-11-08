/*
 * Designed for Super Finder XT 1.6.3.2
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

ModuleExe = %A_WorkingDir%\Apps\Super Finder XT 1.6.3.2 Setup.exe
TestName = 1.install
MainAppFile = SuperFinder.exe ; Mostly this is going to be process we need to look for

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
        RegRead, UninstallerPath, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Super Finder XT_is1, UninstallString
        if ErrorLevel
        {
            ; There was a problem (such as a nonexistent key or value). 
            ; That probably means we have not installed this app before.
            ; Check in default directory to be extra sure
            bHardcoded := true ; To know if we got path from registry or not
            szDefaultDir = %A_ProgramFiles%\FSL\SuperFinder
            IfNotExist, %szDefaultDir%
            {
                TestsInfo("No previous versions detected in hardcoded path: '" szDefaultDir "'.")
                bContinue := true
            }
            else
            {   
                UninstallerPath = %szDefaultDir%\unins000.exe /VERYSILENT
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
                UninstallerPath = %UninstallerPath% /VERYSILENT
                WaitUninstallDone(UninstallerPath, 3) ; Child process '_iu14D2N.tmp'
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
        RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\MicroSoft\Windows\CurrentVersion\Uninstall\Super Finder XT_is1
        RegDelete, HKEY_CURRENT_USER, Software\FreeSoftLand
        if bHardcoded
            TestsOK("Either there was no previous versions or we succeeded removing it using hardcoded path.")
        else
            TestsOK("Either there was no previous versions or we succeeded removing it using data from registry.")
        Run %ModuleExe%
    }
}


; Test if 'Setup - Super Finder XT (Welcome to)' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Setup - Super Finder XT, Welcome to, 5
    if ErrorLevel
        TestsFailed("'Setup - Super Finder XT (Welcome to)' window failed to appear.")
    else
    {
        ControlClick, TNewButton1 ; Setup - Super Finder XT, Welcome to ; Hit 'Next' button
        if ErrorLevel
            TestsFailed("Unable to hit 'Next' button in 'Setup - Super Finder XT (Welcome to)' window.")
        else
        {
            WinWaitClose, Setup - Super Finder XT, Welcome to, 3
            if ErrorLevel
                TestsFailed("'Setup - Super Finder XT (Welcome to)' window failed to close despite 'Next' button being clicked.")
            else
                TestsOK("'Setup - Super Finder XT (Welcome to)' window appeared, 'Next' button clicked and window closed.")
        }
    }
}


; Test if 'Setup - Super Finder XT (License Agreement)' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Setup - Super Finder XT, License Agreement, 3
    if ErrorLevel
        TestsFailed("'Setup - Super Finder XT (License Agreement)' window failed to appear.")
    else
    {
        Control, Check,, TNewRadioButton1, Setup - Super Finder XT, License Agreement ; Check 'I accept the agreement' radiobutton
        if ErrorLevel
            TestsFailed("Unable to check 'I accept' radiobutton in 'Setup - Super Finder XT (License Agreement)' window.")
        else
        {
            ControlClick, TNewButton2 ; Hit 'Next' button
            if ErrorLevel
                TestsFailed("Unable to hit 'Next' button in 'Setup - Super Finder XT (License Agreement)' window.")
            else
                TestsOK("'Setup - Super Finder XT (License Agreement)' window appeared, 'I accept' radiobutton checked and 'Next' button was clicked.")
        }
    }
}


; Test if 'Setup - Super Finder XT (Information)' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Setup - Super Finder XT, Information, 3
    if ErrorLevel
        TestsFailed("'Setup - Super Finder XT (Information)' window failed to appear.")
    else
    {
        ControlClick, TNewButton2 ; Hit 'Next' button
        if ErrorLevel
            TestsFailed("Unable to hit 'Next' button in 'Setup - Super Finder XT (Information)' window.")
        else
            TestsOK("'Setup - Super Finder XT (Information)' window appeared and 'Next' button was clicked.")
    }
}


; Test if 'Setup - Super Finder XT (Select Destination)' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Setup - Super Finder XT, Select Destination, 3
    if ErrorLevel
        TestsFailed("'Setup - Super Finder XT (Select Destination)' window failed to appear.")
    else
    {
        ControlClick, TNewButton3 ; Hit 'Next' button
        if ErrorLevel
            TestsFailed("Unable to hit 'Next' button in 'Setup - Super Finder XT (Select Destination)' window.")
        else
            TestsOK("'Setup - Super Finder XT (Select Destination)' window appeared and 'Next' button was clicked.")
    }
}


; Test if 'Setup - Super Finder XT (Select Start)' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Setup - Super Finder XT, Select Start, 3
    if ErrorLevel
        TestsFailed("'Setup - Super Finder XT (Select Start)' window failed to appear.")
    else
    {
        ControlClick, TNewButton4 ; Hit 'Next' button
        if ErrorLevel
            TestsFailed("Unable to hit 'Next' button in 'Setup - Super Finder XT (Select Start)' window.")
        else
            TestsOK("'Setup - Super Finder XT (Select Start)' window appeared and 'Next' button was clicked.")
    }
}


; Test if 'Setup - Super Finder XT (Select Additional)' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Setup - Super Finder XT, Select Additional, 3
    if ErrorLevel
        TestsFailed("'Setup - Super Finder XT (Select Additional)' window failed to appear.")
    else
    {
        ControlClick, TNewButton4 ; Hit 'Next' button
        if ErrorLevel
            TestsFailed("Unable to hit 'Next' button in 'Setup - Super Finder XT (Select Additional)' window.")
        else
            TestsOK("'Setup - Super Finder XT (Select Additional)' window appeared and 'Next' button was clicked.")
    }
}


; Test if 'Setup - Super Finder XT (Ready to)' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Setup - Super Finder XT, Ready to, 3
    if ErrorLevel
        TestsFailed("'Setup - Super Finder XT (Ready to)' window failed to appear.")
    else
    {
        ControlClick, TNewButton4 ; Hit 'Install' button
        if ErrorLevel
            TestsFailed("Unable to hit 'Install' button in 'Setup - Super Finder XT (Ready to)' window.")
        else
            TestsOK("'Setup - Super Finder XT (Ready to)' window appeared and 'Install' button was clicked.")
    }
}


; Test if can get thru 'Setup - Super Finder XT (Installing)' window
TestsTotal++
if bContinue
{
    WinWaitActive, Setup - Super Finder XT, Installing, 3
    if ErrorLevel
        TestsFailed("'Setup - Super Finder XT (Installing)' window failed to appear.")
    else
    {
        iTimeOut := 20
        while iTimeOut > 0
        {
            IfWinActive, Setup - Super Finder XT, Installing
            {
                WinWaitClose, Setup - Super Finder XT, Installing, 1
                iTimeOut--
            }
            else
                break ; exit the loop if something poped-up
        }
        
        WinWaitClose, Setup - Super Finder XT, Installing, 1
        if ErrorLevel
            TestsFailed("'Setup - Super Finder XT (Installing)' window failed to close (iTimeOut=" iTimeOut ").")
        else
            TestsOK("'Setup - Super Finder XT (Installing)' window closed (iTimeOut=" iTimeOut ").")
    }
}


; Test if 'Setup - Super Finder XT (Completing)' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Setup - Super Finder XT, Completing, 3
    if ErrorLevel
        TestsFailed("'Setup - Super Finder XT (Completing)' window failed to appear.")
    else
    {
        if (LeftClickControl("TNewCheckListBox1") != 1) ; Helper function
            TestsFailed("Unable to uncheck 'Launch Super Finder XT' in 'Setup - Super Finder XT (Completing)' window.")
        else
        {
            ControlClick, TNewButton4 ; Hit 'Finish' button
            if ErrorLevel
                TestsFailed("Unable to hit 'Finish' button in 'Setup - Super Finder XT (Completing)' window.")
            else
            {
                WinWaitClose, Setup - Super Finder XT, Completing, 3
                if ErrorLevel
                    TestsFailed("'Setup - Super Finder XT (Completing)' window failed to close despite 'Finish' button being clicked.")
                else
                    TestsOK("'Setup - Super Finder XT (Completing)' window appeared and 'Finish' button was clicked.")
            }
        }
    }
}


; Check if program exists
TestsTotal++
if bContinue
{
    RegRead, UninstallerPath, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Super Finder XT_is1, UninstallString
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
