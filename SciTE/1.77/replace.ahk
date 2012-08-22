/*
 * Designed for SciTE 1.77
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

TestName = 2.replace
szDocument =  %A_WinDir%\TextFile.dat ; Case sensitive!

; Test if can open document, replace some text, save it and exit SciTE.
TestsTotal++
FileDelete, %szDocument%
FileAppend, My name is Egijs Kolesnikovics, %szDocument%
if not ErrorLevel
{
    RunApplication(szDocument)
    SplitPath, szDocument, NameExt
    if bContinue
    {
        IfWinActive, %NameExt% - SciTE
        {
            WinMenuSelectItem, %NameExt% - SciTE, , Search, Replace
            if not ErrorLevel
            {
                WinWaitActive, Replace, Fi&nd what, 5
                if not ErrorLevel
                {
                    Sleep, 1000
                    ControlSetText, Edit1, Egijs, Replace, Fi&nd what
                    if not ErrorLevel
                    {
                        Sleep, 1000
                        ControlSetText, Edit2, Edijs, Replace, Fi&nd what
                        if not ErrorLevel
                        {
                            Sleep, 500
                            ControlClick, Button8, Replace, Fi&nd what
                            if not ErrorLevel
                            {
                                Sleep, 1000
                                ControlGetText, OutputVar, Static4, Replace, Fi&nd what
                                if not ErrorLevel
                                {
                                    if OutputVar = 1
                                    {
                                        WinClose, Replace, Fi&nd what
                                        WinWaitClose, Replace, Fi&nd what, 5
                                        if not ErrorLevel
                                        {
                                            Sleep, 1000
                                            WinWaitActive, %NameExt% * SciTE,,5
                                            if not ErrorLevel
                                            {
                                                SendInput, {CTRLDOWN}s{CTRLUP} ; Save document
                                                WinWaitActive, %NameExt% - SciTE,,5
                                                if not ErrorLevel
                                                {
                                                    WinClose, %NameExt% - SciTE
                                                    WinWaitClose, %NameExt% - SciTE,,5
                                                    if not ErrorLevel
                                                    {
                                                        TestsOK()
                                                        OutputDebug, OK: %TestName%:%A_LineNumber%: Opened document, replaced some text, saved and closed ScITE successfully.`n
                                                    }
                                                    else
                                                    {
                                                        TestsFailed()
                                                        WinGetTitle, title, A
                                                        OutputDebug, %TestName%:%A_LineNumber%: Test failed: Unable to close'%NameExt% - SciTE' window. Active window caption: '%title%'`n
                                                    }
                                                }
                                                else
                                                {
                                                    TestsFailed()
                                                    WinGetTitle, title, A
                                                    OutputDebug, %TestName%:%A_LineNumber%: Test failed: Keystroke 'Ctrl+S' was sent, '%NameExt% - SciTE' is not active window. Active window caption: '%title%'`n
                                                }
                                            }
                                            else
                                            {
                                                TestsFailed()
                                                WinGetTitle, title, A
                                                OutputDebug, %TestName%:%A_LineNumber%: Test failed: '%NameExt% * SciTE' is not active window. Active window caption: '%title%'`n
                                            }
                                        }
                                        else
                                        {
                                            TestsFailed()
                                            WinGetTitle, title, A
                                            OutputDebug, %TestName%:%A_LineNumber%: Test failed: Unable to close 'Replace (Find what)' window. Active window caption: '%title%'`n
                                        }
                                    }
                                    else
                                    {
                                        TestsFailed()
                                        WinGetTitle, title, A
                                        OutputDebug, %TestName%:%A_LineNumber%: Test failed: Bad number of 'Replacements': '%OutputVar%'. Active window caption: '%title%'`n
                                    }
                                }
                                else
                                {
                                    TestsFailed()
                                    WinGetTitle, title, A
                                    OutputDebug, %TestName%:%A_LineNumber%: Test failed: Unable to get number of 'Replacements' in 'Replace (Find what)' window. Active window caption: '%title%'`n
                                }
                            }
                            else
                            {
                                TestsFailed()
                                WinGetTitle, title, A
                                OutputDebug, %TestName%:%A_LineNumber%: Test failed: Unable to hit 'Replace All' button in 'Replace (Find what)' window. Active window caption: '%title%'`n
                            }
                        }
                        else
                        {
                            TestsFailed()
                            WinGetTitle, title, A
                            OutputDebug, %TestName%:%A_LineNumber%: Test failed: Unable to set 'Replace with' to 'Edijs' in 'Replace (Find what)' window. Active window caption: '%title%'`n
                        }
                    }
                    else
                    {
                        TestsFailed()
                        WinGetTitle, title, A
                        OutputDebug, %TestName%:%A_LineNumber%: Test failed: Unable to set 'Find what' to 'Egijs' in 'Replace (Find what)' window. Active window caption: '%title%'`n
                    }
                }
                else
                {
                    TestsFailed()
                    WinGetTitle, title, A
                    OutputDebug, %TestName%:%A_LineNumber%: Test failed: Window 'Replace (Find what)' failed to appear. Active window caption: '%title%'`n
                }
            }
            else
            {
                TestsFailed()
                WinGetTitle, title, A
                OutputDebug, %TestName%:%A_LineNumber%: Test failed: Unable to hit 'Search -> Replace' in '%NameExt% - SciTE' window. Active window caption: '%title%'`n
            }
        }
        else
        {
            TestsFailed()
            WinGetTitle, title, A
            OutputDebug, %TestName%:%A_LineNumber%: Test failed: Window '%NameExt% - SciTE' failed to appear. Active window caption: '%title%'`n
        }
    }
    else
    {
        TestsFailed()
        WinGetTitle, title, A
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: We failed somewhere in prepare.ahk. Active window caption: '%title%'`n
    }
}
else
{
    TestsFailed()
    WinGetTitle, title, A
    OutputDebug, %TestName%:%A_LineNumber%: Test failed: Unable to create '%szDocument%'. Active window caption: '%title%'`n
}
