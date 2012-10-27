/*
 * Designed for STEAM 1.0
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

ModuleExe = %A_WorkingDir%\Apps\STEAM 1.0 Setup.msi
TestName = 1.install
MainAppFile = Steam.exe ; Mostly this is going to be process we need to look for


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
        bHardcoded := true ; Registry contains no paths
        szDefaultDir = %A_ProgramFiles%\Steam
        IfNotExist, %szDefaultDir%
        {
            TestsInfo("No previous versions detected in hardcoded path: '" szDefaultDir "'.")
            bContinue := true
        }
        else
        {   
            UninstallerPath = %A_WinDir%\System32\MsiExec.exe /X{048298C9-A4D3-490B-9FF9-AB023A9238F3} /norestart /qb-!
            WaitUninstallDone(UninstallerPath, 7)
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

    if bContinue
    {
        RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\MicroSoft\Windows\CurrentVersion\Uninstall\{048298C9-A4D3-490B-9FF9-AB023A9238F3}
        if bHardcoded
            TestsOK("Either there was no previous versions or we succeeded removing it using hardcoded path.")
        else
            TestsOK("Either there was no previous versions or we succeeded removing it using data from registry.")
        Run %ModuleExe%
    }
}



; Test if 'Steam Setup (Welcome)' window can appear
TestsTotal++
if bContinue
{
    iTimeOut := 7
    ProcessExe = msiexec.exe
    while iTimeOut > 0
    {
        Process, Exist, %ProcessExe%
        if ErrorLevel = 0
        {
            TestsFailed("Process '" ProcessExe "' does not exist (iTimeOut=" iTimeOut ").")
            break ; exit the loop
        }
        else
        {
            IfWinNotActive, Steam Setup, Welcome
            {
                WinWaitActive, Steam Setup, Welcome, 1
                iTimeOut--
            }
            else
                break
        }
    }

    WinWaitActive, Steam Setup, Welcome, 1
    if ErrorLevel
        TestsFailed("'Steam Setup (Welcome)' window failed to appear (iTimeOut=" iTimeOut ").")
    else
    {
        ControlClick, Button1 ; Hit 'Next' button
        if ErrorLevel
            TestsFailed("Unable to hit 'Next' button in 'Steam Setup (Welcome)' window.")
        else
        {
            WinWaitClose, Steam Setup, Welcome, 3
            if ErrorLevel
                TestsFailed("'Steam Setup (Welcome)' window failed to close despite 'Next' button being clicked.")
            else
                TestsOK("'Steam Setup (Welcome)' window appeared, 'Next' button clicked and window closed (iTimeOut=" iTimeOut ").")
        }
    }
}


; Test if 'Steam Setup (License Agreement)' window can appear
TestsTotal++
if bContinue
{
    WinWaitActive, Steam Setup, License Agreement, 3
    if ErrorLevel
        TestsFailed("'Steam Setup (License Agreement)' window failed to appear.")
    else
    {
        SendInput, !a ; Check 'I accept' radiobutton
        ControlClick, Button4 ; Hit 'Next' button
        if ErrorLevel
            TestsFailed("Unable to hit 'Next' button in 'Steam Setup (License Agreement)' window.")
        else
            TestsOK("'Steam Setup (License Agreement)' window appeared and 'Next' button was clicked.")
    }
}


; Test if 'Steam Setup (Connection Speed)' window can appear
TestsTotal++
if bContinue
{
    WinWaitActive, Steam Setup, Connection Speed, 3
    if ErrorLevel
        TestsFailed("'Steam Setup (Connection Speed)' window failed to appear.")
    else
    {
        ControlClick, Button1 ; Hit 'Next' button
        if ErrorLevel
            TestsFailed("Unable to hit 'Next' button in 'Steam Setup (Connection Speed)' window.")
        else
            TestsOK("'Steam Setup (Connection Speed)' window appeared and 'Next' button was clicked.")
    }
}


; Test if 'Steam Setup (Select Language)' window can appear
TestsTotal++
if bContinue
{
    WinWaitActive, Steam Setup, Select Language, 3
    if ErrorLevel
        TestsFailed("'Steam Setup (Select Language)' window failed to appear.")
    else
    {
        ControlClick, Button20 ; Hit 'Next' button
        if ErrorLevel
            TestsFailed("Unable to hit 'Next' button in 'Steam Setup (Select Language)' window.")
        else
            TestsOK("'Steam Setup (Select Language)' window appeared and 'Next' button was clicked.")
    }
}


; Test if 'Steam Setup (Destination Folder)' window can appear
TestsTotal++
if bContinue
{
    WinWaitActive, Steam Setup, Destination Folder, 3
    if ErrorLevel
        TestsFailed("'Steam Setup (Destination Folder)' window failed to appear.")
    else
    {
        ControlClick, Button1 ; Hit 'Install' button
        if ErrorLevel
            TestsFailed("Unable to hit 'Install' button in 'Steam Setup (Destination Folder)' window.")
        else
            TestsOK("'Steam Setup (Destination Folder)' window appeared and 'Install' button was clicked.")
    }
}


; Skip 'Steam Setup ()' window


; Test if 'Steam Setup (Steam has been)' window can appear
TestsTotal++
if bContinue
{
    WinWaitActive, Steam Setup, Steam has been, 7 ; We skipped one window
    if ErrorLevel
        TestsFailed("'Steam Setup (Steam has been)' window failed to appear.")
    else
    {
        ControlClick, Button1 ; Hit 'Finish' button
        if ErrorLevel
            TestsFailed("Unable to hit 'Finish' button in 'Steam Setup (Steam has been)' window.")
        else
        {
            WinWaitClose,,,3
            if ErrorLevel
                TestsFailed("'Steam Setup (Steam has been)' window failed to close despite 'Finish' button being clicked")
            else
            {
                Process, wait, %MainAppFile%, 10
                NewPID = %ErrorLevel%  ; Save the value immediately since ErrorLevel is often changed.
                if NewPID = 0
                    TestsFailed("Process '" MainAppFile "' failed to appear.")
                else
                {
                    TestsInfo("'Steam Setup (Steam has been)' window closed, '" MainAppFile "' process appeared.")
                    SetTitleMatchMode, 2 ; A window's title can contain WinTitle anywhere inside it to be a match.
                    WinWaitActive, Steam - Updating,, 5 ; 1st window
                    if ErrorLevel
                        TestsFailed("First 'Steam - Updating' window failed to appear (SetTitleMatchMode=" A_TitleMatchMode ").")
                    else
                    {
                        iTimeOut := 45
                        while iTimeOut > 0
                        {
                            IfWinActive, Steam - Updating
                            {
                                WinWaitClose, Steam - Updating,,1
                                iTimeOut--
                            }
                            else
                                break ; exit the loop if something poped-up
                        }
                        
                        WinWaitClose, Steam - Updating,,1 ; 1st window
                        if ErrorLevel
                            TestsFailed("First 'Steam - Updating' window failed to close (iTimeOut=" iTimeOut ", SetTitleMatchMode=" A_TitleMatchMode ").")
                        else
                        {
                            TestsInfo("First 'Steam - Updating' window closed (iTimeOut=" iTimeOut ", SetTitleMatchMode=" A_TitleMatchMode ").")
                            WinWaitActive, Steam - Updating,, 5 ; 2nd window
                            if ErrorLevel
                                TestsFailed("Second 'Steam - Updating' window failed to appear (SetTitleMatchMode=" A_TitleMatchMode ").")
                            else
                            {
                                iTimeOut := 180
                                while iTimeOut > 0
                                {
                                    IfWinActive, Steam - Updating
                                    {
                                        WinWaitClose, Steam - Updating,,1
                                        iTimeOut--
                                    }
                                    else
                                        break ; exit the loop if something poped-up
                                }
                                
                                WinWaitClose, Steam - Updating,,1 ; 2nd window
                                if ErrorLevel
                                    TestsFailed("Second 'Steam - Updating' window failed to close (iTimeOut=" iTimeOut ", SetTitleMatchMode=" A_TitleMatchMode ").")
                                else
                                {
                                    TestsInfo("Second 'Steam - Updating' window closed (iTimeOut=" iTimeOut ", SetTitleMatchMode=" A_TitleMatchMode ").")
                                    SetTitleMatchMode, 3 ; A window's title must exactly match WinTitle to be a match.
                                    WinWaitActive, Steam,,7
                                    if ErrorLevel
                                        TestsFailed("'Steam' window failed to appear (SetTitleMatchMode=" A_TitleMatchMode ").")
                                    else
                                    {
                                        Process, Close, %MainAppFile%
                                        Process, WaitClose, %MainAppFile%, 7
                                        if ErrorLevel
                                            TestsFailed("Unable to terminate '" MainAppFile "' process.")
                                        else
                                            TestsOK("Done. Steam is up to date. Successfully terminated '" MainAppFile "' process.")
                                    }
                                }
                            }
                        }
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
    IfNotExist, %szDefaultDir%\%MainAppFile%
        TestsFailed("Something went wrong, can't find '" szDefaultDir "\" MainAppFile "'.")
    else
        TestsOK("The application has been installed, because '" szDefaultDir "\" MainAppFile "' was found.")
}


; Terminate MainAppFile process in case of failure
if not bContinue
{
    Process, Close, %MainAppFile%
    Process, WaitClose, %MainAppFile%, 3
    if ErrorLevel
        TestsInfo("Unable to terminate '" MainAppFile "' process.")
    else
        TestsInfo("Successfully terminated '" MainAppFile "' process.")
}
