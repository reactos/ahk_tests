/*
 * Designed for VLC Media Player 2.0.3
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

ModuleExe = %A_WorkingDir%\Apps\VLC_Media_Player_2.0.3_Setup.exe
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
        szDefaultDir = %A_ProgramFiles%\VideoLAN ; Do not move this line
        RegRead, UninstallerPath, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\VLC media player, UninstallString
        if ErrorLevel
        {
            ; There was a problem (such as a nonexistent key or value). 
            ; That probably means we have not installed this app before.
            ; Check in default directory to be extra sure
            bHardcoded := true ; To know if we got path from registry or not
            IfNotExist, %szDefaultDir%
            {
                TestsInfo("No previous versions detected in hardcoded path: '" szDefaultDir "'.")
                bContinue := true
            }
            else
            {   
                UninstallerPath = %szDefaultDir%\uninstall.exe /S
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
                WaitUninstallDone(UninstallerPath, 3) ; Reported child name is 'Au_.exe'
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


; Test if can start setup
TestsTotal++
if bContinue
{
    WinWaitActive, Installer Language, Please select a language, 7
    if ErrorLevel
        TestsFailed("'Installer Language (Please select a language)' window failed to appear.")
    else
    {
        SendInput, {ENTER}
        WinWaitClose, Installer Language, Please select a language, 3
        if ErrorLevel
            TestsFailed("Failed to hit 'OK' button in 'Installer Language (Please select a language)' window.")
        else
            TestsOK("'Installer Language (Please select a language)' window appeared, 'OK' button clicked, window closed.")
    }
}


; Test if 'VLC media player 2.0.3 Setup' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, VLC media player 2.0.3 Setup, Welcome to the VLC, 7
    if ErrorLevel
        TestsFailed("'VLC media player 2.0.3 Setup (Welcome to the VLC)' failed to appear.")
    else
    {
        SendInput, !n ; Hit 'Next' button
        TestsOK("'VLC media player 2.0.3 Setup (Welcome to the VLC)' window appeared and Alt+N was sent.")
    }
}


; Test if 'License Agreement' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, VLC media player 2.0.3 Setup, License Agreement, 3
    if ErrorLevel
        TestsFailed("'VLC media player 2.0.3 Setup (License Agreement)' window failed to appear.")
    else
    {
        SendInput, !n ; Hit 'Next' button
        TestsOK("'VLC media player 2.0.3 Setup (License Agreement)' window appeared and Alt+N was sent.")
    }
}


; Test if 'Choose Components' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, VLC media player 2.0.3 Setup, Choose Components, 3
    if ErrorLevel
        TestsFailed("'VLC media player 2.0.3 Setup (Choose Components)' window failed to appear.")
    else
    {
        SendInput, !n ; Hit 'Next' button
        TestsOK("'VLC media player 2.0.3 Setup (Choose Components)' window appeared and Alt+N was sent.")
    }
}


; Test if 'Choose Install Location' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, VLC media player 2.0.3 Setup, Choose Install Location, 3
    if ErrorLevel
        TestsFailed("'VLC media player 2.0.3 Setup (Choose Install Location)' window failed to appear.")
    else
    {
        SendInput, !i ; Hit 'Install' button
        TestsOK("'VLC media player 2.0.3 Setup (Choose Install Location)' window appeared and Alt+I was sent.")
    }
}


; Test if 'Installing' window can popup and go away
TestsTotal++
if bContinue
{
    WinWaitActive, VLC media player 2.0.3 Setup, Installing, 3
    if ErrorLevel
        TestsFailed("'VLC media player 2.0.3 Setup (Installing)' failed to appear.")
    else
    {
        TestsInfo("'VLC media player 2.0.3 Setup (Installing)' appeared, waiting for it to dissapear.")
        
        iTimeOut := 150
        while iTimeOut > 0
        {
            IfWinActive, VLC media player 2.0.3 Setup, Installing
            {
                WinWaitClose, VLC media player 2.0.3 Setup, Installing, 1
                iTimeOut--
            }
            else
            {
                ; Command line window pops out
                szCmdPopupWnd = %szDefaultDir%\VLC\vlc-cache-gen.exe
                IfWinActive, %szCmdPopupWnd%
                {
                    WinWaitClose, %szCmdPopupWnd%,,5
                    if ErrorLevel
                        break ; Window failed to close for some time
                }
                else
                    break ; Something else poped out
            }
        }

        WinWaitClose, VLC media player 2.0.3 Setup, Installing, 1
        if ErrorLevel
            TestsFailed("'VLC media player 2.0.3 Setup (Installing)' window failed to close (iTimeOut=" iTimeOut ").")
        else
            TestsOK("'VLC media player 2.0.3 Setup (Installing)' window went away (iTimeOut=" iTimeOut ").")
    }
}


; Test if 'Completing' window appeared
TestsTotal++
if bContinue
{
    WinWaitActive, VLC media player 2.0.3 Setup, Completing, 3
    if ErrorLevel
        TestsFailed("'VLC media player 2.0.3 Setup (Completing)' window failed to appear.")
    else
    {
        SendInput, !r ; Uncheck 'Run VLC'
        ControlGet, bChecked, Checked, Button4, VLC media player 2.0.3 Setup, Completing
        if bChecked = 1
            TestsFailed("'Run VLC' checkbox should be unchecked because Alt+R was sent, but further inspection proves that it was still checked.")
        else
        {
            Sleep, 20 ; FIXME: sleep delay added because of CORE-6737
            SendInput, !f ; Hit 'Finish' button
            WinWaitClose, VLC media player 2.0.3 Setup, Completing, 3
            if ErrorLevel
                TestsFailed("'VLC media player 2.0.3 Setup (Completing)' window failed to close.")
            else
                TestsOK("'Run VLC' checkbox unchecked in 'VLC media player 2.0.3 Setup (Completing)' window and the window closed.")
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