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
szDocument =  %A_Desktop%\Notepad++Test.txt ; Case sensitive!
FileAppend, One line.`nLine two`nLine 3, %szDocument%
if not ErrorLevel
{
    RunNotepad(szDocument)
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
                        TestsOK++
                        FileDelete, %szDocument%
                        bContinue := true
                    }
                    else
                    {
                        TestsFailed++
                        WinGetTitle, title, A
                        OutputDebug, FAILED: %Module%:%A_LineNumber%: For some reason number of lines is wrong! Is %iLines% and should be 1. Active window caption: '%title%'`n
                        bContinue := false
                    }
                }
                else
                {
                    TestsFailed++
                    WinGetTitle, title, A
                    OutputDebug, FAILED: %Module%:%A_LineNumber%: Failed to close '%szDocument% - Notepad++' window. Active window caption: '%title%'`n
                    bContinue := false
                }
            }
            else
            {
                TestsFailed++
                WinGetTitle, title, A
                OutputDebug, FAILED: %Module%:%A_LineNumber%: Failed to save. Active window caption: '%title%'`n
                bContinue := false
            }
        }
        else
        {
            TestsFailed++
            WinGetTitle, title, A
            OutputDebug, FAILED: %Module%:%A_LineNumber%: Failed to change text. Active window caption: '%title%'`n
            bContinue := false
        }
    }
    else
    {
        TestsFailed++
        WinGetTitle, title, A
        OutputDebug, FAILED: %Module%:%A_LineNumber%: Window '%szDocument% - Notepad++' failed to appear. Active window caption: '%title%'`n
        bContinue := false
    }
}
else
{
        TestsFailed++
        WinGetTitle, title, A
        OutputDebug, FAILED: %Module%:%A_LineNumber%: Failed to create '%szDocument%'. Active window caption: '%title%'`n
        bContinue := false
}
