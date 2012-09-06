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

        Sleep, 1000
        ImageSearch, FoundX, FoundY, 0, 0, A_ScreenWidth, A_ScreenHeight, *4 %SearchArrowImg%
        if ErrorLevel = 2
            TestsFailed("Could not conduct the ImageSearch ('" SearchArrowImg "' is missing?).")
        else if ErrorLevel = 1
            TestsFailed("The search arrow image '" SearchArrowImg "' could NOT be found on the screen.")
        else
        {
            MouseClick, left, %FoundX%, %FoundY%
            Sleep, 500
            SendInput, y ;Y for Yahoo search
            Sleep, 700
            SendInput, {CTRLDOWN}k{CTRLUP}edijus{ENTER} ; Go to search bar
            Sleep, 7500 ; Let it to load, maybe something will fail
            WinWaitActive, edijus - Yahoo! Search Results - Mozilla Firefox,,25
            if ErrorLevel
                TestsFailed("'edijus - Yahoo! Search Results - Mozilla Firefox' window failed to appear, so, search bar do not work. Bugs 5574, 5930, 6990?")
            else
            {
                Process, Close, %ProcessExe%
                Process, WaitClose, %ProcessExe%, 5
                if ErrorLevel ; The PID still exists.
                    TestsFailed("Unable to terminate '" ProcessExe "' process.")
                else
                    TestsOK("'edijus - Yahoo! Search Results - Mozilla Firefox' window appeared, so search bar works, '" ProcessExe "' process closed.")
            }
        }
    }
}
