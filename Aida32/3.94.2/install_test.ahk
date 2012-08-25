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
bContinue := false
TestName = 1.install

TestsFailed := 0
TestsOK := 0
TestsTotal := 0

; Test if Setup file exists, if so, delete installed files, and run Setup
IfExist, %ModuleExe%
{
    Process, Close, aida32.exe
    ; Get rid of other versions
    IfExist, %A_ProgramFiles%\Aida32
    {
        FileRemoveDir, %A_ProgramFiles%\Aida32, 1
        if not ErrorLevel
            bContinue := true
        else
        {
            OutputDebug, %TestName%:%A_LineNumber%: Test failed: Can NOT delete existing '%A_ProgramFiles%\Aida32'.`n
            bContinue := false
        }
    }
    else
        bContinue := true
    
    if bContinue
        Run %ModuleExe%
}
else
{
    OutputDebug, %TestName%:%A_LineNumber%: Test failed: '%ModuleExe%' not found.`n
    bContinue := false
}


; Test if '7-Zip self-extracting archive' window with 'Extract' button appeared
TestsTotal++
if bContinue
{
    WinWaitActive, 7-Zip self-extracting archive, Extract, 15
    if not ErrorLevel
    {
        Sleep, 250
        ControlSetText, Edit1, %A_ProgramFiles%\Aida32, 7-Zip self-extracting archive, Extract ; Path
        if not ErrorLevel
        {
            ControlClick, Button2, 7-Zip self-extracting archive, Extract ; Hit 'Extract' button
            if not ErrorLevel
                TestsOK("'7-Zip self-extracting archive' window appeared and 'Extract' button was clicked.")
            else
                TestsFailed("Unable to hit 'Extract' button in '7-Zip self-extracting archive' window.")
        }
        else
            TestsFailed("Unable to change 'Edit1' control text to '" A_ProgramFiles "\Aida32'.")
    }
    else
        TestsFailed("'7-Zip self-extracting archive' window with 'Extract' button failed to appear.")
}


TestsTotal++
if bContinue
{
    SetTitleMatchMode, 1
    WinWaitActive, Extracting, Cancel, 10 ; Wait 10 secs for window to appear
    if not ErrorLevel ; Window is found and it is active
    {
        OutputDebug, OK: %TestName%:%A_LineNumber%: 'Extracting' window appeared, waiting for it to close.`n
        WinWaitClose, Extracting, Cancel, 15
        if not ErrorLevel
            TestsOK("'Extracting' window appeared and went away.")
        else
            TestsFailed("'Extracting' window failed to dissapear.")
    }
    else
        TestsFailed("'Extracting' window failed to appear.")
}


; Check if program exist
TestsTotal++
if bContinue
{
    Sleep, 2000
    ProgramDir = %A_ProgramFiles%\Aida32
    IfExist, %ProgramDir%
        TestsOK("The application has been installed, because '" ProgramDir "' was found.")
    else
        TestsFailed("Something went wrong, can't find '" ProgramDir "'.")
}
