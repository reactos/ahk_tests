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
TestsTotal++
TestName = 3.OpenDocument
szDocument =  %A_Desktop%\Notepad++Test.txt ; Case sensitive!

FileAppend, One line.`nLine two`nLine 3, %szDocument%
if not ErrorLevel
{
    RunNotepad(szDocument)
    if not bContinue
        TestsFailed("We failed somewhere in prepare.ahk.")
    else
    {
        IfWinActive, %szDocument% - Notepad++
        {
            Sleep, 700
            SendInput, {CTRLDOWN}a{CTRLUP}{BACKSPACE}New text.
            WinWaitActive, *%szDocument% - Notepad++,, 5 ; We were able to change text
            if not ErrorLevel
            {
                SendInput, {CTRLDOWN}s{CTRLUP}
                WinWaitActive, %szDocument% - Notepad++,, 5 ; We were able to save
                if not ErrorLevel
                {
                    WinClose, %szDocument% - Notepad++,, 5 
                    if not ErrorLevel
                    {
                        iLines := FileCountLines(szDocument)
                        if iLines = 1
                        {
                            TestsOK("")
                            FileDelete, %szDocument%
                        }
                        else
                            TestsFailed("For some reason number of lines is wrong! Is '" iLines "' and should be 1.")
                    }
                    else
                        TestsFailed("Failed to close '" szDocument " - Notepad++' window.")
                }
                else
                    TestsFailed("Failed to save.")
            }
            else
                TestsFailed("Failed to change text.")
        }
        else
            TestsFailed("Window '" szDocument " - Notepad++' is not active.")
    }
}
else
    TestsFailed("Failed to create '" szDocument "'.")
