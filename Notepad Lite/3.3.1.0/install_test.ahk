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
        IfNotExist, %A_ProgramFiles%\Notepad Lite
            bContinue := true
        {
            FileRemoveDir, %A_ProgramFiles%\Notepad Lite, 1
            if ErrorLevel
                TestsFailed("Unable to delete existing '" A_ProgramFiles "\Notepad Lite' ('" MainAppFile "' process is reported as terminated).'")
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
    WinWaitActive, 7-Zip self-extracting archive, Extract, 15
    if ErrorLevel
        TestsFailed("'7-Zip self-extracting archive' window with 'Extract' button failed to appear.")
    else
    {
        Sleep, 250
        ControlSetText, Edit1, %A_ProgramFiles%\Notepad Lite, 7-Zip self-extracting archive, Extract ; Path
        if ErrorLevel
            TestsFailed("Unable to change path to '" A_ProgramFiles "\Notepad Lite'.")
        else
        {
            Sleep, 700
            ControlClick, Button2, 7-Zip self-extracting archive, Extract ; Hit 'Extract' button
            if ErrorLevel
                TestsFailed("Unable to click 'Extract' in '7-Zip self-extracting archive' window.")
            else
            {
                WinWaitClose, 7-Zip self-extracting archive, Extract, 5
                if ErrorLevel
                    TestsFailed("'7-Zip self-extracting archive' window failed to close despite 'Extract' button being clicked.")
                else
                    TestsOK("'7-Zip self-extracting archive' window appeared, path changed and 'Extract' was clicked.")
            }
        }
    }
}


TestsTotal++
if bContinue
{
    SetTitleMatchMode, 2 ; A window's title can contain WinTitle anywhere inside it to be a match.
    WinWaitActive, Extracting, Cancel, 7
    if ErrorLevel ; Window is found and it is active
        TestsFailed("'Extracting' window failed to appear.")
    else
    {
        OutputDebug, OK: %TestName%:%A_LineNumber%: 'Extracting' window appeared, waiting for it to close.`n
        WinWaitClose, Extracting, Cancel, 10
        if ErrorLevel
            TestsFailed("'Extracting' window failed to dissapear.")
        else
            TestsOK("'Extracting' window appeared and went away.")
    }      
}


; Check if program exist
TestsTotal++
if bContinue
{
    Sleep, 2000
    ProgramFile = %A_ProgramFiles%\Notepad Lite\%MainAppFile%
    IfExist, %ProgramFile%
        TestsOK("The application has been installed, because '" ProgramFile "' was found.")
    else
        TestsFailed("Something went wrong, can't find '" ProgramFile "'.")
}
