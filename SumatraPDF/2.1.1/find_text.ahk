/*
 * Designed for SumatraPDF 2.1.1
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

TestName = 2.find_text
szDocument =  %A_WorkingDir%\Media\Book.pdf ; Case sensitive!

; Test if can open PDF file and find some text in it
TestsTotal++
RunApplication(szDocument)
if not bContinue
    TestsFailed("We failed somwehere in 'prepare.ahk'.")
else
{
    SplitPath, szDocument, NameExt
    IfWinNotActive, %NameExt%
        TestsFailed("'" NameExt "' is not an active window.")
    else
    {
        szSearchFor = divorced
        ControlSetText, Edit2, %szSearchFor% ; Set 'Find' field text
        if ErrorLevel
            TestsFailed("Unable to enter '" szSearchFor "' in 'Find' field.")
        else
        {
            ControlFocus, Edit2 ; Focus 'Find' field
            if ErrorLevel
                TestsFailed("Unable to focus 'Find' field.")
            else
            {
                SendInput, {ENTER} ; Start the search

                ; Wait until small window in top left corner appears
                iTimeOut := 3
                while iTimeOut > 0
                {
                    IfWinActive, %NameExt%
                    {
                        ControlGet, bVisible, Visible,, SUMATRA_PDF_NOTIFICATION_WINDOW1 ; 
                        if bVisible = 1
                            break ; Control appeared, break the loop
                        else
                        {
                            Sleep, 1000
                            iTimeOut--
                        }
                    }
                    else
                        break ; exit the loop if something poped-up
                }

                if bVisible <> 1
                    TestsFailed("Small window in top left corner failed to appear. (iTimeOut=" iTimeOut ")")
                else
                {
                    ; Wait until text in that small window is the same as expected
                    iTimeOut := 3
                    szResultHard = Found text at page 56 ; This is what we are hoping to find
                    while iTimeOut > 0
                    {
                        IfWinActive, %NameExt%
                        {
                            ControlGetText, szResult, SUMATRA_PDF_NOTIFICATION_WINDOW1 ; 
                            if (szResult = szResultHard)
                                break ; Match found
                            else
                            {
                                Sleep, 1000
                                iTimeOut--
                            }
                        }
                        else
                            break ; exit the loop if something poped-up
                    }

                    if (szResult != szResultHard)
                        TestsFailed("Unable to find a match? Is '" szResult "', should be '" szResultHard "'. (iTimeOut=" iTimeOut ")")
                    else
                    {
                        WinClose, %NameExt%
                        WinWaitClose,,,3
                        if ErrorLevel
                            TestsFailed("Unable to close '" NameExt "' window. (SetTitleMatchMode=" A_TitleMatchMode ")")
                        else
                        {
                            Process, WaitClose, %ProcessExe%, 4
                            if ErrorLevel
                                TestsFailed("'" ProcessExe "' process failed to close despite '" NameExt "' window reported being closed. (SetTitleMatchMode=" A_TitleMatchMode ").")
                            else
                                TestsOK("Found a match, so, searching text using 'Find' field works. '" ProcessExe "' process closed after closing app window.")
                        }
                    }
                }
            }
        }
    }
}
