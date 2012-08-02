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
bContinue := false
TestName = 1.install

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
            {
                bContinue := true
            }
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
        Run %ModuleExe%
    }
}
else
{
    OutputDebug, %TestName%:%A_LineNumber%: Test failed: '%ModuleExe%' not found.`n
    bContinue := false
}


; Test if 'Installer Language' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Installer Language, Please select, 15
    if not ErrorLevel
    {
        Sleep, 250
        ControlClick, Button1, Installer Language, Please select
        if not ErrorLevel
        {
            TestsOK++
            OutputDebug, OK: %TestName%:%A_LineNumber%: 'Installer Language' window with 'Please select' appeared and 'OK' was clicked.`n
            bContinue := true
        }
        else
        {
            TestsFailed++
            WinGetTitle, title, A
            OutputDebug, %TestName%:%A_LineNumber%: Test failed: Unable to click 'OK' in 'Installer Language' window. Active window caption: '%title%'.`n
            bContinue := false
        }
    }
    else
    {
        TestsFailed++
        WinGetTitle, title, A
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'Installer Language' window with 'Please select' failed to appear. Active window caption: '%title%'.`n
        bContinue := false
    }
}


; Test if 'This wizard' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, AbiWord 2.6.4 Setup, This wizard, 15
    if not ErrorLevel
    {
        Sleep, 250
        ControlClick, Button2, AbiWord 2.6.4 Setup, This wizard
        if not ErrorLevel
        {
            TestsOK++
            OutputDebug, OK: %TestName%:%A_LineNumber%: 'AbiWord 2.6.4 Setup' window with 'This wizard' appeared and 'Next' was clicked.`n
            bContinue := true
        }
        else
        {
            TestsFailed++
            WinGetTitle, title, A
            OutputDebug, %TestName%:%A_LineNumber%: Test failed: Unable to click 'Next' in 'This wizard' window. Active window caption: '%title%'.`n
            bContinue := false
        }
    }
    else
    {
        TestsFailed++
        WinGetTitle, title, A
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'AbiWord 2.6.4 Setup' window with 'This wizard' failed to appear. Active window caption: '%title%'.`n
        bContinue := false
    }
}


; Test if 'License Agreement' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, AbiWord 2.6.4 Setup, License Agreement, 15
    if not ErrorLevel
    {
        Sleep, 250
        ControlClick, Button2, AbiWord 2.6.4 Setup, License Agreement
        if not ErrorLevel
        {
            TestsOK++
            OutputDebug, OK: %TestName%:%A_LineNumber%: 'AbiWord 2.6.4 Setup' window with 'License Agreement' appeared and 'Next' was clicked.`n
            bContinue := true
        }
        else
        {
            TestsFailed++
            WinGetTitle, title, A
            OutputDebug, %TestName%:%A_LineNumber%: Test failed: Unable to click 'Next' in 'License Agreement' window. Active window caption: '%title%'.`n
            bContinue := false
        }
    }
    else
    {
        TestsFailed++
        WinGetTitle, title, A
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'AbiWord 2.6.4 Setup' window with 'License Agreement' failed to appear. Active window caption: '%title%'.`n
        bContinue := false
    }
}


; Test if 'Choose Components' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, AbiWord 2.6.4 Setup, Choose Components, 7
    if not ErrorLevel
    {
        Sleep, 250
        ControlClick, Button2, AbiWord 2.6.4 Setup, Choose Components
        if not ErrorLevel
        {
            TestsOK++
            OutputDebug, OK: %TestName%:%A_LineNumber%: 'AbiWord 2.6.4 Setup' window with 'Choose Components' appeared and 'Next' was clicked.`n
            bContinue := true
        }
        else
        {
            TestsFailed++
            WinGetTitle, title, A
            OutputDebug, %TestName%:%A_LineNumber%: Test failed: Unable to click 'Next' in 'Choose Components' window. Active window caption: '%title%'.`n
            bContinue := false
        }
    }
    else
    {
        TestsFailed++
        WinGetTitle, title, A
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'AbiWord 2.6.4 Setup' window with 'Choose Components' failed to appear. Active window caption: '%title%'.`n
        bContinue := false
    }
}


; Test if 'Choose Install Location' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, AbiWord 2.6.4 Setup, Choose Install Location, 7
    if not ErrorLevel
    {
        Sleep, 250
        ControlClick, Button2, AbiWord 2.6.4 Setup, Choose Install Location
        if not ErrorLevel
        {
            TestsOK++
            OutputDebug, OK: %TestName%:%A_LineNumber%: 'AbiWord 2.6.4 Setup' window with 'Choose Install Location' appeared and 'Next' was clicked.`n
            bContinue := true
        }
        else
        {
            TestsFailed++
            WinGetTitle, title, A
            OutputDebug, %TestName%:%A_LineNumber%: Test failed: Unable to click 'Next' in 'Choose Install Location' window. Active window caption: '%title%'.`n
            bContinue := false
        }
    }
    else
    {
        TestsFailed++
        WinGetTitle, title, A
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'AbiWord 2.6.4 Setup' window with 'Choose Install Location' failed to appear. Active window caption: '%title%'.`n
        bContinue := false
    }
}


