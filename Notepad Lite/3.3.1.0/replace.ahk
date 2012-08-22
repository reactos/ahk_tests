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

TestName = 2.replace
szDocument =  %A_WinDir%\TextFile.dat ; Case sensitive!

; Test if can open document, replace some text, save it and exit Notepad Lite.
TestsTotal++
FileDelete, %szDocument%
FileAppend, My name is Egijs Kolesnikovics, %szDocument%
if not ErrorLevel
{
    RunApplication(szDocument)
    if bContinue
    {
        IfWinActive, GridinSoft Notepad Lite - [%szDocument%]
        {
            SendInput, {ALTDOWN}s{ALTUP} ; WinMenuSelectItem does not work here
            Sleep, 500
            SendInput, r
            WinWaitActive, GridinSoft Notepad - Replace,,5
            if not ErrorLevel
            {
                ControlSetText, Edit2, Egijs, GridinSoft Notepad - Replace ; Search for
                if not ErrorLevel
                {
                    Sleep, 1000
                    ControlSetText, Edit1, Edijs, GridinSoft Notepad - Replace ; Replace with
                    if not ErrorLevel
                    {
                        Sleep, 1000
                        SendInput, {ALTDOWN}o{ALTUP} ; Hit 'OK' button. 'ControlClick' does not report any error, but it fails all the time
                        Sleep, 1000
                        WinWaitClose, GridinSoft Notepad - Replace,,5
                        if not ErrorLevel
                        {
                            Sleep, 1000
                            WinWaitActive, Confirm replace,,5
                            if not ErrorLevel
                            {
                                Sleep, 1000
                                ControlClick, TButton1, Confirm replace ; Hit 'Yes to all' button
                                if not ErrorLevel
                                {
                                    WinWaitClose, Confirm replace,,5
                                    if not ErrorLevel
                                    {
                                        WinWaitActive, GridinSoft Notepad Lite - [%szDocument%],,5
                                        if not ErrorLevel
                                        {
                                            WinClose, GridinSoft Notepad Lite - [%szDocument%]
                                            SplitPath, szDocument, NameExt
                                            WinWaitActive, *%NameExt% - GridinSoft Notepad,,5
                                            if not ErrorLevel
                                            {
                                                Sleep, 1000
                                                ControlClick, Button1, *%NameExt% - GridinSoft Notepad ; Hit 'Yes' button
                                                if not ErrorLevel
                                                {
                                                    WinWaitClose, GridinSoft Notepad Lite - [%szDocument%],,5
                                                    if not ErrorLevel
                                                    {
                                                        TestsOK()
                                                        OutputDebug, OK: %TestName%:%A_LineNumber%: Opened document, replaced some text, saved and closed Notepad Lite successfully.`n
                                                    }
                                                    else
                                                    {
                                                        TestsFailed()
                                                        WinGetTitle, title, A
                                                        OutputDebug, %TestName%:%A_LineNumber%: Test failed: Window 'GridinSoft Notepad Lite - [%szDocument%]' failed to close. Active window caption: '%title%'`n
                                                    }
                                                }
                                                else
                                                {
                                                    TestsFailed()
                                                    WinGetTitle, title, A
                                                    OutputDebug, %TestName%:%A_LineNumber%: Test failed: Unable to hit 'Yes' button in '*%NameExt% - GridinSoft Notepad' window. Active window caption: '%title%'`n
                                                }
                                            }
                                            else
                                            {
                                                TestsFailed()
                                                WinGetTitle, title, A
                                                OutputDebug, %TestName%:%A_LineNumber%: Test failed: Window '*%NameExt% - GridinSoft Notepad' failed to appear. Active window caption: '%title%'`n
                                            }
                                        }
                                        else
                                        {
                                            TestsFailed()
                                            WinGetTitle, title, A
                                            OutputDebug, %TestName%:%A_LineNumber%: Test failed: Window 'GridinSoft Notepad Lite - [%szDocument%]' is not active. Active window caption: '%title%'`n
                                        }
                                    }
                                    else
                                    {
                                        TestsFailed()
                                        WinGetTitle, title, A
                                        OutputDebug, %TestName%:%A_LineNumber%: Test failed: Window 'Confirm replace' failed to close. Active window caption: '%title%'`n
                                    }
                                }
                                else
                                {
                                    TestsFailed()
                                    WinGetTitle, title, A
                                    OutputDebug, %TestName%:%A_LineNumber%: Test failed: Unable to hit 'Yes to all' button in 'Confirm replace' window. Active window caption: '%title%'`n
                                }
                            }
                            else
                            {
                                TestsFailed()
                                WinGetTitle, title, A
                                OutputDebug, %TestName%:%A_LineNumber%: Test failed: Window 'Confirm replace' failed to appear. Active window caption: '%title%'`n
                            }
                        }
                        else
                        {
                            TestsFailed()
                            WinGetTitle, title, A
                            OutputDebug, %TestName%:%A_LineNumber%: Test failed: Window 'GridinSoft Notepad - Replace' failed to close. Active window caption: '%title%'`n
                        }
                    }
                    else
                    {
                        TestsFailed()
                        WinGetTitle, title, A
                        OutputDebug, %TestName%:%A_LineNumber%: Test failed: Unable to set 'Replace with' text in 'GridinSoft Notepad - Replace' window. Active window caption: '%title%'`n
                    }
                }
                else
                {
                    TestsFailed()
                    WinGetTitle, title, A
                    OutputDebug, %TestName%:%A_LineNumber%: Test failed: Unable to set 'Search for' text in 'GridinSoft Notepad - Replace' window. Active window caption: '%title%'`n
                }
            }
            else
            {
                TestsFailed()
                WinGetTitle, title, A
                OutputDebug, %TestName%:%A_LineNumber%: Test failed: Window 'GridinSoft Notepad - Replace' failed to appear. Active window caption: '%title%'`n
            }
        }
        else
        {
            TestsFailed()
            WinGetTitle, title, A
            OutputDebug, %TestName%:%A_LineNumber%: Test failed: Window 'GridinSoft Notepad Lite - [%szDocument%]' failed to appear. Active window caption: '%title%'`n
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
