/*
 * Designed for VLC 0.8.6i Setup
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

ModuleExe = %A_WorkingDir%\Apps\VLC 0.8.6i Setup.exe
TestName = 1.install
MainAppFile = vlc.exe ; Mostly this is going to be process we need to look for

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
        RegRead, UninstallerPath, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\VLC media player, UninstallString
        if ErrorLevel
        {
            ; There was a problem (such as a nonexistent key or value). 
            ; That probably means we have not installed this app before.
            ; Check in default directory to be extra sure
            bHardcoded := true ; To know if we got path from registry or not
            szDefaultDir = %A_ProgramFiles%\VideoLAN
            IfNotExist, %szDefaultDir%
            {
                TestsInfo("No previous versions detected in hardcoded path: '" szDefaultDir "'.")
                bContinue := true
            }
            else
            {   
                UninstallerPath = %szDefaultDir%\VLC\uninstall.exe /S
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
                UninstallerPath = %UninstallerPath% /S
                WaitUninstallDone(UninstallerPath, 3)  ; Child process 'Au_.exe'
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
        RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\VideoLAN
        RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\MicroSoft\Windows\CurrentVersion\Uninstall\VLC media player
        IfExist, %A_AppData%\vlc
        {
            FileRemoveDir, %A_AppData%\vlc, 1
            if ErrorLevel
                TestsFailed("Unable to delete '" A_AppData "\vlc'.")
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


; Test if 'Installer Language' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, Installer Language, Please select, 7
    if ErrorLevel
        TestsFailed("'Installer Language (Please select)' window failed to appear.")
    else
    {
        ControlClick, Button1, Installer Language, Please select
        if ErrorLevel
            TestsFailed("Unable to hit 'OK' in 'Installer Language (Please select)' window.")
        else
        {
            WinWaitClose, Installer Language, Please select, 3
            if ErrorLevel
                TestsFailed("'Installer Language (Please select)' window failed to close.")
            else
                TestsOK("'Installer Language (Please select)' window appeared, 'OK' button clicked and window closed.")
        }
    }
}


; Test if 'Welcome' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, VideoLAN VLC media player 0.8.6i Setup, Welcome, 7
    if ErrorLevel
        TestsFailed("'VideoLAN VLC media player 0.8.6i Setup (Welcome)' window failed to appear.")
    else
    {
        ControlClick, Button2, VideoLAN VLC media player 0.8.6i Setup, Welcome ; Hit 'Next' button
        if ErrorLevel
            TestsFailed("Unable to hit 'Next' button in 'VideoLAN VLC media player 0.8.6i Setup (Welcome)' window.")
        else
        {
            WinWaitClose, VideoLAN VLC media player 0.8.6i Setup, Welcome, 3
            if ErrorLevel
                TestsFailed("'VideoLAN VLC media player 0.8.6i Setup (Welcome)' window failed to close.")
            else
                TestsOK("'VideoLAN VLC media player 0.8.6i Setup (Welcome)' window appeared, 'Next' button clicked and window closed.")
        }
    }
}


; Test if 'License Agreement' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, VideoLAN VLC media player 0.8.6i Setup, License Agreement, 3
    if ErrorLevel
        TestsFailed("'VideoLAN VLC media player 0.8.6i Setup (License Agreement)' window failed to appear.")
    else
    {
        ControlClick, Button2, VideoLAN VLC media player 0.8.6i Setup, License Agreement ; Hit 'I Agree' button
        if ErrorLevel
            TestsFailed("Unable to hit 'I Agree' button in 'VideoLAN VLC media player 0.8.6i Setup (License Agreement)' window.")
        else
            TestsOK("'VideoLAN VLC media player 0.8.6i Setup (License Agreement)' window appeared and 'I Agree' button was clicked.")
    }
}


; Test if 'Choose Components' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, VideoLAN VLC media player 0.8.6i Setup, Choose Components, 3
    if ErrorLevel
        TestsFailed("'VideoLAN VLC media player 0.8.6i Setup (Choose Components)' window failed to appear.")
    else
    {
        ControlClick, Button2, VideoLAN VLC media player 0.8.6i Setup, Choose Components ; Hit 'Next' button
        if ErrorLevel
            TestsFailed("Unable to hit 'Next' button in 'VideoLAN VLC media player 0.8.6i Setup (Choose Components)' window.")
        else
            TestsOK("'VideoLAN VLC media player 0.8.6i Setup (Choose Components)' window appeared and 'Next' was clicked.")
    }
}


; Test if 'Choose Install Location' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, VideoLAN VLC media player 0.8.6i Setup, Choose Install Location, 3
    if ErrorLevel
        TestsFailed("'VideoLAN VLC media player 0.8.6i Setup (Choose Install Location)' window failed to appear.")
    else
    {
        ControlClick, Button2, VideoLAN VLC media player 0.8.6i Setup, Choose Install Location ; Hit 'Install' button
        if ErrorLevel
            TestsFailed("Unable to hit 'Install' button in 'VideoLAN VLC media player 0.8.6i Setup (Choose Install Location)' window.")
        else
            TestsOK("'VideoLAN VLC media player 0.8.6i Setup (Choose Install Location)' window appeared and 'Install' was clicked.")
    }
}


; Test if can get trhu 'Installing' window
TestsTotal++
if bContinue
{
    WinWaitActive, VideoLAN VLC media player 0.8.6i Setup, Installing, 3
    if ErrorLevel
        TestsFailed("'VideoLAN VLC media player 0.8.6i Setup (Installing)' window failed to appear.")
    else
    {
        TestsInfo("'VideoLAN VLC media player 0.8.6i Setup (Installing)' window appeared, waiting for it to close.")
        WinWaitClose, VideoLAN VLC media player 0.8.6i Setup, Installing, 40
        if ErrorLevel
            TestsFailed("'VideoLAN VLC media player 0.8.6i Setup (Installing)' window failed to close.")
        else
            TestsOK("'VideoLAN VLC media player 0.8.6i Setup (Installing)' window went away.")
    }
}


; Test if 'Completing' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, VideoLAN VLC media player 0.8.6i Setup, Completing, 3
    if ErrorLevel
        TestsFailed("'VideoLAN VLC media player 0.8.6i Setup (Completing)' window failed to appear.")
    else
    {
        Control, Uncheck,,Button4, VideoLAN VLC media player 0.8.6i Setup
        if ErrorLevel
            TestsFailed("Unable to uncheck 'Run VLC' checkbox in 'VideoLAN VLC media player 0.8.6i Setup (Completing)' window.")
        else
        {
            ControlGet, bChecked, Checked,, Button4
            if bChecked = 1
                TestsFailed("'Run VLC' checkbox in 'VideoLAN VLC media player 0.8.6i Setup (Completing)' window reported as unchecked, but further inspection proves that it was still checked.")
            else
            {
                ControlClick, Button2, VideoLAN VLC media player 0.8.6i Setup, Completing ; Hit 'Finish' button
                if ErrorLevel
                    TestsFailed("Unable to hit 'Finish' button in 'VideoLAN VLC media player 0.8.6i Setup (Completing)' window.")
                else
                    TestsOK("'VideoLAN VLC media player 0.8.6i Setup (Completing)' window appeared, 'Run VLC' were unchecked for sure and 'Finish' was clicked.")
            }
        }
    }
}


; Check if program exists
TestsTotal++
if bContinue
{
    RegRead, UninstallerPath, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\VLC media player, UninstallString
    if ErrorLevel
        TestsFailed("Either we can't read from registry or data doesn't exist.")
    else
    {
        SplitPath, UninstallerPath,, InstalledDir
        IfNotExist, %InstalledDir%\%MainAppFile%
            TestsFailed("Something went wrong, can't find '" InstalledDir "\" MainAppFile "'.")
        else
            TestsOK("The application has been installed, because '" InstalledDir "\" MainAppFile "' was found.")
    }
}
