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
TestName = 5.Send_Input
szDocument =  ; Case sensitive! [No file to open]
CharList1 = 0123456789
CharList2 = abcdefghijklmnopqrstuvwxyz
CharList3 := "|\,.~$%&*()_[];:'@?/<>"

RunNotepad(szDocument)
if not bContinue
    TestsFailed("We failed somewhere in prepare.ahk.")
else
{
    IfWinNotActive, new  1 - Notepad++
        TestsFailed("Window 'new  1 - Notepad++' is not active.")
    else
    {
        iTimeOut = 150
        bContinue := false
        while iTimeOut > 0 
        {
            IfWinActive, new  1 - Notepad++
            {
                SendInput, %CharList1%
                Sleep, 100 ; 100
                iTimeOut--
            }
            else
            {
                IfWinActive, *new  1 - Notepad++
                {
                    bContinue := true
                    break
                }
                else
                {
                    TestsFailed("Unexpected window.")
                    break
                }
            }
        }
        
        if bContinue
        {
            SendInput, ^a ; Select all previous text
            clipboard = ; Empty the clipboard
            SendInput, ^c ; Copy selected text to clipboard
            ClipWait, 2
            if ErrorLevel
                TestsFailed("The first attempt to copy text onto the clipboard failed.")
            else
            {
                if clipboard <> %CharList1%
                    TestsFailed("Text does NOT mach. Expected '" CharList1 "', got '" clipboard "'")
                else
                {
                    IfWinNotActive, *new  1 - Notepad++
                        TestsFailed("'*new  1 - Notepad++' window is not an active window.")
                    else
                    {
                        SendInput, ^a ; Select all previous text
                        SendInput, %CharList2%
                        clipboard = ; Empty the clipboard
                        SendInput, ^a ; Select all current text
                        SendInput, ^c ; Copy selected text to clipboard
                        ClipWait, 2
                        if ErrorLevel
                            TestsFailed("The second attempt to copy text onto the clipboard failed.")
                        else
                        {
                            if clipboard <> %CharList2%
                                TestsFailed("Text does NOT mach. Expected '" CharList2 "', got '" clipboard "'")
                            else
                            {
                                SendInput, ^a ; Select all previous text
                                SendInput, %CharList3%
                                clipboard = ; Empty the clipboard
                                SendInput, ^a ; Select all current text
                                SendInput, ^c ; Copy selected text to clipboard
                                ClipWait, 2
                                if ErrorLevel
                                    TestsFailed("The third attempt to copy text onto the clipboard failed.")
                                else
                                {
                                    if clipboard <> %CharList3%
                                        TestsFailed("Text does NOT mach. Expected '" CharList3 "', got '" clipboard "'")
                                    else
                                    {
                                        TestsOK("SendInput sent numbers 0-9, letters a-z and some characters successfully.")
                                        TerminateApplication()
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
