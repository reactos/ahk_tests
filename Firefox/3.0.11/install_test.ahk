/*
 * Designed for Firefox 3.0.11
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

ModuleExe = %A_WorkingDir%\Apps\Firefox 3.0.11 Setup.exe
TestName = 1.install
MainAppFile = firefox.exe ; Mostly this is going to be process we need to look for

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
        RegRead, UninstallerPath, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Mozilla Firefox (3.0.11), UninstallString
        if ErrorLevel
        {
            ; There was a problem (such as a nonexistent key or value). 
            ; That probably means we have not installed this app before.
            ; Check in default directory to be extra sure
            IfNotExist, %A_ProgramFiles%\Mozilla Firefox
                bContinue := true ; No previous versions detected in hardcoded path
            else
            {
                bHardcoded := true ; To know if we got path from registry or not
                IfExist, %A_ProgramFiles%\Mozilla Firefox\uninstall\helper.exe
                {
                    RunWait, %A_ProgramFiles%\Mozilla Firefox\uninstall\helper.exe /S ; Silently uninstall it
                    Sleep, 7000
                }

                IfNotExist, %A_ProgramFiles%\Mozilla Firefox ; Uninstaller might delete the dir
                    bContinue := true
                {
                    FileRemoveDir, %A_ProgramFiles%\Mozilla Firefox, 1
                    if ErrorLevel
                        TestsFailed("Unable to delete existing '" A_ProgramFiles "\Mozilla Firefox' ('" MainAppFile "' process is reported as terminated).'")
                    else
                        bContinue := true
                }
            }
        }
        else
        {
            SplitPath, UninstallerPath,, InstalledDir
            SplitPath, InstalledDir,, InstalledDir ; Split once more, since installer was in subdir (3.0.11 specific)
            IfNotExist, %InstalledDir%
                bContinue := true
            else
            {
                IfExist, %UninstallerPath%
                {
                    RunWait, %UninstallerPath% /S ; Silently uninstall it
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
        RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\Mozilla
            RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\mozilla.org
            RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\MozillaPlugins
            RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\MicroSoft\Windows\CurrentVersion\Uninstall\Mozilla Firefox (3.0.11)
        IfExist, %A_AppData%\Mozilla
        {
            FileRemoveDir, %A_AppData%\Mozilla, 1
            if ErrorLevel
                TestsFailed("Unable to delete '" A_AppData "\Mozilla'.")
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


; Test if can start setup
TestsTotal++
if bContinue
{
    SetTitleMatchMode, 2 ; A window's title can contain WinTitle anywhere inside it to be a match.
    WinWaitActive, Extracting, Cancel, 7 ; Wait 7 secs for window to appear
    if ErrorLevel
        TestsFailed("'Extracting' window failed to appear.")
    else
    {
        OutputDebug, OK: %TestName%:%A_LineNumber%: 'Extracting' window appeared, waiting for it to close.`n
        WinWaitClose, Extracting, Cancel, 15
        if ErrorLevel
            TestsFailed("'Extracting' window failed to dissapear.")
        else
            TestsOK("'Extracting' window appeared and went away.")
    }

    SetTitleMatchMode, 3 ; A window's title must exactly match WinTitle to be a match. (Default)
}


; Test if 'Welcome to the Mozilla Firefox' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Mozilla Firefox Setup, Welcome to the Mozilla Firefox, 15
    if ErrorLevel
        TestsFailed("'Mozilla Firefox Setup (Welcome to the Mozilla Firefox)' window failed to appear.")
    else
    {
        Sleep, 700
        ControlClick, Button2, Mozilla Firefox Setup, Welcome to the Mozilla Firefox
        if ErrorLevel
            TestsFailed("Unable to hit 'Next' button in 'Mozilla Firefox Setup (Welcome to the Mozilla Firefox)' window.")
        else
            TestsOK("'Mozilla Firefox Setup (Welcome to the Mozilla Firefox)' window appeared and 'Next' was clicked.") 
    }
}


; Test if 'Setup Type' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Mozilla Firefox Setup, Setup Type, 7
    if ErrorLevel
        TestsFailed("'Mozilla Firefox Setup (Setup Type)' window failed to appear.")
    else
    {
        Sleep, 700
        ControlClick, Button2, Mozilla Firefox Setup, Setup Type
        if ErrorLevel
            TestsFailed("Unable to hit 'Next' button in 'Mozilla Firefox Setup (Setup Type)' window.")
        else
            TestsOK("'Mozilla Firefox Setup (Setup Type)' window appeared and 'Next' was clicked.")
    }
}


; Test if 'Summary' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Mozilla Firefox Setup, Summary, 7
    if ErrorLevel
        TestsFailed("'Mozilla Firefox Setup (Summary)' window failed to appear.")
    else
    {
        Sleep, 700
        ControlClick, Button2, Mozilla Firefox Setup, Summary ; Hit 'Install' button
        if ErrorLevel
            TestsFailed("Unable to hit 'Install' button in 'Mozilla Firefox Setup (Summary)' window.")
        else
            TestsOK("'Mozilla Firefox Setup (Summary)' window appeared and 'Install' button was clicked.")
    }
}


; Test if can get thru 'Installing'
TestsTotal++
if bContinue
{
    WindowSpace := "Mozilla Firefox Setup " ; Note space at the end of window title
    WinWaitActive, %WindowSpace%, Installing, 7
    if ErrorLevel
        TestsFailed("'Mozilla Firefox Setup (Installing)' window failed to appear. Note the space in the end of window title.")
    else
    {
        Sleep, 700
        OutputDebug, OK: %TestName%:%A_LineNumber%: 'Installing' window appeared, waiting for it to close.`n
        WinWaitClose, %WindowSpace%, Installing, 30
        if ErrorLevel
            TestsFailed("'Mozilla Firefox Setup (Installing)' window failed to dissapear.")
        else
            TestsOK("'Mozilla Firefox Setup (Installing)' window went away.")
    }
}


; Test if 'Completing' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, %WindowSpace%, Completing, 7
    if ErrorLevel
        TestsFailed("'Mozilla Firefox Setup (Completing)' window failed to appear.")
    else
    {
        Sleep, 700
        ControlClick, Button4, %WindowSpace%, Completing ; Uncheck 'Launch Mozilla Firefox now'
        if ErrorLevel
        {
            TestsFailed("Unable to uncheck 'Launch Mozilla Firefox now' in 'Mozilla Firefox Setup (Completing)' window.")
            Process, Close, firefox.exe
        }
        else
        {
            Sleep, 500
            ControlClick, Button2, %WindowSpace%, Completing ; Hit 'Finish'
            if ErrorLevel
                TestsFailed("Unable to hit 'Finish' button in 'Mozilla Firefox Setup (Completing)' window.")
            else
            {
                WinWaitClose, %WindowSpace%, Completing, 5
                if ErrorLevel
                    TestsFailed("'Mozilla Firefox Setup (Completing)' window failed to close despite 'Finish' button being clicked.")
                else
                {
                    Process, Wait, %MainAppFile%, 4
                    NewPID = %ErrorLevel%  ; Save the value immediately since ErrorLevel is often changed.
                    if NewPID <> 0
                    {
                        TestsFailed("Process '" MainAppFile "' appeared despite checkbox 'Launch Mozilla Firefox now' was unchecked.")
                        Process, Close, %MainAppFile%
                    }
                    else
                        TestsOK("'Mozilla Firefox Setup (Completing)' window appeared, 'Finish' button clicked, window closed, '" MainAppFile "' process did not appear.")
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
    RegRead, UninstallerPath, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Mozilla Firefox (3.0.11), UninstallString
    if ErrorLevel
        TestsFailed("Either we can't read from registry or data doesn't exist.")
    else
    {
        SplitPath, UninstallerPath,, InstalledDir
        SplitPath, InstalledDir,, InstalledDir ; Split once more, since installer was in subdir (v3.0.11 specific)
        IfNotExist, %InstalledDir%\%MainAppFile%
            TestsFailed("Something went wrong, can't find '" InstalledDir "\" MainAppFile "'.")
        else
            TestsOK("The application has been installed, because '" InstalledDir "\" MainAppFile "' was found.")
    }
}
