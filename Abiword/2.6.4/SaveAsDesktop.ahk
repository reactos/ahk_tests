/*
 * Designed for AbiWord 2.6.4
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
TestName = 2.SaveAsDesktop

; Test if can properly save document to desktop
TestsTotal++
RunApplication("")
WinWaitActive, Untitled1 - AbiWord,,5
if not ErrorLevel
{
    SendInput, AbiWord %TestName% test by Edijus
    WinWaitActive, *Untitled1 - AbiWord,,5
    if not ErrorLevel
    {
        WinClose, *Untitled1 - AbiWord
        WinWaitActive, AbiWord, Save changes, 5
        if not ErrorLevel
        {
            ControlGetText, OutputVar, Static2, AbiWord ; Get control text
            if not ErrorLevel
            {
                ControlText = Save changes to document Untitled1 before closing? ; 
                if OutputVar = %ControlText% ; Check if text matches
                {
                    ControlClick, Button1, AbiWord, Save changes ; Click 'Yes' button
                    if not ErrorLevel
                    {
                        WinWaitActive, Save File As,, 7
                        if not ErrorLevel
                        {
                            FileDelete, %A_Desktop%\AbiWordTest.txt
                            Sleep, 1500
                            ControlSetText, Edit1, %A_Desktop%\AbiWordTest.txt, Save File As
                            if not ErrorLevel
                            {
                                ControlClick, Button2, Save File As ; Click 'Save' button
                                if not ErrorLevel
                                {
                                    WinWaitClose, *Untitled1 - AbiWord,,5
                                    if not ErrorLevel
                                    {
                                        IfExist, %A_Desktop%\AbiWordTest.txt
                                        {
                                            FileReadLine, OutputVar, %A_Desktop%\AbiWordTest.txt, 1 ; Read first line
                                            if not ErrorLevel
                                            {
                                                TestText = <?xml version="1.0" encoding="UTF-8"?> ; This is what you get
                                                if OutputVar = %TestText% ; Check if text matches
                                                {
                                                    TestsOK()
                                                }
                                                else
                                                {
                                                    TestsFailed()
                                                    WinGetTitle, title, A
                                                    OutputDebug, %TestName%:%A_LineNumber%: Test failed: Text is not the same (is '%OutputVar%', should be '%TestText%'). Active window caption: '%title%'`n
                                                }
                                            }
                                            else
                                            {
                                                TestsFailed()
                                                WinGetTitle, title, A
                                                OutputDebug, %TestName%:%A_LineNumber%: Test failed: Unable to read '%A_Desktop%\AbiWordTest.txt'. Active window caption: '%title%'`n
                                            }
                                        }
                                        else
                                        {
                                            TestsFailed()
                                            WinGetTitle, title, A
                                            OutputDebug, %TestName%:%A_LineNumber%: Test failed: '%A_Desktop%\AbiWordTest.txt' does NOT exist, but it should. Active window caption: '%title%'`n
                                        }
                                    }
                                    else
                                    {
                                        TestsFailed()
                                        WinGetTitle, title, A
                                        OutputDebug, %TestName%:%A_LineNumber%: Test failed: '*Untitled1 - AbiWord' window failed to close. Active window caption: '%title%'`n
                                    }
                                }
                                else
                                {
                                    TestsFailed()
                                    WinGetTitle, title, A
                                    OutputDebug, %TestName%:%A_LineNumber%: Test failed: Unable to hit 'Save' button in 'Save File As' window. Active window caption: '%title%'`n
                                }
                            }
                            else
                            {
                                TestsFailed()
                                WinGetTitle, title, A
                                OutputDebug, %TestName%:%A_LineNumber%: Test failed: Unable to change Edit1 control text to '%A_Desktop%\AbiWordTest.txt' in 'Save File As' window. Active window caption: '%title%'`n
                            }
                        }
                        else
                        {
                            TestsFailed()
                            WinGetTitle, title, A
                            OutputDebug, %TestName%:%A_LineNumber%: Test failed: Window 'Save File As' failed to appear. Active window caption: '%title%'`n
                        }
                    }
                    else
                    {
                        TestsFailed()
                        WinGetTitle, title, A
                        OutputDebug, %TestName%:%A_LineNumber%: Test failed: Unable to hit 'Yes' in 'AbiWord (Save changes)' window. Active window caption: '%title%'`n
                    }
                }
                else
                {
                    TestsFailed()
                    WinGetTitle, title, A
                    OutputDebug, %TestName%:%A_LineNumber%: Test failed: Control text is not the same as expected in 'AbiWord (Save changes)' window (is '%OutputVar%', should be '%ControlText%', bug 6035). Active window caption: '%title%'`n
                }
            }
            else
            {
                TestsFailed()
                WinGetTitle, title, A
                OutputDebug, %TestName%:%A_LineNumber%: Test failed: Unable to get Static2 control text of 'AbiWord (Save changes)' window. Active window caption: '%title%'`n
            }
        }
        else
        {
            TestsFailed()
            WinGetTitle, title, A
            OutputDebug, %TestName%:%A_LineNumber%: Test failed: Window 'AbiWord (Save changes)' failed to appear. Active window caption: '%title%'`n
        }
    }
    else
    {
        TestsFailed()
        WinGetTitle, title, A
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: Window '*Untitled1 - AbiWord' failed to appear. Active window caption: '%title%'`n
    }
}
else
{
    TestsFailed()
    WinGetTitle, title, A
    OutputDebug, %TestName%:%A_LineNumber%: Test failed: Window 'Untitled1 - AbiWord' failed to appear. Active window caption: '%title%'`n
}

Process, Close, AbiWord.exe