/*
 * Designed for mIRC 6.35
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

ModuleExe = %A_WorkingDir%\Apps\mIRC 6.35 Setup.exe
bContinue := false
TestName = 1.install

TestsFailed := 0
TestsOK := 0
TestsTotal := 0

; Test if Setup file exists, if so, delete installed files, and run Setup
IfExist, %ModuleExe%
{
    ; Get rid of other versions
    RegRead, UninstallerPath, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\mIRC, UninstallString
    if not ErrorLevel
    {
        Process, Close, mirc.exe ; Teminate process
        Sleep, 1500
        RegRead, InstallLocation, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\mIRC, InstallLocation
        RunWait, %UninstallerPath% /S ; Silently uninstall it
        Sleep, 2500
        ; Delete everything just in case
        RegDelete, HKEY_CURRENT_USER, SOFTWARE\mIRC
        RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\MicroSoft\Windows\CurrentVersion\Uninstall\mIRC
        FileRemoveDir, %InstallLocation%, 1
        Sleep, 1000
        IfExist, %InstallLocation%
        {
            OutputDebug, %TestName%:%A_LineNumber%: Test failed: Failed to delete '%InstallLocation%'.`n
            bContinue := false
        }
        else
        {
            bContinue := true
        }
    }
    else
    {
        ; There was a problem (such as a nonexistent key or value). 
        ; That probably means we have not installed this app before.
        ; Check in default directory to be extra sure
        IfExist, %A_ProgramFiles%\mIRC\Uninstall.exe
        {
            Process, Close, mirc.exe ; Teminate process
            Sleep, 1500
            RunWait, %A_ProgramFiles%\mIRC\Uninstall.exe /S ; Silently uninstall it
            Sleep, 2500
            FileRemoveDir, %A_ProgramFiles%\mIRC, 1
            Sleep, 1000
            IfExist, %A_ProgramFiles%\mIRC
            {
                OutputDebug, %TestName%:%A_LineNumber%: Test failed: Previous version detected and failed to delete '%A_ProgramFiles%\mIRC'.`n
                bContinue := false
            }
            else
            {
                bContinue := true
            }
        }
        else
        {
            ; No previous versions detected.
            bContinue := true
        }
    }
    if bContinue
    {
        FileRemoveDir, %A_AppData%\mIRC, 1
        Run %ModuleExe%
    }
}
else
{
    OutputDebug, %TestName%:%A_LineNumber%: Test failed: '%ModuleExe%' not found.`n
    bContinue := false
}


; Test if 'This wizard' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, mIRC Setup, This wizard, 7
    if not ErrorLevel
    {
        Sleep, 250
        ControlClick, Button2, mIRC Setup, This wizard ; Hit 'Next' button
        if not ErrorLevel
            TestsOK("'mIRC Setup (This wizard)' window appeared and 'Next' was clicked.")
        else
            TestsFailed("Unable to click 'Next' in 'mIRC Setup (This wizard)' window.")
    }
    else
        TestsFailed("'mIRC Setup (This wizard)' window failed to appear.")
}


; Test if 'License Agreement' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, mIRC Setup, License Agreement, 7
    if not ErrorLevel
    {
        Sleep, 250
        ControlClick, Button2, mIRC Setup, License Agreement ; Hit 'I Agree' button
        if not ErrorLevel
            TestsOK("'mIRC Setup (License Agreement)' window appeared and 'I Agree' button was clicked.")
        else
            TestsFailed("Unable to click 'I Agree' button in 'mIRC Setup (License Agreement)' window.")
    }
    else
        TestsFailed("'mIRC Setup (License Agreement)' window failed to appear.")
}


; Test if 'Choose Install Location' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, mIRC Setup, Choose Install Location, 7
    if not ErrorLevel
    {
        Sleep, 250
        ControlClick, Button2, mIRC Setup, Choose Install Location
        if not ErrorLevel
            TestsOK("'mIRC Setup (Choose Install Location)' window appeared and 'Next' was clicked.")
        else
            TestsFailed("Unable to click 'Next' in 'mIRC Setup (Choose Install Location)' window.")
    }
    else
        TestsFailed("'mIRC Setup (Choose Install Location)' window failed to appear.")
}


; Test if 'Choose Components' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, mIRC Setup, Choose Components, 7
    if not ErrorLevel
    {
        Sleep, 250
        ControlClick, Button2, mIRC Setup, Choose Components
        if not ErrorLevel
            TestsOK("'mIRC Setup (Choose Components)' window appeared and 'Next' was clicked.")
        else
            TestsFailed("Unable to click 'Next' in 'mIRC Setup (Choose Components)' window.")
    }
    else
        TestsFailed("'mIRC Setup (Choose Components)' window failed to appear.")
}


; Test if 'Select Additional Tasks' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, mIRC Setup, Select Additional Tasks, 7
    if not ErrorLevel
    {
        Sleep, 250
        Control, Uncheck,, Button6, mIRC Setup, Select Additional Tasks ; Uncheck 'Backup Current Files'
        if not ErrorLevel
        {
            Control, Uncheck,, Button7, mIRC Setup, Select Additional Tasks ; Uncheck 'Automatically Check for Updates'
            if not ErrorLevel
            {
                ControlClick, Button2, mIRC Setup, Select Additional Tasks
                if not ErrorLevel
                    TestsOK("'mIRC Setup (Select Additional Tasks)' window appeared, 'Automatically Check for Updates', 'Backup Current Files' checkboxes unchecked and 'Next' was clicked.")
                else
                    TestsFailed("Unable to click 'Next' in 'mIRC Setup (Select Additional Tasks)' window.")
            }
            else
                TestsFailed("Unable to uncheck 'Automatically Check for Updates' checkbox in 'mIRC Setup (Select Additional Tasks)' window. ")
        }
        else
            TestsFailed("Unable to uncheck 'Backup Current Files' checkbox in 'mIRC Setup (Select Additional Tasks)' window.")
    }
    else
        TestsFailed("'mIRC Setup (Select Additional Tasks)' window failed to appear.")
}


; Test if 'Ready to Install' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, mIRC Setup, Ready to Install, 7
    if not ErrorLevel
    {
        Sleep, 250
        ControlClick, Button2, mIRC Setup, Ready to Install ; Hit 'Install'
        if not ErrorLevel
            TestsOK("'mIRC Setup (Ready to Install)' window appeared and 'Install' was clicked.")
        else
            TestsFailed("Unable to click 'Install' in 'mIRC Setup (Ready to Install)' window.")
    }
    else
        TestsFailed("'mIRC Setup (Ready to Install)' window failed to appear.")
}


; Test if 'mIRC has been installed' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, mIRC Setup, mIRC has been installed, 7
    if not ErrorLevel
    {
        Sleep, 250
        ControlClick, Button2, mIRC Setup, mIRC has been installed ; Hit 'Finish'
        if not ErrorLevel
        {
            TestsOK("'mIRC Setup (mIRC has been installed)' window appeared and 'Finish' was clicked.")
            Sleep, 1500
            ; There are two checkboxes, but unchecked by default. Just to be sure, terminate processes
            Process, Close, hh.exe
            Process, Close, mirc.exe
        }
        else
            TestsFailed("Unable to click 'Finish' in 'mIRC Setup (mIRC has been installed)' window.")
    }
    else
        TestsFailed("'mIRC Setup (mIRC has been installed)' window failed to appear.")
}

; Check if program exists
TestsTotal++
if bContinue
{
    Sleep, 2000
    RegRead, InstallLocation, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\mIRC, InstallLocation
    if not ErrorLevel
    {
        StringReplace, InstallLocation, InstallLocation, `",, All
        IfExist, %InstallLocation%
            TestsOK("The application has been installed, because '" InstallLocation "' was found.")
        else
            TestsFailed("Something went wrong, can't find '" InstallLocation "'.")
    }
    else
        TestsFailed("Either we can't read from registry or data doesn't exist.")
}
