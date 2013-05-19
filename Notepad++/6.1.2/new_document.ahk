/*
 * Designed for Notepad++ 6.1.2
 * Copyright (C) 2013 Edijs Kolesnikovics
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

; Test if can create and save new document
TestsTotal++
TestName = 6.new_document
szDocument =  C:\Notepad_New_Doc.txt ; Case sensitive!

RunNotepad("")
if bContinue
{
    IfWinNotActive, new  1 - Notepad++
        TestsFailed("Window 'new  1 - Notepad++' is NOT active.")
    else
    {
        szWndContent = Extension test
        SendInput, %szWndContent%
        IfWinNotActive, *new  1 - Notepad++
            TestsFailed("Window '*new  1 - Notepad++' is NOT active.")
        else
        {
            clipboard = ; clean the clipboard
            SendInput, ^a ; Ctrl+A aka Select All
            SendInput, ^c ; Ctrl+C aka Copy
            ClipWait, 2
            if ErrorLevel
                TestsFailed("Attempt to copy text from '*new  1 - Notepad++' window onto clipboard failed.")
            else
            {
                IfNotInString, szWndContent, %clipboard%
                    TestsFailed("Unexpected clipboard content. Is '" clipboard "', should be '" szWndContent "'.")
                else
                {
                    SendInput, ^s ; Ctrl+S
                    WinWaitActive, Save As, File &name, 3
                    if ErrorLevel
                        TestsFailed("Window 'Save As (File name)' failed to appear despite Ctrl+S being sent to '*new  1 - Notepad++' window.")
                    else
                    {
                        SendInput, !n ; Focus 'File name' field. Alt+N selects all text
                        SendInput, ^c ; Ctrl+C aka Copy
                        ClipWait, 2
                        if ErrorLevel
                            TestsFailed("Attempt to copy text from 'File name' field in 'Save As' window onto clipboard failed.")
                        else
                        {
                            szText = new  1
                            IfNotInString, szText, %clipboard%
                                TestsFailed("Unexpected variable content. Is '" clipboard "', should be '" szText "'.")
                            else
                                TestsOK("Wrote some text in 'new  1 - Notepad++' window, sent Ctrl+S and 'Save As (File name)' window appeared.")
                        }
                    }
                }
            }
        }
    }
}


TestsTotal++
if bContinue
{
    IfExist, %szDocument%
    {
        FileDelete, %szDocument%
        if ErrorLevel
            TestsFailed("Unable to delete 'szDocument'")
    }

    if bContinue
    {
        SendInput, !n ; Focus 'File name' field. When focused, all text is selected
        SendInput, ^c ; Ctrl+C aka Copy
        ClipWait, 2
        if ErrorLevel
            TestsFailed("Attempt to copy text from 'Save As (File name)' window onto clipboard failed.")
        else
        {
            szText = new  1
            IfNotInString, szText, %clipboard%
                TestsFailed("Unexpected clipboard content. Is '" clipboard "', should be '" szText "'. Unable to focus 'File name' field with Alt+N?")
            else
            {
                SplitPath, szDocument,, dir,, name_no_ext
                szPath = %dir%\%name_no_ext%
                SendInput, %szPath% ; Fill 'File name' field
                SendInput, !n ; Ctrl+A doesn't work, but Alt+N selects all text
                SendInput, ^c ; Ctrl+C aka Copy
                ClipWait, 2
                if ErrorLevel
                    TestsFailed("Attempt to copy text from 'Save As (File name)' window onto clipboard failed after typing address.")
                else
                {
                    IfNotInString, szPath, %clipboard%
                        TestsFailed("Unexpected clipboard content. Is '" clipboard "', should be '" szPath "'. Unable to focus 'File name' field with Alt+N?")
                    else
                    {
                        SendInput, !s ; Hit 'Save' button
                        WinWaitClose, Save As, File &name, 3
                        if ErrorLevel
                            TestsFailed("'Save As (File name)' window failed to close despite Alt+S being sent.")
                        else
                        {
                            IfNotExist, %szDocument%
                            {
                                IfNotExist, %szPath%
                                    TestsFailed("Nor '" szDocument "' nor '" szPath "' exist.")
                                else
                                    TestsFailed("Created extensionless file. #CORE-6477.")
                            }
                            else
                                TestsOK("Created a file that haves an extension. No #CORE-6477.")
                        }
                    }
                }
            }
        }
    }
}


TestsTotal++
if bContinue
{
    FileReadLine, szContent, %szDocument%, 1
    if ErrorLevel
        TestsFailed("Unable to read data from existing '" szDocument "' file.")
    else
    {
        IfNotInString, szWndContent, %szContent%
            TestsFailed("Unexpected '" szDocument "' file content. Is '" szContent "', should be '" szWndContent "'.")
        else
            TestsOK("Content of '" szDocument "' is OK.")
    }
}


TerminateApplication()

