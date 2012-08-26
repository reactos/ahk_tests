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

; Test Ctrl-F 'Find' dialog

TestsTotal++
TestName = 4.Ctrl-F.FindDialog
szDocument =  C:\NotepadTestFile.ini ; Case sensitive!

FileDelete, %szDocument%
FileAppend, This text`nwill contain some`nlines. We will use`nit to test dialogs., %szDocument%
if not ErrorLevel
{
    RunNotepad(szDocument)
    IfWinActive, %szDocument% - Notepad++
    {
        SendInput, {CTRLDOWN}f{CTRLUP} ; Call dialog using Ctrl+F
        WinWaitActive, Find,, 5
        if not ErrorLevel
        {
            TestFindDialog()
            if bContinue
                TestsOK("")
        }
        else
        {
            WinGetTitle, title, A
            OutputDebug, %TestName%:%A_LineNumber%: Test failed: Window 'Find' failed to appear, so Ctrl+F doesn't work, bug #6734. Active window caption: '%title%'`n
            
            ; Check if can open 'Find' from main menu
            SendInput, {ALTDOWN}s ; Hit 'Search'
            SendInput, f ; Hit 'Find'
            WinWaitActive, Find,,5
            if not ErrorLevel
            {
                TestFindDialog()
                if bContinue
                    TestsOK("")
            }
            else
                TestsFailed("Can't open 'Find' from main menu")
        }
    }
    else
        TestsFailed("Window '" szDocument " - Notepad++' is not active.")
}
else
    TestsFailed("Failed to create '" szDocument "'.")

TestFindDialog()
{
    global TestName
    global bContinue

    IfWinActive, Find
    {
        SendInput, {ALTDOWN}f{ALTUP} ; Go to 'Find what'
        SendInput, some ; He have such word in that document
        SendInput, {ALTDOWN}t{ALTUP} ; Hit 'Count'
        WinWaitActive, Count, 1 match, 5 ; We have only 1 match
        if not ErrorLevel
        {
            bContinue := true
        }
        else
            TestsFailed("Can't find a match.")
    }
}

Process, close, notepad++.exe ; We don't care now if application can close correctly, so, terminate