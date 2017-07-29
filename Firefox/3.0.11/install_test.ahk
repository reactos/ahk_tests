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
    Process, WaitClose, %MainAppFile%, 4
    if ErrorLevel ; The PID still exists.
        TestsFailed("Unable to terminate '" MainAppFile "' process.") ; So, process still exists
    else
    {
        RegRead, UninstallerPath, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Mozilla Firefox (3.0.11), UninstallString
        if ErrorLevel
        {
            ; There was a problem (such as a nonexistent key or value). 
            ; That probably means we have not installed this app before.
            ; Check in default directory to be extra sure
            bHardcoded := true ; To know if we got path from registry or not
            szDefaultDir = %A_ProgramFiles%\Mozilla Firefox
            IfNotExist, %szDefaultDir%
            {
                TestsInfo("No previous versions detected in hardcoded path: '" szDefaultDir "'.")
                bContinue := true
            }
            else
            {   
                UninstallerPath = %szDefaultDir%\uninstall\helper.exe /S
                ; There is child process, but seems we can not detect it
                ; Process Explorer shows that 'Au_.exe' was started by 'Non-existent Process' and we start 'helper.exe'
                WaitUninstallDone(UninstallerPath, 3)
                if bContinue
                {
                    ; 2.0.0.20, 3.0.11, 12.0 starts 'Au_.exe' process
                    Process, WaitClose, Au_.exe, 7
                    if ErrorLevel ; The PID still exists
                    {
                        TestsInfo("'Au_.exe' process failed to close.")
                        Process, Close, Au_.exe
                        Process, WaitClose, Au_.exe, 3
                        if ErrorLevel ; The PID still exists
                            TestsFailed("Unable to terminate 'Au_.exe' process.")
                    }
                    else
                    {
                        IfNotExist, %szDefaultDir% ; Uninstaller might delete the dir
                        {
                            TestsInfo("Uninstaller deleted hardcoded path: '" szDefaultDir "'.")
                            bContinue := true
                        }
                        else
                        {
                            FileRemoveDir, %szDefaultDir%, 1
                            if ErrorLevel
                                TestsFailed("Unable to delete hardcoded path '" szDefaultDir "' ('" MainAppFile "' process is reported as terminated).'")
                            else
                            {
                                TestsInfo("Succeeded deleting hardcoded path, because uninstaller did not: '" szDefaultDir "'.")
                                bContinue := true
                            }
                        }
                    }
                }
            }
        }
        else
        {
            SplitPath, UninstallerPath,, InstalledDir
            SplitPath, InstalledDir,, InstalledDir ; Split once more, since installer was in subdir (v3.0.11 specific)
            IfNotExist, %InstalledDir%
            {
                TestsInfo("Got '" InstalledDir "' from registry and such path does not exist.")
                bContinue := true
            }
            else
            {
                UninstallerPath = %UninstallerPath% /S
                WaitUninstallDone(UninstallerPath, 3)
                if bContinue
                {
                    Process, WaitClose, Au_.exe, 7
                    if ErrorLevel ; The PID still exists
                    {
                        TestsInfo("'Au_.exe' process failed to close.")
                        Process, Close, Au_.exe
                        Process, WaitClose, Au_.exe, 3
                        if ErrorLevel ; The PID still exists
                            TestsFailed("Unable to terminate 'Au_.exe' process.")
                    }
                    else
                    {
                        IfNotExist, %InstalledDir%
                        {
                            TestsInfo("Uninstaller deleted path (registry data): '" InstalledDir "'.")
                            bContinue := true
                        }
                        else
                        {
                            FileRemoveDir, %InstalledDir%, 1 ; Uninstaller leaved the path for us to delete, so, do it
                            if ErrorLevel
                                TestsFailed("Unable to delete existing '" InstalledDir "' ('" MainAppFile "' process is reported as terminated).")
                            else
                            {
                                TestsInfo("Succeeded deleting path (registry data), because uninstaller did not: '" InstalledDir "'.")
                                bContinue := true
                            }
                        }
                    }
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
        TestsInfo("'Extracting' window appeared, waiting for it to close.")
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
        ControlClick, Button2
        if ErrorLevel
            TestsFailed("Unable to click 'Next' button in 'Mozilla Firefox Setup (Welcome to the Mozilla Firefox)' window.")
        else
            TestsOK("'Mozilla Firefox Setup (Welcome to the Mozilla Firefox)' window appeared and 'Next' button was clicked.")
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
        ControlClick, Button2
        if ErrorLevel
            TestsFailed("Unable to click 'Next' button in 'Mozilla Firefox Setup (Setup Type)' window.")
        else
            TestsOK("'Mozilla Firefox Setup (Setup Type)' window appeared and 'Next' button was clicked.")
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
        ControlClick, Button2 ; Click 'Install' button
        if ErrorLevel
            TestsFailed("Unable to click 'Install' button in 'Mozilla Firefox Setup (Summary)' window.")
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
        TestsInfo("'Installing' window appeared, waiting for it to close.")
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
        ControlClick, Button4 ; Uncheck 'Launch Mozilla Firefox now'
        if ErrorLevel
        {
            TestsFailed("Unable to uncheck 'Launch Mozilla Firefox now' in 'Mozilla Firefox Setup (Completing)' window.")
            Process, Close, firefox.exe
        }
        else
        {
            ControlGet, bChecked, Checked,, Button4
            if bChecked = 1
                TestsFailed("'Launch Firefox now' checkbox in 'Mozilla Firefox Setup (Completing)' window reported as unchecked, but further inspection proves that it was still checked.")
            else
            {
                ControlClick, Button2 ; Click 'Finish'
                if ErrorLevel
                    TestsFailed("Unable to click 'Finish' button in 'Mozilla Firefox Setup (Completing)' window.")
                else
                {
                    WinWaitClose,,, 5
                    if ErrorLevel
                        TestsFailed("'Mozilla Firefox Setup (Completing)' window failed to close despite 'Finish' button being clicked.")
                    else
                        TestsOK("'Mozilla Firefox Setup (Completing)' window appeared, 'Launch Firefox now' checkbox unchecked, 'Finish' button clicked, window closed.")
                }
            }
        }
    }
}


; Check if program exists
TestsTotal++
if bContinue
{
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
