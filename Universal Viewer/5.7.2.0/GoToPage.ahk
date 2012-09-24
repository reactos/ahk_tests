/*
 * Designed for UniversalViewer 5.7.2.0
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

TestName = 2.GoToPage
szDocument =  %A_WorkingDir%\Media\Book.pdf ; Case sensitive!

; Test if can open PDF document, go to page 29, close document, exit Universal Viewer.
TestsTotal++
RunApplication(szDocument)
SplitPath, szDocument, NameExt
if not bContinue
    TestsFailed("We failed somewhere in prepare.ahk.")
else
{
    IfWinNotActive, %NameExt% - Universal Viewer (slister)
        TestsFailed("Window '" NameExt " - Universal Viewer (slister)' failed to appear.")
    else
    {
        ControlSetText, Edit1, 29, %NameExt% - Universal Viewer (slister) ; Set page number to 29
        if ErrorLevel
            TestsFailed("Unable to enter 'Page' number in '" NameExt " - Universal Viewer (slister)' window.")
        else
        {
            ControlClick, Edit1, %NameExt% - Universal Viewer (slister) ; We have to click on it before sending keystroke
            if ErrorLevel
                TestsFailed("Unable to click 'Page' number in '" NameExt " - Universal Viewer (slister)' window.")
            else
            {
                SendInput, {ENTER} ; Hit enter to actually go to page
                ; Sleep, 2000 ; Load page properly before searching for image on the screen
                ; FIXME: test might work only on 800x600 screen resolution on themeless system
                ; Need to find a way to show PDF in actual size
                SearchImg = %A_WorkingDir%\Media\BookPage29Img800x600.jpg

                IfNotExist, %SearchImg%
                    TestsFailed("Can NOT find '" SearchImg "'.")
                else
                {
                    ImageSearch, FoundX, FoundY, 0, 0, A_ScreenWidth, A_ScreenHeight, *14 %SearchImg%
                    if ErrorLevel = 2
                        TestsFailed("Could not conduct the ImageSearch ('" SearchImg "' exist).")
                    else if ErrorLevel = 1
                        TestsFailed("The search image '" SearchImg "' could NOT be found on the screen (resolution not 800x600?).")
                    else
                    {
                        SendInput, {Alt}f ; Close document. WinMenuSelectItem doesn't work here. Don't use '!f' either, because it fails on Windows
                        SendInput, c
                        WinWaitActive, Universal Viewer, File not loaded, 5
                        if ErrorLevel
                            TestsFailed("Window 'Universal Viewer (File not loaded)' failed to appear.")
                        else
                        {
                            WinClose, Universal Viewer, File not loaded
                            WinWaitClose, Universal Viewer, File not loaded, 7
                            if ErrorLevel
                                TestsFailed("Window 'Universal Viewer (File not loaded)' failed to close.")
                            else
                            {
                                Process, WaitClose, SumatraPDF.exe, 4
                                if ErrorLevel
                                {
                                    Process, Close, SumatraPDF.exe
                                    Process, WaitClose, SumatraPDF.exe, 4
                                    if ErrorLevel
                                        TestsFailed("Unable to terminate 'SumatraPDF.exe' process.")
                                    else
                                        TestsFailed("'SumatraPDF.exe' process failed to close on its own, so, we had to terminate it.")
                                }
                                else
                                    TestsOK("Found image on the screen, so, page 29 was displayed correctly. Document and application closed successfully.")
                            }
                        }
                    }
                }
            }
        }
    }
}
