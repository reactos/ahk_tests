/*
 * Designed for Samba-TNG 0.5-RC1
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

ModuleExe = %A_WorkingDir%\Apps\Samba-TNG_0.5-RC1_Setup.exe
bContinue := false
TestName = 1.install

TestsFailed := 0
TestsOK := 0
TestsTotal := 0

; Test if Setup file exists, if so, delete installed files, and run Setup
IfExist, %ModuleExe%
{
    ; Get rid of other versions
    IfExist, C:\ReactOS\Samba-TNG
    {
        FileRemoveDir, C:\ReactOS\Samba-TNG, 1
        if not ErrorLevel
        {
            bContinue := true
        }
        else
        {
            OutputDebug, %TestName%:%A_LineNumber%: Test failed: Can NOT delete existing 'C:\ReactOS\Samba-TNG'.`n
            bContinue := false
        }
    }
    else
    {
        bContinue := true
    }
    
    if bContinue
    {
        Run %ModuleExe%
    }
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
        ControlSetText, Edit1, C:\ReactOS, 7-Zip self-extracting archive, Extract ; Path
        if not ErrorLevel
        {
            ControlClick, Button2, 7-Zip self-extracting archive, Extract ; Hit 'Extract' button
            if not ErrorLevel
            {
                TestsOK()
                OutputDebug, OK: %TestName%:%A_LineNumber%: '7-Zip self-extracting archive' window appeared and 'Extract' was clicked.`n
            }
            else
            {
                TestsFailed()
                WinGetTitle, title, A
                OutputDebug, %TestName%:%A_LineNumber%: Test failed: Unable to click 'Extract' in '7-Zip self-extracting archive' window. Active window caption: '%title%'.`n
            }
        }
        else
        {
            TestsFailed()
            WinGetTitle, title, A
            OutputDebug, %TestName%:%A_LineNumber%: Test failed: Unable to change 'Edit1' control text to 'C:\ReactOS'. Active window caption: '%title%'.`n
        }
    }
    else
    {
        TestsFailed()
        WinGetTitle, title, A
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: '7-Zip self-extracting archive' window with 'Extract' button failed to appear. Active window caption: '%title%'.`n
    }
}


TestsTotal++
if bContinue
{
    SetTitleMatchMode, 1
    WinWaitActive, Extracting, Cancel, 10 ; Wait 10 secs for window to appear
    if not ErrorLevel ;Window is found and it is active
    {
        OutputDebug, OK: %TestName%:%A_LineNumber%: 'Extracting' window appeared, waiting for it to close.`n
        WinWaitClose, Extracting, Cancel, 15
        if not ErrorLevel
        {
            
            TestsOK()
            OutputDebug, OK: %TestName%:%A_LineNumber%: 'Extracting' window appeared and went away.`n
        }
        else
        {
            TestsFailed()
            WinGetTitle, title, A
            OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'Extracting' window failed to dissapear. Active window caption: '%title%'.`n
        }
    }
    else
    {
        TestsFailed()
        WinGetTitle, title, A
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'Extracting' window failed to appear. Active window caption: '%title%'.`n
    }
}


;Check if program exist
TestsTotal++
if bContinue
{
    Sleep, 2000
    ProgramDir = C:\ReactOS\Samba-TNG
    IfExist, %ProgramDir%
    {
        TestsOK()
        OutputDebug, OK: %TestName%:%A_LineNumber%: The application has been installed, because '%ProgramDir%' was found.`n
    }
    else
    {
        TestsFailed()
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: Something went wrong, can't find '%ProgramDir%'.`n
    }
}
