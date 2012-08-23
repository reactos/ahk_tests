/*
 * Designed for Total Commander 8.0
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

TestName = 2.find_files
 
; Check if can find calc.exe in WinDir\..
TestsTotal++
RunApplication()
if bContinue
{
    IfWinActive, Total Commander 8.0 - NOT REGISTERED
    {
        WinMenuSelectItem, Total Commander 8.0 - NOT REGISTERED, , Commands, Search
        if not ErrorLevel
        {
            WinWaitActive, Find Files, &Start search, 5
            if not ErrorLevel
            {
                ControlSetText, Edit3, calc.exe, Find Files, &Start search ; Search for
                if not ErrorLevel
                {
                    SendInput, {ALTDOWN}i{ALTUP} ;  Focus 'Search in' field, ControlSetText will cause problems
                    SendInput, %A_WinDir%
                    Sleep, 1000
                    ControlClick, TButton16, Find Files, &Start search ; Hit 'Start search' button
                    if not ErrorLevel
                    {
                        ControlText := " [1 files and 0 directories found]"
                        ControlGetText, OutputVar, TMyPanel1, Find Files
                        if not ErrorLevel
                        {
                            TimeOut := 0
                            while (OutputVar <> ControlText) and (TimeOut < 40)
                            {
                                Sleep, 500
                                ControlGetText, OutputVar, TMyPanel1, Find Files
                                TimeOut++
                            }
                            
                            if (OutputVar == ControlText)
                            {
                                TestsOK()
                                OutputDebug, %TestName%:%A_LineNumber%: OK: 'Find Files' executed by 'Commands -> Search' successfully.`n
                                Sleep, 1000
                                Process, Close, TOTALCMD.EXE ; Teminate process
                            }
                            else
                            {
                                TestsFailed()
                                WinGetTitle, title, A
                                OutputDebug, %TestName%:%A_LineNumber%: Test failed: Timed out, result: '%OutputVar%'. Active window caption: '%title%'.`n
                            }
                        }
                        else
                        {
                            TestsFailed()
                            WinGetTitle, title, A
                            OutputDebug, %TestName%:%A_LineNumber%: Test failed: Unable to get caption of 'Start search' button in 'Find Files (Start search)' window. Active window caption: '%title%'.`n
                        }
                    }
                    else
                    {
                        TestsFailed()
                        WinGetTitle, title, A
                        OutputDebug, %TestName%:%A_LineNumber%: Test failed: Unable to hit 'Start search' button in 'Find Files (Start search)' window. Active window caption: '%title%'.`n
                    }
                }
                else
                {
                    TestsFailed()
                    WinGetTitle, title, A
                    OutputDebug, %TestName%:%A_LineNumber%: Test failed: Unable to set 'Search for' to 'calc.exe' in 'Find Files (Start search)' window. Active window caption: '%title%'.`n
                }
            }
            else
            {
                TestsFailed()
                WinGetTitle, title, A
                OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'Find Files (Start search)' window failed to appear. Active window caption: '%title%'.`n
            }
        }
        else
        {
            TestsFailed()
            WinGetTitle, title, A
            OutputDebug, %TestName%:%A_LineNumber%: Test failed: Unable to hit 'Commands -> Search' in 'Total Commander 8.0 - NOT REGISTERED' window. Active window caption: '%title%'.`n
        }
    }
    else
    {
        TestsFailed()
        WinGetTitle, title, A
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'Total Commander 8.0 - NOT REGISTERED' is not active window. Active window caption: '%title%'.`n
    }
}
else
{
    TestsFailed()
    WinGetTitle, title, A
    OutputDebug, %TestName%:%A_LineNumber%: Test failed: We failed somewhere in prepare.ahk. Active window caption: '%title%'`n
}
