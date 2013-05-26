/*
 * Designed for Notepad++ 6.1.2
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

; Test if can create document, open it with Notepad++, delete text, write new one, save and exit
TestName = 3.OpenDocument
szDocument =  %A_Desktop%\Notepad++Test.txt ; Case sensitive!


TestsTotal++
if bContinue
{
    FileAppend, One line.`nLine two`nLine 3, %szDocument%
    if ErrorLevel
        TestsFailed("Failed to create '" szDocument "'.")
    else
    {
        RunNotepad(szDocument)
        if not bContinue
            TestsFailed("We failed somewhere in prepare.ahk.")
        else
        {
            IfWinNotActive, %szDocument% - Notepad++
                TestsFailed("Window '" szDocument " - Notepad++' is not active.")
            else
            {
                SendInput, {CTRLDOWN}a{CTRLUP}{BACKSPACE}New text.
                WinWaitActive, *%szDocument% - Notepad++,, 3 ; We were able to change text
                if ErrorLevel
                    TestsFailed("Failed to change text.")
                else
                {
                    SendInput, {CTRLDOWN}s{CTRLUP}
                    WinWaitActive, %szDocument% - Notepad++,, 3 ; We were able to save
                    if ErrorLevel
                        TestsFailed("Failed to save.")
                    else
                    {
                        WinClose, %szDocument% - Notepad++,, 3
                        if ErrorLevel
                            TestsFailed("Failed to close '" szDocument " - Notepad++' window.")
                        else
                        {
                            iLines := FileCountLines(szDocument)
                            if iLines <> 1
                                TestsFailed("For some reason number of lines is wrong! Is '" iLines "' and should be '1'.")
                            else
                            {
                                TestsOK("Created a document, opened it with Notepad++, entered some text, saved the doc, closed Notepad++.")
                                FileDelete, %szDocument%
                            }
                        }
                    }
                }
            }
        }
    }
}
