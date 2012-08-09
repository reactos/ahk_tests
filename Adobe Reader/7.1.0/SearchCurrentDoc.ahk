/*
 * Designed for Adobe Reader 7.1.0
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
TestName = 2.SearchCurrentDoc
szDocument =  %A_WorkingDir%\Media\Book.pdf ; Case sensitive!

; Test if can open PDF document and search for text in it
TestsTotal++
RunApplication(szDocument)
SplitPath, szDocument, NameExt
WinWaitActive, Adobe Reader - [%NameExt%],,15
if not ErrorLevel
{
    ControlClick, AVL_AVView51, Adobe Reader - [%NameExt%],, R ; Click right mouse button on document
    if not ErrorLevel
    {
        Sleep, 1200
        SendInput, s ; Select 'Search' from popup menu
        ControlGetText, OutputVar, Static34, Adobe Reader - [%NameExt%]
        ControlText = Where would you like to search?
        TimeOut := 0
        while OutputVar <> ControlText ; Sleep until side bar appears
        {
            ControlGetText, OutputVar, Static34, Adobe Reader - [%NameExt%]
            Sleep, 1000
            TimeOut++
            bContinue := true
            if TimeOut > 10 ; There is no way we need more than 10sec
            {
                bContinue := false
                Break
            }
        }
        
        if bContinue
        {
            Sleep, 1000 ; Sleep one more second for side bar to properly load
            ControlSetText, Edit10, phone during, Adobe Reader - [%NameExt%]
            if not ErrorLevel
            {
                ControlClick, Button17, Adobe Reader - [%NameExt%] ; Hit 'Search' button
                if not ErrorLevel
                {
                    ControlGetText, OutputVar, Static20, Adobe Reader - [%NameExt%]
                    ControlText = 1 ; We are going to find only one match
                    TimeOut := 0
                    while OutputVar <> ControlText
                    {
                        ControlGetText, OutputVar, Static20, Adobe Reader - [%NameExt%]
                        Sleep, 1000
                        TimeOut++
                        if TimeOut > 10
                        {
                            bContinue := false
                            Break ; Search doesn't take so long, there is something wrong, so, breake loop
                        }
                    }
                    
                    if bContinue
                    {
                        OutputDebug, OK: %TestName%:%A_LineNumber%: Searching 'phone during' returned one result as it was expected.`n
                        TestsOK()
                    }
                    else
                    {
                        TestsFailed()
                        WinGetTitle, title, A
                        OutputDebug, %TestName%:%A_LineNumber%: Test failed: It took too long for Search to give results. Active window caption: '%title%'`n
                    }
                }
                else
                {
                    TestsFailed()
                    WinGetTitle, title, A
                    OutputDebug, %TestName%:%A_LineNumber%: Test failed: Unable to hit 'Search' button in 'Adobe Reader - [%NameExt%]' window. Active window caption: '%title%'`n
                }
            }
            else
            {
                TestsFailed()
                WinGetTitle, title, A
                OutputDebug, %TestName%:%A_LineNumber%: Test failed: Unable to change 'Edit10' control text in 'Adobe Reader - [%NameExt%]' window. Active window caption: '%title%'`n
            }
        }
        else
        {
            TestsFailed()
            WinGetTitle, title, A
            OutputDebug, %TestName%:%A_LineNumber%: Test failed: It took too long for Search side bar to appear. Active window caption: '%title%'`n
        }
    }
    else
    {
        TestsFailed()
        WinGetTitle, title, A
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: Unable to right-click on document in 'Adobe Reader - [%NameExt%]' window. Active window caption: '%title%'`n
    }
}
else
{
    TestsFailed()
    WinGetTitle, title, A
    OutputDebug, %TestName%:%A_LineNumber%: Test failed: Window 'Adobe Reader - [%NameExt%]' failed to appear. Active window caption: '%title%'`n
}

Process, Close, AcroRd32.exe