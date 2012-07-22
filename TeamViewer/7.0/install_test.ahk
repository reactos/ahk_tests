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
    IfExist, %A_ProgramFiles%\TeamViewer
    {
        Process, close, TeamViewer.exe
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
        {
            TestsOK++
            OutputDebug, OK: %TestName%:%A_LineNumber%: 'TeamViewer 7 Setup' window with 'Welcome to TeamViewer' text appeared and 'Next' button was clicked.`n
            bContinue := true
        }
        else
        {
            TestsFailed++
            WinGetTitle, title, A
            OutputDebug, %TestName%:%A_LineNumber%: Test failed: Failed to hit 'Next' button in 'TeamViewer 7 Setup' window with 'Welcome to TeamViewer' text in it. Active window caption: '%title%'.`n
            bContinue := false
        }
    }
    else
    {
        TestsFailed++
        WinGetTitle, title, A
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'TeamViewer 7 Setup' window with 'Welcome to TeamViewer' text failed to appear. Active window caption: '%title%'.`n
        bContinue := false
    }
}


; Choose 'Company / commercial use' in 'Environment'
TestsTotal++
if bContinue
{
    WinWaitActive, TeamViewer 7 Setup, Environment, 15
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
            {
                TestsOK++
                OutputDebug, OK: %TestName%:%A_LineNumber%: 'Next' button was clicked in 'Environment'.`n
                bContinue := true
            }
            else
            {
                TestsFailed++
                WinGetTitle, title, A
                OutputDebug, %TestName%:%A_LineNumber%: Failed to click 'Next' button in 'Environment'. Active window caption: '%title%'.`n
                bContinue := false
            }
        }
        else
        {
            TestsFailed++
            WinGetTitle, title, A
            OutputDebug, %TestName%:%A_LineNumber%: Failed to check 'personal / non-commercial use' radiobutton in 'Environment'. Active window caption: '%title%'.`n
            bContinue := false
        }
    }
    else
    {
        TestsFailed++
        WinGetTitle, title, A
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'Environmnt' window failed to appear. Active window caption: '%title%'.`n
        bContinue := false
    }
}


; Test if 'License Agreement' window can appear
TestsTotal++
if bContinue
{
    WinWaitActive, TeamViewer 7 Setup, License Agreement, 15
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
            {
                TestsOK++
                OutputDebug, OK: %TestName%:%A_LineNumber%: 'Next' button was clicked in 'License Agreement'.`n
                bContinue := true
            }
            else
            {
                TestsFailed++
                WinGetTitle, title, A
                OutputDebug, %TestName%:%A_LineNumber%: Failed to click 'Next' button in 'License Agreement'. Active window caption: '%title%'.`n
                bContinue := false
            }
        }
        else
        {
            TestsFailed++
            WinGetTitle, title, A
            OutputDebug, %TestName%:%A_LineNumber%: Failed to check 'I accept the terms...' checkbox in 'License Agreement'. Active window caption: '%title%'.`n
            bContinue := false
        }
    }
    else
    {
        TestsFailed++
        WinGetTitle, title, A
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'License Agreement' window failed to appear. Active window caption: '%title%'.`n
        bContinue := false
    }
}


; Test if 'Choose installation type' window can appear
TestsTotal++
if bContinue
{
    WinWaitActive, TeamViewer 7 Setup, Choose installation type, 15
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
            {
                TestsOK++
                OutputDebug, OK: %TestName%:%A_LineNumber%: 'Next' button was clicked in 'Choose installation type'.`n
                bContinue := true
            }
            else
            {
                TestsFailed++
                WinGetTitle, title, A
                OutputDebug, %TestName%:%A_LineNumber%: Failed to click 'Next' button in 'Choose installation type'. Active window caption: '%title%'.`n
                bContinue := false
            }
        }
        else
        {
            TestsFailed++
            WinGetTitle, title, A
            OutputDebug, %TestName%:%A_LineNumber%: Failed to check 'No (default)' radiobutton in 'Choose installation type'. Active window caption: '%title%'.`n
            bContinue := false
        }
    }
    else
    {
        TestsFailed++
        WinGetTitle, title, A
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'Choose installation type' window failed to appear. Active window caption: '%title%'.`n
        bContinue := false
    }
}


; Test if 'Access Control' window can appear
TestsTotal++
if bContinue
{
    WinWaitActive, TeamViewer 7 Setup, Access Control, 15
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
            {
                TestsOK++
                OutputDebug, OK: %TestName%:%A_LineNumber%: 'Next' button was clicked in 'Access Control'.`n
                bContinue := true
            }
            else
            {
                TestsFailed++
                WinGetTitle, title, A
                OutputDebug, %TestName%:%A_LineNumber%: Failed to click 'Next' button in 'Access Control'. Active window caption: '%title%'.`n
                bContinue := false
            }
        }
        else
        {
            TestsFailed++
            WinGetTitle, title, A
            OutputDebug, %TestName%:%A_LineNumber%: Failed to check 'Full access (recommended)' radiobutton in 'Access Control'. Active window caption: '%title%'.`n
            bContinue := false
        }
    }
    else
    {
        TestsFailed++
        WinGetTitle, title, A
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'Access Control' window failed to appear. Active window caption: '%title%'.`n
        bContinue := false
    }
}


; Test if 'Install VPN adapter' window can appear
TestsTotal++
if bContinue
{
    WinWaitActive, TeamViewer 7 Setup, Install VPN adapter, 15
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
            {
                TestsOK++
                OutputDebug, OK: %TestName%:%A_LineNumber%: 'Next' button was clicked in 'Install VPN adapter'.`n
                bContinue := true
            }
            else
            {
                TestsFailed++
                WinGetTitle, title, A
                OutputDebug, %TestName%:%A_LineNumber%: Failed to click 'Next' button in 'Install VPN adapter'. Active window caption: '%title%'.`n
                bContinue := false
            }
        }
        else
        {
            TestsFailed++
            WinGetTitle, title, A
            OutputDebug, %TestName%:%A_LineNumber%: Failed to check 'Use TeamViewer VPN' checkbox in 'Install VPN adapter'. Active window caption: '%title%'.`n
            bContinue := false
        }
    }
    else
    {
        TestsFailed++
        WinGetTitle, title, A
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'Install VPN adapter' window failed to appear. Active window caption: '%title%'.`n
        bContinue := false
    }
}


; Test if 'Choose Install Location' window can appear
TestsTotal++
if bContinue
{
    WinWaitActive, TeamViewer 7 Setup, Choose Install Location, 15
    if not ErrorLevel
    {   
        ; Hit 'Next' button //For some reason SendMessage doesn't work here on XP.
        PostMessage, 0x201, 0, 0, Button2
        PostMessage, 0x202, 0, 0, Button2 
        if not ErrorLevel
        {
            TestsOK++
            OutputDebug, OK: %TestName%:%A_LineNumber%: 'Next' button was clicked in 'Choose Install Location'.`n
            bContinue := true
        }
        else
        {
            TestsFailed++
            WinGetTitle, title, A
            OutputDebug, %TestName%:%A_LineNumber%: Failed to click 'Next' button in 'Choose Install Location'. Active window caption: '%title%'.`n
            bContinue := false
        }
    }
    else
    {
        TestsFailed++
        WinGetTitle, title, A
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'Choose Install Location' window failed to appear. Active window caption: '%title%'.`n
        bContinue := false
    }
}


