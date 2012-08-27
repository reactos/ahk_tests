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

SetupExe = %A_WorkingDir%\Apps\TeamViewer_7.0_Setup.exe
bContinue := false
TestName = 1.install

TestsFailed := 0
TestsOK := 0
TestsTotal := 0

; Test if Setup file exists, if so, delete already installed files if any, and run Setup
IfExist, %SetupExe%
{

    ; Get rid of other versions
    IfExist, %A_ProgramFiles%\TeamViewer\Version7\uninstall.exe
    {
        Process, close, TeamViewer.exe
        RunWait, %A_ProgramFiles%\TeamViewer\Version7\uninstall.exe /S
        Sleep, 4500
        RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\TeamViewer
        RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\MicroSoft\Windows\CurrentVersion\Uninstall\TeamViewer 7
        FileRemoveDir, %A_ProgramFiles%\TeamViewer, 1
        FileRemoveDir, %A_AppData%\TeamViewer, 1
        Sleep, 1000
        IfExist, %A_ProgramFiles%\TeamViewer
        {
            OutputDebug, %TestName%:%A_LineNumber%: Test failed: Failed to delete '%A_ProgramFiles%\TeamViewer'.`n
            bContinue := false
        }
        else
        {
            Run %SetupExe%
            bContinue := true
        }
    }
    else
    {
        Run %SetupExe%
        bContinue := true
    }
}
else
{
    OutputDebug, %TestName%:%A_LineNumber%: Test failed: '%SetupExe%' not found.`n
    bContinue := false
}


; Test if can start setup
TestsTotal++
if bContinue
{
    WinWaitActive, TeamViewer 7 Setup, Welcome to TeamViewer, 15 ; Wait 15 secs for window to appear
    if not ErrorLevel ;Window is found and it is active
    {
        ; Check 'Install' radiobutton
        SendMessage, 0x201, 0, 0, Button4
        SendMessage, 0x202, 0, 0, Button4
        
        ; Check 'Show advanced settings' checkbox
        SendMessage, 0x201, 0, 0, Button6
        SendMessage, 0x202, 0, 0, Button6
        
        ; Hit 'Next' button
        SendMessage, 0x201, 0, 0, Button2
        SendMessage, 0x202, 0, 0, Button2
        if not ErrorLevel
            TestsOK("'TeamViewer 7 Setup (Welcome to TeamViewer)' window appeared, 'Install' radiobutton and 'Show advanced settings' checkbox checked, 'Next' button was clicked.")
        else
            TestsFailed("Unable to hit 'Next' button in 'TeamViewer 7 Setup (Welcome to TeamViewer)' window.")
    }
    else
        TestsFailed("'TeamViewer 7 Setup (Welcome to TeamViewer)' window failed to appear.")
}


; Choose 'Company / commercial use' in 'Environment'
TestsTotal++
if bContinue
{
    WinWaitActive, TeamViewer 7 Setup, Environment, 5
    if not ErrorLevel
    {
        ; Check 'company / commercial use' radiobutton
        SendMessage, 0x201, 0, 0, Button5
        SendMessage, 0x202, 0, 0, Button5
        if not ErrorLevel
        {
            ; Hit 'Next' button
            SendMessage, 0x201, 0, 0, Button2
            SendMessage, 0x202, 0, 0, Button2
            if not ErrorLevel
                TestsOK("'company / commercial use' radiobutton checked, 'Next' button was clicked in 'TeamViewer 7 Setup (Environment)' window.")
            else
                TestsFailed("Unable to click 'Next' button in 'TeamViewer 7 Setup (Environment)' window.")
        }
        else
            TestsFailed("Failed to check 'personal / non-commercial use' radiobutton in 'TeamViewer 7 Setup (Environment)' window.")
    }
    else
        TestsFailed("'TeamViewer 7 Setup (Environment)' window failed to appear.")
}


; Test if 'License Agreement' window can appear
TestsTotal++
if bContinue
{
    WinWaitActive, TeamViewer 7 Setup, License Agreement, 5
    if not ErrorLevel
    {   
        ; Check 'I accept the terms...' checkbox
        SendMessage, 0x201, 0, 0, Button4
        SendMessage, 0x202, 0, 0, Button4
        if not ErrorLevel
        {
            ; Hit 'Next' button
            SendMessage, 0x201, 0, 0, Button2
            SendMessage, 0x202, 0, 0, Button2
            if not ErrorLevel
                TestsOK("'I accept the terms...' checkbox checked, 'Next' button was clicked in 'TeamViewer 7 Setup (License Agreement)' window.")
            else
                TestsFailed("Unable to hit 'Next' button in 'TeamViewer 7 Setup (License Agreement)' window.")
        }
        else
            TestsFailed("Failed to check 'I accept the terms...' checkbox in 'License Agreement'.")
    }
    else
        TestsFailed("'License Agreement' window failed to appear.")
}


; Test if 'Choose installation type' window can appear
TestsTotal++
if bContinue
{
    WinWaitActive, TeamViewer 7 Setup, Choose installation type, 5
    if not ErrorLevel
    {   
        ; Check 'No (default)' radiobutton
        SendMessage, 0x201, 0, 0, Button4
        SendMessage, 0x202, 0, 0, Button4
        if not ErrorLevel
        {
            ; Hit 'Next' button
            SendMessage, 0x201, 0, 0, Button2
            SendMessage, 0x202, 0, 0, Button2
            if not ErrorLevel
                TestsOK("'No (default)' radiobutton checked, 'Next' button was clicked in 'TeamViewer 7 Setup (Choose installation type)' window.")
            else
                TestsFailed("Unable to hit 'Next' button in 'TeamViewer 7 Setup (Choose installation type)' window.")
        }
        else
            TestsFailed("Failed to check 'No (default)' radiobutton in 'TeamViewer 7 Setup (Choose installation type)' window.")
    }
    else
        TestsFailed("'TeamViewer 7 Setup (Choose installation type)' window failed to appear.")
}


; Test if 'Access Control' window can appear
TestsTotal++
if bContinue
{
    WinWaitActive, TeamViewer 7 Setup, Access Control, 5
    if not ErrorLevel
    {   
        ; Check 'Full access (recommended)' radiobutton
        SendMessage, 0x201, 0, 0, Button4
        SendMessage, 0x202, 0, 0, Button4
        if not ErrorLevel
        {
            ; Hit 'Next' button
            SendMessage, 0x201, 0, 0, Button2
            SendMessage, 0x202, 0, 0, Button2
            if not ErrorLevel
                TestsOK("'Full access (recommended)' radiobutton checked, 'Next' button was clicked in 'TeamViewer 7 Setup (Access Control)' window.")
            else
                TestsFailed("Unable to hit 'Next' button in 'TeamViewer 7 Setup (Access Control)' window.")
        }
        else
            TestsFailed("Failed to check 'Full access (recommended)' radiobutton in 'TeamViewer 7 Setup (Access Control)' window.")
    }
    else
        TestsFailed("'TeamViewer 7 Setup (Access Control)' window failed to appear.")
}


; Test if 'Install VPN adapter' window can appear
TestsTotal++
if bContinue
{
    WinWaitActive, TeamViewer 7 Setup, Install VPN adapter, 5
    if not ErrorLevel
    {   
        ; Check 'Use TeamViewer VPN' checkbox
        SendMessage, 0x201, 0, 0, Button4
        SendMessage, 0x202, 0, 0, Button4
        if not ErrorLevel
        {
            ; Hit 'Next' button
            SendMessage, 0x201, 0, 0, Button2
            SendMessage, 0x202, 0, 0, Button2
            if not ErrorLevel
                TestsOK("'Use TeamViewer VPN' checkbox checked, 'Next' button was clicked in 'Install VPN adapter'.")
            else
                TestsFailed("Unable to hit 'Next' button in 'TeamViewer 7 Setup (Install VPN adapter)' window.")
        }
        else
            TestsFailed("Failed to check 'Use TeamViewer VPN' checkbox in 'TeamViewer 7 Setup (Install VPN adapter)' window.")
    }
    else
        TestsFailed("'TeamViewer 7 Setup (Install VPN adapter)' window window failed to appear.")
}


; Test if 'Choose Install Location' window can appear
TestsTotal++
if bContinue
{
    WinWaitActive, TeamViewer 7 Setup, Choose Install Location, 5
    if not ErrorLevel
    {   
        ; Hit 'Next' button //For some reason SendMessage doesn't work here on XP.
        PostMessage, 0x201, 0, 0, Button2
        PostMessage, 0x202, 0, 0, Button2 
        if not ErrorLevel
            TestsOK("'Next' button was clicked in 'TeamViewer 7 Setup (Choose Install Location)' window.")
        else
            TestsFailed("Unable to hit 'Next' button in 'TeamViewer 7 Setup (Choose Install Location)' window.")
    }
    else
        TestsFailed("'TeamViewer 7 Setup (Choose Install Location)' window failed to appear.")
}


; Test if 'Choose Start Menu Folder' window can appear
TestsTotal++
if bContinue
{
    WinWaitActive, TeamViewer 7 Setup, Choose Start, 5
    if not ErrorLevel
    {   
        Sleep, 500
        ; Hit 'Finish' button
        SendMessage, 0x201, 0, 0, Button2
        SendMessage, 0x202, 0, 0, Button2
        if not ErrorLevel
            TestsOK("'Finish' button was clicked in 'TeamViewer 7 Setup (Choose Start Menu Folder)' window.")
        else
            TestsFailed("Unable to hit 'Finish' button in 'TeamViewer 7 Setup (Choose Start Menu Folder)' window.")
    }
    else
        TestsFailed("'TeamViewer 7 Setup (Choose Start Menu Folder)' window failed to appear.")
}


; Test if 'Installing' window can appear
TestsTotal++
if bContinue
{
    WinWaitActive, TeamViewer 7 Setup, Installing, 5
    if not ErrorLevel
    {
        WinWaitNotActive, TeamViewer 7 Setup, Installing, 35 ; 35secs should be enough time to get thru install
        if not ErrorLevel
        {
            Process, wait, TeamViewer.exe, 10
            NewPID = %ErrorLevel%  ; Save the value immediately since ErrorLevel is often changed.
            if NewPID <> 0
            {
                TestsOK("Process 'TeamViewer.exe' appeared, terminating it.")
                Process, Close, TeamViewer.exe
            }
            else
                TestsFailed("Process 'TeamViewer.exe' failed to appear.")
        }
        else
            TestsFailed("'TeamViewer 7 Setup (Installing)' window failed to close.")
    }
    else
        TestsFailed("'TeamViewer 7 Setup (Installing)' window failed to appear.")
}

; Check if program exists
TestsTotal++
if bContinue
{
    Sleep, 250
    AppExe = %A_ProgramFiles%\TeamViewer\Version7\TeamViewer.exe
    IfExist, %AppExe%
        TestsOK("Should be installed, because '" AppExe "' was found.")
    else
        TestsFailed("Can NOT find '" AppExe "'.")
}
