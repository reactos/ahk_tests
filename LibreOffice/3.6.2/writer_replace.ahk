/*
 * Designed for LibreOffice 3.6.2
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

TestName = 2.writer_replace
szDocument =  C:\LibreOffice_Writer_test.txt
szSearchFor = Earl
szReplaceWith = Edijs
szText = Hello. My name is


; Test if can open document with LibreOffice Writer, replace some text and save changes
TestsTotal++
if bContinue
{
    IfExist, %szDocument%
    {
        FileDelete, %szDocument%
        if ErrorLevel
            TestsFailed("Unable to delete existing '" szDocument "'.")
    }

    if bContinue
    {
        FileAppend, %szText% %szSearchFor%, %szDocument%
        if ErrorLevel
            TestsFailed("Unable to create '" szDocument "'.")
        else
        {
            RunApplication()
            if bContinue
            {
                IfWinNotActive, LibreOffice
                    TestsFailed("'LibreOffice' window is not active.")
                else
                {
                    SendInput, !fo ; Alt+F, O aka File->Open. 'WinMenuSelectItem, LibreOffice,, File, Open' fails on 2k3
                    WinWaitActive, Open, File &name, 3
                    if ErrorLevel
                        TestsFailed("'Open (File name)' window failed to appear.")
                    else
                    {
                        ControlSetText, Edit1, %szDocument%, Open, File &name
                        if ErrorLevel
                            TestsFailed("Unable to enter '" szDocument "' to 'File name' field in 'Open (File name)' window.")
                        else
                        {
                            ControlClick, Button2 ; Hit 'Open' button
                            if ErrorLevel
                                TestsFailed("Unable to hit 'Open' button in 'Open (File name)' window")
                            else
                            {
                                WinWaitClose, Open, File &name, 3
                                if ErrorLevel
                                {
                                    TestsFailed("'Open (File name)' window failed to close.")
                                    WinClose, Open, File &name
                                }
                                else
                                    TestsOK("Hit File->Open, entered '" szDocument "' in 'File name' field in 'Open (File name)' window.")
                            }
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
    SplitPath, szDocument, szFileName
    WinWaitActive, %szFileName% - LibreOffice Writer,,5 ; Window caption/title is only thing we can use
    if ErrorLevel
        TestsFailed("'" szFileName " - LibreOffice Writer' window failed to appear.")
    else
    {
        SendInput, ^h ; Ctrl+H aka Edit->Find & Replace. WinMenuSelectItem doesn't work here
        WinWaitActive, Find & Replace,,3 ; Window caption/title is only thing we can use
        if ErrorLevel
            TestsFailed("'Find & Replace' window failed to appear. Ctrl+H fails?")
        else
        {
            ; Sleep, 5500 ; Let it to load
            SendInput, !s ; Al+S to focus 'Search for' field in 'Find & Replace' window
            SendInput, %szSearchFor%
            clipboard = ; Empty the clipboard
            SendInput, ^a ; Ctrl+A to select all
            SendInput, ^c ; Ctrl+C to copy
            ClipWait, 3
            if ErrorLevel
                TestsFailed("The attempt to copy text onto the clipboard failed.")
            else
            {
                if (szSearchFor != clipboard)
                    TestsFailed("Unexpected clipboard text (is '" clipboard "', expected '" szSearchFor "').")
                else
                {
                    SendInput, !p ; Alt+P aka focus 'Replace with' field in 'Find & Replace' window
                    SendInput, %szReplaceWith% ; Put text
                    SendInput, !l ; Alt+L aka hit 'Replace All' button in 'Find & Replace' window
                    WinWaitActive, LibreOffice 3.6,,3 ; Thats all we can have to pass
                    if ErrorLevel
                        TestsFailed("'LibreOffice 3.6' window failed to appear.")
                    else
                    {
                        WinClose, LibreOffice 3.6
                        WinWaitClose,,,3
                        if ErrorLevel
                            TestsFailed("Unable to close 'LibreOffice 3.6' window.")
                        else
                        {
                            WinWaitActive, Find & Replace,,3
                            if ErrorLevel
                                TestsFailed("Closed 'LibreOffice 3.6' window, but 'Find & Replace' window was not activated.")
                            else
                            {
                                WinClose, Find & Replace
                                WinWaitClose,,,3
                                if ErrorLevel
                                    TestsFailed("'Unable to close 'Find & Replace' window.")
                                else
                                    TestsOK("Replaced '" szSearchFor "' with '" szReplaceWith "'.")
                            }
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
    WinWaitActive, %szFileName% - LibreOffice Writer,,5
    if ErrorLevel
        TestsFailed("'" szFileName " - LibreOffice Writer' window was not activated.")
    else
    {
        clipboard = ; Empty the clipboard
        SendInput, ^a ; Ctrl+A to select all
        SendInput, ^c ; Ctrl+C to copy
        ClipWait, 3
        if ErrorLevel
            TestsFailed("The attempt to copy text from '" szFileName " - LibreOffice Writer' window onto the clipboard failed.")
        else
        {
            szResult = %szText% %szReplaceWith%
            if (clipboard !=  szResult)
                TestsFailed("Text does NOT match (is '" clipboard "', expected '" szResult "').")
            else
            {
                WinClose, %szFileName% - LibreOffice Writer
                WinWaitActive, LibreOffice 3.6,,3 ; 'Do you want to save your changes?'
                if ErrorLevel
                    TestsFailed("'LibreOffice 3.6' (save confirm) window failed to appear.")
                else
                {
                    SendInput, !s ; Alt+S aka hit 'Save' button
                    WinWaitClose, LibreOffice 3.6,,3
                    if ErrorLevel
                        TestsFailed("'LibreOffice 3.6' (save confirm) window failed to close despite Alt+S was sent.")
                    else
                    {
                        WinWaitActive, Confirm File Format,,3
                        if ErrorLevel
                            TestsFailed("'Confirm File Format' window failed to appear.")
                        else
                        {
                            SendInput, !u ; Alt+U aka hit 'Use Text Format' button
                            WinWaitClose, Confirm File Format,,3
                            if ErrorLevel
                                TestsFailed("'Confirm File Format' window failed to close despite Alt+U was sent.")
                            else
                            {
                                WinWaitClose, %szFileName% - LibreOffice Writer,,3
                                if ErrorLevel
                                    TestsFailed("'" szFileName " - LibreOffice Writer' window failed to close.")
                                else
                                {
                                    Process, WaitClose, %ProcessExe%, 5
                                    if ErrorLevel ; The PID still exists
                                        TestsFailed("'" ProcessExe "' process failed to close despite '" szFileName " - LibreOffice Writer' window being closed.")
                                    else
                                    {
                                        Process, WaitClose, %ProcessBin%, 5
                                        if ErrorLevel ; The PID still exists
                                            TestsFailed("'" ProcessBin "' process failed to close despite '" szFileName " - LibreOffice Writer' window being closed.")
                                        else
                                            TestsOK("Replaced, saved, closed '" szFileName " - LibreOffice Writer' window, '" ProcessExe "' and '" ProcessBin "' closed on their own.")
                                    }
                                }
                            }
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
    FileReadLine, szSavedText, %szDocument%, 1 ; Read line 1 from saved document
    if ErrorLevel <> 0
        TestsFailed("Unable to read line 1 from '" szDocument "'.")
    else
    {
        if (szResult != szSavedText)
            TestsFailed("Got unexpected file content (is '" szSavedText "', should be '" szResult "').")
        else
            TestsOK("Read text document, content is correct.")
    }
}
