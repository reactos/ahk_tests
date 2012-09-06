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
TestName = 1.install
MainAppFile = Filzip.exe ; Mostly this is going to be process we need to look for

; Test if Setup file exists, if so, delete installed files, and run Setup
TestsTotal++
IfNotExist, %ModuleExe%
    TestsFailed("'" ModuleExe "' not found.")
else
{
    Process, Close, %MainAppFile% ; Teminate process
    Process, WaitClose, %MainAppFile%, 4
    if ErrorLevel ; The PID still exists.
        TestsFailed("Unable to terminate '" MainAppFile "' process.") ; So, process still exists
    else
    {
        RegRead, UninstallerPath, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Filzip 3.0.6.93_is1, UninstallString
        if ErrorLevel
        {
            ; There was a problem (such as a nonexistent key or value). 
            ; That probably means we have not installed this app before.
            ; Check in default directory to be extra sure
            IfNotExist, %A_ProgramFiles%\Filzip
                bContinue := true ; No previous versions detected in hardcoded path
            else
            {
                bHardcoded := true ; To know if we got path from registry or not
                IfExist, %A_ProgramFiles%\Filzip\unins000.exe
                {
                    RunWait, %A_ProgramFiles%\Filzip\unins000.exe /SILENT ; Silently uninstall it
                    Sleep, 7000
                }

                IfNotExist, %A_ProgramFiles%\Filzip ; Uninstaller might delete the dir
                    bContinue := true
                {
                    FileRemoveDir, %A_ProgramFiles%\Filzip, 1
                    if ErrorLevel
                        TestsFailed("Unable to delete existing '" A_ProgramFiles "\Filzip' ('" MainAppFile "' process is reported as terminated).'")
                    else
                        bContinue := true
                }
            }
        }
        else
        {
            StringReplace, UninstallerPath, UninstallerPath, `",, All ; The Filzip uninstaller path is quoted, remove quotes
            SplitPath, UninstallerPath,, InstalledDir
            IfNotExist, %InstalledDir%
                bContinue := true
            else
            {
                IfExist, %UninstallerPath%
                {
                    RunWait, %UninstallerPath% /SILENT ; Silently uninstall it
                    Sleep, 7000
                }

                IfNotExist, %InstalledDir%
                    bContinue := true
                else
                {
                    FileRemoveDir, %InstalledDir%, 1 ; Delete just in case
                    if ErrorLevel
                        TestsFailed("Unable to delete existing '" InstalledDir "' ('" MainAppFile "' process is reported as terminated).")
                    else
                        bContinue := true
                }
            }
        }
    }

    if bContinue
    {
        RegDelete, HKEY_CURRENT_USER, SOFTWARE\Filzip
        RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\MicroSoft\Windows\CurrentVersion\Uninstall\Filzip 3.0.6.93_is1

        if bContinue
        {
            if bHardcoded
                TestsOK("Either there was no previous versions or we succeeded removing it using hardcoded path.")
            else
                TestsOK("Either there was no previous versions or we succeeded removing it using data from registry.")
            Run %ModuleExe%
        }
    }
}


; Test if 'Select Setup Language' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Select Setup Language, Select the language, 15
    if ErrorLevel
        TestsFailed("'Select Setup Language (Select the language)' window failed to appear.")
    else
    {
        Sleep, 700
        ControlClick, TButton1, Select Setup Language, Select the language ; hit 'OK' button
        if ErrorLevel
            TestsFailed("Unable to hit 'OK' button in 'Select Setup Language (Select the language)' window.")
        else
        {
            WinWaitClose, Select Setup Language, Select the language, 5
            if ErrorLevel
                TestsFailed("'Select Setup Language (Select the language)' window failed to close despite 'OK' button being clicked.")
            else
                TestsOK("'Select Setup Language (Select the language)' window appeared, 'OK' button clicked and window closed.")
        }
    }
}


; Test if 'Welcome' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Setup - Filzip, Welcome, 7
    if ErrorLevel
        TestsFailed("'Setup - Filzip (Welcome)' window failed to appear.")
    else
    {
        Sleep, 700
        ControlClick, TButton1, Setup - Filzip, Welcome ; Hit 'Next' button
        if ErrorLevel
            TestsFailed("Unable to hit 'Next' button in 'Setup - Filzip (Welcome)' window.")
        else
            TestsOK("'Setup - Filzip (Welcome)' window appeared and 'Next' was clicked.")
    }
}


; Test if 'License Agreement' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Setup - Filzip, License Agreement, 7
    if ErrorLevel
        TestsFailed("'Setup - Filzip (License Agreement)' window failed to appear.")
    else
    {
        Sleep, 500
        Control, Check,, TRadioButton1, Setup - Filzip, License Agreement ; Check 'I accept the agreement' radio button
        if ErrorLevel
            TestsFailed("Unable to check 'I accept the agreement' radiobutton in 'Setup - Filzip (License Agreement)' window.")
        else
        {
            Sleep, 700
            ControlClick, TButton2, Setup - Filzip, License Agreement ; Hit 'Next' button
            if ErrorLevel
                TestsFailed("Unable to hit 'Next' button in 'Setup - Filzip (License Agreement)' window.")
            else
                TestsOK("'Setup - Filzip (License Agreement)' window appeared, radiobutton 'I accept' checked and 'Next' button was clicked.")
        }
    }
}


; Test if 'Select Destination Location' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Setup - Filzip, Select Destination Location, 7
    if ErrorLevel
        TestsFailed("'Setup - Filzip (Select Destination Location)' window failed to appear.")
    else
    {
        Sleep, 700
        ControlClick, TButton3, Setup - Filzip, Select Destination Location ; Hit 'Next' button
        if ErrorLevel
            TestsFailed("Unable to hit 'Next' button in 'Setup - Filzip (Select Destination Location)' window.")
        else
            TestsOK("'Setup - Filzip (Select Destination Location)' window appeared and 'Next' was clicked.")
    }
}


; Test if 'Select Components' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Setup - Filzip, Select Components, 7
    if ErrorLevel
        TestsFailed("'Setup - Filzip (Select Components)' window failed to appear.")
    else
    {
        Sleep, 700
        ControlClick, TButton3, Setup - Filzip, Select Components ; Hit 'Next' button
        if ErrorLevel
            TestsFailed("Unable to hit 'Next' button in 'Setup - Filzip (Select Components)' window.")
        else
            TestsOK("'Setup - Filzip (Select Components)' window appeared and 'Next' was clicked.")
    }
}


; Test if 'Select Start Menu Folder' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Setup - Filzip, Select Start Menu Folder, 7
    if ErrorLevel
        TestsFailed("'Setup - Filzip (Select Start Menu Folder)' window failed to appear.")
    else
    {
        Sleep, 700
        ControlClick, TButton4, Setup - Filzip, Select Start Menu Folder ; Hit 'Next' button
        if ErrorLevel
            TestsFailed("Unable to hit 'Next' button in 'Setup - Filzip (Select Start Menu Folder)' window.")
        else
            TestsOK("'Setup - Filzip (Select Start Menu Folder)' window appeared and 'Next' was clicked.")
    }
}


; Test if 'Ready to Install' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Setup - Filzip, Ready to Install, 7
    if ErrorLevel
        TestsFailed("'Setup - Filzip (Ready to Install)' window failed to appear.")
    else
    {
        Sleep, 700
        ControlClick, TButton4, Setup - Filzip, Ready to Install ; Hit 'Install' button
        if ErrorLevel
            TestsFailed("Unable to hit 'Install' button in 'Setup - Filzip (Ready to Install)' window.")
        else
            TestsOK("'Setup - Filzip (Ready to Install)' window appeared and 'Install' was clicked.")
    }
}


; Test if can get trhu 'Installing' window
TestsTotal++
if bContinue
{
    WinWaitActive, Setup - Filzip, Installing, 7
    if ErrorLevel
        TestsFailed("'Setup - Filzip (Installing)' window failed to appear.")
    else
    {
        OutputDebug, OK: %TestName%:%A_LineNumber%: 'Setup - Filzip (Installing)' window appeared, waiting for it to close.`n
        WinWaitClose, Setup - Filzip, Installing, 20
        if ErrorLevel
            TestsFailed("'Setup - Filzip (Installing)' window failed to close.")
        else
            TestsOK("'Setup - Filzip (Installing)' window went away.")
    }
}


; Test if 'Completing' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Setup - Filzip, Completing, 7
    if ErrorLevel
        TestsFailed("'Setup - Filzip (Completing)' window failed to appear.")
    else
    {
        Sleep, 700
        SendInput, {SPACE}{DOWN}{SPACE} ; Uncheck 'View readme.txt' and 'Run Filzip' //FIXME: is there a better way? Control, Uncheck won't work here
        Sleep, 500
        ControlClick, TButton4, Setup - Filzip, Completing ; Hit 'Finish' button
        if ErrorLevel
            TestsFailed("Unable to hit 'Finish' button in 'Setup - Filzip (Completing)' window.")
        else
        {
            WinWaitClose, Setup - Filzip, Completing
            if ErrorLevel
                TestsFailed("'Setup - Filzip (Completing)' window failed to close despite 'Finish' button being clicked.")
            else
            {
                Process, Wait, %MainAppFile%, 4
                NewPID = %ErrorLevel%  ; Save the value immediately since ErrorLevel is often changed.
                if NewPID <> 0
                {
                    TestsFailed("Process '" MainAppFile "' appeared despite 'Run Filzip' being reported as unchecked.")
                    Process, Close, %MainAppFile%
                    Process, Close, Notepad.exe
                }
                else
                    TestsOK("'Setup - Filzip (Completing)' window appeared, 'View readme.txt', 'Run Filzip' were unchecked, 'Finish' clicked and window closed.")
            }
        }
    }
}


; Check if program exists
TestsTotal++
if bContinue
{
    Sleep, 2000
    RegRead, UninstallerPath, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Filzip 3.0.6.93_is1, UninstallString
    if ErrorLevel
        TestsFailed("Either we can't read from registry or data doesn't exist.")
    else
    {
        StringReplace, UninstallerPath, UninstallerPath, `",, All ; The Filzip uninstaller path is quoted, remove quotes
        SplitPath, UninstallerPath,, InstalledDir
        IfNotExist, %InstalledDir%\%MainAppFile%
            TestsFailed("Something went wrong, can't find '" InstalledDir "\" MainAppFile "'.")
        else
            TestsOK("The application has been installed, because '" InstalledDir "\" MainAppFile "' was found.")
    }
}
