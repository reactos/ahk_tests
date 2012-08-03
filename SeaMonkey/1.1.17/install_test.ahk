/*
 * Designed for SeaMonkey 1.1.17
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

ModuleExe = %A_WorkingDir%\Apps\SeaMonkey 1.1.17 Setup.exe
bContinue := false
TestName = 1.install

TestsFailed := 0
TestsOK := 0
TestsTotal := 0

; Test if Setup file exists, if so, delete installed files, and run Setup
IfExist, %ModuleExe%
{
    ; Get rid of other versions
    IfExist, %A_ProgramFiles%\mozilla.org\SeaMonkey\uninstall\SeaMonkeyUninstall.exe
    {
        Process, Close, seamonkey.exe ; Teminate process
        FileRemoveDir, %A_AppData%\Mozilla, 1
        Sleep, 1500
        RunWait, %A_ProgramFiles%\mozilla.org\SeaMonkey\uninstall\SeaMonkeyUninstall.exe -ms -ira ; Silently uninstall it
        Sleep, 2500
        FileRemoveDir, %A_ProgramFiles%\mozilla.org\, 1
        RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\Mozilla
        RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\mozilla.org
        RegDelete, HKEY_CURRENT_USER, SOFTWARE\Mozilla
        RegDelete, HKEY_CURRENT_USER, SOFTWARE\mozilla.org
        RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\MicroSoft\Windows\CurrentVersion\Uninstall\SeaMonkey (1.1.17)
        Sleep, 1000
        IfExist, %A_ProgramFiles%\mozilla.org
        {
            OutputDebug, %TestName%:%A_LineNumber%: Test failed: Previous version detected and failed to delete '%A_ProgramFiles%\mozilla.org'.`n
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
    if bContinue
    {
        Run %ModuleExe%
    }
}
else
{
    OutputDebug, %TestName%:%A_LineNumber%: Test failed: '%ModuleExe%' not found.`n
    bContinue := false
}


; Test if 'Extracting...' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Extracting...,, 7
    if not ErrorLevel
    {
        OutputDebug, OK: %TestName%:%A_LineNumber%: 'Extracting...' window appeared, waiting for it to close.`n
        WinWaitClose, Extracting...,,10
        if not ErrorLevel
        {
            TestsOK()
            OutputDebug, OK: %TestName%:%A_LineNumber%: 'Extracting...' window went away.`n
        }
        else
        {
            TestsFailed()
            WinGetTitle, title, A
            OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'Extracting...' window failed to disappear. Active window caption: '%title%'.`n
        }
        
    }
    else
    {
        TestsFailed()
        WinGetTitle, title, A
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'Extracting...' window failed to appear. Active window caption: '%title%'.`n
    }
}


; Test if 'SeaMonkey Setup - Welcome' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, SeaMonkey Setup - Welcome,, 7
    if not ErrorLevel
    {
        Sleep, 250
        ControlClick, Button1, SeaMonkey Setup - Welcome ; Hit 'Next' button
        if not ErrorLevel
        {
            TestsOK()
            OutputDebug, OK: %TestName%:%A_LineNumber%: 'SeaMonkey Setup - Welcome' window appeared and 'Next' was clicked.`n
        }
        else
        {
            TestsFailed()
            WinGetTitle, title, A
            OutputDebug, %TestName%:%A_LineNumber%: Test failed: Unable to hit 'Next' button in 'SeaMonkey Setup - Welcome' window. Active window caption: '%title%'.`n
        }
    }
    else
    {
        TestsFailed()
        WinGetTitle, title, A
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'SeaMonkey Setup - Welcome' window failed to appear. Active window caption: '%title%'.`n
    }
}


; Test if 'SeaMonkey Setup - Software License Agreement' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, SeaMonkey Setup - Software License Agreement,, 7
    if not ErrorLevel
    {
        Sleep, 250
        ControlClick, Button1, SeaMonkey Setup - Software License Agreement ; Hit 'Accept' button
        if not ErrorLevel
        {
            TestsOK()
            OutputDebug, OK: %TestName%:%A_LineNumber%: 'SeaMonkey Setup - Software License Agreement' window appeared and 'Accept' was clicked.`n
        }
        else
        {
            TestsFailed()
            WinGetTitle, title, A
            OutputDebug, %TestName%:%A_LineNumber%: Test failed: Unable to hit 'Accept' button in 'SeaMonkey Setup - Software License Agreement' window. Active window caption: '%title%'.`n
        }
    }
    else
    {
        TestsFailed()
        WinGetTitle, title, A
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'SeaMonkey Setup - Software License Agreement' window failed to appear. Active window caption: '%title%'.`n
    }
}


; Test if 'SeaMonkey Setup - Setup Type' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, SeaMonkey Setup - Setup Type,, 7
    if not ErrorLevel
    {
        Sleep, 250
        ControlClick, Button9, SeaMonkey Setup - Setup Type ; Hit 'Next' button
        if not ErrorLevel
        {
            TestsOK()
            OutputDebug, OK: %TestName%:%A_LineNumber%: 'SeaMonkey Setup - Setup Type' window appeared and 'Next' was clicked.`n
        }
        else
        {
            TestsFailed()
            WinGetTitle, title, A
            OutputDebug, %TestName%:%A_LineNumber%: Test failed: Unable to hit 'Next' button in 'SeaMonkey Setup - Setup Type' window. Active window caption: '%title%'.`n
        }
    }
    else
    {
        TestsFailed()
        WinGetTitle, title, A
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'SeaMonkey Setup - Setup Type' window failed to appear. Active window caption: '%title%'.`n
    }
}


; Test if 'SeaMonkey Setup - Quick Launch' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, SeaMonkey Setup - Quick Launch,, 7
    if not ErrorLevel
    {
        Sleep, 250
        ControlClick, Button3, SeaMonkey Setup - Quick Launch ; Hit 'Next' button
        if not ErrorLevel
        {
            TestsOK()
            OutputDebug, OK: %TestName%:%A_LineNumber%: 'SeaMonkey Setup - Quick Launch' window appeared and 'Next' was clicked.`n
        }
        else
        {
            TestsFailed()
            WinGetTitle, title, A
            OutputDebug, %TestName%:%A_LineNumber%: Test failed: Unable to hit 'Next' button in 'SeaMonkey Setup - Quick Launch' window. Active window caption: '%title%'.`n
        }
    }
    else
    {
        TestsFailed()
        WinGetTitle, title, A
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'SeaMonkey Setup - Quick Launch' window failed to appear. Active window caption: '%title%'.`n
    }
}


; Test if 'SeaMonkey Setup - Start Install' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, SeaMonkey Setup - Start Install,, 7
    if not ErrorLevel
    {
        Sleep, 250
        ControlClick, Button1, SeaMonkey Setup - Start Install ; Hit 'Install' button
        if not ErrorLevel
        {
            TestsOK()
            OutputDebug, OK: %TestName%:%A_LineNumber%: 'SeaMonkey Setup - Start Install' window appeared and 'Install' was clicked.`n
            Sleep, 2000
        }
        else
        {
            TestsFailed()
            WinGetTitle, title, A
            OutputDebug, %TestName%:%A_LineNumber%: Test failed: Unable to hit 'Install' button in 'SeaMonkey Setup - Start Install' window. Active window caption: '%title%'.`n
        }
    }
    else
    {
        TestsFailed()
        WinGetTitle, title, A
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'SeaMonkey Setup - Start Install' window failed to appear. Active window caption: '%title%'.`n
    }
}


; Test if 'SeaMonkey Setup' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, SeaMonkey Setup,, 15
    if not ErrorLevel
    {
        OutputDebug, OK: %TestName%:%A_LineNumber%: 'SeaMonkey Setup' window appeared, waiting for it to close.`n
        WinWaitClose, SeaMonkey Setup,,25
        if not ErrorLevel
        {
            TestsOK()
            OutputDebug, OK: %TestName%:%A_LineNumber%: 'SeaMonkey Setup' window went away.`n
        }
        else
        {
            TestsFailed()
            WinGetTitle, title, A
            OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'SeaMonkey Setup' window failed to disappear. Active window caption: '%title%'.`n
        }
        
    }
    else
    {
        TestsFailed()
        WinGetTitle, title, A
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'SeaMonkey Setup' window failed to appear. Active window caption: '%title%'.`n
    }
}


; Test if 'SeaMonkey Setup - Install Progress' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, SeaMonkey Setup - Install Progress,, 15
    if not ErrorLevel
    {
        OutputDebug, OK: %TestName%:%A_LineNumber%: 'SeaMonkey Setup - Install Progress' window appeared, waiting for it to close.`n
        WinWaitClose, SeaMonkey Setup,,25
        if not ErrorLevel
        {
            TestsOK()
            OutputDebug, OK: %TestName%:%A_LineNumber%: 'SeaMonkey Setup - Install Progress' window went away.`n
            Sleep, 2000
            Process, Close, seamonkey.exe
        }
        else
        {
            TestsFailed()
            WinGetTitle, title, A
            OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'SeaMonkey Setup - Install Progress' window failed to disappear. Active window caption: '%title%'.`n
        }
        
    }
    else
    {
        TestsFailed()
        WinGetTitle, title, A
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'SeaMonkey Setup - Install Progress' window failed to appear. Active window caption: '%title%'.`n
    }
}


;Check if program exists in program files
TestsTotal++
if bContinue
{
    Sleep, 2000
    IfExist, %A_ProgramFiles%\mozilla.org\SeaMonkey
    {
        TestsOK()
        OutputDebug, OK: %TestName%:%A_LineNumber%: The application has been installed, because '%A_ProgramFiles%\mozilla.org\SeaMonkey' was found.`n
    }
    else
    {
        TestsFailed()
        WinGetTitle, title, A
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: Can NOT find '%A_ProgramFiles%\mozilla.org\SeaMonkey'. Active window caption: '%title%'.`n
    }
}
