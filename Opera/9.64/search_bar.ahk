/*
 * Designed for Opera 9.64
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

TestName = 8.search_bar
szSearchTerm = ReactOS

; Test if we can open search engine using search bar
TestsTotal++
if bContinue
{
    IfWinNotActive, Speed Dial - Opera
        TestsFailed("Window 'Speed Dial - Opera' is not active window.")
    else
    {
        SendInput, ^e ; Ctrl+E. Toggle searc bar
        SendInput, %szSearchTerm% ; Enter search term
        clipboard = ; Empty the clipboard
        Send, ^a ; Ctrl+A
        Send, ^c ; Ctrl+C
        ClipWait, 2
        if ErrorLevel
            TestsFailed(" The attempt to copy text onto the clipboard failed.")
        else
        {
            if clipboard <> %szSearchTerm%
                TestsFailed("Clipboard and URL contents are not the same (expected '" szSearchTerm "', got '" clipboard "'). Ctrl+E doesnt work?")
            else
            {
                SendInput, {ENTER} ; Start the search
                TestsInfo("Successfully typed '" szSearchTerm "' to search bar using Ctrl+E.")
                WinWaitActive, %szSearchTerm% - Google Search - Opera,,10
                if ErrorLevel
                    TestsFailed("'" szSearchTerm " - Google Search- Opera' window failed to appear.")
                else
                    TestsOK("Ctrl+E and search bar works.")
            }
        }
    }
}

bTerminateProcess(ProcessExe)
