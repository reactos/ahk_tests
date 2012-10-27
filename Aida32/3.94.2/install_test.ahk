/*
 * Designed for Aida32 3.94.2
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

ModuleExe = %A_WorkingDir%\Apps\Aida32 3.94.2 Setup.exe
TestName = 1.install

; Test if Setup file exists, if so, delete installed files, and run Setup
TestsTotal++
IfNotExist, %ModuleExe%
    TestsFailed("Can NOT find '" ModuleExe "'.")
else
{
    Process, Close, aida32.exe
    Process, WaitClose, aida32.exe, 4
    if ErrorLevel
        TestsFailed("Process 'aida32.exe' failed to close.")
    else
    {
        Process, Close, aida32.bin
        Process, WaitClose, aida32.bin, 4
        if ErrorLevel
            TestsFailed("Process 'aida32.bin' failed to close.")
        else
        {
            ; Get rid of other versions
            IfNotExist, %A_ProgramFiles%\Aida32
                bContinue := true
            else
            {
                FileRemoveDir, %A_ProgramFiles%\Aida32, 1
                if ErrorLevel
                    TestsFailed("Can NOT delete existing '" A_ProgramFiles "\Aida32'. 'aida32.exe' and 'aida32.bin' processes are terminated.")
                else
                    bContinue := true
            }
        }
    }
    
    if bContinue
    {
        TestsOK("Either there was no previous versions or we succeeded removing it using hardcoded path.")
        Run %ModuleExe%
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
        InstallLocation = %A_ProgramFiles%\Aida32
        ControlSetText, Edit1, %InstallLocation%, 7-Zip self-extracting archive, Extract ; Path
        if ErrorLevel
            TestsFailed("Unable to change path to '" InstallLocation "'.")
        else
        {
            ControlClick, Button2, 7-Zip self-extracting archive, Extract ; Hit 'Extract' button
            if ErrorLevel
                TestsFailed("Unable to hit 'Extract' button in '7-Zip self-extracting archive' window.")
            else
            {
                WinWaitClose, 7-Zip self-extracting archive, Extract, 4
                if ErrorLevel
                    TestsFailed("'7-Zip self-extracting archive' window with 'Extract' button failed to close despite 'Extract' button being clicked.")
                else
                    TestsOK("'7-Zip self-extracting archive' window appeared and 'Extract' button was clicked and window closed.")
            }
        }
    }
}


TestsTotal++
if bContinue
{
    SetTitleMatchMode, 2 ; A window's title can contain WinTitle anywhere inside it to be a match.
    WinWaitActive, Extracting, Cancel, 7
    if ErrorLevel
    {
        ; Sometimes files are extracted so fast that AHK doesn't detect the window
        IfNotExist, %InstallLocation%\aida32.exe
            TestsFailed("'Extracting' window failed to appear (SetTitleMatchMode=" A_TitleMatchMode ") and '" InstallLocation "\aida32.exe' doesnt exist.")
        else
            TestsOK("AHK unabled to detect 'Extracting' window, but '" InstallLocation "\aida32.exe' exist.")
    }
    else
    {
        TestsInfo("'Extracting' window appeared, waiting for it to close.")
        WinWaitClose, Extracting, Cancel, 15
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
    ProgramExe = %A_ProgramFiles%\Aida32\aida32.exe
    IfNotExist, %ProgramExe%
        TestsFailed("Something went wrong, can't find '" ProgramExe "'.")
    else
        TestsOK("The application has been installed, because '" ProgramExe "' was found.")
}
