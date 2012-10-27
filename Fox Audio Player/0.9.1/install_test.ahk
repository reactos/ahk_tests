/*
 * Designed for Fox Audio Player 0.9.1
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

ModuleExe = %A_WorkingDir%\Apps\Fox Audio Player 0.9.1 Setup.exe
TestName = 1.install
MainAppFile = fap.exe

; Test if Setup file exists, if so, delete installed files, and run Setup
TestsTotal++
IfNotExist, %ModuleExe%
    TestsFailed("Can NOT find '" ModuleExe "'")
else
{
    Process, Close, %MainAppFile%
    Process, WaitClose, %MainAppFile%, 4
    if ErrorLevel
        TestsFailed("Process '" MainAppFile "' failed to close.")
    else
    {
        InstallLocation = %A_ProgramFiles%\Fox Audio Player
        RegDelete, HKEY_CURRENT_USER, Software\DrFiemost
        IfNotExist, %InstallLocation%
            bContinue := true ; No previous versions detected.
        else
        {
            FileRemoveDir, %InstallLocation%, 1
            if ErrorLevel
                TestsFailed("Previous version detected and failed to delete '" InstallLocation "'. '" MainAppFile "' process not detected.")
            else
                bContinue := true
        }
        
        if bContinue
        {
            TestsOK("Either there was no previous versions or we succeeded removing it using hardcoded path.")
            Run %ModuleExe%
        }
    }
}


; Test if '7-Zip self-extracting archive' window with 'Extract' button appeared
TestsTotal++
if bContinue
{
    WinWaitActive, 7-Zip self-extracting archive, Extract, 7
    if ErrorLevel
        TestsFailed("'7-Zip self-extracting archive' window with 'Extract' button failed to appear.")
    else
    {
        ControlSetText, Edit1, %InstallLocation%, 7-Zip self-extracting archive, Extract ; Path
        if ErrorLevel
            TestsFailed("Unable to change 'Edit1' control text to '" InstallLocation "'.")
        else
        {
            ControlClick, Button2, 7-Zip self-extracting archive, Extract ; Hit 'Extract' button
            if ErrorLevel
                TestsFailed("Unable to click 'Extract' in '7-Zip self-extracting archive' window.")
            else
            {
                WinWaitClose, 7-Zip self-extracting archive, Extract, 3
                if ErrorLevel
                    TestsFailed("'7-Zip self-extracting archive' window failed to close despite 'Extract' button being clicked.")
                else
                    TestsOK("'7-Zip self-extracting archive' window appeared, 'Extract' button clicked, window closed.")
            }
        }
    }
}


TestsTotal++
if bContinue
{
    SetTitleMatchMode, 2 ; A window's title can contain WinTitle anywhere inside it to be a match.
    WinWaitActive, Extracting, Cancel, 3
    if ErrorLevel
    {
        ; Sometimes files are extracted so fast that AHK doesn't detect the window
        IfNotExist, %InstallLocation%\fap-0.9.1-win32-bin\%MainAppFile%
            TestsFailed("'Extracting' window failed to appear (SetTitleMatchMode=" A_TitleMatchMode ") and '" InstallLocation "\fap-0.9.1-win32-bin\" MainAppFile "' doesnt exist.")
        else
            TestsOK("AHK unabled to detect 'Extracting' window, but '" InstallLocation "\fap-0.9.1-win32-bin\" MainAppFile "' exist.")
    }
    else
    {
        TestsInfo("'Extracting' window appeared, waiting for it to close.")
        WinWaitClose, Extracting, Cancel, 5
        if ErrorLevel
            TestsFailed("'Extracting' window failed to close.")
        else
            TestsOK("'Extracting' window went away.")
    }
}


; Check if program exist
TestsTotal++
if bContinue
{
    IfExist, %InstallLocation%\fap-0.9.1-win32-bin\%MainAppFile%
        TestsOK("The application has been installed, because '" InstallLocation "\fap-0.9.1-win32-bin\" MainAppFile "' was found.")
    else
        TestsFailed("Something went wrong, can't find '" InstallLocation "\fap-0.9.1-win32-bin\" MainAppFile "'.")
}
