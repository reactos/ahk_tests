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
            IfNotExist, %A_ProgramFiles%\IrfanView
                bContinue := true ; No previous versions detected in hardcoded path
            else
            {
                IfExist, %A_ProgramFiles%\IrfanView\iv_uninstall.exe
                {
                    RunWait, %A_ProgramFiles%\IrfanView\iv_uninstall.exe /silent ; Silently uninstall it
                    Sleep, 7000
                }

                IfNotExist, %A_ProgramFiles%\IrfanView ; Uninstaller might delete the dir
                    bContinue := true
                {
                    FileRemoveDir, %A_ProgramFiles%\IrfanView, 1
                    if ErrorLevel
                        TestsFailed("Unable to delete hardcoded path '" A_ProgramFiles "\IrfanView' ('" MainAppFile "' process is reported as terminated).'")
                    else
                        bContinue := true
                }
            }
        }
        else
        {
            StringReplace, UninstallerPath, UninstallerPath, `",, All ; Remove quotes in case some version quotes the path
            SplitPath, UninstallerPath,, InstalledDir
            IfNotExist, %InstalledDir%
                bContinue := true
            else
            {
                IfExist, %UninstallerPath%
                {
                    RunWait, %UninstallerPath% /silent ; Silently uninstall it
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
    WinWaitActive, IrfanView Setup, Welcome, 7
    if ErrorLevel
        TestsFailed("'IrfanView Setup (Welcome)' window failed to appear.")
    else
    {
        Sleep, 700
        ControlClick, Button11, IrfanView Setup, Welcome ; Hit 'Next' button
        if ErrorLevel
            TestsFailed("Unable to hit 'Next' button in 'IrfanView Setup (Welcome)' window.")
        else
        {
            WinWaitClose, IrfanView Setup, Welcome, 5
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
    WinWaitActive, IrfanView Setup, What's new, 7
    if ErrorLevel
        TestsFailed("'IrfanView Setup (What's new)' window failed to appear.")
    else
    {
        Sleep, 700
        ControlClick, Button11, IrfanView Setup, What's new ; Hit 'Next' button
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
    WinWaitActive, IrfanView Setup, Do you want to associate, 7
    if ErrorLevel
        TestsFailed("'IrfanView Setup (Do you want to associate)' window failed to appear.")
    else
    {
        Sleep, 700
        ControlClick, Button1, IrfanView Setup, Do you want to associate ; Hit 'Images only' button
        if ErrorLevel
            TestsFailed("Unable to hit 'Images only' button in 'IrfanView Setup (Do you want to associate)' window.")
        else
        {
            Sleep, 500
            ControlClick, Button16, IrfanView Setup, Do you want to associate ; Hit 'Next' button
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
    WinWaitActive, IrfanView Setup, Google Desktop Search, 7
    if ErrorLevel
        TestsFailed("'IrfanView Setup (Google Desktop Search)' window failed to appear.")
    else
    {
        Sleep, 700
        ControlGetText, OutputVar, Button1, IrfanView Setup
        if OutputVar <> &Install Google Desktop Search ; We are in XP system
        {
            Control, Uncheck,, Button1, IrfanView Setup, Google Desktop Search ; Uncheck 'Google Toolbar for Internet Explorer'
            if ErrorLevel
                TestsFailed("Unable to uncheck 'Google Toolbar for Internet Explorer' in 'IrfanView Setup (Google Desktop Search)' window.")
            else
            {
                Control, Uncheck,, Button2, IrfanView Setup, Google Desktop Search ; Uncheck 'Google Desktop Search'
                if ErrorLevel
                    TestsFailed("Unable to uncheck 'Google Desktop Search' in 'IrfanView Setup (Google Desktop Search)' window.")
                else
                {
                    Sleep, 700
                    ControlClick, Button18, IrfanView Setup, Google Desktop Search ; Hit 'Next' button
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
            Control, Check,, Button2, IrfanView Setup, Google Desktop Search ; Check 'Dont install Google Desktop Search'
            if ErrorLevel
                TestsFailed("Unable to check 'Dont install Google Desktop Search' in 'IrfanView Setup (Google Desktop Search)' window.")
            else
            {
                Sleep, 700
                ControlClick, Button18, IrfanView Setup, Google Desktop Search ; Hit 'Next' button
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
    WinWaitActive, IrfanView Setup, Ready to install, 7
    if ErrorLevel
        TestsFailed("'IrfanView Setup (Ready to install)' window failed to appear.")
    else
    {
        Sleep, 700
        Control, Check,, Button2, IrfanView Setup, Ready to install ; Check 'Users Application Data folder'
        if ErrorLevel
            TestsFailed("Unable to check 'Users Application Data folder' in 'IrfanView Setup (Ready to install)' window.")
        else
        {
            Sleep, 700
            ControlClick, Button23, IrfanView Setup, Ready to install ; Hit 'Next' button
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
    WinWaitActive, IrfanView Setup, You want to change, 7
    if ErrorLevel
        TestsFailed("'IrfanView Setup (You want to change)' window failed to appear.")
    else
    {
        Sleep, 700
        ControlClick, Button1, IrfanView Setup, You want to change ; Hit 'Yes' button
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
    WinWaitActive, IrfanView Setup, Installation successfull, 7
    if ErrorLevel
        TestsFailed("'IrfanView Setup (Installation successfull)' window failed to appear.")
    else
    {
        Sleep, 700
        Control, Uncheck,, Button2, IrfanView Setup, Installation successfull ; Uncheck 'Start IrfanView'
        if ErrorLevel
            TestsFailed("Unable to uncheck 'Start IrfanView' in 'IrfanView Setup (Installation successfull)' window.")
        else
        {
            Sleep, 700
            ControlClick, Button27, IrfanView Setup, Installation successfull ; Hit 'Done' button
            if ErrorLevel
                TestsFailed("Unable to hit 'Done' button in 'IrfanView Setup (Installation successfull)' window.")
            else
            {
                WinWaitClose, IrfanView Setup, Installation successfull, 20
                if ErrorLevel
                    TestsFailed("'IrfanView Setup (Installation successfull)' window failed to close despite the 'Done' button being reported as clicked .")
                else
                {
                    Process, Close, firefox.exe ; Terminate those until code to terminate default browser is written
                    Process, Close, iexplore.exe
                    Process, Close, Opera.exe
                        
                    Process, Wait, %MainAppFile%, 4
                    NewPID = %ErrorLevel%  ; Save the value immediately since ErrorLevel is often changed.
                    if NewPID <> 0
                        TestsFailed("'" MainAppFile "' process appeared despite 'Start Irfanview' checkbox being unchecked.")
                    else
                        TestsOK("'IrfanView Setup (Installation successfull)' window appeared, 'Start IrfanView' unchecked and 'Done' was clicked. FIXME: terminate browser process.")
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
        StringReplace, UninstallerPath, UninstallerPath, `",, All
        SplitPath, UninstallerPath,, InstalledDir
        IfNotExist, %InstalledDir%\%MainAppFile%
            TestsFailed("Something went wrong, can't find '" InstalledDir "\" MainAppFile "'.")
        else
            TestsOK("The application has been installed, because '" InstalledDir "\" MainAppFile "' was found.")
    }
}
