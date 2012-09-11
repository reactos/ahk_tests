/*
 * Designed for Universal Viewer 5.7.2.0
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

ModuleExe = %A_WorkingDir%\Apps\UniversalViewer 5.7.2.0 Setup.exe
TestName = 1.install
MainAppFile = Viewer.exe ; Mostly this is going to be process we need to look for

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
        RegRead, UninstallerPath, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Universal Viewer Free_is1, UninstallString
        if ErrorLevel
        {
            ; There was a problem (such as a nonexistent key or value). 
            ; That probably means we have not installed this app before.
            ; Check in default directory to be extra sure
            IfNotExist, %A_ProgramFiles%\Universal Viewer
                bContinue := true ; No previous versions detected in hardcoded path
            else
            {
                bHardcoded := true ; To know if we got path from registry or not
                IfExist, %A_ProgramFiles%\Universal Viewer\unins000.exe
                {
                    RunWait, %A_ProgramFiles%\Universal Viewer\unins000.exe /SILENT ; Silently uninstall it
                    Sleep, 7000
                }

                IfNotExist, %A_ProgramFiles%\Universal Viewer ; Uninstaller might delete the dir
                    bContinue := true
                {
                    FileRemoveDir, %A_ProgramFiles%\Universal Viewer, 1
                    if ErrorLevel
                        TestsFailed("Unable to delete hardcoded path '" A_ProgramFiles "\Universal Viewer' ('" MainAppFile "' process is reported as terminated).'")
                    else
                        bContinue := true
                }
            }
        }
        else
        {
            StringReplace, UninstallerPath, UninstallerPath, `",, All ; Universal Viewer registry data contains quotes
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
        RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\MicroSoft\Windows\CurrentVersion\Uninstall\Universal Viewer Free_is1
        IfExist, %A_AppData%\ATViewer
        {
            FileRemoveDir, %A_AppData%\ATViewer, 1
            if ErrorLevel
                TestsFailed("Unable to delete '" A_AppData "\ATViewer'.")
        }
        FileRemoveDir, %A_AppData%\SumatraPDF, 1
        FileRemoveDir, %A_AppData%\Adobe, 1

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
        ControlClick, TNewButton1, Select Setup Language, Select the language
        if ErrorLevel
            TestsFailed("Unable to hit 'OK' in 'Select Setup Language (Select the language)' window.")
        else
        {
            WinWaitClose, Select Setup Language, Select the language, 5
            if ErrorLevel
                TestsFailed("'Select Setup Language (Select the language)' window failed to close despite 'OK' button being clicked.")
            else
                TestsOK("'Select Setup Language (Select the language)' window appeared and 'OK' was clicked.")
        }
    }
}


; Test if 'Welcome' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Setup - Universal Viewer Free, Welcome, 12
    if ErrorLevel
        TestsFailed("'Setup - Universal Viewer Free (Welcome)' window failed to appear.")
    else
    {
        Sleep, 700
        ControlClick, TNewButton1, Setup - Universal Viewer Free, Welcome ; Hit 'Next' button
        if ErrorLevel
            TestsFailed("Unable to hit 'Next' button in 'Setup - Universal Viewer Free (Welcome)' window.")
        else
            TestsOK("'Setup - Universal Viewer Free (Welcome)' window appeared and 'Next' was clicked.")
    }
}


; Test if 'Select Destination Location' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Setup - Universal Viewer Free, Select Destination Location, 7
    if ErrorLevel
        TestsFailed("'Setup - Universal Viewer Free (Select Destination Location)' window failed to appear.")
    else
    {
        Sleep, 700
        ControlClick, TNewButton3, Setup - Universal Viewer Free, Select Destination Location ; Hit 'Next' button
        if ErrorLevel
            TestsFailed("Unable to hit 'Next' button in 'Setup - Universal Viewer Free (Select Destination Location)' window.")
        else
            TestsOK("'Setup - Universal Viewer Free (Select Destination Location)' window appeared and 'Next' was clicked.")
    }
}


; Test if 'Select Additional Tasks' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Setup - Universal Viewer Free, Select Additional Tasks, 7
    if ErrorLevel
        TestsFailed("'Setup - Universal Viewer Free (Select Additional Tasks)' window failed to appear.")
    else
    {
        Sleep, 700
        ControlClick, TNewButton3, Setup - Universal Viewer Free, Select Additional Tasks ; Hit 'Next' button
        if ErrorLevel
            TestsFailed("Unable to hit 'Next' button in 'Setup - Universal Viewer Free (Select Additional Tasks)' window.")
        else
            TestsOK("'Setup - Universal Viewer Free (Select Additional Tasks)' window appeared and 'Next' was clicked.")
    }
}


; Test if 'Ready to Install' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Setup - Universal Viewer Free, Ready to Install, 7
    if ErrorLevel
        TestsFailed("'Setup - Universal Viewer Free (Ready to Install)' window failed to appear.")
    else
    {
        Sleep, 700
        ControlClick, TNewButton3, Setup - Universal Viewer Free, Ready to Install ; Hit 'Install' button
        if ErrorLevel
            TestsFailed("Unable to hit 'Install' button in 'Setup - Universal Viewer Free (Ready to Install)' window.")
        else
            TestsOK("'Setup - Universal Viewer Free (Ready to Install)' window appeared and 'Install' was clicked.")
    }
}


; Test if can get trhu 'Installing' window
TestsTotal++
if bContinue
{
    WinWaitActive, Setup - Universal Viewer Free, Installing, 7
    if ErrorLevel
        TestsFailed("'Setup - Universal Viewer Free (Installing)' window failed to appear.")
    else
    {
        OutputDebug, OK: %TestName%:%A_LineNumber%: 'Setup - Universal Viewer Free (Installing)' window appeared, waiting for it to close.`n
        WinWaitClose, Setup - Universal Viewer Free, Installing, 20
        if ErrorLevel
            TestsFailed("'Setup - Universal Viewer Free (Installing)' window failed to close.")
        else
            TestsOK("'Setup - Universal Viewer Free (Installing)' window went away.")
    }
}


; Test if 'Completing' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Setup - Universal Viewer Free, Completing, 7
    if ErrorLevel
        TestsFailed("'Setup - Universal Viewer Free (Completing)' window failed to appear.")
    else
    {
        Sleep, 700
        SendInput, {SPACE}{DOWN}{SPACE} ; Uncheck 'Launch Universal Viewer' and 'View version history'. Control, Uncheck won't work here
        Sleep, 1000
        ControlClick, TNewButton3, Setup - Universal Viewer Free, Completing ; Hit 'Finish' button
        if ErrorLevel
            TestsFailed("Unable to hit 'Finish' button in 'Setup - Universal Viewer Free (Completing)' window.")
        else
        {
            Process, wait, %MainAppFile%, 5
            NewPID = %ErrorLevel%  ; Save the value immediately since ErrorLevel is often changed.
            if NewPID <> 0
            {
                Process, Close, %MainAppFile%
                Process, WaitClose, %MainAppFile%, 4
                if ErrorLevel
                    TestsFailed("Unable to uncheck 'Launch Universal Viewer' in 'Setup - Universal Viewer Free (Completing)' window, because process '" MainAppFile "' was detected and failed to terminate it.")
                else
                    TestsFailed("Unable to uncheck 'Launch Universal Viewer' in 'Setup - Universal Viewer Free (Completing)' window, because process '" MainAppFile "' was detected.")
            }
            else
                TestsOK("'Setup - Universal Viewer Free (Completing)' window appeared, 'Launch Universal Viewer', 'View version history' were unchecked and 'Finish' was clicked.")
        }
    }
}

; Check if program exists
TestsTotal++
if bContinue
{
    Sleep, 2000
    RegRead, UninstallerPath, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Universal Viewer Free_is1, UninstallString
    if ErrorLevel
        TestsFailed("Either we can't read from registry or data doesn't exist.")
    else
    {
        StringReplace, UninstallerPath, UninstallerPath, `",, All ; Universal Viewer registry data contains quotes
        SplitPath, UninstallerPath,, InstalledDir
        IfNotExist, %InstalledDir%\%MainAppFile%
            TestsFailed("Something went wrong, can't find '" InstalledDir "\" MainAppFile "'.")
        else
            TestsOK("The application has been installed, because '" InstalledDir "\" MainAppFile "' was found.")
    }
}
