/*
 * Designed for Flash Player 10.3.183.11
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

ModuleExe = %A_WorkingDir%\Apps\Flash Player 10.3.183.11 Setup.exe
bContinue := false
TestName = 1.install

TestsFailed := 0
TestsOK := 0
TestsTotal := 0

; Test if Setup file exists, if so, delete installed files, and run Setup
IfExist, %ModuleExe%
{
    InstallLocation = %A_WinDir%\System32\Macromed\Flash
    ; Get rid of other versions
    RegRead, UninstallerPath, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Adobe Flash Player ActiveX, UninstallString
    if not ErrorLevel
    {
        Run, %UninstallerPath%
        WinWaitActive, Uninstall Adobe Flash Player,,7
        if not ErrorLevel
        {
            ControlClick, Button3, Uninstall Adobe Flash Player ; Uninstall
            Sleep, 5000
            ControlClick, Button3, Uninstall Adobe Flash Player ; Done
        }
        else
        {
            OutputDebug, %TestName%:%A_LineNumber%: Test failed: Failed to run '%UninstallerPath%' (window 'Uninstall Adobe Flash Player' failed to appear).`n
            bContinue := false
        }
        Sleep, 2500
        ; Delete everything just in case
        RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\MicroSoft\Windows\CurrentVersion\Uninstall\Adobe Flash Player ActiveX
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
        IfExist, %InstallLocation%
        {
            IfExist, %InstallLocation%\FlashUtil10y_ActiveX.exe
            {
                Run, %InstallLocation%\FlashUtil10y_ActiveX.exe -maintain activex
                WinWaitActive, Uninstall Adobe Flash Player,,7
                if not ErrorLevel
                {
                    ControlClick, Button3, Uninstall Adobe Flash Player ; Uninstall
                    Sleep, 5000
                    ControlClick, Button3, Uninstall Adobe Flash Player ; Done
                }
                else
                {
                    OutputDebug, %TestName%:%A_LineNumber%: Test failed: Failed to run '%InstallLocation%\FlashUtil10y_ActiveX.exe' (window 'Uninstall Adobe Flash Player' failed to appear).`n
                    bContinue := false
                }
            }
            Sleep, 2500
            FileRemoveDir, %InstallLocation%, 1
            Sleep, 1000
            IfExist, %InstallLocation%
            {
                OutputDebug, %TestName%:%A_LineNumber%: Test failed: Previous version detected and failed to delete '%InstallLocation%'.`n
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
        Process, Close, FlashUtil10y_ActiveX.exe ; Just in case
        Sleep, 1500
        Run %ModuleExe%
    }
}
else
{
    OutputDebug, %TestName%:%A_LineNumber%: Test failed: '%ModuleExe%' not found.`n
    bContinue := false
}


; Test if can click 'Install' button
TestsTotal++
if bContinue
{
    WinWaitActive, Adobe® Flash® Player 10.3 Installer,, 7
    if not ErrorLevel
    {
        Sleep, 250
        Control, Check,,Button6, Adobe® Flash® Player 10.3 Installer ; Check 'I have read and agree' checkbox
        if not ErrorLevel
        {
            Sleep, 1500 ; Wait until 'Install' button is enabled
            ControlClick, Button3, Adobe® Flash® Player 10.3 Installer ; Hit 'Install' button
            if not ErrorLevel
            {
                TestsOK()
                OutputDebug, OK: %TestName%:%A_LineNumber%: 'Adobe® Flash® Player 10.3 Installer' appeared and 'Install' button was clicked.`n
            }
            else
            {
                TestsFailed()
                WinGetTitle, title, A
                OutputDebug, %TestName%:%A_LineNumber%: Test failed: unable to hit 'Install' button. Active window caption: '%title%'.`n
            }
        }
        else
        {
            TestsFailed()
            WinGetTitle, title, A
            OutputDebug, %TestName%:%A_LineNumber%: Test failed: unable to check 'I have read and agree' checkbox. Active window caption: '%title%'.`n
        }
    }
    else
    {
        TestsFailed()
        WinGetTitle, title, A
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'Adobe® Flash® Player 10.3 Installer' window with 'Install' button failed to appear. Active window caption: '%title%'.`n
    }
}


; Test if can click 'Done' button
TestsTotal++
if bContinue
{
    IfWinActive, Adobe® Flash® Player 10.3 Installer
    {
        while not %OutputVar% ; Sleep while 'Done' button is disabled
        {
            ControlGet, OutputVar, Enabled,, Button3, Adobe® Flash® Player 10.3 Installer
            Sleep, 1000
        }
        ControlClick, Button3, Adobe® Flash® Player 10.3 Installer ; Hit 'Done' button
        if not ErrorLevel
        {
            TestsOK()
            OutputDebug, OK: %TestName%:%A_LineNumber%: 'Adobe® Flash® Player 10.3 Installer' appeared and 'Done' button was clicked.`n
        }
        else
        {
            TestsFailed()
            WinGetTitle, title, A
            OutputDebug, %TestName%:%A_LineNumber%: Test failed: unable to hit 'Done' button. Active window caption: '%title%'.`n
        }
    }
    else
    {
        TestsFailed()
        WinGetTitle, title, A
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'Adobe® Flash® Player 10.3 Installer' is not active window. Active window caption: '%title%'.`n
    }
}


;Check if program exists in program files
TestsTotal++
if bContinue
{
    Sleep, 2000
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
