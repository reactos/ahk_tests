/*
 * Designed for FAR Manager 1.70.2087
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

ModuleExe = %A_WorkingDir%\Apps\FAR Manager 1.70.2087 Setup.exe
bContinue := false
TestName = 1.install

TestsFailed := 0
TestsOK := 0
TestsTotal := 0

; Test if Setup file exists, if so, delete installed files, and run Setup
IfExist, %ModuleExe%
{
    ; Get rid of other versions
    RegRead, UninstallerPath, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Far manager, UninstallString
    if not ErrorLevel
    {   
        IfExist, %UninstallerPath%
        {
            Process, Close, Far.exe ; Teminate process
            Sleep, 1500
            ; Silent uninstall is broken (at least /S shows dialog)
            ; Delete everything just in case
            RegDelete, HKEY_CURRENT_USER, SOFTWARE\Far
            RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\MicroSoft\Windows\CurrentVersion\Uninstall\Far manager
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
        IfExist, %A_ProgramFiles%\Far
        {
            Process, Close, Far.exe ; Teminate process
            Sleep, 1500
            FileRemoveDir, %A_ProgramFiles%\Far, 1
            RegDelete, HKEY_CURRENT_USER, SOFTWARE\Far
            RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\MicroSoft\Windows\CurrentVersion\Uninstall\Far manager
            IfExist, %A_ProgramFiles%\Far
            {
                OutputDebug, %TestName%:%A_LineNumber%: Test failed: Previous version detected and failed to delete '%A_ProgramFiles%\Far'.`n
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
        FileRemoveDir, %A_StartMenu%\Programs\Far Manager, 1
        FileDelete, %A_Desktop%\Far Manager.lnk
        Sleep, 1000
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


; Test if 'This program will install' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Far Manager v1.70 Setup, This program will install, 15
    if not ErrorLevel
    {
        Sleep, 250
        ControlClick, Button2, Far Manager v1.70 Setup, This program will install
        if not ErrorLevel
        {
            TestsOK++
            OutputDebug, OK: %TestName%:%A_LineNumber%: 'Far Manager v1.70 Setup' window with 'This program will install' appeared and 'Next' was clicked.`n
            bContinue := true
        }
        else
        {
            TestsFailed++
            WinGetTitle, title, A
            OutputDebug, %TestName%:%A_LineNumber%: Test failed: Unable to click 'Next' in 'This program will install' window. Active window caption: '%title%'.`n
            bContinue := false
        }
    }
    else
    {
        TestsFailed++
        WinGetTitle, title, A
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'Far Manager v1.70 Setup' window with 'This program will install' failed to appear. Active window caption: '%title%'.`n
        bContinue := false
    }
}


; Test if 'License Agreement' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Far Manager v1.70 Setup, License Agreement, 15
    if not ErrorLevel
    {
        Sleep, 250
        ControlClick, Button4, Far Manager v1.70 Setup, License Agreement ; check 'I accept' checkbox
        if not ErrorLevel
        {
            Sleep, 1500 ; Give some time for 'Next' to get enabled
            ControlGet, OutputVar, Enabled,, Button2, Far Manager v1.70 Setup, License Agreement
            if %OutputVar%
            {
                ControlClick, Button2, Far Manager v1.70 Setup, License Agreement
                if not ErrorLevel
                {
                    TestsOK++
                    OutputDebug, OK: %TestName%:%A_LineNumber%: 'Far Manager v1.70 Setup' window with 'License Agreement' appeared and 'Next' was clicked.`n
                    bContinue := true
                }
                else
                {
                    TestsFailed++
                    WinGetTitle, title, A
                    OutputDebug, %TestName%:%A_LineNumber%: Test failed: Unable to hit 'Next' button in 'License Agreement' window despite it is enabled. Active window caption: '%title%'.`n
                    bContinue := false
                }
            }
            else
            {
                TestsFailed++
                WinGetTitle, title, A
                OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'I agree' radio button is checked in 'License Agreement', but 'Next' button is disabled. Active window caption: '%title%'.`n
                bContinue := false
            }
        }
        else
        {
            TestsFailed++
            WinGetTitle, title, A
            OutputDebug, %TestName%:%A_LineNumber%: Test failed: Unable to check 'I agree' radio button in 'License Agreement' window. Active window caption: '%title%'.`n
            bContinue := false
        }
    }
    else
    {
        TestsFailed++
        WinGetTitle, title, A
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'Far Manager v1.70 Setup' window with 'License Agreement' failed to appear. Active window caption: '%title%'.`n
        bContinue := false
    }
}


; Test if 'Choose Install Location' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Far Manager v1.70 Setup, Choose Install Location, 7
    if not ErrorLevel
    {
        Sleep, 250
        ControlClick, Button2, Far Manager v1.70 Setup, Choose Install Location
        if not ErrorLevel
        {
            TestsOK++
            OutputDebug, OK: %TestName%:%A_LineNumber%: 'Far Manager v1.70 Setup' window with 'Choose Install Location' appeared and 'Next' was clicked.`n
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
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'Far Manager v1.70 Setup' window with 'Choose Install Location' failed to appear. Active window caption: '%title%'.`n
        bContinue := false
    }
}


; Test if 'Choose Components' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Far Manager v1.70 Setup, Choose Components, 7
    if not ErrorLevel
    {
        Sleep, 250
        ControlClick, Button2, Far Manager v1.70 Setup, Choose Components
        if not ErrorLevel
        {
            TestsOK++
            OutputDebug, OK: %TestName%:%A_LineNumber%: 'Far Manager v1.70 Setup' window with 'Choose Components' appeared and 'Next' was clicked.`n
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
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'Far Manager v1.70 Setup' window with 'Choose Components' failed to appear. Active window caption: '%title%'.`n
        bContinue := false
    }
}


; Test if 'Choose Start Menu Folder' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Far Manager v1.70 Setup, Choose Start Menu Folder, 7
    if not ErrorLevel
    {
        Sleep, 250
        ControlClick, Button2, Far Manager v1.70 Setup, Choose Start Menu Folder ; Hit 'Install' button
        if not ErrorLevel
        {
            TestsOK++
            OutputDebug, OK: %TestName%:%A_LineNumber%: 'Far Manager v1.70 Setup' window with 'Choose Start Menu Folder' appeared and 'Install' was clicked.`n
            bContinue := true
        }
        else
        {
            TestsFailed++
            WinGetTitle, title, A
            OutputDebug, %TestName%:%A_LineNumber%: Test failed: Unable to click 'Install' in 'Choose Start Menu Folder' window. Active window caption: '%title%'.`n
            bContinue := false
        }
    }
    else
    {
        TestsFailed++
        WinGetTitle, title, A
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'Far Manager v1.70 Setup' window with 'Choose Start Menu Folder' failed to appear. Active window caption: '%title%'.`n
        bContinue := false
    }
}


; Test if can get thru 'Installing'
TestsTotal++
if bContinue
{
    WinWaitActive, Far Manager v1.70 Setup, Installing, 7
    if not ErrorLevel
    {
        Sleep, 250
        OutputDebug, OK: %TestName%:%A_LineNumber%: 'Installing' window appeared, waiting for it to close.`n
        WinWaitClose, Far Manager v1.70 Setup, Installing, 35
        if not ErrorLevel
        {
            WinWaitActive, Far Manager v1.70 Setup, Installation Complete, 7
            if not ErrorLevel
            {
                ControlClick, Button2, Far Manager v1.70 Setup, Installation Complete
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
                OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'Far Manager v1.70 Setup' window with 'Installation Complete' failed to appear. Active window caption: '%title%'.`n
                bContinue := false
            }
        }
        else
        {
            TestsFailed++
            WinGetTitle, title, A
            OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'Far Manager v1.70 Setup' window with 'Installing' failed to dissapear. Active window caption: '%title%'.`n
            bContinue := false
        }
    }
    else
    {
        TestsFailed++
        WinGetTitle, title, A
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'Far Manager v1.70 Setup' window with 'Installing' failed to appear. Active window caption: '%title%'.`n
        bContinue := false
    }
}


; Test if 'Additional tasks' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Far Manager v1.70 Setup, Additional tasks, 7
    if not ErrorLevel
    {
        Sleep, 250
        ControlClick, Button2, Far Manager v1.70 Setup, Additional tasks
        if not ErrorLevel
        {
            TestsOK++
            OutputDebug, OK: %TestName%:%A_LineNumber%: 'Far Manager v1.70 Setup' window with 'Additional tasks' appeared and 'Next' was clicked.`n
            bContinue := true
        }
        else
        {
            TestsFailed++
            WinGetTitle, title, A
            OutputDebug, %TestName%:%A_LineNumber%: Test failed: Unable to click 'Next' in 'Additional tasks' window. Active window caption: '%title%'.`n
            bContinue := false
        }
    }
    else
    {
        TestsFailed++
        WinGetTitle, title, A
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'Far Manager v1.70 Setup' window with 'Additional tasks' failed to appear. Active window caption: '%title%'.`n
        bContinue := false
    }
}


; Test if 'Completing' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Far Manager v1.70 Setup, Completing, 7
    if not ErrorLevel
    {
        Sleep, 250
        ControlClick, Button4, Far Manager v1.70 Setup, Completing ; Uncheck 'Run Far Manager v1.70'
        if not ErrorLevel
        {
            ControlClick, Button5, Far Manager v1.70 Setup, Completing ; Uncheck 'Show whats new'
            if not ErrorLevel
            {
                ControlClick, Button2, Far Manager v1.70 Setup, Completing ; Hit 'Finish'
                if not ErrorLevel
                {
                    TestsOK++
                    OutputDebug, OK: %TestName%:%A_LineNumber%: 'Far Manager v1.70 Setup' window with 'Completing' appeared and 'Finish' was clicked.`n
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
                OutputDebug, %TestName%:%A_LineNumber%: Test failed: unable to uncheck 'Show whats new' in 'Completing' window. Active window caption: '%title%'.`n
                bContinue := false
            }
        }
        else
        {
            TestsFailed++
            WinGetTitle, title, A
            OutputDebug, %TestName%:%A_LineNumber%: Test failed: unable to uncheck 'Run Far Manager v1.70' in 'Completing' window. Active window caption: '%title%'.`n
            bContinue := false
            Process, Close, Far.exe ; Just in case
        }
    }
    else
    {
        TestsFailed++
        WinGetTitle, title, A
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'Far Manager v1.70 Setup' window with 'Completing' failed to appear. Active window caption: '%title%'.`n
        bContinue := false
    }
}


;Check if program exists in program files
TestsTotal++
if bContinue
{
    Sleep, 2000
    RegRead, UninstallerPath, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Far manager, UninstallString
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
