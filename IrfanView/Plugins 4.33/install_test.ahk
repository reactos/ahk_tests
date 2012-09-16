/*
 * Designed for IrfanView Plugins 4.33
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

ModuleExe = %A_WorkingDir%\Apps\IrfanView Plugins 4.33 Setup.exe
TestName = 1.install
MainAppFile = IV_Player.exe ; Mostly this is going to be process we need to look for

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
        ; Installer reads IrfanView path from registry, so do we
        RegRead, UninstallerPath, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\IrfanView, UninstallString
        if ErrorLevel
        {
            ; There was a problem (such as a nonexistent key or value). 
            ; That probably means we have not installed this app before.
            ; Check in default directory to be extra sure
            bHardcoded := true ; To know if we got path from registry or not
            IfNotExist, %A_ProgramFiles%\IrfanView\Plugins
                bContinue := true ; No previous versions detected in hardcoded path
            else
            {
                IfNotExist, %A_ProgramFiles%\IrfanView\Plugins
                    bContinue := true
                {
                    FileRemoveDir, %A_ProgramFiles%\IrfanView\Plugins, 1
                    if ErrorLevel
                        TestsFailed("Unable to delete hardcoded path '" A_ProgramFiles "\IrfanView\Plugins' ('" MainAppFile "' process is reported as terminated).'")
                    else
                        bContinue := true
                }
            }
        }
        else
        {
            SplitPath, UninstallerPath,, InstalledDir
            IfNotExist, %InstalledDir%
                bContinue := true
            else
            {
                IfNotExist, %InstalledDir%\Plugins
                    bContinue := true
                else
                {
                    FileRemoveDir, %InstalledDir%\Plugins, 1 ; Delete just in case
                    if ErrorLevel
                        TestsFailed("Unable to delete existing '" InstalledDir "\Plugins' ('" MainAppFile "' process is reported as terminated).")
                    else
                        bContinue := true
                }
            }
        }
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


; Check if required MFC42.DLL is installed (Win2k3 SP2 comes with it already)
TestsTotal++
if bContinue
{
    mfc42 = %A_WinDir%\System32\mfc42.dll
    IfNotExist, %mfc42%
    {
        IfNotExist, %A_WorkingDir%\mfc42.dll
            TestsFailed("Neither '" mfc42 "' nor '" A_WorkingDir "\mfc42.dll can be found'.")
        else
        {
            FileCopy, %A_WorkingDir%\mfc42.dll, %mfc42%
            if ErrorLevel
                TestsFailed("Unable to copy '" %A_WorkingDir% "\mfc42.dll' to '" mfc42 "'.")
            else
                TestsOK("Had to copy '" %A_WorkingDir% "\mfc42.dll' to '" mfc42 "'.")
        }
    }
    else
        TestsOK("'" mfc42 "' already exist.")
}


; Test if 'IrfanView PlugIns Setup (This program)' window appeared
TestsTotal++
if bContinue
{
    szInstallDir = %A_ProgramFiles%\IrfanView
    WinWaitActive, IrfanView PlugIns Setup, This program, 7
    if ErrorLevel
        TestsFailed("'IrfanView PlugIns Setup (This program)' window failed to appear.")
    else
    {
        Sleep, 700
        ControlGetText, szPath, Edit1, IrfanView PlugIns Setup, This program
        if ErrorLevel
            TestsFailed("Unable to get 'Destination folder' path from 'IrfanView PlugIns Setup (This program)' window.")
        else
        {
            If szPath =
            {
                ControlSetText, Edit1, %szInstallDir%, IrfanView PlugIns Setup, This program
                if ErrorLevel
                {
                    TestsFailed("Unable to set 'Destination folder' path in 'IrfanView PlugIns Setup (This program)' window.")
                }
                else
                    bContinue := true
            }
            else
                bContinue := true
            
            if bContinue
            {
                ControlClick, Button3, IrfanView PlugIns Setup, This program ; Hit 'Next' button
                if ErrorLevel
                    TestsFailed("Unable to hit 'Next' button in 'IrfanView PlugIns Setup (This program)' window.")
                else
                {
                    WinWaitActive, IrfanView PlugIns Setup, Installation successfull, 7
                    if ErrorLevel
                        TestsFailed("'IrfanView PlugIns Setup (Installation successfull)' window failed to appear.")
                    else
                    {
                        Sleep, 700
                        ControlClick, Button1, IrfanView PlugIns Setup, Installation successfull ; Hit 'OK' button
                        if ErrorLevel
                            TestsFailed("Unable to hit 'OK' button in 'IrfanView PlugIns Setup (Installation successfull)' window.")
                        else
                        {
                            WinWaitClose, IrfanView PlugIns Setup, This program, 5
                            if ErrorLevel
                                TestsFailed("'IrfanView PlugIns Setup (This program)' window failed to close despite 'Next' button being clicked.")
                            else
                                TestsOK("'IrfanView PlugIns Setup (This program)' window appeared, 'Next' button clicked, window closed.")
                        }
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
    Sleep, 2000
    RegRead, UninstallerPath, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\IrfanView, UninstallString
    if ErrorLevel
    {
        IfNotExist, %szInstallDir%\Plugins\%MainAppFile%
            TestsFailed("Something went wrong, can't find '" szInstallDir "\Plugins\" MainAppFile "'.")
        else
            TestsOK("The application has been installed, because '" szInstallDir "\Plugins\" MainAppFile "' was found.")
    }
    else
    {
        SplitPath, UninstallerPath,, InstalledDir
        IfNotExist, %InstalledDir%\Plugins\%MainAppFile%
            TestsFailed("Something went wrong, can't find '" InstalledDir "\Plugins\" MainAppFile "'.")
        else
            TestsOK("The application has been installed, because '" InstalledDir "\Plugins\" MainAppFile "' was found.")
    }
}
