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
        {
            TestsOK()
            OutputDebug, OK: %TestName%:%A_LineNumber%: 'mIRC Setup' window with 'This wizard' appeared and 'Next' was clicked.`n
        }
        else
        {
            TestsFailed()
            WinGetTitle, title, A
            OutputDebug, %TestName%:%A_LineNumber%: Test failed: Unable to click 'Next' in 'This wizard' window. Active window caption: '%title%'.`n
        }
    }
    else
    {
        TestsFailed()
        WinGetTitle, title, A
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'mIRC Setup' window with 'This wizard' failed to appear. Active window caption: '%title%'.`n
    }
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
        {
            TestsOK()
            OutputDebug, OK: %TestName%:%A_LineNumber%: 'mIRC Setup' window with 'License Agreement' appeared and 'I Agree' was clicked.`n
        }
        else
        {
            TestsFailed()
            WinGetTitle, title, A
            OutputDebug, %TestName%:%A_LineNumber%: Test failed: Unable to click 'I Agree' in 'License Agreement' window. Active window caption: '%title%'.`n
        }
    }
    else
    {
        TestsFailed()
        WinGetTitle, title, A
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'mIRC Setup' window with 'License Agreement' failed to appear. Active window caption: '%title%'.`n
    }
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
        {
            TestsOK()
            OutputDebug, OK: %TestName%:%A_LineNumber%: 'mIRC Setup' window with 'Choose Install Location' appeared and 'Next' was clicked.`n
        }
        else
        {
            TestsFailed()
            WinGetTitle, title, A
            OutputDebug, %TestName%:%A_LineNumber%: Test failed: Unable to click 'Next' in 'Choose Install Location' window. Active window caption: '%title%'.`n
        }
    }
    else
    {
        TestsFailed()
        WinGetTitle, title, A
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'mIRC Setup' window with 'Choose Install Location' failed to appear. Active window caption: '%title%'.`n
    }
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
        {
            TestsOK()
            OutputDebug, OK: %TestName%:%A_LineNumber%: 'mIRC Setup' window with 'Choose Components' appeared and 'Next' was clicked.`n
        }
        else
        {
            TestsFailed()
            WinGetTitle, title, A
            OutputDebug, %TestName%:%A_LineNumber%: Test failed: Unable to click 'Next' in 'Choose Components' window. Active window caption: '%title%'.`n
        }
    }
    else
    {
        TestsFailed()
        WinGetTitle, title, A
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'mIRC Setup' window with 'Choose Components' failed to appear. Active window caption: '%title%'.`n
    }
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
                {
                    TestsOK()
                    OutputDebug, OK: %TestName%:%A_LineNumber%: 'mIRC Setup' window with 'Select Additional Tasks' appeared, some checkboxes unchecked and 'Next' was clicked.`n
                }
                else
                {
                    TestsFailed()
                    WinGetTitle, title, A
                    OutputDebug, %TestName%:%A_LineNumber%: Test failed: Unable to click 'Next' in 'Select Additional Tasks' window. Active window caption: '%title%'.`n
                }
            }
            else
            {
                TestsFailed()
                WinGetTitle, title, A
                OutputDebug, %TestName%:%A_LineNumber%: Test failed: Unable to uncheck 'Automatically Check for Updates' in 'Select Additional Tasks' window. Active window caption: '%title%'.`n
            }
        }
        else
        {
            TestsFailed()
            WinGetTitle, title, A
            OutputDebug, %TestName%:%A_LineNumber%: Test failed: Unable to uncheck 'Backup Current Files' in 'Select Additional Tasks' window. Active window caption: '%title%'.`n
        }
    }
    else
    {
        TestsFailed()
        WinGetTitle, title, A
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'mIRC Setup' window with 'Select Additional Tasks' failed to appear. Active window caption: '%title%'.`n
    }
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
        {
            TestsOK()
            OutputDebug, OK: %TestName%:%A_LineNumber%: 'mIRC Setup' window with 'Ready to Install' appeared and 'Install' was clicked.`n
        }
        else
        {
            TestsFailed()
            WinGetTitle, title, A
            OutputDebug, %TestName%:%A_LineNumber%: Test failed: Unable to click 'Install' in 'Ready to Install' window. Active window caption: '%title%'.`n
        }
    }
    else
    {
        TestsFailed()
        WinGetTitle, title, A
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'mIRC Setup' window with 'Ready to Install' failed to appear. Active window caption: '%title%'.`n
    }
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
            TestsOK()
            OutputDebug, OK: %TestName%:%A_LineNumber%: 'mIRC Setup' window with 'mIRC has been installed' appeared and 'Finish' was clicked.`n
            Sleep, 1500
            ; There are two checkboxes, but unchecked by default. Just to be sure, terminate processes
            Process, Close, hh.exe
            Process, Close, mirc.exe
        }
        else
        {
            TestsFailed()
            WinGetTitle, title, A
            OutputDebug, %TestName%:%A_LineNumber%: Test failed: Unable to click 'Finish' in 'mIRC has been installed' window. Active window caption: '%title%'.`n
        }
    }
    else
    {
        TestsFailed()
        WinGetTitle, title, A
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'mIRC Setup' window with 'mIRC has been installed' failed to appear. Active window caption: '%title%'.`n
    }
}

;Check if program exists in program files
TestsTotal++
if bContinue
{
    Sleep, 2000
    RegRead, InstallLocation, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\mIRC, InstallLocation
    if not ErrorLevel
    {
        StringReplace, InstallLocation, InstallLocation, `",, All
        IfExist, %InstallLocation%
        {
            TestsOK()
            OutputDebug, OK: %TestName%:%A_LineNumber%: The application has been installed, because '%InstallLocation%' was found.`n
        }
        else
        {
            TestsFailed()
            OutputDebug, %TestName%:%A_LineNumber%: Test failed: Something went wrong, can't find '%InstallLocation%'.`n
        }
    }
    else
    {
        TestsFailed()
        WinGetTitle, title, A
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: Either we can't read from registry or data doesn't exist. Active window caption: '%title%'.`n
    }
}
