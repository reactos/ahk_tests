/*
 * Designed for IrfanView 4.23
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

ModuleExe = %A_WorkingDir%\Apps\IrfanView 4.23 Setup.exe
bContinue := false
TestName = 1.install

TestsFailed := 0
TestsOK := 0
TestsTotal := 0

; Test if Setup file exists, if so, delete installed files, and run Setup
IfExist, %ModuleExe%
{
    ; Get rid of other versions
    RegRead, UninstallerPath, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\IrfanView, UninstallString
    if not ErrorLevel
    {
        Process, Close, i_view32.exe ; Teminate process
        FileRemoveDir, %A_AppData%\IrfanView, 1
        Sleep, 1500
        StringReplace, UninstallerPath, UninstallerPath, `",, All
        SplitPath, UninstallerPath,, InstallLocation
        RunWait, %UninstallerPath% /silent ; Silently uninstall it
        Sleep, 2500
        ; Delete everything just in case
        RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\MicroSoft\Windows\CurrentVersion\Uninstall\IrfanView
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
        IfExist, %A_ProgramFiles%\IrfanView\iv_uninstall.exe
        {
            Process, Close, i_view32.exe ; Teminate process
            FileRemoveDir, %A_AppData%\IrfanView, 1
            Sleep, 1500
            RunWait, %A_ProgramFiles%\IrfanView\iv_uninstall.exe /silent ; Silently uninstall it
            Sleep, 2500
            FileRemoveDir, %A_ProgramFiles%\IrfanView, 1
            Sleep, 1000
            IfExist, %A_ProgramFiles%\IrfanView
            {
                OutputDebug, %TestName%:%A_LineNumber%: Test failed: Previous version detected and failed to delete '%A_ProgramFiles%\IrfanView'.`n
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


; Test if 'Welcome' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, IrfanView Setup, Welcome, 7
    if not ErrorLevel
    {
        Sleep, 250
        ControlClick, Button11, IrfanView Setup, Welcome ; Hit 'Next' button
        if not ErrorLevel
        {
            TestsOK("")
            OutputDebug, OK: %TestName%:%A_LineNumber%: 'IrfanView Setup (Welcome)' window appeared and 'Next' button was clicked.`n
        }
        else
        {
            TestsFailed("")
            WinGetTitle, title, A
            OutputDebug, %TestName%:%A_LineNumber%: Test failed: Unable to hit 'Next' button in 'IrfanView Setup (Welcome)' window. Active window caption: '%title%'.`n
        }
    }
    else
    {
        TestsFailed("")
        WinGetTitle, title, A
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'IrfanView Setup (Welcome)' window failed to appear. Active window caption: '%title%'.`n
    }
}


; Test if 'What's new' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, IrfanView Setup, What's new, 7
    if not ErrorLevel
    {
        Sleep, 250
        ControlClick, Button11, IrfanView Setup, What's new ; Hit 'Next' button
        if not ErrorLevel
            TestsOK("'IrfanView Setup (What's new)' window appeared and 'Next' button was clicked.")
        else
            TestsFailed("Unable to hit 'Next' button in 'IrfanView Setup (What's new)' window.")
    }
    else
        TestsFailed("'IrfanView Setup (What's new)' window failed to appear.")
}


; Test if 'Do you want to associate' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, IrfanView Setup, Do you want to associate, 7
    if not ErrorLevel
    {
        Sleep, 250
        ControlClick, Button1, IrfanView Setup, Do you want to associate ; Hit 'Images only' button
        if not ErrorLevel
        {
            Sleep, 500
            ControlClick, Button16, IrfanView Setup, Do you want to associate ; Hit 'Next' button
            if not ErrorLevel
                TestsOK("'IrfanView Setup (Do you want to associate)' window appeared, 'Images only' and 'Next' buttons were clicked.")
            else
                TestsFailed("Unable to hit 'Next' button in 'IrfanView Setup (Do you want to associate)' window.")
        }
        else
            TestsFailed("Unable to hit 'Images only' button in 'IrfanView Setup (Do you want to associate)' window.")
    }
    else
        TestsFailed("'IrfanView Setup (Do you want to associate)' window failed to appear.")
}


; Test if 'Google Desktop Search' window appeared (different results in WinXP and Win2k3)
TestsTotal++
if bContinue
{
    WinWaitActive, IrfanView Setup, Google Desktop Search, 7
    if not ErrorLevel
    {
        Sleep, 250
        ControlGetText, OutputVar, Button1, IrfanView Setup
        if OutputVar <> &Install Google Desktop Search ; We are in XP system
        {
            Control, Uncheck,, Button1, IrfanView Setup, Google Desktop Search ; Uncheck 'Google Toolbar for Internet Explorer'
            if not ErrorLevel
            {
                Control, Uncheck,, Button2, IrfanView Setup, Google Desktop Search ; Uncheck 'Google Desktop Search'
                if not ErrorLevel
                {
                    ControlClick, Button18, IrfanView Setup, Google Desktop Search ; Hit 'Next' button
                    if not ErrorLevel
                        TestsOK(" 'IrfanView Setup (Google Desktop Search)' window appeared, 'Google Toolbar', 'Google Desktop Search' checkboxes were unchecked, 'Next' was clicked (XP OS).")
                    else
                        TestsFailed("Unable to hit 'Next' button in 'IrfanView Setup (Google Desktop Search)' window.")
                }
                else
                    TestsFailed("Unable to uncheck 'Google Desktop Search' in 'IrfanView Setup (Google Desktop Search)' window.")
            }
            else
                TestsFailed("Unable to uncheck 'Google Toolbar for Internet Explorer' in 'IrfanView Setup (Google Desktop Search)' window.")
        }
        else
        {
            ; We are in win2k3 system
            Control, Check,, Button2, IrfanView Setup, Google Desktop Search ; Check 'Dont install Google Desktop Search'
            if not ErrorLevel
            {
                ControlClick, Button18, IrfanView Setup, Google Desktop Search ; Hit 'Next' button
                if not ErrorLevel
                    TestsOK("'IrfanView Setup (Google Desktop Search)' window appeared, 'Google Toolbar', 'Google Desktop Search' checkboxes were unchecked, 'Next' was clicked (win2k3 OS).")
                else
                    TestsFailed("Unable to hit 'Next' button in 'IrfanView Setup (Google Desktop Search)' window.")
            }
            else
                TestsFailed("Unable to check 'Dont install Google Desktop Search' in 'IrfanView Setup (Google Desktop Search)' window.")
        }
    }
    else
        TestsFailed("'IrfanView Setup (Google Desktop Search)' window failed to appear.")
}


; Test if 'Ready to install' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, IrfanView Setup, Ready to install, 7
    if not ErrorLevel
    {
        Sleep, 250
        Control, Check,, Button2, IrfanView Setup, Ready to install ; Check 'Users Application Data folder'
        if not ErrorLevel
        {
            ControlClick, Button23, IrfanView Setup, Ready to install ; Hit 'Next' button
            if not ErrorLevel
                TestsOK("'IrfanView Setup (Ready to install)' window appeared and 'Next' button was clicked.")
            else
                TestsFailed("Unable to hit 'Next' button in 'IrfanView Setup (Ready to install)' window.")
        }
        else
            TestsFailed("Unable to check 'Users Application Data folder' in 'IrfanView Setup (Ready to install)' window.")
    }
    else
        TestsFailed("'IrfanView Setup (Ready to install)' window failed to appear.")
}


; Test if 'You want to change' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, IrfanView Setup, You want to change, 7
    if not ErrorLevel
    {
        Sleep, 250
        ControlClick, Button1, IrfanView Setup, You want to change ; Hit 'Yes' button
        if not ErrorLevel
            TestsOK("'IrfanView Setup (You want to change)' window appeared and 'Yes' was clicked.")
        else
            TestsFailed("Unable to hit 'Yes' button in 'IrfanView Setup (You want to change)' window.")
    }
    else
        TestsFailed("'IrfanView Setup (You want to change)' window failed to appear.")
}


; Test if 'Installation successfull' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, IrfanView Setup, Installation successfull, 7
    if not ErrorLevel
    {
        Sleep, 250
        Control, Uncheck,, Button2, IrfanView Setup, Installation successfull ; Uncheck 'Start IrfanView'
        if not ErrorLevel
        {
            ControlClick, Button27, IrfanView Setup, Installation successfull ; Hit 'Done' button
            if not ErrorLevel
            {
                TestsOK("'IrfanView Setup (Installation successfull)' window appeared, 'Start IrfanView' unchecked and 'Done' was clicked. FIXME: terminate browser process.")
                Process, Close, i_view32.exe ; Just in case
            }
            else
                TestsFailed("Unable to hit 'Done' button in 'IrfanView Setup (Installation successfull)' window.")
        }
        else
            TestsFailed("Unable to uncheck 'Start IrfanView' in 'IrfanView Setup (Installation successfull)' window.")
    }
    else
        TestsFailed("'IrfanView Setup (Installation successfull)' window failed to appear.")
}


;Check if program exists
TestsTotal++
if bContinue
{
    Sleep, 2000
    RegRead, UninstallString, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\IrfanView, UninstallString
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
