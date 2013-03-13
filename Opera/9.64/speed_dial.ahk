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

TestName = 6.speed_dial
szURL = http://dsx86.patrickaalto.com

; Test if speed dial works
TestsTotal++
if bContinue
{
    IfWinNotActive, Speed Dial - Opera
        TestsFailed("Window 'Speed Dial - Opera' is not active window.")
    else
    {
        iButtonX := 251
        iButtonY := 227
        PixelGetColor, szButtonColor, %iButtonX%, %iButtonY%
        if ErrorLevel
            TestsFailed("There was a problem with PixelGetColor.")
        else
        {
            szExpectedColor = 0xAAAAAA
            if (szButtonColor != szExpectedColor)
                TestsFailed("Color of '" iButtonX "x" iButtonY "' doesn't match. Got '" szButtonColor "', expected '" szExpectedColor "'.")
            else
            {
                Click, %iButtonX%, %iButtonY% ; Click on first 'Click to add a Web page' button
                WinWaitActive, D_SPEED_DIAL_CONFIG_TITLE,,3
                if ErrorLevel
                    TestsFailed("'D_SPEED_DIAL_CONFIG_TITLE' window failed to appear. #CORE-4975?")
                else
                {
                    ; Scroll to 'Opera Mini'
                    Loop, 8
                        SendInput, {DOWN}

                    SendInput, {ENTER} ; Hit 'OK' button
                    WinWaitClose, D_SPEED_DIAL_CONFIG_TITLE,,3
                    if ErrorLevel
                        TestsFailed("'D_SPEED_DIAL_CONFIG_TITLE' window failed to close despite ENTER was sent to click 'OK' button.")
                    else
                    {
                        Click, %iButtonX%, %iButtonY% ; Click to see if really succeeded configuring speed dial
                        szWinTitle = Opera browser - The alternative web browser - Download free - Opera
                        WinWaitActive, %szWinTitle%,,10
                        if ErrorLevel
                            TestsFailed("'" szWinTitle "' window failed to appear.")
                        else
                            TestsOK("Speed dial in Opera 9.64 works, because '" szWinTitle "' window appeared.")
                    }
                }
            }
        }
    }
}

bTerminateProcess("Opera.exe")
