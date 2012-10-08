/*
 * Designed for WinBoard 4.2.7
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

ModuleExe = %A_WorkingDir%\Apps\WinBoard 4.2.7 Setup.exe
TestName = 1.install
MainAppFile = winboard.exe ; Mostly this is going to be process we need to look for

; Test if Setup file exists, if so, delete installed files, and run Setup
IfNotExist, %ModuleExe%
    TestsFailed("Can NOT find '" ModuleExe "'.")
else
{
    Process, Close, GNUChess.exe ; Teminate process
    Process, Close, %MainAppFile% ; Teminate process
    Process, WaitClose, %MainAppFile%, 5
    if ErrorLevel ; The PID still exists
        TestsFailed("Can NOT terminate '" MainAppFile "' process.")
    else
    {
        ; Installer does not write any uninstall information in registry
        IfNotExist, %A_ProgramFiles%\WinBoard-4.2.7
            bContinue := true
        else
        {
            IfExist, %A_ProgramFiles%\WinBoard-4.2.7\UnInstall.exe
            {
                FileDelete, %A_ProgramFiles%\WinBoard-4.2.7\*.ini ; Delete configuration files first or uninstaller will complain
                UninstallerPath = %A_ProgramFiles%\WinBoard-4.2.7\UnInstall.exe /S 
                WaitUninstallDone(UninstallerPath, 3) ; Reported child name is 'A~NSISu_.exe'. We will have to terminate it.
                if bContinue
                {
                    IfNotExist, %A_ProgramFiles%\WinBoard-4.2.7
                        bContinue := true ; Uninstaller deleted the dir
                    else
                    {
                        FileRemoveDir, %A_ProgramFiles%\WinBoard-4.2.7, 1
                        if ErrorLevel
                            TestsFailed("Unable to delete hardcoded path '" A_ProgramFiles "\WinBoard-4.2.7' ('" MainAppFile "' process is reported as terminated).'")
                        else
                            bContinue := true
                    }
                }
            }
        }

        RegDelete, HKEY_CURRENT_USER, SOFTWARE\WinBoard
        if bContinue
            Run %ModuleExe%
    }
}


; Test if 'WinBoard - Chessboard For Windows (This wizard)' window appeared, if so, click 'Next' button
TestsTotal++
if bContinue
{
    WinWaitActive, WinBoard - Chessboard For Windows, This wizard, 7
    if ErrorLevel
        TestsFailed("'WinBoard - Chessboard For Windows (This wizard)' window failed to appear.")
    else
    {
        ControlClick, Button2, WinBoard - Chessboard For Windows, This wizard
        if ErrorLevel
            TestsFailed("Unable to hit 'Next' button in 'WinBoard - Chessboard For Windows (This wizard)' window.")
        else
            TestsOK("'WinBoard - Chessboard For Windows (This wizard)' window appeared and 'Next' button was clicked.")
    }
}


; Test if 'WinBoard - Chessboard For Windows (License Agreement)' window appeared, if so, click 'Continue' button
TestsTotal++
if bContinue
{
    WinWaitActive, WinBoard - Chessboard For Windows, License Agreement, 3
    if ErrorLevel
        TestsFailed("'WinBoard - Chessboard For Windows (License Agreement)' window failed to appear.")
    else
    {
        ControlClick, Button2, WinBoard - Chessboard For Windows, License Agreement
        if ErrorLevel
            TestsFailed("Unable to hit 'Continue' button in 'WinBoard - Chessboard For Windows (License Agreement)' window.")
        else
            TestsOK("'WinBoard - Chessboard For Windows (License Agreement)' window appeared and 'Continue' button was clicked.")
    }
}


; Test if 'WinBoard - Chessboard For Windows (Choose Components)' window appeared, if so, click 'Next' button
TestsTotal++
if bContinue
{
    WinWaitActive, WinBoard - Chessboard For Windows, Choose Components, 3
    if ErrorLevel
        TestsFailed("'WinBoard - Chessboard For Windows (Choose Components)' window failed to appear.")
    else
    {
        ControlClick, Button2, WinBoard - Chessboard For Windows, Choose Components
        if ErrorLevel
            TestsFailed("Unable to hit 'Next' button in 'WinBoard - Chessboard For Windows (License Agreement)' window.")
        else
            TestsOK("'WinBoard - Chessboard For Windows (Choose Components)' window appeared and 'Next' button was clicked.")
    }
}


; Test if 'WinBoard - Chessboard For Windows (Windows File Associations)' window appeared, if so uncheck:
; 1. '.PNG'
; 2. '.FEN'
; and click 'Next' button
TestsTotal++
if bContinue
{
    WinWaitActive, WinBoard - Chessboard For Windows, Windows File Associations, 3
    if ErrorLevel
        TestsFailed("'WinBoard - Chessboard For Windows (Windows File Associations)' window failed to appear.")
    else
    {
        Control, Uncheck, , Button4, WinBoard - Chessboard For Windows, Windows File Associations ; Uncheck '.PNG' checkbox
        if ErrorLevel
            TestsFailed("Unable to uncheck '.PNG' checkbox in 'WinBoard - Chessboard For Windows (Windows File Associations)' window.")
        else
        {
            Control, Uncheck, , Button5, WinBoard - Chessboard For Windows, Windows File Associations ; Uncheck '.FEN' checkbox
            if ErrorLevel
                TestsFailed("Unable to uncheck '.FEN' checkbox in 'WinBoard - Chessboard For Windows (Windows File Associations)' window.")
            else
            {
                ControlClick, Button2, WinBoard - Chessboard For Windows, Windows File Associations
                if ErrorLevel
                    TestsFailed("Unable to hit 'Next' button in 'WinBoard - Chessboard For Windows (Windows File Associations)' window.")
                else
                    TestsOK("'WinBoard - Chessboard For Windows (Windows File Associations)' window appeared and 'Next' button was clicked.")
            }
        }
    }
}


; Test if 'WinBoard - Chessboard For Windows (Choose Install Location)' window appeared, if so, click 'Next' button
TestsTotal++
if bContinue
{
    WinWaitActive, WinBoard - Chessboard For Windows, Choose Install Location, 3
    if ErrorLevel
        TestsFailed("'WinBoard - Chessboard For Windows (Choose Install Location)' window failed to appear.")
    else
    {
        ControlClick, Button2, WinBoard - Chessboard For Windows, Choose Install Location
        if ErrorLevel
            TestsFailed("Unable to hit 'Next' button in 'WinBoard - Chessboard For Windows (Choose Install Location)' window.")
        else
            TestsOK("'WinBoard - Chessboard For Windows (Choose Install Location)' window appeared and 'Next' button was clicked.")
    }
}


; Test if 'WinBoard - Chessboard For Windows (Choose Start Menu Folder)' window appeared, if so, click 'Install' button
TestsTotal++
if bContinue
{
    WinWaitActive, WinBoard - Chessboard For Windows, Choose Start Menu Folder, 3
    if ErrorLevel
        TestsFailed("'WinBoard - Chessboard For Windows (Choose Start Menu Folder)' window failed to appear.")
    else
    {
        ControlClick, Button2, WinBoard - Chessboard For Windows, Choose Start Menu Folder
        if ErrorLevel
            TestsFailed("Unable to hit 'Install' button in 'WinBoard - Chessboard For Windows (Choose Start Menu Folder)' window.")
        else
            TestsOK("'WinBoard - Chessboard For Windows (Choose Start Menu Folder)' window appeared and 'Install' button was clicked.")
    }
}


; Test if can get thru 'WinBoard - Chessboard For Windows (Installing)' window
TestsTotal++
if bContinue
{
    WinWaitActive, WinBoard - Chessboard For Windows, Installing, 3
    if ErrorLevel
        TestsFailed("'WinBoard - Chessboard For Windows (Installing)' window failed to appear.")
    else
    {
        TestsInfo("'WinBoard - Chessboard For Windows (Installing)' window appeared, waiting for it to close.")
        
        iTimeOut := 25
        while iTimeOut > 0
        {
            IfWinActive, WinBoard - Chessboard For Windows, Installing
            {
                WinWaitClose, WinBoard - Chessboard For Windows, Installing, 1
                iTimeOut--
            }
            else
                break ; exit the loop if something poped-up
        }

        WinWaitClose, WinBoard - Chessboard For Windows, Installing, 1
        if ErrorLevel
            TestsFailed("'WinBoard - Chessboard For Windows (Installing)' window failed to close (iTimeOut=" iTimeOut ").")
        else
            TestsOK("'WinBoard - Chessboard For Windows (Installing)' window went away (iTimeOut=" iTimeOut ").")
    }
}


; Test if 'WinBoard - Chessboard For Windows (Click Finish)' window appeared, if so, click 'Finish' button
TestsTotal++
if bContinue
{
    WinWaitActive, WinBoard - Chessboard For Windows, Click Finish, 3
    if ErrorLevel
        TestsFailed("'WinBoard - Chessboard For Windows (Click Finish)' window failed to appear.")
    else
    {
        ControlClick, Button2, WinBoard - Chessboard For Windows, Click Finish
        if ErrorLevel
            TestsFailed("Unable to hit 'Finish' button in 'WinBoard - Chessboard For Windows (Click Finish)' window.")
        else
            TestsOK("'WinBoard - Chessboard For Windows (Click Finish)' window appeared and 'Finish' button was clicked.")
    }
}


; Check if program exists in program files
TestsTotal++
if bContinue
{
    AppFile = %A_ProgramFiles%\WinBoard-4.2.7\%MainAppFile%
    IfExist, %AppFile%
        TestsOK("The application has been installed, because '" AppFile "' was found.")
    else
        TestsFailed("Something went wrong, cant find '" AppFile "'.")
}
