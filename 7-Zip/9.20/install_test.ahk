/*
 * Designed for TeamViewer 7.0 (7.0.12979)
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

ModuleExe = %A_WorkingDir%\Apps\7zip_9.20_Setup.exe
bContinue := false
TestName = 1.install

TestsFailed := 0
TestsOK := 0
TestsTotal := 0

; Test if Setup file exists, if so, delete already installed files if any, and run Setup
IfExist, %ModuleExe%
{
    ; Get rid of other versions
    RegRead, UninstallerPath, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\7-Zip, UninstallString
    if not ErrorLevel
    {
        StringReplace, UninstallerPath, UninstallerPath, `",, All ; String contains quotes, replace em
        IfExist, %UninstallerPath%
        {
            Process, Close, 7zFM.exe ; Teminate process
            Sleep, 1500
            RunWait, %UninstallerPath% /S ; Silently uninstall it
            Sleep, 2500
            ; Delete everything just in case
            RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\7-Zip
            RegDelete, HKEY_CURRENT_USER, SOFTWARE\7-Zip
            RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\MicroSoft\Windows\CurrentVersion\Uninstall\7-Zip
            SplitPath, UninstallerPath,, InstalledDir
            Run, regsvr32 /s /u "%A_ProgramFiles%\7-Zip\7-zip.dll"
            Process, Close, explorer.exe ; Explorer restart is required
            Sleep, 2500
            FileRemoveDir, %InstalledDir%, 1
            Sleep, 1000
            IfExist, %InstalledDir%
            {
                OutputDebug, %TestName%:%A_LineNumber%: Test failed: Failed to delete '%InstalledDir%'.`n
                bContinue := false
            }
            else
            {
                bContinue := true
            }
        }
        else
        {
            OutputDebug, %TestName%:%A_LineNumber%: Test failed: '%UninstallerPath%' does not exist.`n
            bContinue := false
        }
    }
    else
    {
        ; There was a problem (such as a nonexistent key or value). 
        ; That probably means we have not installed this app before.
        ; Check in default directory to be extra sure
        IfExist, %A_ProgramFiles%\7-Zip\Uninstall.exe
        {
            Process, Close, 7zFM.exe ; Teminate process
            Sleep, 1500
            RunWait, %A_ProgramFiles%\7-Zip\Uninstall.exe /S ; Silently uninstall it
            Sleep, 2500
            Run, regsvr32 /s /u "%A_ProgramFiles%\7-Zip\7-zip.dll"
            Process, Close, explorer.exe
            Sleep, 2500
            FileRemoveDir, %A_ProgramFiles%\7-Zip, 1
            Sleep, 1000
            IfExist, %A_ProgramFiles%\7-Zip
            {
                OutputDebug, %TestName%:%A_LineNumber%: Test failed: Previous version detected and failed to delete '%A_ProgramFiles%\7-Zip'.`n
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


; Test if '7-Zip 9.20 Setup (Choose Install Location)' window appeared, if so, hit 'Install' button
TestsTotal++
if bContinue
{
    WinWait, 7-Zip 9.20 Setup, Choose Install Location, 15
    if ErrorLevel
        TestsFailed("'7-Zip 9.20 Setup (Choose Install Location)' window does not exist.")
    else
    {
        ; We had to kill explorer, so, make sure 7-Zip window is active
        WinActivate, 7-Zip 9.20 Setup, Choose Install Location
        WinWaitActive, 7-Zip 9.20 Setup, Choose Install Location, 7
        if ErrorLevel
            TestsFailed("Unable to activate existing '7-Zip 9.20 Setup (Choose Install Location)' window.")
        else
        {
            ControlClick, Button2, 7-Zip 9.20 Setup, Choose Install Location ; Hit 'Install' button
            if ErrorLevel
                TestsFailed("Unable to hit 'Install' button in '7-Zip 9.20 Setup (Choose Install Location)' window.")
            else
            {
                TestsOK("'7-Zip 9.20 Setup (Choose Install Location)' window appeared and 'Install' button was clicked.")
            }
        }
    }
}


; Test if can get thru '7-Zip 9.20 Setup (Installing)' window
TestsTotal++
if bContinue
{
    WinWaitActive, 7-Zip 9.20 Setup, Installing, 5
    if ErrorLevel
        TestsFailed("'7-Zip 9.20 Setup (Installing)' window failed to appear.")
    else
    {
        OutputDebug, %TestName%:%A_LineNumber%: '7-Zip 9.20 Setup (Installing)' window appeared, waiting for it to close.`n
        WinWaitClose, 7-Zip 9.20 Setup, Installing, 20
        if ErrorLevel
            TestsFailed("'7-Zip 9.20 Setup (Installing)' window failed to close.")
        else
        {
            TestsOK("'7-Zip 9.20 Setup (Installing)' window appeared and closed.")
        }
    }
}


; Test if '7-Zip 9.20 Setup (Completing)' window appeared, if so
; check 'I want to reboot manually' radio button (if exist) and hit 'Finish' button
TestsTotal++
if bContinue
{
    WinWaitActive, 7-Zip 9.20 Setup, Completing, 5
    if ErrorLevel
        TestsFailed("'7-Zip 9.20 Setup (Completing)' window failed to appear.")
    else
    {
        ControlGet, bVisible, Visible,, 7-Zip 9.20 Setup, Completing
        if bVisible = 1 ; Control is visible
        {
            Control, Check, , Button5, 7-Zip 9.20 Setup, Completing ; Check 'I want to reboot manually' radiobutton
            if ErrorLevel
                TestsFailed("Unable to check 'I want to reboot manually' radiobutton in '7-Zip 9.20 Setup (Completing)' window.")
            else
            {
                ControlClick, Button2, 7-Zip 9.20 Setup, Completing ; Hit 'Finish' button
                if ErrorLevel
                    TestsFailed("Unable to hit 'Finish' button in '7-Zip 9.20 Setup (Completing)' window.")
                else
                {
                    WinWaitClose, 7-Zip 9.20 Setup, Completing, 5
                    if ErrorLevel
                        TestsFailed("'7-Zip 9.20 Setup (Completing)' window failed to close after clicking on 'Finish' button.")
                    else
                        TestsOK("'I want to reboot manually' radiobutton was checked and 'Finish' button was clicked in '7-Zip 9.20 Setup (Completing)' window and it closed.")
                }
            }
        }
        else
        {
            ControlClick, Button2, 7-Zip 9.20 Setup, Completing ; Hit 'Finish' button
            if ErrorLevel
                TestsFailed("Unable to hit 'Finish' button in '7-Zip 9.20 Setup (Completing)' window.")
            else
            {
                WinWaitClose, 7-Zip 9.20 Setup, Completing, 5
                if ErrorLevel
                    TestsFailed("'7-Zip 9.20 Setup (Completing)' window failed to close after clicking on 'Finish' button.")
                else
                    TestsOK("'Finish' button was clicked in '7-Zip 9.20 Setup (Completing)' window and it closed.")
            }
        }
    }
}


; Check if program exists in program files
TestsTotal++
if bContinue
{
    Sleep, 2000
    RegRead, UninstallerPath, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\7-Zip, UninstallString
    if not ErrorLevel
    {
        StringReplace, UninstallerPath, UninstallerPath, `",, All ; String contains quotes, replace em
        IfExist, %UninstallerPath%
            TestsOK("The application has been installed, because '" UninstallerPath "' was found.")
        else
            TestsFailed("Something went wrong, can't find '" UninstallerPath "'.")
    }
    else
        TestsFailed("Either we can't read from registry or data doesn't exist.")
}