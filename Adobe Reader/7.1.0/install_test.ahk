/*
 * Designed for Adobe Reader 7.1.0
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

ModuleExe = %A_WorkingDir%\Apps\Adobe Reader 7.1.0 Setup.exe
TestName = 1.install
MainAppFile = AcroRd32.exe ; Mostly this is going to be process we need to look for

; Test if Setup file exists, if so, delete installed files, and run Setup
TestsTotal++
IfNotExist, %ModuleExe%
    TestsFailed("'" ModuleExe "' not found.")
else
{
    Process, Close, %MainAppFile% ; Teminate process
    Sleep, 2000
    Process, Exist, %MainAppFile%
    if ErrorLevel <> 0
        TestsFailed("Unable to terminate '" MainAppFile "' process.") ; So, process still exists
    else
    {
        RegRead, InstallLocation, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{AC76BA86-7AD7-1033-7B44-A71000000002}, InstallLocation
        if ErrorLevel
        {
            ; There was a problem (such as a nonexistent key or value). 
            ; That probably means we have not installed this app before.
            ; Check in default directory to be extra sure
            IfNotExist, %A_ProgramFiles%\Adobe\Acrobat 7.0
                bContinue := true ; No previous versions detected in hardcoded path
            else
            {
                bHardcoded := true ; To know if we got path from registry or not
                IfExist, %A_ProgramFiles%\Adobe\Acrobat 7.0
                {
                    RunWait, MsiExec.exe /qn /norestart /x {AC76BA86-7AD7-1033-7B44-A71000000002} ; Silently uninstall it
                    Sleep, 7000
                }

                IfNotExist, %A_ProgramFiles%\Adobe\Acrobat 7.0 ; Uninstaller might delete the dir
                    bContinue := true
                else
                {
                    FileRemoveDir, %A_ProgramFiles%\Adobe\Acrobat 7.0, 1
                    if ErrorLevel
                        TestsFailed("Unable to delete existing '" A_ProgramFiles "\Adobe\Acrobat 7.0' ('" MainAppFile "' process is reported as terminated).'")
                    else
                        bContinue := true
                }
            }
        }
        else
        {
            IfNotExist, %InstallLocation%
                bContinue := true
            else
            {
                IfExist, %InstallLocation%
                {
                    RunWait, MsiExec.exe /qn /norestart /x {AC76BA86-7AD7-1033-7B44-A71000000002} ; Silently uninstall it
                    Sleep, 7000
                }

                IfNotExist, %InstallLocation%
                    bContinue := true
                else
                {
                    FileRemoveDir, %InstallLocation%, 1 ; Delete just in case
                    if ErrorLevel
                        TestsFailed("Unable to delete existing '" InstallLocation "' ('" MainAppFile "' process is reported as terminated).")
                    else
                        bContinue := true
                }
            }
        }
    }

    if bContinue
    {
        RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\Adobe\Acrobat Reader
        RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\Adobe\Repair\Acrobat Reader
        RegDelete, HKEY_CURRENT_USER, SOFTWARE\Adobe\Acrobat Reader
        RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\MicroSoft\Windows\CurrentVersion\Uninstall\{AC76BA86-7AD7-1033-7B44-A71000000002}
        IfExist, %A_AppData%\Adobe\Acrobat
        {
            FileRemoveDir, %A_AppData%\Adobe\Acrobat, 1
            if ErrorLevel
                TestsFailed("Unable to delete '" A_AppData "\Adobe\Acrobat'.")
        }

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


; Test if 'Please wait' and Setup windows appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Adobe Reader 7.1.0, Resume, 15
    if ErrorLevel
        TestsFailed("'Adobe Reader 7.1.0 (Resume)' window failed to appear.")
    else
    {
        OutputDebug, OK: %TestName%:%A_LineNumber%: 'Adobe Reader 7.1.0' window with 'Resume' button appeared.`n
        WinWaitActive, Adobe Reader 7.1.0 - Setup, Next, 50
        if ErrorLevel
            TestsFailed("First 'Adobe Reader 7.1.0 - Setup' window (Splash Screen) failed to appear.")
        else
        {
            Sleep, 700
            ControlClick, Button1, Adobe Reader 7.1.0 - Setup, Next
            if ErrorLevel
                TestsFailed("Unable to click first 'Next' in 'Adobe Reader 7.1.0 - Setup' window.")
            else
                TestsOK("'Adobe Reader 7.1.0 - Setup' window appeared and first 'Next' button was clicked.")
        }
    } 
}


; Test if 'Adobe Reader 7.1.0 - Setup (Welcome to Setup)' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Adobe Reader 7.1.0 - Setup, Welcome to Setup, 14
    if ErrorLevel
        TestsFailed("'Adobe Reader 7.1.0 - Setup (Welcome to Setup)' window failed to appear.")
    else
    {
        Sleep, 700
        ControlClick, Button1, Adobe Reader 7.1.0 - Setup, Welcome to Setup
        if ErrorLevel
            TestsFailed("Unable to hit 'Next' button in 'Adobe Reader 7.1.0 - Setup (Welcome to Setup)' window.")
        else
            TestsOK("'Adobe Reader 7.1.0 - Setup (Welcome to Setup)' window appeared and 'Next' button was clicked.")
    }
}


; Test if 'Adobe Reader 7.1.0 - Setup (Destination Folder)' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Adobe Reader 7.1.0 - Setup, Destination Folder, 7
    if ErrorLevel
        TestsFailed("'Adobe Reader 7.1.0 - Setup (Destination Folder)' window failed to appear.")
    else
    {
        Sleep, 700
        ControlClick, Button1, Adobe Reader 7.1.0 - Setup, Destination Folder
        if ErrorLevel
            TestsFailed("Unable to hit 'Next' button in ' Adobe Reader 7.1.0 - Setup (Destination Folder)' window.")
        else
            TestsOK("'Adobe Reader 7.1.0 - Setup (Destination Folder)' window appeared and 'Next' button was clicked.")
    }
}


; Test if 'Adobe Reader 7.1.0 - Setup (Ready to Install)' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Adobe Reader 7.1.0 - Setup, Ready to Install, 7
    if ErrorLevel
        TestsFailed("'Adobe Reader 7.1.0 - Setup (Ready to Install)' window failed to appear.")
    else
    {
        Sleep, 700
        ControlClick, Button1, Adobe Reader 7.1.0 - Setup, Ready to Install ; Hit 'Install' button
        if ErrorLevel
            TestsFailed("Unable to hit 'Install' button in 'Adobe Reader 7.1.0 - Setup (Ready to Install)' window.")
        else
            TestsOK("'Adobe Reader 7.1.0 - Setup (Ready to Install)' window appeared and 'Install' button was clicked.")
    }
}


; Test if can get thru 'Installing'
TestsTotal++
if bContinue
{
    WinWaitActive, Adobe Reader 7.1.0 - Setup, Installing Adobe, 7
    if ErrorLevel
        TestsFailed("'Adobe Reader 7.1.0 - Setup (Installing)' window failed to appear.")
    else
    {
        Sleep, 700
        OutputDebug, OK: %TestName%:%A_LineNumber%: 'Adobe Reader 7.1.0 - Setup (Installing Adobe)' window appeared, waiting for it to close.`n
        WinWaitClose, Adobe Reader 7.1.0 - Setup, Installing Adobe, 55
        if ErrorLevel
            TestsFailed("'Adobe Reader 7.1.0 - Setup (Installing Adobe)' window failed to dissapear.")
        else
        {
            WinWaitActive, Adobe Reader 7.1.0 - Setup, Setup Completed, 7
            if ErrorLevel
                TestsFailed("'Adobe Reader 7.1.0 - Setup (Setup Completed)' window failed to appear.")
            else
            {
                ControlClick, Button1, Adobe Reader 7.1.0 - Setup, Setup Completed ; Hit 'Finish' button
                if ErrorLevel
                    TestsFailed("Unable to hit 'Finish' button in 'Adobe Reader 7.1.0 - Setup (Setup Completed)' window.")
                else
                {
                    WinWaitClose, Adobe Reader 7.1.0 - Setup, Setup Completed, 5
                    if ErrorLevel
                        TestsFailed("'Adobe Reader 7.1.0 - Setup (Setup Completed)' window failed to close despite 'Finish' button being clicked.")
                    else
                        TestsOK("'Adobe Reader 7.1.0 - Setup (Setup Completed)' window closed after 'Finish' button was clicked.")
                }
            }
        }
    }
}


; Check if program exists
TestsTotal++
if bContinue
{
    Sleep, 2000
    RegRead, InstallLocation, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{AC76BA86-7AD7-1033-7B44-A71000000002}, InstallLocation
    if not ErrorLevel
    {
        IfExist, %InstallLocation%%MainAppFile% ; Registry path contains trailing backslash
            TestsOK("The application has been installed, because '" InstallLocation MainAppFile "' was found.")
        else
            TestsFailed("Something went wrong, can't find '" InstallLocation MainAppFile "'.")
    }
    else
        TestsFailed("Either we can't read from registry or data doesn't exist.")
}
