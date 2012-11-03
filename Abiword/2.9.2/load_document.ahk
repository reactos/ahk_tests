/*
 * Designed for AbiWord 2.6.4
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

TestName = 2.load_document
szDocument = C:\AbiWordTest.txt

; Test if can open, edit and save text file
TestsTotal++
{
    IfExist, %szDocument%
    {
        FileDelete, %szDocument%
        if ErrorLevel
            TestsFailed("Unable to delete '" szDocument "'.")
    }

    if bContinue
    {
        FileAppend, AbiWordTezzt`n, %szDocument% ; Create document
        if ErrorLevel
            TestsFailed("Can not create and edit '" szDocument "'.")
        else
        {
            SplitPath, szDocument, fname
            RunApplication(szDocument) ; Open the document
            if not bContinue
                TestsFailed("We failed somwehere in 'prepare.ahk'.")
            else
            {
                IfWinNotActive, %fname% - AbiWord
                    TestsFailed("Window '" fname " - AbiWord' failed to appear.")
                else
                {
                    SendInput, ^h ; Ctrl+H aka Edit->Replace
                    WinWaitActive, Replace - %fname%,,3
                    if ErrorLevel
                        TestsFailed("Window 'Replace - " fname "' failed to appear. Ctrl+H is not working?")
                    else
                    {
                        SendInput, !n ; Alt+N to focus 'Find what' field
                        SendInput, zz
                        ControlGetText, FindWhat, Edit1
                        if (FindWhat != "zz")
                            TestsFailed("Text doesn't match (expected 'zz', got '" FindWhat "').")
                    }
                }
            }
        }
    }
    
    if bContinue
    {
        SendInput, !p ; Alt+P to focus 'Replace with' field
        SendInput, s
        ControlGetText, ReplaceWith, Edit2
        if (ReplaceWith != "s")
            TestsFailed("Text doesn't match (expected 's', got '" ReplaceWith "').")
        else
        {
            SendInput, !a ; Hit 'Replace All' button
            WinWaitActive, AbiWord, 1 replacements, 3
            if ErrorLevel
                TestsFailed("'AbiWord (1 replacements)' window failed to appear.")
            else
            {
                ControlClick, Button1 ; Hit 'OK' button
                if ErrorLevel
                    TestsFailed("Unable to hit 'OK' button in 'AbiWord (1 replacements)' window.")
                else
                {
                    WinWaitClose,,,3
                    if ErrorLevel
                        TestsFailed("'AbiWord (1 replacements)' window failed to close despite 'OK' button being closed")
                    else
                    {
                        WinWaitActive, *%fname% - AbiWord,,3
                        if ErrorLevel
                            TestsFailed("'*" fname " - AbiWord' is not an active window.")
                        else
                        {
                            SendInput, ^s ; Ctrl+S
                            WinWaitActive, %fname% - AbiWord,,3
                            if ErrorLevel
                                TestsFailed("'" fname " - AbiWord' is not an active window.")
                        }
                    }
                }
            }
        }
    }
    
    if bContinue
    {
        WinClose
        WinWaitClose,,,3
        if ErrorLevel
            TestsFailed("Unable to close '" fname " - AbiWord' window.")
        else
        {
            Process, WaitClose, %ProcessExe%, 4
            if ErrorLevel
                TestsFailed("'" ProcessExe "' process failed to close despite '" fname " - AbiWord' window has closed.")
            else
            {
                FileReadLine, Line, %szDocument%, 1
                if ErrorLevel
                    TestsFailed("Unable to read '" szDocument "'.")
                else
                {
                    if (Line != "AbiWordTest")
                        TestsFailed("Contents of '" szDocument "' are not the same as expected (is '" Line "', should be 'AbiWordTest').")
                    else
                        TestsOK("Opened document, replaced some text, closed application, comapred text.")
                }
            }
        }
    }
}
