/*
 * Designed for Mozilla Firefox 12.0
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

TestName = 5.fullscreen

 
; Check if can make Firefox window to go full screen
TestsTotal++
if not bContinue
    TestsFailed("We failed somwehere in 'prepare.ahk'.")
else
{
    IfWinNotActive, Mozilla Firefox Start Page - Mozilla Firefox
        TestsFailed("'Mozilla Firefox Start Page - Mozilla Firefox' is not active window.")
    else
    {
        SendInput, {F11} ; View -> Full Screen

        iTimeOut := 700
        while (iTimeOut > 0)
        {
            IfWinNotActive, Mozilla Firefox Start Page - Mozilla Firefox
                break
            else
            {
                WinGetPos, WinX, WinY, WinWidth, WinHeight, Mozilla Firefox Start Page - Mozilla Firefox
                if ((WinWidth = A_ScreenWidth) AND (WinHeight = A_ScreenHeight))
                    break ; Window is fullscreen
                else
                {
                    Sleep, 10
                    iTimeOut--
                }
            }
        }

        Sleep, 2500 ; Stay fullscreen for a bit. Maybe something will crash.
        IfWinNotActive, Mozilla Firefox Start Page - Mozilla Firefox
            TestsFailed("Sent F11 and 'Mozilla Firefox Start Page - Mozilla Firefox' window became inactive (iTimeOut=" iTimeOut ").")
        else
        {
            WinGetPos, WinX, WinY, WinWidth, WinHeight, Mozilla Firefox Start Page - Mozilla Firefox
            if not ((WinWidth = A_ScreenWidth) AND (WinHeight = A_ScreenHeight))
                TestsFailed("Sent F11 to 'Mozilla Firefox Start Page - Mozilla Firefox' window, but window size is wrong. Is '" WinWidth "x" WinHeight "', should be '" A_ScreenWidth "x" A_ScreenHeight "'. (iTimeOut=" iTimeOut ")")
            else
                TestsOK("You can make Firefox go fullscreen by clicking F11 in your keyboard. (iTimeOut=" iTimeOut ")")
        }
    }
}


bTerminateProcess(ProcessExe)
