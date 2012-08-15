/*
 * Designed for K-Meleon 1.5.2
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
TestName = 2.OpenDocument
szDocument =  %A_WorkingDir%\Media\index.html ; Case insensitive

; Test if can open html document using File -> Open and close application
TestsTotal++
WinWaitActive, K-Meleon 1.5.2 (K-Meleon),,7
if not ErrorLevel
{
    SendInput, {ALTDOWN}f{ALTUP} ; WinMenuSelectItem doesn't work with K-Meleon
    Sleep, 1500
    SendInput, o
    Sleep, 1500
    WinWaitActive, Open, Look, 7
    if not ErrorLevel
    {
        ControlSetText, Edit1, %szDocument%, Open, Look
        if not ErrorLevel
        {
            Sleep, 1000
            ControlClick, Button2, Open, Look
            if not ErrorLevel
            {
                WinWaitClose, Open, Look, 7
                if not ErrorLevel
                {
                    WinWaitActive, ReactOS HTML test (K-Meleon),,7
                    if not ErrorLevel
                    {
                        Sleep, 1500
                        SearchImg = %A_WorkingDir%\Media\BookPage29Img.jpg
                        IfExist, %SearchImg%
                        {
                            ImageSearch, FoundX, FoundY, 0, 0, A_ScreenWidth, A_ScreenHeight, *14 %SearchImg%
                            if ErrorLevel = 2
                            {
                                TestsFailed()
                                OutputDebug, %TestName%:%A_LineNumber%: Test failed: Could not conduct the ImageSearch ('%SearchImg%' exist).`n
                            }
                            else if ErrorLevel = 1
                            {
                                TestsFailed()
                                OutputDebug, %TestName%:%A_LineNumber%: Test failed: The search image '%SearchImg%' could NOT be found on the screen.`n
                            }
                            else
                            {
                                WinClose, ReactOS HTML test (K-Meleon)
                                WinWaitClose, ReactOS HTML test (K-Meleon),,7
                                if not ErrorLevel
                                {
                                    TestsOK()
                                    OutputDebug, OK: %TestName%:%A_LineNumber%: Successfully opened '%szDocument%' and closed K-Meleon application.`n
                                }
                                else
                                {
                                    TestsFailed()
                                    WinGetTitle, title, A
                                    OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'ReactOS HTML test (K-Meleon)' window failed to close. Active window caption: '%title%'`n
                                }
                            }
                        }
                        else
                        {
                            TestsFailed()
                            WinGetTitle, title, A
                            OutputDebug, %TestName%:%A_LineNumber%: Test failed: Can NOT find '%SearchImg%'. Active window caption: '%title%'`n
                        }
                    }
                    else
                    {
                        TestsFailed()
                        WinGetTitle, title, A
                        OutputDebug, %TestName%:%A_LineNumber%: Test failed: Window 'ReactOS HTML test (K-Meleon)' failed to appear. Active window caption: '%title%'`n
                    }
                }
                else
                {
                    TestsFailed()
                    WinGetTitle, title, A
                    OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'Open (Look)' window failed to dissapear. Active window caption: '%title%'`n
                }
            }
            else
            {
                TestsFailed()
                WinGetTitle, title, A
                OutputDebug, %TestName%:%A_LineNumber%: Test failed: Unable to hit 'Open' button in 'Open (Look)' window. Active window caption: '%title%'`n
            }
        }
        else
        {
            TestsFailed()
            WinGetTitle, title, A
            OutputDebug, %TestName%:%A_LineNumber%: Test failed: Unable to enter '%szDocument%' in 'Open (Look)' window. Active window caption: '%title%'`n
        }
    }
    else
    {
        TestsFailed()
        WinGetTitle, title, A
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: Window 'Open (Look)' failed to appear, bug 4779?. Active window caption: '%title%'`n
    }
}
else
{
    TestsFailed()
    WinGetTitle, title, A
    OutputDebug, %TestName%:%A_LineNumber%: Test failed: Window 'K-Meleon 1.5.2 (K-Meleon)' failed to appear. Active window caption: '%title%'`n
}