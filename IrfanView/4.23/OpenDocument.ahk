/*
 * Designed for Foxit IrfanView 4.23
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

bContinue := false
TestsTotal := 0
TestsSkipped := 0
TestsFailed := 0
TestsOK := 0
TestsExecuted := 0
TestName = 2.GoToPage
szDocument =  %A_WorkingDir%\Media\BookPage29Img.jpg ; Case sensitive!

; Test if can open picture using File -> Open dialog and close application successfully
TestsTotal++
RunApplication("")
SplitPath, szDocument, NameExt
WinWaitActive, IrfanView,,7
if not ErrorLevel
{
    IfExist, %szDocument%
    {
        WinMenuSelectItem, IrfanView, , File, Open
        if not ErrorLevel
        {
            WinWaitActive, Open, Look &in,7
            if not ErrorLevel
            {
                Sleep, 1500
                ControlSetText, Edit1, %szDocument%, Open, Look &in
                if not ErrorLevel
                {
                    Sleep, 1500
                    ControlClick, Button2, Open, Look &in
                    if not ErrorLevel
                    {
                        Sleep, 1500
                        WinWaitActive, %NameExt% - IrfanView,,7
                        if not ErrorLevel
                        {
                            ImageSearch, FoundX, FoundY, 0, 0, A_ScreenWidth, A_ScreenHeight, *14 %szDocument%
                            if ErrorLevel = 2
                            {
                                TestsFailed()
                                OutputDebug, %TestName%:%A_LineNumber%: Test failed: Could not conduct the ImageSearch ('%szDocument%' exist).`n
                            }
                            else if ErrorLevel = 1
                            {
                                TestsFailed()
                                OutputDebug, %TestName%:%A_LineNumber%: Test failed: The search image '%szDocument%' could NOT be found on the screen. Color depth not 32bit?.`n
                            }
                            else
                            {
                                WinClose, %NameExt% - IrfanView
                                WinWaitClose, %NameExt% - IrfanView,,7
                                if not ErrorLevel
                                {
                                    TestsOK()
                                    OutputDebug, OK: %TestName%:%A_LineNumber%: Opened '%szDocument%' using 'File -> Open' and closed application successfully.`n
                                }
                                else
                                {
                                    TestsFailed()
                                    WinGetTitle, title, A
                                    OutputDebug, %TestName%:%A_LineNumber%: Test failed: Unable to close '%NameExt% - IrfanView' window. Active window caption: '%title%'`n
                                }
                            }
                        }
                        else
                        {
                            TestsFailed()
                            WinGetTitle, title, A
                            OutputDebug, %TestName%:%A_LineNumber%: Test failed: Window '%NameExt% - IrfanView' failed to appear. Active window caption: '%title%'`n
                        }
                    }
                    else
                    {
                        TestsFailed()
                        WinGetTitle, title, A
                        OutputDebug, %TestName%:%A_LineNumber%: Test failed: Unable to click 'Open' button in 'Open (Look in)' window. Active window caption: '%title%'`n
                    }
                }
                else
                {
                    TestsFailed()
                    WinGetTitle, title, A
                    OutputDebug, %TestName%:%A_LineNumber%: Test failed: Unable to change 'File name' control text to '%szDocument%' in 'Open (Look in)' window, bug 7089?. Active window caption: '%title%'`n
                }
            }
            else
            {
                TestsFailed()
                WinGetTitle, title, A
                OutputDebug, %TestName%:%A_LineNumber%: Test failed: Window 'Open (Look in)' failed to appear. Active window caption: '%title%'`n
            }
        }
        else
        {
            TestsFailed()
            WinGetTitle, title, A
            OutputDebug, %TestName%:%A_LineNumber%: Test failed: Unable to hit 'File -> Open' in 'IrfanView' window. Active window caption: '%title%'`n
        }
    }
    else
    {
        TestsFailed()
        WinGetTitle, title, A
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: File '%szDocument%' was NOT found. Active window caption: '%title%'`n
    }
}
else
{
    TestsFailed()
    WinGetTitle, title, A
    OutputDebug, %TestName%:%A_LineNumber%: Test failed: Window 'IrfanView' failed to appear. Active window caption: '%title%'`n
}