; Test if 'Choose Start Menu Folder' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, AbiWord 2.6.4 Setup, Choose Start Menu Folder, 7
    if not ErrorLevel
    {
        Sleep, 250
        ControlClick, Button2, AbiWord 2.6.4 Setup, Choose Start Menu Folder
        if not ErrorLevel
        {
            TestsOK++
            OutputDebug, OK: %TestName%:%A_LineNumber%: 'AbiWord 2.6.4 Setup' window with 'Choose Start Menu Folder' appeared and 'Next' was clicked.`n
            bContinue := true
        }
        else
        {
            TestsFailed++
            WinGetTitle, title, A
            OutputDebug, %TestName%:%A_LineNumber%: Test failed: Unable to click 'Next' in 'Choose Start Menu Folder' window. Active window caption: '%title%'.`n
            bContinue := false
        }
    }
    else
    {
        TestsFailed++
        WinGetTitle, title, A
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'AbiWord 2.6.4 Setup' window with 'Choose Start Menu Folder' failed to appear. Active window caption: '%title%'.`n
        bContinue := false
    }
}


; Test if can get thru 'Installing'
TestsTotal++
if bContinue
{
    WinWaitActive, AbiWord 2.6.4 Setup, Installing, 7
    if not ErrorLevel
    {
        Sleep, 250
        OutputDebug, OK: %TestName%:%A_LineNumber%: 'Installing' window appeared, waiting for it to close.`n
        WinWaitClose, AbiWord 2.6.4 Setup, Installing, 35
        if not ErrorLevel
        {
            WinWaitActive, AbiWord 2.6.4 Setup, Installation Complete, 7
            if not ErrorLevel
            {
                ControlClick, Button2, AbiWord 2.6.4 Setup, Installation Complete
                if not ErrorLevel
                {
                    TestsOK++
                    OutputDebug, OK: %TestName%:%A_LineNumber%: 'Installing' went away, and 'Next' was clicked in 'Installation Complete' window.`n
                    bContinue := true
                }
                else
                {
                    TestsFailed++
                    WinGetTitle, title, A
                    OutputDebug, %TestName%:%A_LineNumber%: Test failed: Unable to click 'Next' in 'Installation Complete' window. Active window caption: '%title%'.`n
                    bContinue := false
                }
            }
            else
            {
                TestsFailed++
                WinGetTitle, title, A
                OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'AbiWord 2.6.4 Setup' window with 'Installation Complete' failed to appear. Active window caption: '%title%'.`n
                bContinue := false
            }
        }
        else
        {
            TestsFailed++
            WinGetTitle, title, A
            OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'AbiWord 2.6.4 Setup' window with 'Installing' failed to dissapear. Active window caption: '%title%'.`n
            bContinue := false
        }
    }
    else
    {
        TestsFailed++
        WinGetTitle, title, A
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'AbiWord 2.6.4 Setup' window with 'Installing' failed to appear. Active window caption: '%title%'.`n
        bContinue := false
    }
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
            {
                TestsOK++
                OutputDebug, OK: %TestName%:%A_LineNumber%: 'AbiWord 2.6.4 Setup' window with 'Completing' appeared and 'Finish' was clicked.`n
                bContinue := true
            }
            else
            {
                TestsFailed++
                WinGetTitle, title, A
                OutputDebug, %TestName%:%A_LineNumber%: Test failed: Unable to click 'Finish' in 'Completing' window. Active window caption: '%title%'.`n
                bContinue := false
            }
        }
        else
        {
            TestsFailed++
            WinGetTitle, title, A
            OutputDebug, %TestName%:%A_LineNumber%: Test failed: unable to uncheck 'Run AbiWord 2.6.4' in 'Completing' window. Active window caption: '%title%'.`n
            bContinue := false
            Process, Close, AbiWord.exe ; Just in case
        }
    }
    else
    {
        TestsFailed++
        WinGetTitle, title, A
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'AbiWord 2.6.4 Setup' window with 'Completing' failed to appear. Active window caption: '%title%'.`n
        bContinue := false
    }
}


;Check if program exists in program files
TestsTotal++
if bContinue
{
    Sleep, 2000
    RegRead, UninstallerPath, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Abiword2, UninstallString
    if not ErrorLevel
    {
        IfExist, %UninstallerPath%
        {
            TestsOK++
            OutputDebug, OK: %TestName%:%A_LineNumber%: The application has been installed, because '%UninstallerPath%' was found.`n
            bContinue := true
        }
        else
        {
            TestsFailed++
            OutputDebug, %TestName%:%A_LineNumber%: Test failed: Something went wrong, can't find '%UninstallerPath%'.`n
            bContinue := false
        }
    }
    else
    {
        TestsFailed++
        WinGetTitle, title, A
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: Either we can't read from registry or data doesn't exist. Active window caption: '%title%'.`n
        bContinue := false
    }
}