; Test if 'Choose Start Menu Folder' window can appear
TestsTotal++
if bContinue
{
    WinWaitActive, TeamViewer 7 Setup, Choose Start, 15
    if not ErrorLevel
    {   
        Sleep, 1500
        ; Hit 'Finish' button
        SendMessage, 0x201, 0, 0, Button2
        SendMessage, 0x202, 0, 0, Button2
        if not ErrorLevel
        {
            TestsOK++
            OutputDebug, OK: %TestName%:%A_LineNumber%: 'Finish' button was clicked in 'Choose Start Menu Folder'.`n
            bContinue := true
        }
        else
        {
            TestsFailed++
            WinGetTitle, title, A
            OutputDebug, %TestName%:%A_LineNumber%: Failed to click 'Finish' button in 'Choose Start Menu Folder'. Active window caption: '%title%'.`n
            bContinue := false
        }
    }
    else
    {
        TestsFailed++
        WinGetTitle, title, A
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'Choose Start Menu Folder' window failed to appear. Active window caption: '%title%'.`n
        bContinue := false
    }
}


; Test if 'Installing' window can appear
TestsTotal++
if bContinue
{
    WinWaitActive, TeamViewer 7 Setup, Installing, 15
    if not ErrorLevel
    {
        WinWaitNotActive, TeamViewer 7 Setup, Installing, 35 ; 35secs should be enough time to get thru install
        if not ErrorLevel
        {
            WinWaitActive, TeamViewer, Ready to connect, 15 ; Sadly app is started every time after setup is done
            if not ErrorLevel
            {
                Process, close, TeamViewer.exe
            }
            else
            {
                TestsFailed++
                WinGetTitle, title, A
                OutputDebug, %TestName%:%A_LineNumber%: Test failed: Application window failed to appear. Active window caption: '%title%'.`n
                bContinue := false
            }
        }
        else
        {
            TestsFailed++
            WinGetTitle, title, A
            OutputDebug, %TestName%:%A_LineNumber%: 'Installing' window failed to disappear. Active window caption: '%title%'.`n
            bContinue := false
        }
    }
    else
    {
        TestsFailed++
        WinGetTitle, title, A
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'Installing' window failed to appear. Active window caption: '%title%'.`n
        bContinue := false
    }
}

;Check if program exists in program files
TestsTotal++
if bContinue
{
    Sleep, 250
    AppExe = %A_ProgramFiles%\TeamViewer\Version7\TeamViewer.exe
    IfExist, %AppExe%
    {
        TestsOK++
        OutputDebug, OK: %TestName%:%A_LineNumber%: Should be installed, because '%AppExe%' was found.`n
        bContinue := true
    }
    else
    {
        TestsFailed++
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: Can NOT find '%AppExe%'.`n
        bContinue := false
    }
}
