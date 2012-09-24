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

TestName = 2.SaveAsDesktop

; Test if can properly save document to desktop
TestsTotal++
RunApplication("")
if not bContinue
    TestsFailed("We failed somwehere in 'prepare.ahk'.")
else
{
    WinWaitActive, Untitled1 - AbiWord,,3
    if ErrorLevel
        TestsFailed("Window 'Untitled1 - AbiWord' failed to appear.")
    else
    {
        SendInput, AbiWord %TestName% test by Edijus
        WinWaitActive, *Untitled1 - AbiWord,,3
        if ErrorLevel
            TestsFailed("Window '*Untitled1 - AbiWord' failed to appear.")
        else
        {
            SendInput, !{F4}
            WinWaitActive, AbiWord, Save changes, 3
            if ErrorLevel
                TestsFailed("Window 'AbiWord (Save changes)' failed to appear.")
            else
            {
                ControlGetText, OutputVar, Static2, AbiWord ; Get control text
                if ErrorLevel
                    TestsFailed("Unable to get Static2 control text of 'AbiWord (Save changes)' window.")
                else
                {
                    ControlText = Save changes to document Untitled1 before closing? ; 
                    if OutputVar != %ControlText% ; Check if text matches
                        TestsFailed("Control text is not the same as expected in 'AbiWord (Save changes)' window (is '" OutputVar "', should be '" ControlText "', bug 6035?).")
                    else
                    {
                        ControlClick, Button1, AbiWord, Save changes ; Click 'Yes' button
                        if ErrorLevel
                            TestsFailed("Unable to hit 'Yes' button in 'AbiWord (Save changes)' window.")
                        else
                        {
                            WinWaitActive, Save File As,, 7
                            if ErrorLevel
                                TestsFailed("Window 'Save File As' failed to appear.")
                            else
                            {
                                FileDelete, %A_Desktop%\AbiWordTest.txt
                                ControlSetText, Edit1, %A_Desktop%\AbiWordTest.txt, Save File As
                                if ErrorLevel
                                    TestsFailed("Unable to change Edit1 control text to '" A_Desktop "\AbiWordTest.txt' in 'Save File As' window.")
                                else
                                {
                                    ControlClick, Button2, Save File As ; Click 'Save' button
                                    if ErrorLevel
                                        TestsFailed("Unable to hit 'Save' button in 'Save File As' window.")
                                    else
                                    {
                                        WinWaitClose, *Untitled1 - AbiWord,,5
                                        if ErrorLevel
                                            TestsFailed("'*Untitled1 - AbiWord' window failed to close.")
                                        else
                                        {
                                            IfNotExist, %A_Desktop%\AbiWordTest.txt
                                                TestsFailed("'" A_Desktop "\AbiWordTest.txt' does NOT exist, but it should.")
                                            else
                                            {
                                                FileReadLine, OutputVar, %A_Desktop%\AbiWordTest.txt, 1 ; Read first line
                                                if ErrorLevel
                                                    TestsFailed("Unable to read '" A_Desktop "\AbiWordTest.txt'.")
                                                else
                                                {
                                                    TestText = <?xml version="1.0" encoding="UTF-8"?> ; This is what you get
                                                    if OutputVar != %TestText% ; Check if text matches
                                                        TestsFailed("Text is not the same (is '" OutputVar "', should be '" TestText "').")
                                                    else
                                                    {
                                                        Process, Close, AbiWord.exe
                                                        Process, WaitClose, AbiWord.exe, 4
                                                        if ErrorLevel
                                                            TestsFailed("Unable to close 'AbiWord.exe' process.")
                                                        else
                                                            TestsOK("")
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
            }
        }
    }
}
