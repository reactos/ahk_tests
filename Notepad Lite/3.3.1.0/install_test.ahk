/*
 * Designed for Notepad Lite 3.3.1.0
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

ModuleExe = %A_WorkingDir%\Apps\Notepad Lite 3.3.1.0 Setup.exe
TestName = 1.install
MainAppFile = gsnote3.exe ; Mostly this is going to be process we need to look for

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
        InstallLocation = %A_ProgramFiles%\Notepad Lite
        IfNotExist, %InstallLocation%
            bContinue := true
        else
        {
            FileRemoveDir, %InstallLocation%, 1
            if ErrorLevel
                TestsFailed("Unable to delete existing '" InstallLocation "' ('" MainAppFile "' process is reported as terminated).'")
            else
                bContinue := true
        }

        if bContinue
        {
            RegDelete, HKEY_CURRENT_USER, SOFTWARE\GridinSoft\Notepad3 ; Delete saved settings
            TestsOK("Either there was no previous versions or we succeeded removing it using hardcoded path.")
            Run %ModuleExe%
        }
    }
}


; Test if '7-Zip self-extracting archive' window with 'Extract' button appeared
TestsTotal++
if bContinue
{
    WinWaitActive, 7-Zip self-extracting archive, Extract, 5
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
        IfNotExist, %InstallLocation%\%MainAppFile%
            TestsFailed("'Extracting' window failed to appear (SetTitleMatchMode=2) and '" InstallLocation "\" MainAppFile "' doesnt exist.")
        else
            TestsOK("AHK unabled to detect 'Extracting' window, but '" InstallLocation "\" MainAppFile "' exist.")
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
    IfExist, %InstallLocation%\%MainAppFile%
        TestsOK("The application has been installed, because '" InstallLocation "\" MainAppFile "' was found.")
    else
        TestsFailed("Something went wrong, can't find '" InstallLocation "\" MainAppFile "'.")
}
