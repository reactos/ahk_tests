/*
 * Designed for mIRC 6.35
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
TestName = 2.ChatTest

; Test if can type some text in chat window (IRC channel) and exit application correctly
TestsTotal++
WinWaitActive, mIRC,,7
if not ErrorLevel
{
    TimeOut := 0
    ControlGet, OutputVar, Visible,, Static2, mIRC ; Wait until chat window appears
    while OutputVar <> 1
    {
        ControlGet, OutputVar, Visible,, Static2, mIRC
        TimeOut++
        Sleep, 1000
        bContinue := true
        if TimeOut > 35
        {
            TestsFailed()
            OutputDebug, %TestName%:%A_LineNumber%: Test failed: Timed out.`n
            Process, Close, mirc.exe
            Sleep, 1500
            Break ; exit loop
        }
    }
    
    if bContinue
    {
        Sleep, 1500
        ControlSetText, RichEdit20A1, I confirm that mIRC 6.35 is working on ReactOS, mIRC
        if not ErrorLevel
        {
            SendInput, {ENTER} ; Send text to IRC channel
            WinClose, mIRC
            WinWaitActive, Confirm Exit, Are you sure,7
            if not ErrorLevel
            {
                ControlClick, Button1, Confirm Exit, Are you sure ; Hit 'Yes' button
                if not ErrorLevel
                {
                    WinWaitClose, mIRC,,7
                    if not ErrorLevel
                    {
                        TestsOK()
                        OutputDebug, %TestName%:%A_LineNumber%: OK: Connected to IRC server, entered some text in channel and closed application successfully.`n
                    }
                    else
                    {
                        TestsFailed()
                        WinGetTitle, title, A
                        OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'mIRC' window failed to disappear after exit was confirmed. Active window caption: '%title%'`n
                    }
                }
                else
                {
                    TestsFailed()
                    WinGetTitle, title, A
                    OutputDebug, %TestName%:%A_LineNumber%: Test failed: Unable to hit 'Yes' button in 'Confirm Exit (Are you sure)' window. Active window caption: '%title%'`n
                }
            }
            else
            {
                TestsFailed()
                WinGetTitle, title, A
                OutputDebug, %TestName%:%A_LineNumber%: Test failed: Window 'Confirm Exit (Are you sure)' failed to appear. Active window caption: '%title%'`n
            }
        }
        else
        {
            TestsFailed()
            WinGetTitle, title, A
            OutputDebug, %TestName%:%A_LineNumber%: Test failed: Unable to set chat text in 'mIRC' window. Active window caption: '%title%'`n
        }
    }
}
else
{
    TestsFailed()
    WinGetTitle, title, A
    OutputDebug, %TestName%:%A_LineNumber%: Test failed: Window 'mIRC' failed to appear. Active window caption: '%title%'`n
}
