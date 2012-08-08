/*
 * Designed for Filzip 3.0.6
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

ModuleExe = %A_WorkingDir%\Apps\Filzip 3.0.6 Setup.exe
bContinue := false
TestName = 1.install

TestsFailed := 0
TestsOK := 0
TestsTotal := 0

; Test if Setup file exists, if so, delete installed files, and run Setup
IfExist, %ModuleExe%
{
    ; Get rid of other versions
    RegRead, UninstallerPath, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Filzip 3.0.6.93_is1, UninstallString
    if not ErrorLevel
    {
        Process, Close, Filzip.exe ; Teminate process
        Sleep, 1500
        RegDelete, HKEY_CURRENT_USER, SOFTWARE\Filzip
        StringReplace, UninstallerPath, UninstallerPath, `",, All
        SplitPath, UninstallerPath,, InstallLocation
        RunWait, %UninstallerPath% /SILENT ; Silently uninstall it
        Sleep, 2500
        ; Delete everything just in case
        RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\MicroSoft\Windows\CurrentVersion\Uninstall\Filzip 3.0.6.93_is1
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
        IfExist, %A_ProgramFiles%\Filzip\unins000.exe
        {
            Process, Close, Filzip.exe ; Teminate process
            Sleep, 1500
            RegDelete, HKEY_CURRENT\USER, SOFTWARE\Filzip
            RunWait, %A_ProgramFiles%\Filzip\unins000.exe /SILENT ; Silently uninstall it
            Sleep, 2500
            FileRemoveDir, %A_ProgramFiles%\Filzip, 1
            Sleep, 1000
            IfExist, %A_ProgramFiles%\Filzip
            {
                OutputDebug, %TestName%:%A_LineNumber%: Test failed: Previous version detected and failed to delete '%A_ProgramFiles%\Filzip'.`n
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


; Test if 'Select Setup Language' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Select Setup Language, Select the language, 15
    if not ErrorLevel
    {
        Sleep, 250
        ControlClick, TButton1, Select Setup Language, Select the language
        if not ErrorLevel
        {
            TestsOK++
            OutputDebug, OK: %TestName%:%A_LineNumber%: 'Select Setup Language (Select the language)' window appeared and 'OK' was clicked.`n
            bContinue := true
        }
        else
        {
            TestsFailed++
            WinGetTitle, title, A
            OutputDebug, %TestName%:%A_LineNumber%: Test failed: Unable to hit 'OK' in 'Select Setup Language (Select the language)' window. Active window caption: '%title%'.`n
            bContinue := false
        }
    }
    else
    {
        TestsFailed++
        WinGetTitle, title, A
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'Select Setup Language (Select the language)' window failed to appear. Active window caption: '%title%'.`n
        bContinue := false
    }
}


; Test if 'Welcome' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Setup - Filzip, Welcome, 7
    if not ErrorLevel
    {
        Sleep, 250
        ControlClick, TButton1, Setup - Filzip, Welcome ; Hit 'Next' button
        if not ErrorLevel
        {
            TestsOK()
            OutputDebug, OK: %TestName%:%A_LineNumber%: 'Setup - Filzip (Welcome)' window appeared and 'Next' was clicked.`n
        }
        else
        {
            TestsFailed()
            WinGetTitle, title, A
            OutputDebug, %TestName%:%A_LineNumber%: Test failed: Unable to hit 'Next' button in 'Setup - Filzip (Welcome)' window. Active window caption: '%title%'.`n
        }
    }
    else
    {
        TestsFailed()
        WinGetTitle, title, A
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'Setup - Filzip (Welcome)' window failed to appear. Active window caption: '%title%'.`n
    }
}


; Test if 'License Agreement' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Setup - Filzip, License Agreement, 7
    if not ErrorLevel
    {
        Sleep, 250
        Control, Check,, TRadioButton1, Setup - Filzip, License Agreement ; Check 'I accept the agreement' radio button
        if not ErrorLevel
        {
            Sleep, 500
            ControlClick, TButton2, Setup - Filzip, License Agreement ; Hit 'Next' button
            if not ErrorLevel
            {
                TestsOK()
                OutputDebug, OK: %TestName%:%A_LineNumber%: 'Setup - Filzip (License Agreement)' window appeared and 'Next' was clicked.`n
            }
            else
            {
                TestsFailed()
                WinGetTitle, title, A
                OutputDebug, %TestName%:%A_LineNumber%: Test failed: Unable to hit 'Next' button in 'Setup - Filzip (License Agreement)' window. Active window caption: '%title%'.`n
            }
        }
        else
        {
            TestsFailed()
            WinGetTitle, title, A
            OutputDebug, %TestName%:%A_LineNumber%: Test failed: Unable to check 'I accept the agreement' radiobutton in 'Setup - Filzip (License Agreement)' window. Active window caption: '%title%'.`n
        }
    }
    else
    {
        TestsFailed()
        WinGetTitle, title, A
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'Setup - Filzip (License Agreement)' window failed to appear. Active window caption: '%title%'.`n
    }
}


; Test if 'Select Destination Location' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Setup - Filzip, Select Destination Location, 7
    if not ErrorLevel
    {
        Sleep, 250
        ControlClick, TButton3, Setup - Filzip, Select Destination Location ; Hit 'Next' button
        if not ErrorLevel
        {
            TestsOK()
            OutputDebug, OK: %TestName%:%A_LineNumber%: 'Setup - Filzip (Select Destination Location)' window appeared and 'Next' was clicked.`n
        }
        else
        {
            TestsFailed()
            WinGetTitle, title, A
            OutputDebug, %TestName%:%A_LineNumber%: Test failed: Unable to hit 'Next' button in 'Setup - Filzip (Select Destination Location)' window. Active window caption: '%title%'.`n
        }
    }
    else
    {
        TestsFailed()
        WinGetTitle, title, A
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'Setup - Filzip (Select Destination Location)' window failed to appear. Active window caption: '%title%'.`n
    }
}


; Test if 'Select Components' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Setup - Filzip, Select Components, 7
    if not ErrorLevel
    {
        Sleep, 250
        ControlClick, TButton3, Setup - Filzip, Select Components ; Hit 'Next' button
        if not ErrorLevel
        {
            TestsOK()
            OutputDebug, OK: %TestName%:%A_LineNumber%: 'Setup - Filzip (Select Components)' window appeared and 'Next' was clicked.`n
        }
        else
        {
            TestsFailed()
            WinGetTitle, title, A
            OutputDebug, %TestName%:%A_LineNumber%: Test failed: Unable to hit 'Next' button in 'Setup - Filzip (Select Components)' window. Active window caption: '%title%'.`n
        }
    }
    else
    {
        TestsFailed()
        WinGetTitle, title, A
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'Setup - Filzip (Select Components)' window failed to appear. Active window caption: '%title%'.`n
    }
}


; Test if 'Select Start Menu Folder' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Setup - Filzip, Select Start Menu Folder, 7
    if not ErrorLevel
    {
        Sleep, 250
        ControlClick, TButton4, Setup - Filzip, Select Start Menu Folder ; Hit 'Next' button
        if not ErrorLevel
        {
            TestsOK()
            OutputDebug, OK: %TestName%:%A_LineNumber%: 'Setup - Filzip (Select Start Menu Folder)' window appeared and 'Next' was clicked.`n
        }
        else
        {
            TestsFailed()
            WinGetTitle, title, A
            OutputDebug, %TestName%:%A_LineNumber%: Test failed: Unable to hit 'Next' button in 'Setup - Filzip (Select Start Menu Folder)' window. Active window caption: '%title%'.`n
        }
    }
    else
    {
        TestsFailed()
        WinGetTitle, title, A
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'Setup - Filzip (Select Start Menu Folder)' window failed to appear. Active window caption: '%title%'.`n
    }
}


; Test if 'Ready to Install' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Setup - Filzip, Ready to Install, 7
    if not ErrorLevel
    {
        Sleep, 250
        ControlClick, TButton4, Setup - Filzip, Ready to Install ; Hit 'Install' button
        if not ErrorLevel
        {
            TestsOK()
            OutputDebug, OK: %TestName%:%A_LineNumber%: 'Setup - Filzip (Ready to Install)' window appeared and 'Install' was clicked.`n
        }
        else
        {
            TestsFailed()
            WinGetTitle, title, A
            OutputDebug, %TestName%:%A_LineNumber%: Test failed: Unable to hit 'Install' button in 'Setup - Filzip (Ready to Install)' window. Active window caption: '%title%'.`n
        }
    }
    else
    {
        TestsFailed()
        WinGetTitle, title, A
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'Setup - Filzip (Ready to Install)' window failed to appear. Active window caption: '%title%'.`n
    }
}


; Test if can get trhu 'Installing' window
TestsTotal++
if bContinue
{
    WinWaitActive, Setup - Filzip, Installing, 7
    if not ErrorLevel
    {
        OutputDebug, OK: %TestName%:%A_LineNumber%: 'Setup - Filzip (Installing)' window appeared, waiting for it to close.`n
        WinWaitClose, Setup - Filzip, Installing, 20
        if not ErrorLevel
        {
            TestsOK()
            OutputDebug, OK: %TestName%:%A_LineNumber%: 'Setup - Filzip (Installing)' window went away.`n
        }
        else
        {
            TestsFailed()
            WinGetTitle, title, A
            OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'Setup - Filzip (Installing)' window failed to close. Active window caption: '%title%'.`n
        }
    }
    else
    {
        TestsFailed()
        WinGetTitle, title, A
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'Setup - Filzip (Installing)' window failed to appear. Active window caption: '%title%'.`n
    }
}


; Test if 'Completing' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Setup - Filzip, Completing, 7
    if not ErrorLevel
    {
        Sleep, 250
        SendInput, {SPACE}{DOWN}{SPACE} ; Uncheck 'View readme.txt' and 'Run Filzip' //FIXME: is there a better way? Control, Uncheck won't work here
        ControlClick, TButton4, Setup - Filzip, Completing ; Hit 'Finish' button
        if not ErrorLevel
        {
            TestsOK()
            OutputDebug, OK: %TestName%:%A_LineNumber%: 'Setup - Filzip (Completing)' window appeared, 'View readme.txt', 'Run Filzip' were unchecked and 'Finish' was clicked.`n
            Process, Close, Filzip.exe ; Just in case
            Process, Close, Notepad.exe ; Just in case
        }
        else
        {
            TestsFailed()
            WinGetTitle, title, A
            OutputDebug, %TestName%:%A_LineNumber%: Test failed: Unable to hit 'Finish' button in 'Setup - Filzip (Completing)' window. Active window caption: '%title%'.`n
        }
    }
    else
    {
        TestsFailed()
        WinGetTitle, title, A
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'Setup - Filzip (Completing)' window failed to appear. Active window caption: '%title%'.`n
    }
}


;Check if program exists in program files
TestsTotal++
if bContinue
{
    Sleep, 2000
    RegRead, UninstallString, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Filzip 3.0.6.93_is1, UninstallString
    if not ErrorLevel
    {
        StringReplace, UninstallString, UninstallString, `",, All
        IfExist, %UninstallString%
        {
            TestsOK()
            OutputDebug, OK: %TestName%:%A_LineNumber%: The application has been installed, because '%UninstallString%' was found.`n
        }
        else
        {
            TestsFailed()
            OutputDebug, %TestName%:%A_LineNumber%: Test failed: Something went wrong, can't find '%UninstallString%'.`n
        }
    }
    else
    {
        TestsFailed()
        WinGetTitle, title, A
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: Either we can't read from registry or data doesn't exist. Active window caption: '%title%'.`n
    }
}
