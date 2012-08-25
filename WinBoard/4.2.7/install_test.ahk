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

bContinue := false
TestsFailed := 0
TestsOK := 0
TestsTotal := 0

; Test if Setup file exists, if so, delete installed files, and run Setup
IfExist, %ModuleExe%
{
    ; Installer does not write any uninstall information in registry
    IfExist, %A_ProgramFiles%\WinBoard-4.2.7\UnInstall.exe
    {
        Process, Close, winboard.exe ; Teminate process
        FileDelete, %A_ProgramFiles%\WinBoard-4.2.7\*.ini ; Delete configuration files first or uninstaller will complain
        Sleep, 1500
        RunWait, %A_ProgramFiles%\WinBoard-4.2.7\UnInstall.exe /S ; Silently uninstall it
        Process, Close, A~NSISu_.exe ; In case it still complains
        RegDelete, HKEY_CURRENT_USER, SOFTWARE\WinBoard
        Sleep, 2500
        FileRemoveDir, %A_ProgramFiles%\WinBoard-4.2.7, 1
        Sleep, 1000
        IfExist, %A_ProgramFiles%\WinBoard-4.2.7
        {
            OutputDebug, %TestName%:%A_LineNumber%: Test failed: Previous version detected and failed to delete '%A_ProgramFiles%\WinBoard-4.2.7'.`n
            bContinue := false
        }
        else
            bContinue := true
    }
    else
        bContinue := true ; No previous versions detected.

    if bContinue
        Run %ModuleExe%
}
else
{
    OutputDebug, %TestName%:%A_LineNumber%: Test failed: '%ModuleExe%' not found.`n
    bContinue := false
}


; Test if 'WinBoard - Chessboard For Windows (This wizard)' window appeared, if so, click 'Next' button
TestsTotal++
if bContinue
{
    WinWaitActive, WinBoard - Chessboard For Windows, This wizard, 15
    if not ErrorLevel
    {
        Sleep, 1000
        ControlClick, Button2, WinBoard - Chessboard For Windows, This wizard
        if not ErrorLevel
            TestsOK("'WinBoard - Chessboard For Windows (This wizard)' window appeared and 'Next' button was clicked.")
        else
            TestsFailed("Unable to hit 'Next' button in 'WinBoard - Chessboard For Windows (This wizard)' window.")
    }
    else
        TestsFailed("'WinBoard - Chessboard For Windows (This wizard)' window failed to appear.")
}


; Test if 'WinBoard - Chessboard For Windows (License Agreement)' window appeared, if so, click 'Continue' button
TestsTotal++
if bContinue
{
    WinWaitActive, WinBoard - Chessboard For Windows, License Agreement, 5
    if not ErrorLevel
    {
        Sleep, 700
        ControlClick, Button2, WinBoard - Chessboard For Windows, License Agreement
        if not ErrorLevel
            TestsOK("'WinBoard - Chessboard For Windows (License Agreement)' window appeared and 'Continue' button was clicked.")
        else
            TestsFailed("Unable to hit 'Continue' button in 'WinBoard - Chessboard For Windows (License Agreement)' window.")
    }
    else
        TestsFailed("'WinBoard - Chessboard For Windows (License Agreement)' window failed to appear.")
}


; Test if 'WinBoard - Chessboard For Windows (Choose Components)' window appeared, if so, click 'Next' button
TestsTotal++
if bContinue
{
    WinWaitActive, WinBoard - Chessboard For Windows, Choose Components, 5
    if not ErrorLevel
    {
        Sleep, 700
        ControlClick, Button2, WinBoard - Chessboard For Windows, Choose Components
        if not ErrorLevel
            TestsOK("'WinBoard - Chessboard For Windows (Choose Components)' window appeared and 'Next' button was clicked.")
        else
            TestsFailed("Unable to hit 'Next' button in 'WinBoard - Chessboard For Windows (License Agreement)' window.")
    }
    else
        TestsFailed("'WinBoard - Chessboard For Windows (Choose Components)' window failed to appear.")
}


; Test if 'WinBoard - Chessboard For Windows (Windows File Associations)' window appeared, if so uncheck:
; 1. '.PNG'
; 2. '.FEN'
; and click 'Next' button
TestsTotal++
if bContinue
{
    WinWaitActive, WinBoard - Chessboard For Windows, Windows File Associations, 5
    if not ErrorLevel
    {
        Sleep, 700
        Control, Uncheck, , Button4, WinBoard - Chessboard For Windows, Windows File Associations ; Uncheck '.PNG' checkbox
        if not ErrorLevel
        {
            Control, Uncheck, , Button5, WinBoard - Chessboard For Windows, Windows File Associations ; Uncheck '.FEN' checkbox
            if not ErrorLevel
            {
                Sleep, 700
                ControlClick, Button2, WinBoard - Chessboard For Windows, Windows File Associations
                if not ErrorLevel
                    TestsOK("'WinBoard - Chessboard For Windows (Windows File Associations)' window appeared and 'Next' button was clicked.")
                else
                    TestsFailed("Unable to hit 'Next' button in 'WinBoard - Chessboard For Windows (Windows File Associations)' window.")
            }
            else
                TestsFailed("Unable to uncheck '.FEN' checkbox in 'WinBoard - Chessboard For Windows (Windows File Associations)' window.")
        }
        else
            TestsFailed("Unable to uncheck '.PNG' checkbox in 'WinBoard - Chessboard For Windows (Windows File Associations)' window.")
    }
    else
        TestsFailed("'WinBoard - Chessboard For Windows (Windows File Associations)' window failed to appear.")
}


; Test if 'WinBoard - Chessboard For Windows (Choose Install Location)' window appeared, if so, click 'Next' button
TestsTotal++
if bContinue
{
    WinWaitActive, WinBoard - Chessboard For Windows, Choose Install Location, 5
    if not ErrorLevel
    {
        Sleep, 700
        ControlClick, Button2, WinBoard - Chessboard For Windows, Choose Install Location
        if not ErrorLevel
            TestsOK("'WinBoard - Chessboard For Windows (Choose Install Location)' window appeared and 'Next' button was clicked.")
        else
            TestsFailed("Unable to hit 'Next' button in 'WinBoard - Chessboard For Windows (Choose Install Location)' window.")
    }
    else
        TestsFailed("'WinBoard - Chessboard For Windows (Choose Install Location)' window failed to appear.")
}


; Test if 'WinBoard - Chessboard For Windows (Choose Start Menu Folder)' window appeared, if so, click 'Install' button
TestsTotal++
if bContinue
{
    WinWaitActive, WinBoard - Chessboard For Windows, Choose Start Menu Folder, 5
    if not ErrorLevel
    {
        Sleep, 700
        ControlClick, Button2, WinBoard - Chessboard For Windows, Choose Start Menu Folder
        if not ErrorLevel
            TestsOK("'WinBoard - Chessboard For Windows (Choose Start Menu Folder)' window appeared and 'Install' button was clicked.")
        else
            TestsFailed("Unable to hit 'Install' button in 'WinBoard - Chessboard For Windows (Choose Start Menu Folder)' window.")
    }
    else
        TestsFailed("'WinBoard - Chessboard For Windows (Choose Start Menu Folder)' window failed to appear.")
}


; Test if can get thru 'WinBoard - Chessboard For Windows (Installing)' window
TestsTotal++
if bContinue
{
    WinWaitActive, WinBoard - Chessboard For Windows, Installing, 5
    if not ErrorLevel
    {
        OutputDebug, OK: %TestName%: 'WinBoard - Chessboard For Windows (Installing)' window appeared, waiting for it to close.`n
        WinWaitClose, WinBoard - Chessboard For Windows, Installing, 25
        if not ErrorLevel
            TestsOK("'WinBoard - Chessboard For Windows (Installing)' window went away")
        else
            TestsFailed("'WinBoard - Chessboard For Windows (Installing)' window failed to close.")
    }
    else
        TestsFailed("'WinBoard - Chessboard For Windows (Installing)' window failed to appear.")
}


; Test if 'WinBoard - Chessboard For Windows (Click Finish)' window appeared, if so, click 'Finish' button
TestsTotal++
if bContinue
{
    WinWaitActive, WinBoard - Chessboard For Windows, Click Finish, 5
    if not ErrorLevel
    {
        Sleep, 700
        ControlClick, Button2, WinBoard - Chessboard For Windows, Click Finish
        if not ErrorLevel
            TestsOK("'WinBoard - Chessboard For Windows (Click Finish)' window appeared and 'Finish' button was clicked.")
        else
            TestsFailed("Unable to hit 'Finish' button in 'WinBoard - Chessboard For Windows (Click Finish)' window.")
    }
    else
        TestsFailed("'WinBoard - Chessboard For Windows (Click Finish)' window failed to appear.")
}


; Check if program exists in program files
TestsTotal++
if bContinue
{
    Sleep, 1000
    AppFile = %A_ProgramFiles%\WinBoard-4.2.7\winboard.exe
    IfExist, %AppFile%
        TestsOK("The application has been installed, because '" AppFile "' was found.")
    else
        TestsFailed("Something went wrong, cant find '" AppFile "'.")
}
