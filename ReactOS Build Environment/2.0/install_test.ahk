/*
 * Designed for ReactOS Build Environment 2.0
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

ModuleExe = %A_WorkingDir%\Apps\RosBE 2.0 Setup.exe
TestName = 1.install
MainAppFile = RosBE.cmd

; Test if Setup file exists, if so, delete installed files, and run Setup
TestsTotal++
IfNotExist, %ModuleExe%
    TestsFailed("'" ModuleExe "' not found.")
else
{
    RegRead, UninstallerPath, HKEY_CURRENT_USER, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\ReactOS Build Environment for Windows, UninstallString
    if ErrorLevel
    {
        ; There was a problem (such as a nonexistent key or value). 
        ; That probably means we have not installed this app before.
        ; Check in default directory to be extra sure
        bHardcoded := true ; To know if we got path from registry or not
        szDefaultDir = %A_ProgramFiles%\RosBE
        IfNotExist, %szDefaultDir%
        {
            TestsInfo("No previous versions detected in hardcoded path: '" szDefaultDir "'.")
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
            FileRemoveDir, %InstalledDir%, 1 ; This is Nullsoft and '/S' and '/silent' doesn't work
            if ErrorLevel
                TestsFailed("Unable to delete existing '" InstalledDir "' ('" MainAppFile "' process is reported as terminated).")
            else
            {
                TestsInfo("Succeeded deleting path (registry data), because uninstaller did not: '" InstalledDir "'.")
                bContinue := true
            }
        }
    }

    if bContinue
    {
        RegDelete, HKEY_CURRENT_USER, SOFTWARE\MicroSoft\Windows\CurrentVersion\Uninstall\ReactOS Build Environment for Windows
        IfExist, %A_AppData%\RosBE
        {
            FileRemoveDir, %A_AppData%\RosBE, 1
            if ErrorLevel
                TestsFailed("Unable to delete '" A_AppData "\RosBE'.")
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


; Test if 'This wizard' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, ReactOS Build Environment for Windows 2.0 Setup, This wizard, 5
    if ErrorLevel
        TestsFailed("'ReactOS Build Environment for Windows 2.0 Setup (This wizard)' window failed to appear.")
    else
    {
        ControlClick, Button2 ; Hit 'Next' button
        if ErrorLevel
            TestsFailed("Unable to hit 'Next' button in 'ReactOS Build Environment for Windows 2.0 Setup (This wizard)' window.")
        else
        {
            WinWaitClose, ReactOS Build Environment for Windows 2.0 Setup, This wizard, 3
            if ErrorLevel
                TestsFailed("'ReactOS Build Environment for Windows 2.0 Setup (This wizard)' window failed to close despite 'Next' button being clicked.")
            else
                TestsOK("'ReactOS Build Environment for Windows 2.0 Setup (This wizard)' window appeared, 'Next' button clicked and window closed.")
        }
    }
}


; Test if 'License Agreement' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, ReactOS Build Environment for Windows 2.0 Setup, License Agreement, 3
    if ErrorLevel
        TestsFailed("'ReactOS Build Environment for Windows 2.0 Setup (License Agreement)' window failed to appear.")
    else
    {
        ControlClick, Button2 ; Hit 'I Agree' button
        if ErrorLevel
            TestsFailed("Unable to hit 'I Agree' button in 'ReactOS Build Environment for Windows 2.0 Setup (License Agreement)' window.")
        else
            TestsOK("'ReactOS Build Environment for Windows 2.0 Setup (License Agreement)' window appeared and 'I Agree' button was clicked.")
    }
}


; Test if 'Choose Install Location' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, ReactOS Build Environment for Windows 2.0 Setup, Choose Install Location, 3
    if ErrorLevel
        TestsFailed("'ReactOS Build Environment for Windows 2.0 Setup (Choose Install Location)' window failed to appear.")
    else
    {
        ControlClick, Button2 ; Hit 'Next' button
        if ErrorLevel
            TestsFailed("Unable to hit 'Next' button in 'ReactOS Build Environment for Windows 2.0 Setup (Choose Install Location)' window.")
        else
            TestsOK("'ReactOS Build Environment for Windows 2.0 Setup (Choose Install Location)' window appeared and 'Next' button was clicked.")
    }
}


; Test if 'Select ReactOS Source Location' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, ReactOS Build Environment for Windows 2.0 Setup, Select ReactOS Source Location, 3
    if ErrorLevel
        TestsFailed("'ReactOS Build Environment for Windows 2.0 Setup (Select ReactOS Source Location)' window failed to appear.")
    else
    {
        ControlClick, Button2 ; Hit 'Next' button
        if ErrorLevel
            TestsFailed("Unable to hit 'Next' button in 'ReactOS Build Environment for Windows 2.0 Setup (Select ReactOS Source Location)' window.")
        else
            TestsOK("'ReactOS Build Environment for Windows 2.0 Setup (Select ReactOS Source Location)' window appeared and 'Next' button was clicked.")
    }
}


; Test if 'Choose Start Menu Folder' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, ReactOS Build Environment for Windows 2.0 Setup, Choose Start Menu Folder, 3
    if ErrorLevel
        TestsFailed("'ReactOS Build Environment for Windows 2.0 Setup (Choose Start Menu Folder)' window failed to appear.")
    else
    {
        ControlClick, Button2 ; Hit 'Next' button
        if ErrorLevel
            TestsFailed("Unable to hit 'Next' button in 'ReactOS Build Environment for Windows 2.0 Setup (Choose Start Menu Folder)' window.")
        else
            TestsOK("'ReactOS Build Environment for Windows 2.0 Setup (Choose Start Menu Folder)' window appeared and 'Next' button was clicked.")
    }
}


; Test if 'Choose Components' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, ReactOS Build Environment for Windows 2.0 Setup, Choose Components, 3
    if ErrorLevel
        TestsFailed("'ReactOS Build Environment for Windows 2.0 Setup (Choose Components)' window failed to appear.")
    else
    {
        ControlClick, Button2 ; Hit 'Install' button
        if ErrorLevel
            TestsFailed("Unable to hit 'Install' button in 'ReactOS Build Environment for Windows 2.0 Setup (Choose Components)' window.")
        else
            TestsOK("'ReactOS Build Environment for Windows 2.0 Setup (Choose Components)' window appeared and 'Install' button was clicked.")
    }
}


; Test if can get thru 'Installing' window
TestsTotal++
if bContinue
{
    WinWaitActive, ReactOS Build Environment for Windows 2.0 Setup, Installing, 3
    if ErrorLevel
        TestsFailed("'ReactOS Build Environment for Windows 2.0 Setup (Installing)' window failed to appear.")
    else
    {
        TestsInfo("'ReactOS Build Environment for Windows 2.0 Setup (Installing)' window appeared, waiting for it to close.")
        iTimeOut := 45
        while iTimeOut > 0
        {
            IfWinActive, ReactOS Build Environment for Windows 2.0 Setup, Installing
            {
                WinWaitClose, ReactOS Build Environment for Windows 2.0 Setup, Installing, 1
                iTimeOut--
            }
            else
                break ; exit the loop if something poped-up
        }

        IfWinNotActive, ReactOS Build Environment for Windows 2.0 Setup, A REG ; This window pops-up
            TestsFailed("'ReactOS Build Environment for Windows 2.0 Setup (A REG)' window failed to appear (iTimeOut=" iTimeOut ").")
        else
        {
            ControlClick, Button1 ; Hit 'OK' button
            if ErrorLevel
                TestsFailed("Unable to hit 'OK' button in 'ReactOS Build Environment for Windows 2.0 Setup (A REG)' window.")
            else
            {
                WinWaitClose, ReactOS Build Environment for Windows 2.0 Setup, A REG, 3
                if ErrorLevel
                    TestsFailed("'ReactOS Build Environment for Windows 2.0 Setup (A REG)' window failed to close despite 'OK' button being clicked.")
                else
                    TestsOK("'ReactOS Build Environment for Windows 2.0 Setup (A REG)' window appeared, 'OK' button clicked and window closed.")
            }
        }
    }
}


; Test if 'Completing' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, ReactOS Build Environment for Windows 2.0 Setup, Completing, 3
    if ErrorLevel
        TestsFailed("'ReactOS Build Environment for Windows 2.0 Setup (Completing)' window failed to appear.")
    else
    {
        ControlClick, Button2 ; Hit 'Finish' button
        if ErrorLevel
            TestsFailed("Unable to hit 'Finish' button in 'ReactOS Build Environment for Windows 2.0 Setup (Completing)' window.")
        else
        {
            WinWaitClose, ReactOS Build Environment for Windows 2.0 Setup, Completing, 3
            if ErrorLevel
                TestsFailed("'ReactOS Build Environment for Windows 2.0 Setup (Completing)' window failed to close despite 'Finish' button being clicked.")
            else
                TestsOK("'ReactOS Build Environment for Windows 2.0 Setup (Completing)' window appeared, 'Finish' button clicked and window closed.")
        }
    }
}


; Check if program exists
TestsTotal++
if bContinue
{
    ; No need to sleep, because we already waited for process to appear
    RegRead, UninstallerPath, HKEY_CURRENT_USER, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\ReactOS Build Environment for Windows, UninstallString
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
