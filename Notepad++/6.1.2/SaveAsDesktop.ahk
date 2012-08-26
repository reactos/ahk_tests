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
TestName = 2.SaveAsDesktop
szDocument =  ; Case sensitive! [No file to open]

RunNotepad(szDocument)
if not bContinue
    TestsFailed("We failed somewhere in prepare.ahk.")
else
{
    IfWinActive, new  1 - Notepad++
    {
        SendInput, Line 1{ENTER}Line two with @{ENTER}Line 3 with question mark?{ENTER}{ENTER}This is line 5. Line 4 was empty.
        Sleep, 1500
        IfWinActive, *new  1 - Notepad++
        {
            SendInput, {CTRLDOWN}s{CTRLUP}
            Sleep, 1500 ; It can appear and fail, so sleep
            WinWaitActive, Save As,, 15
            if not ErrorLevel
            {
                OutputDebug, OK: %TestName%:%A_LineNumber%: 'Save As' dialog appeared.`n
                bContinue := true
            }
             else
                TestsFailed("'Save As' dialog failed to appear")
        }
        else
            TestsFailed("The '*new  1 - Notepad++' window is not active anymore.")
    }
    else
        TestsFailed("Window 'new  1 - Notepad++' is not active.")


    ; Test if we can save file to desktop
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
                SendInput, !s ; Hit 'Save' in 'Save As' dialog
                Sleep, 1500 ; Let file to appear
                szDocumentPath = %A_Desktop%\new  1.txt
                IfExist, %szDocumentPath%
                {
                    OutputDebug, OK: %TestName%:%A_LineNumber%: '%szDocumentPath%' exist as it should.`n
                    bContinue := true
                }
                else
                    TestsFailed("File '" szDocumentPath "' does not exist, but it should.")
            }
            else
                TestsFailed("Unable to enter '" A_Desktop "\new  1.txt' in 'File name' field in 'Save As' window.")
        }
        else
            TestsFailed("For some reason 'Save As' dialog is not active anymore.")
    }


    ; Test if we can close program
    if bContinue
    {
        bContinue := false
        WinClose, %szDocumentPath% - Notepad++,, 10
        if not ErrorLevel
            TestsOK("Window '" szDocumentPath " - Notepad++' was closed successfully.")
        else
            TestsFailed("Failed to close '" szDocumentPath " - Notepad++' window.")
    }
}