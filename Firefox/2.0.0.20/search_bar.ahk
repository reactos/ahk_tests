/*
 * Designed for Mozilla Firefox 2.0.0.20
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
if bContinue
{
    IfWinActive, Mozilla Firefox Start Page - Mozilla Firefox
    {
        SearchArrowImg = %A_WorkingDir%\Media\FF_2_Search_Arrow.jpg

        Sleep, 1000
        ImageSearch, FoundX, FoundY, 0, 0, A_ScreenWidth, A_ScreenHeight, *11 %SearchArrowImg%
        if ErrorLevel = 2
        {
            TestsFailed("")
            OutputDebug, %TestName%:%A_LineNumber%: Test failed: Could not conduct the ImageSearch (%SearchArrowImg% is missing?).`n
            bContinue := false
        }
        else if ErrorLevel = 1
        {
            TestsFailed("")
            OutputDebug, %TestName%:%A_LineNumber%: Test failed: The search arrow image %SearchArrowImg% could NOT be found on the screen.`n
            bContinue := false
        }
        else
        {
            MouseClick, left, %FoundX%, %FoundY%
            Sleep, 500
            SendInput, y ;Y for Yahoo search
            Sleep, 700
            SendInput, {CTRLDOWN}k{CTRLUP}edijus{ENTER} ; Go to search bar
            Sleep, 7500 ; Let it to load, maybe something will fail
            WinWaitActive, edijus - Yahoo! Search Results - Mozilla Firefox,,25
            if not ErrorLevel
                TestsOK("'edijus - Yahoo! Search Results - Mozilla Firefox' window appeared, so search bar works.")
            else
                TestsFailed("'edijus - Yahoo! Search Results - Mozilla Firefox' window failed to appear, so, search bar do not work. Bugs 5574, 5930, 6990?")
        }
    }
    else
        TestsFailed("'Mozilla Firefox Start Page - Mozilla Firefox' is not active window.")
}
else
    TestsFailed("We failed somwehere in 'prepare.ahk'.")

Process, Close, firefox.exe ; Teminate process
