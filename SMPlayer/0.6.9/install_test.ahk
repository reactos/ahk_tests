/*
 * Designed for SMPlayer 0.6.9
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

ModuleExe = %A_WorkingDir%\Apps\SMPlayer 0.6.9 Setup.exe
bContinue := false
TestName = 1.install

TestsFailed := 0
TestsOK := 0
TestsTotal := 0

; Test if Setup file exists, if so, delete installed files, and run Setup
IfExist, %ModuleExe%
{
    ; Get rid of other versions
    RegRead, UninstallerPath, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\SMPlayer, UninstallString
    if not ErrorLevel
    {
        Process, Close, smplayer.exe ; Teminate process
        Sleep, 1500
        StringReplace, UninstallerPath, UninstallerPath, `",, All
        SplitPath, UninstallerPath,, InstallLocation
        RunWait, %UninstallerPath% /S ; Silently uninstall it
        Sleep, 3500
        ; Delete everything just in case
        RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\MicroSoft\Windows\CurrentVersion\Uninstall\SMPlayer
        RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\SMPlayer
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
        IfExist, %A_ProgramFiles%\SMPlayer\uninst.exe
        {
            Process, Close, smplayer.exe ; Teminate process
            Sleep, 1500
            RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\SMPlayer
            RunWait, %A_ProgramFiles%\SMPlayer\uninst.exe /S ; Silently uninstall it
            Sleep, 2500
            FileRemoveDir, %A_ProgramFiles%\SMPlayer, 1
            Sleep, 1000
            IfExist, %A_ProgramFiles%\SMPlayer
            {
                OutputDebug, %TestName%:%A_LineNumber%: Test failed: Previous version detected and failed to delete '%A_ProgramFiles%\SMPlayer'.`n
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


; Test if 'Installer Language (Please select)' window appeared, if so, click 'OK' button
TestsTotal++
if bContinue
{
    WinWaitActive, Installer Language, Please select, 15
    if not ErrorLevel
    {
        Sleep, 1000
        ControlClick, Button1, Installer Language, Please select ; Hit 'OK' button
        if not ErrorLevel
            TestsOK("'Installer Language (Please select)' window appeared and 'OK' button was clicked.")
        else
            TestsFailed("Unable to hit 'OK' button in 'Installer Language (Please select)' window.")
    }
    else
        TestsFailed("'Installer Language (Please select)' window failed to appear.")
}


; Test if 'SMPlayer 0.6.9 Setup (Welcome)' window appeared, if so, click 'Next' button
TestsTotal++
if bContinue
{
    WinWaitActive, SMPlayer 0.6.9 Setup, Welcome, 10
    if not ErrorLevel
    {
        Sleep, 1000
        ControlClick, Button2, SMPlayer 0.6.9 Setup, Welcome ; Hit 'Next' button
        if not ErrorLevel
            TestsOK("'SMPlayer 0.6.9 Setup (Welcome)' window appeared and 'Next' button was clicked.")
        else
            TestsFailed("Unable to hit 'Next' button in 'SMPlayer 0.6.9 Setup (Welcome)' window.")
    }
    else
        TestsFailed("'SMPlayer 0.6.9 Setup (Welcome)' window failed to appear.")
}


; Test if 'SMPlayer 0.6.9 Setup (License Agreement)' window appeared, if so, check 'I accept' checkbox and click 'Next' button
TestsTotal++
if bContinue
{
    WinWaitActive, SMPlayer 0.6.9 Setup, License Agreement, 7
    if not ErrorLevel
    {
        Sleep, 500
        Control, Check, , Button4, SMPlayer 0.6.9 Setup, License Agreement ; Check 'I accept the terms of the License Agreement' radiobutton
        if not ErrorLevel
        {
            Sleep, 1000

            TimeOut := 0
            while (not %bNextEnabled%) and (TimeOut < 6) ; Sleep while 'Next' button is disabled
            {
                ControlGet, bNextEnabled, Enabled,, Button4, SMPlayer 0.6.9 Setup, License Agreement
                Sleep, 1000
                TimeOut++
            }
            
            if %bNextEnabled%
            {
                ControlClick, Button2, SMPlayer 0.6.9 Setup, License Agreement ; Hit 'Next' button
                if not ErrorLevel
                    TestsOK("'SMPlayer 0.6.9 Setup (License Agreement)' window appeared, 'I accept' radiobutton checked, 'Next' button was clicked.")
                else
                    TestsFailed("Unable to hit enabled 'Next' button in 'SMPlayer 0.6.9 Setup (License Agreement)' window ('I accept' radiobutton is checked).")
            }
            else
                TestsFailed("'Next' button did not get enabled in 'SMPlayer 0.6.9 Setup (License Agreement)' window after checking 'I accept' checkbox.")
        }
        else
            TestsFailed("Unable to check 'I accept the terms of the License Agreement' checkbox in 'SMPlayer 0.6.9 Setup (License Agreement)' window.")
    }
    else
        TestsFailed("'SMPlayer 0.6.9 Setup (License Agreement)' window failed to appear.")
}


; Test if 'SMPlayer 0.6.9 Setup (Choose Components)' window appeared, if so, click 'Next' button
TestsTotal++
if bContinue
{
    WinWaitActive, SMPlayer 0.6.9 Setup, Choose Components, 7
    if not ErrorLevel
    {
        Sleep, 1000
        ControlClick, Button2, SMPlayer 0.6.9 Setup, Choose Components ; Hit 'Next' button
        if not ErrorLevel
            TestsOK("'SMPlayer 0.6.9 Setup (Choose Components)' window appeared and 'Next' button was clicked.")
        else
            TestsFailed("Unable to hit 'Next' button in 'SMPlayer 0.6.9 Setup (Choose Components)' window.")
    }
    else
        TestsFailed("'SMPlayer 0.6.9 Setup (Choose Components)' window failed to appear.")
}


; Test if 'SMPlayer 0.6.9 Setup (Choose Install Location)' window appeared, if so, click 'Install' button
TestsTotal++
if bContinue
{
    WinWaitActive, SMPlayer 0.6.9 Setup, Choose Install Location, 7
    if not ErrorLevel
    {
        Sleep, 1000
        ControlClick, Button2, SMPlayer 0.6.9 Setup, Choose Install Location ; Hit 'Install' button
        if not ErrorLevel
            TestsOK("'SMPlayer 0.6.9 Setup (Choose Install Location)' window appeared and 'Install' button was clicked.")
        else
            TestsFailed("Unable to hit 'Install' button in 'SMPlayer 0.6.9 Setup (Choose Install Location)' window.")
    }
    else
        TestsFailed("'SMPlayer 0.6.9 Setup (Choose Install Location)' window failed to appear.")
}


; Test if can get thru 'SMPlayer 0.6.9 Setup (Installing)' window
TestsTotal++
if bContinue
{
    WinWaitActive, SMPlayer 0.6.9 Setup, Installing, 5
    if not ErrorLevel
    {
        OutputDebug, OK: %TestName%:%A_LineNumber%: 'SMPlayer 0.6.9 Setup (Installing)' window appeared, waiting for it to close.`n
        WinWaitClose, SMPlayer 0.6.9 Setup, Installing, 25
        if not ErrorLevel
            TestsOK("'SMPlayer 0.6.9 Setup (Installing)' window appeared, went away.")
        else
            TestsFailed("'SMPlayer 0.6.9 Setup (Installing)' window failed to go away.")
            WinGetTitle, title, A
    }
    else
        TestsFailed("'SMPlayer 0.6.9 Setup (Installing)' window failed to appear.")
}


; Test if 'SMPlayer 0.6.9 Setup (Completing)' window appeared, if so, click 'Finish' button
TestsTotal++
if bContinue
{
    WinWaitActive, SMPlayer 0.6.9 Setup, Completing, 5
    if not ErrorLevel
    {
        Sleep, 1000
        ControlClick, Button2, SMPlayer 0.6.9 Setup, Completing ; Hit 'Finish' button
        if not ErrorLevel
        {
            WinWaitClose, SMPlayer 0.6.9 Setup, Completing, 5
            if not ErrorLevel
                TestsOK("'SMPlayer 0.6.9 Setup (Completing)' window appeared, 'Finish' button was clicked and window closed.")
            else
                TestsFailed("'SMPlayer 0.6.9 Setup (Completing)' window failed to close after hitting 'Finish' button.")
        }
        else
            TestsFailed("Unable to hit 'Finish' button in 'SMPlayer 0.6.9 Setup (Completing)' window.")
    }
    else
        TestsFailed("'SMPlayer 0.6.9 Setup (Completing)' window failed to appear.")
}


;Check if program exists in program files
TestsTotal++
if bContinue
{
    Sleep, 2000
    RegRead, UninstallString, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\SMPlayer, UninstallString
    if not ErrorLevel
    {
        StringReplace, UninstallString, UninstallString, `",, All
        IfExist, %UninstallString%
            TestsOK("The application has been installed, because '" UninstallString "' was found.")
        else
            TestsFailed("Something went wrong, can't find '" UninstallString "'.")
    }
    else
        TestsFailed("Either we can't read from registry or data doesn't exist.")
}
