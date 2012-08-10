/*
 * Designed for Foxit Reader 2.1.2023
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
szDocument =  %A_WorkingDir%\Media\Book.pdf ; Case sensitive!

; Test if can open PDF document, go to page 29, close document, exit Foxit Reader.
TestsTotal++
RunApplication(szDocument)
SplitPath, szDocument, NameExt
WinWaitActive, %NameExt% - Foxit Reader 2.1 - [%NameExt%],,7
if not ErrorLevel
{
    SendInput, *^{1} ; Scortcut for RMB option 'Actual Size'
    WinMenuSelectItem, %NameExt% - Foxit Reader 2.1 - [%NameExt%], , Document, Go to Page ; File menu: Document -> Go to Page
    if not ErrorLevel
    {
        WinWaitActive, Go to  Page,, 5 ; Note two spaces between 'to' and 'Page'
        if not ErrorLevel
        {
            ControlSetText, Edit1, 29, Go to  Page ; enter '29' as page number
            if not ErrorLevel
            {
                ControlClick, Button1, Go to  Page
                if not ErrorLevel
                {
                    Sleep, 2000 ; Load page properly before searching for image on the screen
                    SearchImg = %A_WorkingDir%\Media\BookPage29Img.jpg
                    
                    IfExist, %SearchImg%
                    {
                        ImageSearch, FoundX, FoundY, 0, 0, A_ScreenWidth, A_ScreenHeight, *14 %SearchImg% ; 14 is best what Windows can do
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
                            OutputDebug, OK: %TestName%:%A_LineNumber%: Found image on the screen, so, page 29 was displayed correctly. Next step - close document.`n
                            Sleep, 1000
                            SendInput, {CTRLDOWN}w{CTRLUP} ; Shortcut to close document
                            Sleep, 2000 ; Let some error to come up
                            WinWaitActive, Foxit Reader 2.1,,5
                            if not ErrorLevel
                            {
                                WinClose, Foxit Reader 2.1
                                Sleep, 1500 ; Let WinClose to do it's job
                                IfWinNotExist, Foxit Reader 2.1
                                {
                                    TestsOK()
                                    OutputDebug, OK: %TestName%:%A_LineNumber%: Successfully opened PDF document, loaded page 29, closed document, closed Foxit Reader application.`n
                                }
                                else
                                {
                                    TestsFailed() ; This will terminate 'Foxit Reader.exe'
                                    WinGetTitle, title, A
                                    OutputDebug, %TestName%:%A_LineNumber%: Test failed: Window 'Foxit Reader 2.1' failed to close. Active window caption: '%title%'`n
                                }
                            }
                            else
                            {
                                TestsFailed()
                                WinGetTitle, title, A
                                OutputDebug, %TestName%:%A_LineNumber%: Test failed: Window 'Foxit Reader 2.1' failed to appear after closing document. Active window caption: '%title%'`n
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
                    OutputDebug, %TestName%:%A_LineNumber%: Test failed: Unable to hit 'OK' button in 'Go to  Page' window. Active window caption: '%title%'`n
                }
            }
            else
            {
                TestsFailed()
                WinGetTitle, title, A
                OutputDebug, %TestName%:%A_LineNumber%: Test failed: Unable to enter page number '29' in 'Go to  Page' window. Active window caption: '%title%'`n
            }
        }
        else
        {
            TestsFailed()
            WinGetTitle, title, A
            OutputDebug, %TestName%:%A_LineNumber%: Test failed: Window 'Go to  Page' failed to appear [Note two spaces between 'to' and 'Page']. Active window caption: '%title%'`n
        }
    }
    else
    {
        TestsFailed()
        WinGetTitle, title, A
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: Unable to hit 'Document -> Go to Page'. Active window caption: '%title%'`n
    }
}
else
{
    TestsFailed()
    WinGetTitle, title, A
    OutputDebug, %TestName%:%A_LineNumber%: Test failed: Window '%NameExt% - Foxit Reader 2.1 - [%NameExt%]' failed to appear. Can not open PDF? Active window caption: '%title%'`n
}
