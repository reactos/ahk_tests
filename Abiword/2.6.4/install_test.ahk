/*
 * Designed for Abiword 2.6.4
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

ModuleExe = %A_WorkingDir%\Apps\Abiword 2.6.4 Setup.exe
TestName = 1.install

bContinue := false
TestsFailed := 0
TestsOK := 0
TestsTotal := 0


; Test if Setup file exists, if so, delete installed files, and run Setup
IfExist, %ModuleExe%
{
    ; Get rid of other versions
    RegRead, UninstallerPath, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Abiword2, UninstallString
    if not ErrorLevel
    {
        IfExist, %UninstallerPath%
        {
            Process, Close, AbiWord.exe ; Teminate process
            Sleep, 1500
            ; Silent switch is broken
            RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\Abisuite
            RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\MicroSoft\Windows\CurrentVersion\Uninstall\Abiword2
            SplitPath, UninstallerPath,, InstalledDir
            FileRemoveDir, %InstalledDir%, 1
            Sleep, 1000
            IfExist, %InstalledDir%
            {
                OutputDebug, %TestName%:%A_LineNumber%: Test failed: Failed to delete '%InstalledDir%'.`n
                bContinue := false
            }
            else
                bContinue := true
        }
    }
    else
    {
        ; There was a problem (such as a nonexistent key or value). 
        ; That probably means we have not installed this app before.
        ; Check in default directory to be extra sure
        IfExist, %A_ProgramFiles%\AbiSuite2
        {
            Process, Close, AbiWord.exe ; Teminate process
            Sleep, 1500
            FileRemoveDir, %A_ProgramFiles%\AbiSuite2, 1
            Sleep, 1000
            RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\Abisuite
            RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\MicroSoft\Windows\CurrentVersion\Uninstall\Abiword2
            IfExist, %A_ProgramFiles%\AbiSuite2
            {
                OutputDebug, %TestName%:%A_LineNumber%: Test failed: Previous version detected and failed to delete '%A_ProgramFiles%\AbiSuite2'.`n
                bContinue := false
            }
            else
                bContinue := true
        }
        else
            bContinue := true ; No previous versions detected.
    }
    if bContinue
        Run %ModuleExe%
}
else
{
    OutputDebug, %TestName%:%A_LineNumber%: Test failed: '%ModuleExe%' not found.`n
    bContinue := false
}


; Test if 'Installer Language (Please select)' window appeared, if so, hit 'OK' button
TestsTotal++
if bContinue
{
    WinWaitActive, Installer Language, Please select, 15
    if not ErrorLevel
    {
        Sleep, 250
        ControlClick, Button1, Installer Language, Please select
        if not ErrorLevel
            TestsOK("'Installer Language (Please select)' window appeared and 'OK' button was clicked.")
        else
            TestsFailed("Unable to hit 'OK' button in 'Installer Language (Please select)' window.")
    }
    else
        TestsFailed("'Installer Language (Please select)' window failed to appear.")
}


; Test if 'AbiWord 2.6.4 Setup (This wizard)' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, AbiWord 2.6.4 Setup, This wizard, 15
    if not ErrorLevel
    {
        Sleep, 250
        ControlClick, Button2, AbiWord 2.6.4 Setup, This wizard ; Hit 'Next' button
        if not ErrorLevel
            TestsOK("'AbiWord 2.6.4 Setup (This wizard)' window appeared and 'Next' button was clicked.")
        else
            TestsFailed("Unable to hit 'Next' button in 'AbiWord 2.6.4 Setup (This wizard)' window.")
    }
    else
        TestsFailed("'AbiWord 2.6.4 Setup (This wizard)' window failed to appear.")
}


; Test if 'AbiWord 2.6.4 Setup (License Agreement)' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, AbiWord 2.6.4 Setup, License Agreement, 5
    if not ErrorLevel
    {
        Sleep, 250
        ControlClick, Button2, AbiWord 2.6.4 Setup, License Agreement
        if not ErrorLevel
            TestsOK("'AbiWord 2.6.4 Setup (License Agreement)' window appeared and 'Next' button was clicked.")
        else
            TestsFailed("Unable to hit 'Next' button in 'AbiWord 2.6.4 Setup (License Agreement)' window.")
    }
    else
        TestsFailed("'AbiWord 2.6.4 Setup (License Agreement)' window failed to appear.")
}


; Test if 'AbiWord 2.6.4 Setup (Choose Components)' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, AbiWord 2.6.4 Setup, Choose Components, 5
    if not ErrorLevel
    {
        Sleep, 250
        ControlClick, Button2, AbiWord 2.6.4 Setup, Choose Components
        if not ErrorLevel
            TestsOK("'AbiWord 2.6.4 Setup (Choose Components)' window appeared and 'Next' button was clicked.")
        else
            TestsFailed("Unable to hit 'Next' button in 'AbiWord 2.6.4 Setup (Choose Components)' window.")
    }
    else
        TestsFailed("'AbiWord 2.6.4 Setup (Choose Components)' window failed to appear.")
}


; Test if 'AbiWord 2.6.4 Setup (Choose Install Location)' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, AbiWord 2.6.4 Setup, Choose Install Location, 5
    if not ErrorLevel
    {
        Sleep, 250
        ControlClick, Button2, AbiWord 2.6.4 Setup, Choose Install Location
        if not ErrorLevel
            TestsOK("'AbiWord 2.6.4 Setup (Choose Install Location)' window appeared and 'Next' button was clicked.")
        else
            TestsFailed("Unable to hit 'Next' button in 'AbiWord 2.6.4 Setup (Choose Install Location)' window.")
    }
    else
        TestsFailed("'AbiWord 2.6.4 Setup (Choose Install Location)' window failed to appear.")
}


; Test if 'AbiWord 2.6.4 Setup (Choose Start Menu Folder)' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, AbiWord 2.6.4 Setup, Choose Start Menu Folder, 5
    if not ErrorLevel
    {
        Sleep, 250
        ControlClick, Button2, AbiWord 2.6.4 Setup, Choose Start Menu Folder
        if not ErrorLevel
            TestsOK("'AbiWord 2.6.4 Setup (Choose Start Menu Folder)' window appeared and 'Next' button was clicked.")
        else
            TestsFailed("Unable to hit 'Next' button in 'AbiWord 2.6.4 Setup (Choose Start Menu Folder)' window.")
    }
    else
        TestsFailed("'AbiWord 2.6.4 Setup (Choose Start Menu Folder)' window failed to appear.")
}


; Test if can get thru 'Installing'
TestsTotal++
if bContinue
{
    WinWaitActive, AbiWord 2.6.4 Setup, Installing, 5
    if not ErrorLevel
    {
        Sleep, 250
        OutputDebug, OK: %TestName%: 'Installing' window appeared, waiting for it to close.`n
        WinWaitClose, AbiWord 2.6.4 Setup, Installing, 35
        if not ErrorLevel
        {
            WinWaitActive, AbiWord 2.6.4 Setup, Installation Complete, 7
            if not ErrorLevel
            {
                ControlClick, Button2, AbiWord 2.6.4 Setup, Installation Complete
                if not ErrorLevel
                    TestsOK("'AbiWord 2.6.4 Setup (Installing)' went away, and 'Next' button was clicked in 'AbiWord 2.6.4 Setup (Installation Complete)' window.")
                else
                    TestsFailed("Unable to hit 'Next' button in 'AbiWord 2.6.4 Setup (Installation Complete)' window.")
            }
            else
                TestsFailed("'AbiWord 2.6.4 Setup (Installation Complete)' window failed to appear.")
        }
        else
            TestsFailed("'AbiWord 2.6.4 Setup (Installing)' window failed to disappear.")
    }
    else
        TestsFailed("'AbiWord 2.6.4 Setup (Installing)' window failed to appear.")
}


; Test if 'Completing' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, AbiWord 2.6.4 Setup, Completing, 7
    if not ErrorLevel
    {
        Sleep, 250
        ControlClick, Button4, AbiWord 2.6.4 Setup, Completing ; Uncheck 'Run AbiWord 2.6.4'
        if not ErrorLevel
        {
            ControlClick, Button2, AbiWord 2.6.4 Setup, Completing ; Hit 'Finish'
            if not ErrorLevel
                TestsOK("'AbiWord 2.6.4 Setup (Completing)' window appeared and 'Finish' button was clicked.")
            else
                TestsFailed("Unable to hit 'Finish' button in 'AbiWord 2.6.4 Setup (Completing)' window.")
        }
        else
        {
            TestsFailed("Unable to uncheck 'Run AbiWord 2.6.4' checkbox in 'AbiWord 2.6.4 Setup (Completing)' window.")
            Process, Close, AbiWord.exe ; Just in case
        }
    }
    else
        TestsFailed("'AbiWord 2.6.4 Setup (Completing)' window failed to appear.")
}


; Check if program exists in program files
TestsTotal++
if bContinue
{
    Sleep, 2000
    RegRead, UninstallerPath, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Abiword2, UninstallString
    if not ErrorLevel
    {
        IfExist, %UninstallerPath%
            TestsOK("The application has been installed, because '" UninstallerPath "' was found.")
        else
            TestsFailed("Something went wrong, can't find '" UninstallerPath "'.")
    }
    else
        TestsFailed("Either we can't read from registry or data doesn't exist.")
}
