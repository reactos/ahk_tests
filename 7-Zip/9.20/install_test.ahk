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

SetupExe = %A_WorkingDir%\Apps\7zip_9.20_Setup.exe
bContinue := false
TestName = 1.install

TestsFailed := 0
TestsOK := 0
TestsTotal := 0

; Test if Setup file exists, if so, delete already installed files if any, and run Setup
IfExist, %SetupExe%
{

    ; Get rid of other versions
    IfExist, %A_ProgramFiles%\7-Zip
    {
        IfExist, %A_ProgramFiles%\7-Zip\Uninstall.exe
        {
            OutputDebug, %TestName%:%A_LineNumber%: '%A_ProgramFiles%\7-Zip\Uninstall.exe' was found. Running it in silent mode then terminating explorer.exe.`n
            Run, %A_ProgramFiles%\7-Zip\Uninstall.exe /S
        }
        Process, close, 7zFM.exe
        Run, regsvr32 /s /u "C:\Program Files\7-Zip\7-zip.dll"
        Process, Close, explorer.exe ; Sadly uninstalling and unregistering dll isn't enough
        RegDelete, HKEY_CURRENT_USER, SOFTWARE\7-Zip
        RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\7-Zip
        RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\MicroSoft\Windows\CurrentVersion\Uninstall\7-Zip
        FileRemoveDir, %A_ProgramFiles%\7-Zip, 1
        Run, explorer.exe
        Sleep, 5000 ; Let explorer to load all its windows
        IfExist, %A_ProgramFiles%\7-Zip
        {
            OutputDebug, %TestName%:%A_LineNumber%: Test failed: Failed to delete '%A_ProgramFiles%\7-Zip'.`n
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
        WinActivate, 7-Zip 9.20 Setup, Choose Install Location ; If we have explorer terminated, make sure we bring 7-Zip window to the top
        WinWaitActive, 7-Zip 9.20 Setup, Choose Install Location, 15 ; Wait 15 secs for window to appear
        if not ErrorLevel ;Window is found and it is active
        {
            if LeftClickControl("Button2")
            {
                TestsOK++
                OutputDebug, OK: %TestName%:%A_LineNumber%: 'Choose Install Location' window appeared and 'Install' button was clicked.`n
                bContinue := true
            }
            else
            {
                TestsFailed++
                WinGetTitle, title, A
                OutputDebug, %TestName%:%A_LineNumber%: Test failed: There was some problem with LeftClickControl. Active window caption: '%title%'.`n
                bContinue := false
            }
        }
        else
        {
            TestsFailed++
            WinGetTitle, title, A
            OutputDebug, %TestName%:%A_LineNumber%: Test failed: '7-Zip 9.20 Setup' window with 'Choose Install Location' text failed to appear. Active window caption: '%title%'.`n
            bContinue := false
        }
}


; Test if 'Installing' window can appear
TestsTotal++
if bContinue
{
    WinWaitActive, 7-Zip 9.20 Setup, Installing, 15 ; Wait 15 secs for window to appear
    if not ErrorLevel ;Window is found and it is active
    {
        TestsOK++
        OutputDebug, OK: %TestName%:%A_LineNumber%: 'Installing' window appeared.`n
        bContinue := true
    }
    else
    {
        TestsFailed++
        WinGetTitle, title, A
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'Installing' window failed to appear. Active window caption: '%title%'.`n
        bContinue := false
    }
}


; Test if 'Completing' window and 'Finish' button can appear
TestsTotal++
if bContinue
{
    WinWaitActive, 7-Zip 9.20 Setup, Completing the, 15 ; Wait 15 secs for window to appear
    if not ErrorLevel ;Window is found and it is active
    {
        if LeftClickControl("Button2")
        {
            TestsOK++
            OutputDebug, OK: %TestName%:%A_LineNumber%: 'Completing' window appeared and 'Finish' button was clicked.`n
            bContinue := true
        }
        else
        {
            TestsFailed++
            WinGetTitle, title, A
            OutputDebug, %TestName%:%A_LineNumber%: Test failed: There was some problem with LeftClickControl. Active window caption: '%title%'.`n
            bContinue := false
        }
    }
    else
    {
        TestsFailed++
        WinGetTitle, title, A
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'Completing' window failed to appear. Active window caption: '%title%'.`n
        bContinue := false
    }
}

;Check if program exists in program files
TestsTotal++
if bContinue
{
    Sleep, 250
    AppExe = %A_ProgramFiles%\7-Zip\7zFM.exe
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
