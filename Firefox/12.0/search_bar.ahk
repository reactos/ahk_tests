/*
 * Designed for Mozilla Firefox 12.0
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

TestName = 4.search_bar
 
; Check if we can change search engine to Yahoo! and type inside search field
TestsTotal++
if not bContinue
    TestsFailed("We failed somwehere in 'prepare.ahk'.")
else
{
    IfWinNotActive, Mozilla Firefox Start Page - Mozilla Firefox
        TestsFailed("'Mozilla Firefox Start Page - Mozilla Firefox' is not active window.")
    else
    {
        SearchArrowImg = %A_WorkingDir%\Media\searcharrow.png

        IfNotExist, %SearchArrowImg%
            TestsFailed("Can NOT find '" SearchArrowImg "'.")
        else
        {
            ImageSearch, FoundX, FoundY, 0, 0, A_ScreenWidth, A_ScreenHeight, *11 %SearchArrowImg%
            if ErrorLevel = 2
                TestsFailed("Could not conduct the ImageSearch.")
            else if ErrorLevel = 1
                TestsFailed("The search arrow image '" SearchArrowImg "' could NOT be found on the screen.")
            else
            {
                MouseClick, left, %FoundX%, %FoundY%
                SendInput, y ;Y for Yahoo search
                SendInput, {CTRLDOWN}k{CTRLUP}edijus ; Go to search bar and type 'edijus'
                ; copy text to clipboard and compare
                clipboard = ; Empty the clipboard
                Send, ^a ; Select all
                Send, ^c
                ClipWait, 2
                if ErrorLevel
                    TestsFailed("The attempt to copy text onto the clipboard failed.")
                else
                {
                    if clipboard <> edijus
                        TestsFailed("Clipboard content is not the same as expected (is '" clipboard "', should be 'edijus') Can't focus search bar using Ctrl+K?.")
                    else
                    {
                        SendInput, {ENTER}
                        WinWaitActive, edijus - Yahoo Search Results - Mozilla Firefox,,15 ; Time depends on connection speed
                        if ErrorLevel
                            TestsFailed("'edijus - Yahoo Search Results - Mozilla Firefox' window failed to appear, so, search bar does not work. Bug #CORE-6342?")
                        else
                        {
                            Sleep, 5500 ; Let the URL to load, maybe something will fail
                            Process, Close, %ProcessExe%
                            Process, WaitClose, %ProcessExe%, 5
                            if ErrorLevel ; The PID still exists.
                                TestsFailed("Unable to terminate '" ProcessExe "' process.")
                            else
                                TestsOK("'edijus - Yahoo Search Results - Mozilla Firefox' window appeared, so search bar works, '" ProcessExe "' process closed.")
                        }
                    }
                }
            }
        }
    }
}
