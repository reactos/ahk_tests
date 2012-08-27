/*
 * Designed for Mozilla Firefox 12.0
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

ModuleExe = %A_WorkingDir%\Apps\Mozilla Firefox 12.0 Setup.exe
bContinue := false
TestName = 1.install

TestsFailed := 0
TestsOK := 0
TestsTotal := 0

; Test if Setup file exists, if so, delete installed files, and run Setup
IfExist, %ModuleExe%
{
    ; Get rid of other versions
    RegRead, UninstallerPath, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Mozilla Firefox 12.0 (x86 en-US), UninstallString
    if not ErrorLevel
    {   
        IfExist, %UninstallerPath%
        {
            Process, Close, firefox.exe ; Teminate process
            Sleep, 1500
            RunWait, %UninstallerPath% /S ; Silently uninstall it
            Sleep, 2500
            ; Delete everything just in case
            RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\Mozilla
            RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\mozilla.org
            RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\MozillaPlugins
            RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\MicroSoft\Windows\CurrentVersion\Uninstall\Mozilla Firefox 12.0 (x86 en-US)
            SplitPath, UninstallerPath,, InstalledDir
            FileRemoveDir, %InstalledDir%, 1
            FileRemoveDir, %A_AppData%\Mozilla, 1
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
        IfExist, %A_ProgramFiles%\Mozilla Firefox\uninstall\helper.exe
        {
            Process, Close, firefox.exe ; Teminate process
            Sleep, 1500
            RunWait, %A_ProgramFiles%\Mozilla Firefox\uninstall.exe /S ; Silently uninstall it
            Sleep, 2500
            FileRemoveDir, %A_ProgramFiles%\Mozilla Firefox, 1
            FileRemoveDir, %A_AppData%\Mozilla, 1
            Sleep, 1000
            IfExist, %A_ProgramFiles%\Mozilla Firefox
            {
                OutputDebug, %TestName%:%A_LineNumber%: Test failed: Previous version detected and failed to delete '%A_ProgramFiles%\Mozilla Firefox'.`n
                bContinue := false
            }
            else
                bContinue := true
        }
        else
            bContinue := true ; No previous versions detected.
    }

    FileRemoveDir, %A_ProgramFiles%\Mozilla Firefox, 1 ; v12.0 Requires an extra delete
    if bContinue
        Run %ModuleExe%
}
else
{
    OutputDebug, %TestName%:%A_LineNumber%: Test failed: '%ModuleExe%' not found.`n
    bContinue := false
}

; Test if can start setup
TestsTotal++
if bContinue
{
    SetTitleMatchMode, 1
    WinWaitActive, Extracting, Cancel, 7 ; Wait 7 secs for window to appear
    if not ErrorLevel ;Window is found and it is active
    {
        OutputDebug, OK: %TestName%:%A_LineNumber%: 'Extracting' window appeared, waiting for it to close.`n
        WinWaitClose, Extracting, Cancel, 15
        if not ErrorLevel
            TestsOK("'Extracting' window appeared and went away.")
        else
            TestsFailed("'Extracting' window failed to dissapear.")
    }
    else
        TestsFailed("'Extracting' window failed to appear.")
}


; Test if 'Welcome to the Mozilla Firefox' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Mozilla Firefox Setup, Welcome to the Mozilla Firefox, 15
    if not ErrorLevel
    {
        Sleep, 250
        SendInput, !n ; Hit 'Next' button
        TestsOK("'Mozilla Firefox Setup (Welcome to the Mozilla Firefox)' window appeared and Alt+N was sent.")
    }
    else
        TestsFailed("'Mozilla Firefox Setup (Welcome to the Mozilla Firefox)' window failed to appear.")
}


; Test if 'Setup Type' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Mozilla Firefox Setup, Setup Type, 7
    if not ErrorLevel
    {
        Sleep, 250
        SendInput, !n ; Hit 'Next' button
        TestsOK("'Mozilla Firefox Setup (Setup Type)' window appeared and Alt+N was sent.")
    }
    else
        TestsFailed("'Mozilla Firefox Setup (Setup Type)' window failed to appear.")
}


; Test if 'Summary' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Mozilla Firefox Setup, Summary, 7
    if not ErrorLevel
    {
        Sleep, 250
        SendInput, {ALTDOWN}i{ALTUP} ; Hit 'Install' button
        TestsOK("'Mozilla Firefox Setup (Summary)' window appeared and Alt+I was sent.")
    }
    else
        TestsFailed("'Mozilla Firefox Setup (Summary)' window failed to appear.")
}


; Test if can get thru 'Installing'
TestsTotal++
if bContinue
{
    WinWaitActive, Mozilla Firefox Setup, Installing, 7
    if not ErrorLevel
    {
        Sleep, 250
        OutputDebug, OK: %TestName%:%A_LineNumber%: 'Mozilla Firefox Setup (Installing)' window appeared, waiting for it to close.`n
        WinWaitClose, Mozilla Firefox Setup, Installing, 25
        if not ErrorLevel
            TestsOK("'Mozilla Firefox Setup (Installing)' window went away.")
        else
            TestsFailed("'Mozilla Firefox Setup (Installing)' window failed to dissapear.")
    }
    else
        TestsFailed("'Mozilla Firefox Setup (Installing)' window failed to appear.")
}


; Test if 'Completing' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Mozilla Firefox Setup, Completing, 7
    if not ErrorLevel
    {
        Sleep, 250
        SendInput, !l ; Uncheck 'Lounch Firefox now'
        SendInput, !f ; Hit 'Finish' button
        TestsOK("'Mozilla Firefox Setup (Completing)' window appeared, Alt+L and Alt+F was sent.")
    }
    else
        TestsFailed("'Mozilla Firefox Setup (Completing)' window failed to appear.")
}

Process, Close, firefox.exe ; Just in case

;Check if program exists
TestsTotal++
if bContinue
{
    Sleep, 250
    AppExe = %A_ProgramFiles%\Mozilla Firefox\firefox.exe
    IfExist, %AppExe%
        TestsOK("Should be installed, because '" AppExe "' was found.")
    else
        TestsFailed("Can NOT find '" AppExe "'.")
}
