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
if ErrorLevel
    TestsFailed("Failed to create '" szDocument "'.")
else
{
    RunNotepad(szDocument)
    IfWinNotActive, %szDocument% - Notepad++
        TestsFailed("Window '" szDocument " - Notepad++' is not active.")
    else
    {
        SendInput, {CTRLDOWN}f{CTRLUP} ; Call dialog using Ctrl+F
        WinWaitActive, Find,, 3
        if ErrorLevel
            TestsFailed("Window 'Find' failed to appear, so Ctrl+F doesn't work, bug #CORE-6112.")
        else
        {
            TestFindDialog()
            if bContinue
                TestsOK("Ctrl+F works, found a match.")
        }

        ; The window we need is still active, so, check if we can open 'Find' thru main menu
        TestsTotal++
        SendInput, {ALTDOWN}s ; Hit 'Search'
        SendInput, f ; Hit 'Find'
        WinWaitActive, Find,,3
        if ErrorLevel
            TestsFailed("Can't open 'Find' from main menu")
        else
        {
            TestFindDialog()
            if bContinue
                TestsOK("Alt+S -> F works, found a match.")
        }
    }
}


TerminateApplication()


TestFindDialog()
{
    global TestName
    global bContinue

    IfWinActive, Find
    {
        SendInput, !f ; Go to 'Find what'
        SendInput, some ; He have such word in that document
        SendInput, !t ; Hit 'Count'
        WinWaitActive, Count, 1 match, 3 ; We have only 1 match
        if ErrorLevel
            TestsFailed("Can't find a match.")
        else
        {
            SendInput, {ENTER} ; Close 'Count' dialog
            WinClose, Count, 1 match
            WinWaitClose, Count, 1 match, 3
            if ErrorLevel
                TestsFailed("Unable to close 'Count (1 match)' window.")
            else
            {
                WinWaitActive, Find,, 3
                if ErrorLevel
                    TestsFailed("'Find' window is not an active window.")
                else
                {
                    WinClose, Find
                    WinWaitClose, Find,,3
                    if ErrorLevel
                        TestsFailed("Unable to close 'Find' window.")
                    else
                        bContinue := true
                }
            }
        }
    }
}
