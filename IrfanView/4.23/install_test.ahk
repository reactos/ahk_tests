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
TestName = 1.install
MainAppFile = i_view32.exe ; Mostly this is going to be process we need to look for

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
        RegRead, UninstallerPath, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\IrfanView, UninstallString
        if ErrorLevel
        {
            ; There was a problem (such as a nonexistent key or value). 
            ; That probably means we have not installed this app before.
            ; Check in default directory to be extra sure
            bHardcoded := true ; To know if we got path from registry or not
            szDefaultDir = %A_ProgramFiles%\IrfanView
            IfNotExist, %szDefaultDir%
            {
                TestsInfo("No previous versions detected in hardcoded path: '" szDefaultDir "'.")
                bContinue := true
            }
            else
            {   
                UninstallerPath = %szDefaultDir%\iv_uninstall.exe /silent
                WaitUninstallDone(UninstallerPath, 3)
                if bContinue
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
        else
        {
            UninstallerPath := ExeFilePathNoParam(UninstallerPath)
            SplitPath, UninstallerPath,, InstalledDir
            IfNotExist, %InstalledDir%
            {
                TestsInfo("Got '" InstalledDir "' from registry and such path does not exist.")
                bContinue := true
            }
            else
            {
                UninstallerPath = %UninstallerPath% /silent
                WaitUninstallDone(UninstallerPath, 3)
                if bContinue
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

    if bContinue
    {
        RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\MicroSoft\Windows\CurrentVersion\Uninstall\IrfanView
        IfExist, %A_AppData%\IrfanView
        {
            FileRemoveDir, %A_AppData%\IrfanView, 1
            if ErrorLevel
                TestsFailed("Unable to delete '" A_AppData "\IrfanView'.")
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


; Check if required MFC42.DLL is installed (Win2k3 SP2 comes with it already)
TestsTotal++
if bContinue
{
    mfc42 = %A_WinDir%\System32\mfc42.dll
    IfNotExist, %mfc42%
    {
        IfNotExist, %A_WorkingDir%\mfc42.dll
            TestsFailed("Neither '" mfc42 "' nor '" A_WorkingDir "\mfc42.dll can be found'.")
        else
        {
            FileCopy, %A_WorkingDir%\mfc42.dll, %mfc42%
            if ErrorLevel
                TestsFailed("Unable to copy '" %A_WorkingDir% "\mfc42.dll' to '" mfc42 "'.")
            else
                TestsOK("Had to copy '" %A_WorkingDir% "\mfc42.dll' to '" mfc42 "'.")
        }
    }
    else
        TestsOK("'" mfc42 "' already exist.")
}


; Test if 'Welcome' window appeared
TestsTotal++
if bContinue
{
    DetectHiddenText, Off ; Hidden text is not detected
    WinWaitActive, IrfanView Setup, Welcome, 7
    if ErrorLevel
        TestsFailed("'IrfanView Setup (Welcome)' window failed to appear.")
    else
    {
        ControlClick, Button11 ; Hit 'Next' button
        if ErrorLevel
            TestsFailed("Unable to hit 'Next' button in 'IrfanView Setup (Welcome)' window.")
        else
        {
            WinWaitClose, IrfanView Setup, Welcome, 7
            if ErrorLevel
                TestsFailed("'IrfanView Setup (Welcome)' window failed to close despite 'Next' button being clicked.")
            else
                TestsOK("'IrfanView Setup (Welcome)' window appeared, 'Next' button clicked and window closed.")
        }
    }
}


; Test if 'What's new' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, IrfanView Setup, What's new, 3
    if ErrorLevel
        TestsFailed("'IrfanView Setup (What's new)' window failed to appear.")
    else
    {
        ControlClick, Button11 ; Hit 'Next' button
        if ErrorLevel
            TestsFailed("Unable to hit 'Next' button in 'IrfanView Setup (What's new)' window.")
        else
            TestsOK("'IrfanView Setup (What's new)' window appeared and 'Next' button was clicked.")
    }
}


; Test if 'Do you want to associate' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, IrfanView Setup, Do you want to associate, 3
    if ErrorLevel
        TestsFailed("'IrfanView Setup (Do you want to associate)' window failed to appear.")
    else
    {
        ControlClick, Button1 ; Hit 'Images only' button
        if ErrorLevel
            TestsFailed("Unable to hit 'Images only' button in 'IrfanView Setup (Do you want to associate)' window.")
        else
        {
            ControlClick, Button16 ; Hit 'Next' button
            if ErrorLevel
                TestsFailed("Unable to hit 'Next' button in 'IrfanView Setup (Do you want to associate)' window.")
            else
                TestsOK("'IrfanView Setup (Do you want to associate)' window appeared, 'Images only' and 'Next' buttons were clicked.")
        }
    }
}


; Test if 'Google Desktop Search' window appeared (different results in WinXP and Win2k3)
TestsTotal++
if bContinue
{
    WinWaitActive, IrfanView Setup, Google Desktop Search, 3
    if ErrorLevel
        TestsFailed("'IrfanView Setup (Google Desktop Search)' window failed to appear.")
    else
    {
        ControlGetText, OutputVar, Button1
        if OutputVar <> &Install Google Desktop Search ; We are in XP system
        {
            Control, Uncheck,, Button1 ; Uncheck 'Google Toolbar for Internet Explorer'
            if ErrorLevel
                TestsFailed("Unable to uncheck 'Google Toolbar for Internet Explorer' in 'IrfanView Setup (Google Desktop Search)' window.")
            else
            {
                Control, Uncheck,, Button2 ; Uncheck 'Google Desktop Search'
                if ErrorLevel
                    TestsFailed("Unable to uncheck 'Google Desktop Search' in 'IrfanView Setup (Google Desktop Search)' window.")
                else
                {
                    ControlClick, Button18 ; Hit 'Next' button
                    if ErrorLevel
                        TestsFailed("Unable to hit 'Next' button in 'IrfanView Setup (Google Desktop Search)' window.")
                    else
                        TestsOK("'IrfanView Setup (Google Desktop Search)' window appeared, 'Google Toolbar', 'Google Desktop Search' checkboxes were unchecked, 'Next' was clicked (XP OS).")
                }
            }
        }
        else
        {
            ; We are in win2k3 system
            Control, Check,, Button2 ; Check 'Dont install Google Desktop Search'
            if ErrorLevel
                TestsFailed("Unable to check 'Dont install Google Desktop Search' in 'IrfanView Setup (Google Desktop Search)' window.")
            else
            {
                ControlClick, Button18 ; Hit 'Next' button
                if ErrorLevel
                    TestsFailed("Unable to hit 'Next' button in 'IrfanView Setup (Google Desktop Search)' window.")
                else
                    TestsOK("'IrfanView Setup (Google Desktop Search)' window appeared, 'Google Toolbar', 'Google Desktop Search' checkboxes were unchecked, 'Next' was clicked (win2k3 OS).")
            }
        }
    }
}


; Test if 'Ready to install' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, IrfanView Setup, Ready to install, 3
    if ErrorLevel
        TestsFailed("'IrfanView Setup (Ready to install)' window failed to appear.")
    else
    {
        Control, Check,, Button2 ; Check 'Users Application Data folder'
        if ErrorLevel
            TestsFailed("Unable to check 'Users Application Data folder' in 'IrfanView Setup (Ready to install)' window.")
        else
        {
            ControlClick, Button23 ; Hit 'Next' button
            if ErrorLevel
                TestsFailed("Unable to hit 'Next' button in 'IrfanView Setup (Ready to install)' window.")
            else
                TestsOK("'IrfanView Setup (Ready to install)' window appeared and 'Next' button was clicked.")
        }
    }
}


; Test if 'You want to change' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, IrfanView Setup, You want to change, 3
    if ErrorLevel
        TestsFailed("'IrfanView Setup (You want to change)' window failed to appear.")
    else
    {
        ControlClick, Button1 ; Hit 'Yes' button
        if ErrorLevel
            TestsFailed("Unable to hit 'Yes' button in 'IrfanView Setup (You want to change)' window.")
        else
            TestsOK("'IrfanView Setup (You want to change)' window appeared and 'Yes' was clicked.")
    }
}


; Test if 'Installation successfull' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, IrfanView Setup, Installation successfull, 3
    if ErrorLevel
        TestsFailed("'IrfanView Setup (Installation successfull)' window failed to appear.")
    else
    {
        Control, Uncheck,, Button2 ; Uncheck 'Start IrfanView'
        if ErrorLevel
            TestsFailed("Unable to uncheck 'Start IrfanView' in 'IrfanView Setup (Installation successfull)' window.")
        else
        {
            ControlGet, bChecked, Checked, Button2, IrfanView Setup, Installation successfull ; Need all params or it will fail
            if bChecked = 1
                TestsFailed("'Start IrfanView' checkbox reported as unchecked in 'IrfanView Setup (Installation successfull)' window, but further inspection proves that it was still checked.")
            else
            {
                ControlClick, Button27 ; Hit 'Done' button
                if ErrorLevel
                    TestsFailed("Unable to hit 'Done' button in 'IrfanView Setup (Installation successfull)' window.")
                else
                {
                    WinWaitClose,,, 20 ; It loads browser, so, need more to sleep
                    if ErrorLevel
                        ; Window will close only when it detects default browser process running (or something like that)
                        TestsFailed("'IrfanView Setup (Installation successfull)' window failed to close despite the 'Done' button being reported as clicked .")
                    else
                    {
                        if not TerminateDefaultBrowser(10)
                            TestsFailed("Either default browser process failed to appear of we failed to terminate it.")
                        else
                            TestsOK("'IrfanView Setup (Installation successfull)' window appeared, 'Start IrfanView' checkbox unchecked, 'Done' button clicked, browser process terminated and window closed.")
                    }
                }
            }
        }
    }
}


; Check if program exists
TestsTotal++
if bContinue
{
    ; No need to sleep, because we already waited for process to appear
    RegRead, UninstallerPath, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\IrfanView, UninstallString
    if ErrorLevel
        TestsFailed("Either we can't read from registry or data doesn't exist.")
    else
    {
        UninstallerPath := ExeFilePathNoParam(UninstallerPath)
        SplitPath, UninstallerPath,, InstalledDir
        IfNotExist, %InstalledDir%\%MainAppFile%
            TestsFailed("Something went wrong, can't find '" InstalledDir "\" MainAppFile "'.")
        else
            TestsOK("The application has been installed, because '" InstalledDir "\" MainAppFile "' was found.")
    }
}
