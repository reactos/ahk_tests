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

TestName = 2.SearchCurrentDoc
szDocument =  %A_WorkingDir%\Media\Book.pdf ; Case sensitive!

; Test if can open PDF document and search for text in it
TestsTotal++
RunApplication(szDocument)
if not bContinue
    TestsFailed("We failed somwehere in 'prepare.ahk'.")
else
{
    SplitPath, szDocument, NameExt
    WinWaitActive, Adobe Reader - [%NameExt%],,15
    if ErrorLevel
        TestsFailed("Window 'Adobe Reader - [" NameExt "]' failed to appear.")
    else
    {
        ControlClick, AVL_AVView51, Adobe Reader - [%NameExt%],, R ; Click right mouse button on document
        if ErrorLevel
            TestsFailed("Unable to right-click on document in 'Adobe Reader - [" NameExt "]' window.")
        else
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
            
            if not bContinue
                TestsFailed("It took too long for Search side bar to appear.")
            else
            {
                Sleep, 1000 ; Sleep one more second for side bar to properly load
                ControlSetText, Edit10, phone during, Adobe Reader - [%NameExt%]
                if ErrorLevel
                    TestsFailed("Unable to change 'Edit10' control text in 'Adobe Reader - [%NameExt%]' window.")
                else
                {
                    ControlClick, Button17, Adobe Reader - [%NameExt%] ; Hit 'Search' button
                    if ErrorLevel
                        TestsFailed("Unable to hit 'Search' button in 'Adobe Reader - [%NameExt%]' window.")
                    else
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
                        
                        if not bContinue
                            TestsFailed("It took too long for Search to give results.")
                        else
                        {
                            Process, Close, AcroRd32.exe
                            Process, WaitClose, AcroRd32.exe, 4
                            if ErrorLevel
                                TestsFailed("We almost succeeded, but process 'AcroRd32.exe' failed to close.")
                            else
                                TestsOK("Searching 'phone during' returned one result as it was expected and 'AcroRd32.exe' process was closed.")
                        }
                    }
                }
            }
        }
    }
}
