/*
 * Designed for Foxit Reader 2.1.2023
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

ModuleExe = %A_WorkingDir%\Apps\Foxit Reader 2.1.2023 Setup.exe
bContinue := false
TestName = 1.install

TestsFailed := 0
TestsOK := 0
TestsTotal := 0

; Test if Setup file exists, if so, delete installed files, and run Setup
IfExist, %ModuleExe%
{
    ; Get rid of other versions
    RegRead, UninstallerPath, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Foxit Reader, UninstallString
    if not ErrorLevel
    {   
        IfExist, %UninstallerPath%
        {
            Process, Close, Foxit Reader.exe ; Teminate process
            ; No silent switch for uninstaller
            RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\Foxit Software
            RegDelete, HKEY_CURRENT_USER, SOFTWARE\Foxit Software
            RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\MicroSoft\Windows\CurrentVersion\Uninstall\Foxit Reader
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
        IfExist, %A_ProgramFiles%\Foxit Software\Foxit Reader
        {
            Process, Close, Foxit Reader.exe ; Teminate process
            Sleep, 1500
            FileRemoveDir, %A_ProgramFiles%\Foxit Software\Foxit Reader, 1
            Sleep, 1000
            IfExist, %A_ProgramFiles%\Foxit Software\Foxit Reader
            {
                OutputDebug, %TestName%:%A_LineNumber%: Test failed: Previous version detected and failed to delete '%A_ProgramFiles%\Foxit Software\Foxit Reader'.`n
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
        IfExist, %A_WinDir%\System32\mfc42.dll
        {
            Run %ModuleExe%
        }
        else
        {
            OutputDebug, %TestName%:%A_LineNumber%: Test failed: '%A_WinDir%\System32\mfc42.dll' is required, but it was not found (VC++6).`n
            bContinue := false
        }
    }
}
else
{
    OutputDebug, %TestName%:%A_LineNumber%: Test failed: '%ModuleExe%' not found.`n
    bContinue := false
}


; Test if 'Setup will install' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Foxit Reader Install Wizard, Setup will install, 15
    if not ErrorLevel
    {
        Sleep, 250
        ControlClick, Button1, Foxit Reader Install Wizard, Setup will install
        if not ErrorLevel
        {
            TestsOK++
            OutputDebug, OK: %TestName%:%A_LineNumber%: 'Foxit Reader Install Wizard' window with 'Setup will install' appeared and 'Next' was clicked.`n
            bContinue := true
        }
        else
        {
            TestsFailed++
            WinGetTitle, title, A
            OutputDebug, %TestName%:%A_LineNumber%: Test failed: Unable to click 'Next' in 'Setup will install' window. Active window caption: '%title%'.`n
            bContinue := false
        }
    }
    else
    {
        TestsFailed++
        WinGetTitle, title, A
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'Foxit Reader Install Wizard' window with 'Setup will install' failed to appear. Active window caption: '%title%'.`n
        bContinue := false
    }
}


; Test if 'New features' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Foxit Reader Install Wizard, New features, 15
    if not ErrorLevel
    {
        Sleep, 250
        ControlClick, Button1, Foxit Reader Install Wizard, New features
        if not ErrorLevel
        {
            TestsOK++
            OutputDebug, OK: %TestName%:%A_LineNumber%: 'Foxit Reader Install Wizard' window with 'New features' appeared and 'Next' was clicked.`n
            bContinue := true
        }
        else
        {
            TestsFailed++
            WinGetTitle, title, A
            OutputDebug, %TestName%:%A_LineNumber%: Test failed: Unable to click 'Next' in 'New features' window. Active window caption: '%title%'.`n
            bContinue := false
        }
    }
    else
    {
        TestsFailed++
        WinGetTitle, title, A
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'Foxit Reader Install Wizard' window with 'New features' failed to appear. Active window caption: '%title%'.`n
        bContinue := false
    }
}


; Test if 'Please read the license' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Foxit Reader Install Wizard, Please read the license, 7
    if not ErrorLevel
    {
        Sleep, 250
        ControlClick, Button1, Foxit Reader Install Wizard, Please read the license ; Hit 'I agree' button
        if not ErrorLevel
        {
            TestsOK++
            OutputDebug, OK: %TestName%:%A_LineNumber%: 'Foxit Reader Install Wizard' window with 'Please read the license' appeared and 'I agree' was clicked.`n
            bContinue := true
        }
        else
        {
            TestsFailed++
            WinGetTitle, title, A
            OutputDebug, %TestName%:%A_LineNumber%: Test failed: Unable to click 'I agree' in 'Please read the license' window. Active window caption: '%title%'.`n
            bContinue := false
        }
    }
    else
    {
        TestsFailed++
        WinGetTitle, title, A
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'Foxit Reader Install Wizard' window with 'Please read the license' failed to appear. Active window caption: '%title%'.`n
        bContinue := false
    }
}


; Test if 'installation type' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Foxit Reader Install Wizard, installation type, 7
    if not ErrorLevel
    {
        Sleep, 250
        ControlClick, Button1, Foxit Reader Install Wizard, installation type ; Hit 'Default' button
        if not ErrorLevel
        {
            TestsOK++
            OutputDebug, OK: %TestName%:%A_LineNumber%: 'Foxit Reader Install Wizard' window with 'installation type' appeared and 'Next' was clicked.`n
            bContinue := true
        }
        else
        {
            TestsFailed++
            WinGetTitle, title, A
            OutputDebug, %TestName%:%A_LineNumber%: Test failed: Unable to click 'Next' in 'installation type' window. Active window caption: '%title%'.`n
            bContinue := false
        }
    }
    else
    {
        TestsFailed++
        WinGetTitle, title, A
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'Foxit Reader Install Wizard' window with 'installation type' failed to appear. Active window caption: '%title%'.`n
        bContinue := false
    }
}


; Test if 'Click Install' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Foxit Reader Install Wizard, Click Install, 7
    if not ErrorLevel
    {
        Sleep, 250
        ControlClick, Button1, Foxit Reader Install Wizard, Click Install ; Hit 'Install' button
        if not ErrorLevel
        {
            TestsOK++
            OutputDebug, OK: %TestName%:%A_LineNumber%: 'Foxit Reader Install Wizard' window with 'Click Install' appeared and 'Next' was clicked.`n
            bContinue := true
        }
        else
        {
            TestsFailed++
            WinGetTitle, title, A
            OutputDebug, %TestName%:%A_LineNumber%: Test failed: Unable to click 'Next' in 'Click Install' window. Active window caption: '%title%'.`n
            bContinue := false
        }
    }
    else
    {
        TestsFailed++
        WinGetTitle, title, A
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'Foxit Reader Install Wizard' window with 'Click Install' failed to appear. Active window caption: '%title%'.`n
        bContinue := false
    }
}


; Test if 'Setup has successfully installed' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Foxit Reader Install Wizard, Setup has successfully installed, 35
    if not ErrorLevel
    {
        Sleep, 250
        ControlClick, Button3, Foxit Reader Install Wizard, Setup has successfully installed ; Uncheck 'Make it your default PDF reader'
        if not ErrorLevel
        {
            ControlClick, Button2, Foxit Reader Install Wizard, Setup has successfully installed ; Uncheck 'Run Foxit Reader'
            if not ErrorLevel
            {
                ControlClick, Button1, Foxit Reader Install Wizard, Setup has successfully installed ; Hit 'Finish'
                if not ErrorLevel
                {
                    TestsOK++
                    OutputDebug, OK: %TestName%:%A_LineNumber%: 'Foxit Reader Install Wizard' window with 'Setup has successfully installed' appeared and 'Finish' was clicked.`n
                    bContinue := true
                }
                else
                {
                    TestsFailed++
                    WinGetTitle, title, A
                    OutputDebug, %TestName%:%A_LineNumber%: Test failed: Unable to click 'Finish' in 'Setup has successfully installed' window. Active window caption: '%title%'.`n
                    bContinue := false
                }
            }
            else
            {
                TestsFailed++
                WinGetTitle, title, A
                OutputDebug, %TestName%:%A_LineNumber%: Test failed: Unable to uncheck 'Run Foxit Reader' in 'Setup has successfully installed' window. Active window caption: '%title%'.`n
                bContinue := false
                Process, Close, Foxit Reader
            }
        }
        else
        {
            TestsFailed++
            WinGetTitle, title, A
            OutputDebug, %TestName%:%A_LineNumber%: Test failed: unable to uncheck 'Make it your default PDF reader' in 'Setup has successfully installed' window. Active window caption: '%title%'.`n
            bContinue := false
        }
    }
    else
    {
        TestsFailed++
        WinGetTitle, title, A
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'Foxit Reader Install Wizard' window with 'Setup has successfully installed' failed to appear. Active window caption: '%title%'.`n
        bContinue := false
    }
}


;Check if program exists in program files
TestsTotal++
if bContinue
{
    Sleep, 2000
    RegRead, UninstallerPath, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Foxit Reader, UninstallString
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
