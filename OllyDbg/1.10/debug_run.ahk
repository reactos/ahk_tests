/*
 * Designed for OllyDbg 1.10
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

TestName = 2.debug_run
szDocument =  %A_WinDir%\System32\calc.exe ; File name is case sensitive!

; Test if can 
TestsTotal++
SplitPath, szDocument, NameExt
Process, Close, %NameExt% ; Terminate external app, because we don't want it running
Sleep, 1000
RunApplication(szDocument)
if bContinue
{
    IfWinActive, OllyDbg - %NameExt%
    {
        Sleep, 1000
        WinMenuSelectItem, OllyDbg - %NameExt%, , Debug, Run
        if not ErrorLevel
        {
            WinWaitActive, Calculator,,10
            if not ErrorLevel
            {
                Sleep, 2000
                WinClose, Calculator
                WinWaitClose, Calculator,, 5
                if not ErrorLevel
                {
                    WinWaitActive, OllyDbg - %NameExt%,, 7
                    if not ErrorLevel
                    {
                        Sleep, 1000
                        WinClose, OllyDbg - %NameExt%
                        WinWaitClose, OllyDbg - %NameExt%,,7
                        if not ErrorLevel
                        {
                            TestsOK()
                            OutputDebug, OK: %TestName%:%A_LineNumber%: '%NameExt%' was opened via command line, ran it via 'Debug -> Run', closed its window and closed OllyDbg successfully.`n
                        }
                        else
                        {
                            TestsFailed()
                            WinGetTitle, title, A
                            OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'OllyDbg - %NameExt%' window failed to close. Active window caption: '%title%'`n
                        }
                    }
                    else
                    {
                        TestsFailed()
                        WinGetTitle, title, A
                        OutputDebug, %TestName%:%A_LineNumber%: Test failed: Window 'OllyDbg - %NameExt%' did not became active after closing 'Calculator' window. Active window caption: '%title%'`n
                    }
                }
                else
                {
                    TestsFailed()
                    WinGetTitle, title, A
                    OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'Calculator' window failed to close. Active window caption: '%title%'`n
                }
            }
            else
            {
                TestsFailed()
                WinGetTitle, title, A
                OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'Calculator' window failed to appear. Active window caption: '%title%'`n
            }
        }
        else
        {
            TestsFailed()
            WinGetTitle, title, A
            OutputDebug, %TestName%:%A_LineNumber%: Test failed: Unable to hit 'Debug -> Run' in 'OllyDbg - %NameExt%' window. Active window caption: '%title%'`n
        }
    }    
    else
    {
        TestsFailed()
        WinGetTitle, title, A
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: Window 'OllyDbg - %NameExt%' is not active. Active window caption: '%title%'`n
    }
}
else
{
    TestsFailed()
    WinGetTitle, title, A
    OutputDebug, %TestName%:%A_LineNumber%: Test failed: We failed somewhere in prepare.ahk. Active window caption: '%title%'`n
}
