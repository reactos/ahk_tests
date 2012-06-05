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
TestName = Ctrl-F.Find.Dialog
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
            TestsOK++
            TestFindDialog()
        }
        else
        {
            TestsFailed++
            WinGetTitle, title, A
            OutputDebug, %TestName%:%A_LineNumber%: Test failed: Window 'Find' failed to appear, so Ctrl+F doesn't work, bug #6734. Active window caption: '%title%'`n
            
            ; Check if can open 'Find' from main menu
            SendInput, {ALTDOWN}s ; Hit 'Search'
            SendInput, f ; Hit 'Find'
            WinWaitActive, Find,,5
            if not ErrorLevel
            {
                TestFindDialog()
                bContinue := true
            }
            else
            {
                TestsFailed++
                WinGetTitle, title, A
                OutputDebug, %TestName%:%A_LineNumber%: Test failed: Can't open 'Find' from main menu. Active window caption: '%title%'`n
                bContinue := false
            }
        }
    }
    else
    {
        TestsFailed++
        WinGetTitle, title, A
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: Window '%szDocument% - Notepad++' is not active. Active window caption: '%title%'`n
        bContinue := false
    }
}
else
{
    TestsFailed++
    WinGetTitle, title, A
    OutputDebug, %TestName%:%A_LineNumber%: Test failed: Failed to create '%szDocument%'. Active window caption: '%title%'`n
    bContinue := false
}

TestFindDialog()
{
    global TestsTotal
    global TestsOK
    global TestsFailed
    global bContinue

    TestsTotal++
    IfWinActive, Find
    {
        SendInput, {ALTDOWN}f{ALTUP} ; Go to 'Find what'
        SendInput, some ; He have such word in that document
        SendInput, {ALTDOWN}t{ALTUP} ; Hit 'Count'
        WinWaitActive, Count, 1 match, 5 ; We have only 1 match
        if not ErrorLevel
        {
            TestsOK++
            bContinue := true
        }
        else
        {
            TestsFailed++
            WinGetTitle, title, A
            OutputDebug, %TestName%:%A_LineNumber%: Test failed: Can't find match. Active window caption: '%title%'`n
            bContinue := false
        }
    }
}

Process, close, notepad++.exe ; We don't care now if application can close correctly, so, terminate