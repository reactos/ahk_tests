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

; Type some text and test if 'Save As' dialog can appear
TestsTotal++
szDocument = "" ; No file to open. Case sensitive!
NotepadWndCaption = RunNotepad(szDocument)
IfWinActive, %NotepadWndCaption%
{
    SendInput, Line 1{ENTER}Line two with @{ENTER}Line 3 with question mark?{ENTER}{ENTER}This is line 5. Line 4 was empty.
    Sleep, 1500
    IfWinActive, *%NotepadWndCaption%
    {
        SendInput, {CTRLDOWN}s{CTRLUP}
        Sleep, 1500 ; It can appear and fail, so sleep
        WinWaitActive, Save As,, 15
        if not ErrorLevel
        {
            TestsOK++
            OutputDebug, OK: %Module%:%A_LineNumber%: 'Save As' dialog appeared.`n
            bContinue := true
        }
         else
        {
            TestsFailed++
            WinGetTitle, title, A
            OutputDebug, FAILED: %Module%:%A_LineNumber%: 'Save As' dialog failed to appear. Active window caption: '%title%'`n
            bContinue := false
        }
    }
    else
    {
        TestsFailed++
        WinGetTitle, title, A
        OutputDebug, FAILED: %Module%:%A_LineNumber%: For some reason '*%szDocument% - Notepad++' window is not active anymore. Active window caption: '%title%'`n
        bContinue := false
    }
}


; Test if we can save file to desktop
TestsTotal++
if bContinue
{
    IfWinActive, Save As
    {
        ControlSend, Edit1, %A_Desktop%\new  1.txt, Save As ; Give full path to 'File Name'
        if not ErrorLevel
        {
            Sleep, 3500
            FileDelete, %A_Desktop%\new  1.txt ; Delete file before saving
            Sleep, 1500
            SendInput, {ALTDOWN}s{ALTUP} ; Hit 'Save' in 'Save As' dialog
            Sleep, 1500 ; Let file to appear
            szDocumentPath = %A_Desktop%\new  1.txt
            IfExist, %szDocumentPath%
            {
                TestsOK++
                OutputDebug, OK: %Module%:%A_LineNumber%: '%szDocumentPath%' exist as it should.`n
                bContinue := true
            }
            else
            {
                TestsFailed++
                WinGetTitle, title, A
                OutputDebug, FAILED: %Module%:%A_LineNumber%: File '%szDocumentPath%' does not exist, but it should. Active window caption: '%title%'`n
                bContinue := false
            }
        }
        else
        {
            TestsFailed++
            WinGetTitle, title, A
            OutputDebug, FAILED: %Module%:%A_LineNumber%: There was a problem selecting 'Desktop' from ComboBox1. Active window caption: '%title%'`n
            bContinue := false
        }
    }
    else
    {
        TestsFailed++
        WinGetTitle, title, A
        OutputDebug, FAILED: %Module%:%A_LineNumber%: For some reason 'Save As' dialog is not active anymore. Active window caption: '%title%'`n
        bContinue := false
    }
}


; Test if we can close program
TestsTotal++
if bContinue
{
    bContinue := false
    WinClose, %szDocumentPath% - Notepad++,, 10
    if not ErrorLevel
    {
        TestsOK++
        OutputDebug, OK: %Module%:%A_LineNumber%: '%szDocumentPath% - Notepad++' was closed successfully.`n
        bContinue := true
    }
    else
    {
        TestsFailed++
        WinGetTitle, title, A
        OutputDebug, FAILED: %Module%:%A_LineNumber%: Failed to close '%szDocumentPath% - Notepad++' window. Active window caption: '%title%'`n
        bContinue := false
    }
}