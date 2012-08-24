/*
 * Designed for Visual C++ 6 Redistributable
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

ModuleExe = %A_WorkingDir%\Apps\VC6RedistSetup_enu.exe
bContinue := false
TestName = 1.install

TestsFailed := 0
TestsOK := 0
TestsTotal := 0

; Test if Setup file exists, if so, delete installed files, and run Setup
TestsTotal++
IfExist, %ModuleExe%
{
    FileDelete, %A_WinDir%\vcredist.exe
    Run %ModuleExe%
    TestsOK()
}
else
{
    OutputDebug, %TestName%:%A_LineNumber%: Test failed: '%ModuleExe%' not found.`n
    TestsFailed()
}


; Test if can click 'Yes' in 'VCRedist Installation (Please read)' window
TestsTotal++
if bContinue
{
    WinWaitActive, VCRedist Installation, Please read, 10
    if not ErrorLevel
    {
        Sleep, 1000
        ControlClick, Button1, VCRedist Installation, Please read ; Hit 'Yes' button
        if not ErrorLevel
        {
            TestsOK()
            OutputDebug, OK: %TestName%:%A_LineNumber%: 'VCRedist Installation (Please read)' window appeared and 'Yes' button was clicked.`n
        }
        else
        {
            TestsFailed()
            WinGetTitle, title, A
            OutputDebug, %TestName%:%A_LineNumber%: Test failed: Unable to hit 'Yes' button in 'VCRedist Installation (Please read)' window. Active window caption: '%title%'.`n
        }
    }
    else
    {
        TestsFailed()
        WinGetTitle, title, A
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: Window 'VCRedist Installation (Please read)' failed to appear. Active window caption: '%title%'.`n
    }
}


; Test if can click 'OK' in 'VCRedist Installation (Please type)' window
TestsTotal++
if bContinue
{
    WinWaitActive, VCRedist Installation, Please type, 10
    if not ErrorLevel
    {
        ControlSetText, Edit1, %A_WinDir%, VCRedist Installation, Please type
        if not ErrorLevel
        {
            Sleep, 1000
            ControlClick, Button2, VCRedist Installation, Please type ; Hit 'OK' button
            if not ErrorLevel
            {
                TestsOK()
                OutputDebug, OK: %TestName%:%A_LineNumber%: 'VCRedist Installation (Please type)' window appeared and 'OK' button was clicked.`n
            }
            else
            {
                TestsFailed()
                WinGetTitle, title, A
                OutputDebug, %TestName%:%A_LineNumber%: Test failed: Unable to hit 'OK' button in 'VCRedist Installation (Please type)' window. Active window caption: '%title%'.`n
            }
        }
        else
        {
            TestsFailed()
            WinGetTitle, title, A
            OutputDebug, %TestName%:%A_LineNumber%: Test failed: Unable to set path to '%A_WinDir%' in 'VCRedist Installation (Please type)' window. Active window caption: '%title%'.`n
        }
    }
    else
    {
        TestsFailed()
        WinGetTitle, title, A
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: Window 'VCRedist Installation (Please type)' failed to appear. Active window caption: '%title%'.`n
    }
}


; Test if 'VCRedist Installation' window went away
TestsTotal++
if bContinue
{
    WinWaitClose, VCRedist Installation,,10
    if not ErrorLevel
    {
        TestsOK()
        OutputDebug, OK: %TestName%:%A_LineNumber%: 'VCRedist Installation (Please type)' window went away.`n
    }
    else
    {
        TestsFailed()
        WinGetTitle, title, A
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: Window 'VCRedist Installation' failed to close. Active window caption: '%title%'.`n
    }
}

; Check if installed file(s) exist
TestsTotal++
if bContinue
{
    Sleep, 2000
    ProgramFile = %A_WinDir%\system32\mfc42.dll
    IfExist, %ProgramFile%
    {
        TestsOK()
        OutputDebug, OK: %TestName%:%A_LineNumber%: The application has been installed, because '%ProgramFile%' was found.`n
    }
    else
    {
        TestsFailed()
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: Something went wrong, can't find '%ProgramFile%'.`n
    }
}
