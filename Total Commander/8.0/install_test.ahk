/*
 * Designed for Total Commander 8.0
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

Modulexe = %A_WorkingDir%\Apps\Total Commander 8.0 Setup.exe
bContinue := false
TestName = 1.install
InstallToDir = %A_ProgramFiles%\Total Commander ; This is where we are going to install

TestsFailed := 0
TestsOK := 0
TestsTotal := 0

; Test if Setup file exists, if so, delete installed files, and run Setup
IfExist, %Modulexe%
{
    ; Get rid of other versions
    RegRead, UninstallerPath, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Totalcmd, UninstallString
    if not ErrorLevel
    {   
        IfExist, %UninstallerPath%
        {
            Process, Close, TOTALCMD.exe ; Teminate process
            Sleep, 1500
            RunWait, %UninstallerPath% /7 ; Silently uninstall it
            Sleep, 10000
            ; Delete everything just in case
            RegDelete, HKEY_CURRENT_USER, SOFTWARE\Ghisler
            RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\MicroSoft\Windows\CurrentVersion\Uninstall\Totalcmd
            FileRemoveDir, %InstalledDir%, 1
            FileRemoveDir, %A_AppData%\GHISLER, 1
            Sleep, 1000
            IfExist, %InstalledDir%
            {
                OutputDebug, %TestName%:%A_LineNumber%: Test failed: Failed to delete '%InstalledDir%'.`n
                bContinue := false
            }
        }
        Run %Modulexe%
        bContinue := true
    }
    else
    {
        ; There was a problem (such as a nonexistent key or value). That probably means we have not installed this app before
        Run %Modulexe%
        bContinue := true
    }
}
else
{
    OutputDebug, %TestName%:%A_LineNumber%: Test failed: '%Modulexe%' not found.`n
    bContinue := false
}


; Test if 'Please select a language' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Installation Total Commander 32+64bit 8.0, Please select a language, 15
    if not ErrorLevel
    {
        Sleep, 1000
        ; Hit 'Next' button. Specify all params in case some other window will pop up
        ControlClick, Button3, Installation Total Commander 32+64bit 8.0, Please select a language 
        if not ErrorLevel
        {
            TestsOK()
            OutputDebug, OK: %TestName%:%A_LineNumber%: 'Installation Total Commander 32+64bit 8.0 (Please select a language)' window appeared and 'Next' button was clicked.`n
        }
        else
        {
            TestsFailed()
            WinGetTitle, title, A
            OutputDebug, %TestName%:%A_LineNumber%: Test failed: Unable to click 'Next' in 'Installation Total Commander 32+64bit 8.0 (Please select a language)' window. Active window caption: '%title%'.`n
        }
    }
    else
    {
        TestsFailed()
        WinGetTitle, title, A
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'Installation Total Commander 32+64bit 8.0 (Please select a language)' window failed to appear. Active window caption: '%title%'.`n
    }
}


; Test if 'Do you also' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Installation Total Commander 32+64bit 8.0, Do you also, 5
    if not ErrorLevel
    {
        Sleep, 1000
        ControlClick, Button3, Installation Total Commander 32+64bit 8.0, Do you also
        if not ErrorLevel
        {
            TestsOK()
            OutputDebug, OK: %TestName%:%A_LineNumber%: 'Installation Total Commander 32+64bit 8.0 (Do you also)' window appeared and 'Next' button was clicked.`n
        }
        else
        {
            TestsFailed()
            WinGetTitle, title, A
            OutputDebug, %TestName%:%A_LineNumber%: Test failed: Unable to click 'Next' in 'Installation Total Commander 32+64bit 8.0 (Do you also)' window. Active window caption: '%title%'.`n
        }
    }
    else
    {
        TestsFailed()
        WinGetTitle, title, A
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'Installation Total Commander 32+64bit 8.0 (Do you also)' window failed to appear. Active window caption: '%title%'.`n
    }
}


; Test if 'Please enter target directory' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Installation Total Commander 32+64bit 8.0, Please enter target directory, 5
    if not ErrorLevel
    {
        ControlSetText, Edit1, %InstallToDir%, Installation Total Commander 32+64bit 8.0, Please enter target directory
        if not ErrorLevel
        {
            Sleep, 1000
            ControlClick, Button2, Installation Total Commander 32+64bit 8.0, Please enter target directory
            if not ErrorLevel
            {
                TestsOK()
                OutputDebug, OK: %TestName%:%A_LineNumber%: 'Installation Total Commander 32+64bit 8.0 (Please enter target directory)' window appeared and 'Next' button was clicked.`n
            }
            else
            {
                TestsFailed()
                WinGetTitle, title, A
                OutputDebug, %TestName%:%A_LineNumber%: Test failed: Unable to click 'Next' in 'Installation Total Commander 32+64bit 8.0 (Please enter target directory)' window. Active window caption: '%title%'.`n
            }
        }
        else
        {
            TestsFailed()
            WinGetTitle, title, A
            OutputDebug, %TestName%:%A_LineNumber%: Test failed: Unable to enter '%InstallToDir%' in 'Installation Total Commander 32+64bit 8.0 (Please enter target directory)' window. Active window caption: '%title%'.`n
        }
    }
    else
    {
        TestsFailed()
        WinGetTitle, title, A
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'Installation Total Commander 32+64bit 8.0 (Please enter target directory)' window failed to appear. Active window caption: '%title%'.`n
    }
}


; Test if 'You can define' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Installation Total Commander 32+64bit 8.0, You can define, 5
    if not ErrorLevel
    {
        Sleep, 1000
        ControlClick, Button1, Installation Total Commander 32+64bit 8.0, You can define
        if not ErrorLevel
        {
            TestsOK()
            OutputDebug, OK: %TestName%:%A_LineNumber%: 'Installation Total Commander 32+64bit 8.0 (You can define)' window appeared and 'Next' button was clicked.`n
        }
        else
        {
            TestsFailed()
            WinGetTitle, title, A
            OutputDebug, %TestName%:%A_LineNumber%: Test failed: Unable to click 'Next' in 'Installation Total Commander 32+64bit 8.0 (You can define)' window. Active window caption: '%title%'.`n
        }
    }
    else
    {
        TestsFailed()
        WinGetTitle, title, A
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'Installation Total Commander 32+64bit 8.0 (You can define)' window failed to appear. Active window caption: '%title%'.`n
    }
}


; Test if 'Create shortcut' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Installation Total Commander 32+64bit 8.0, Create shortcut, 5
    if not ErrorLevel
    {
        Sleep, 1000
        ControlClick, Button1, Installation Total Commander 32+64bit 8.0, Create shortcut
        if not ErrorLevel
        {
            TestsOK()
            OutputDebug, OK: %TestName%:%A_LineNumber%: 'Installation Total Commander 32+64bit 8.0 (Create shortcut)' window appeared and 'Next' button was clicked.`n
        }
        else
        {
            TestsFailed()
            WinGetTitle, title, A
            OutputDebug, %TestName%:%A_LineNumber%: Test failed: Unable to click 'Next' in 'Installation Total Commander 32+64bit 8.0 (Create shortcut)' window. Active window caption: '%title%'.`n
        }
    }
    else
    {
        TestsFailed()
        WinGetTitle, title, A
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'Installation Total Commander 32+64bit 8.0 (Create shortcut)' window failed to appear. Active window caption: '%title%'.`n
    }
}


; Test if 'Installation successful' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Installation Total Commander 32+64bit 8.0, Installation successful, 5
    if not ErrorLevel
    {
        Sleep, 1000
        ControlClick, Button1, Installation Total Commander 32+64bit 8.0, Installation successful
        if not ErrorLevel
        {
            WinWaitClose, Installation Total Commander 32+64bit 8.0,, 5
            if not ErrorLevel
            {
                TestsOK()
                OutputDebug, OK: %TestName%:%A_LineNumber%: 'Installation Total Commander 32+64bit 8.0 (Installation successful)' window appeared and 'OK' button was clicked.`n
            }
            else
            {
                TestsFailed()
                WinGetTitle, title, A
                OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'Installation Total Commander 32+64bit 8.0' window failed to close. Active window caption: '%title%'.`n
            }
        }
        else
        {
            TestsFailed()
            WinGetTitle, title, A
            OutputDebug, %TestName%:%A_LineNumber%: Test failed: Unable to click 'OK' in 'Installation Total Commander 32+64bit 8.0 (Installation successful)' window. Active window caption: '%title%'.`n
        }
    }
    else
    {
        TestsFailed()
        WinGetTitle, title, A
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'Installation Total Commander 32+64bit 8.0 (Installation successful)' window failed to appear. Active window caption: '%title%'.`n
    }
}




;Check if program exists in program files
TestsTotal++
if bContinue
{
    Sleep, 1000
    RegRead, UninstallerPath, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Totalcmd, UninstallString
    if not ErrorLevel
    {
        IfExist, %UninstallerPath%
        {
            TestsOK()
            OutputDebug, OK: %TestName%:%A_LineNumber%: Should be installed, because '%UninstallerPath%' was found.`n
            bContinue := true
        }
        else
        {
            TestsFailed()
            OutputDebug, %TestName%:%A_LineNumber%: Test failed: Can NOT find '%UninstallerPath%'.`n
        }
    }
    else
    {
        TestsFailed()
        WinGetTitle, title, A
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: Either can not read registry or data doesn't exist. Active window caption: '%title%'.`n
    }
}
