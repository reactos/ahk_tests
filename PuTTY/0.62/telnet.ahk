/*
 * Designed for PuTTY 0.62
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

TestName = 2.telnet
szHostName = towel.blinkenlights.nl ; 94.142.241.111

; Test if can make telnet connection
TestsTotal++
RunApplication()
if not bContinue
    TestsFailed("We failed somwehere in 'prepare.ahk'.")
else
{
    IfWinNotActive, PuTTY Configuration, Specify the destination
        TestsFailed("'PuTTY Configuration (Specify the destination)' is not active window.")
    else
    {
        SendInput, %szHostName% ; 'Host Name (or IP address)' field is focused by default
        ControlGetText, szHostText, Edit1, PuTTY Configuration, Specify the destination ; OK, we sent host name to the field, now make sure if it really worked
        if ErrorLevel
            TestsFailed("Unable to get text from 'Host Name (or IP address)' field.")
        else
        {
            if (szHostName != szHostText)
                TestsFailed("'Host Name (or IP address)' field text is wrong (is '" szHostText "', should be '" szHostName "').")
            else
            {
                Control, Check, , Button6, PuTTY Configuration, Specify the destination ; Text matches, now, change 'Connection type' to 'Telnet'
                if ErrorLevel
                    TestsFailed("Unable to check 'Telnet' radiobutton in 'PuTTY Configuration (Specify the destination)' window.")
                else
                {
                    ControlGetText, szPort, Edit2, PuTTY Configuration, Specify the destination ; Check if port number changed
                    if ErrorLevel
                        TestsFailed("Unable to get text from 'Port' field.")
                    else
                    {
                        if (szPort != 23)
                            TestsFailed("'Port' field text is wrong (is '" szPort "', should be '23').")
                        else
                        {
                            SendInput, !o ; Alt+O aka hit 'Open' button
                            WinWaitClose, PuTTY Configuration, Specify the destination, 3
                            if ErrorLevel
                                TestsFailed("'PuTTY Configuration (Specify the destination)' window failed to close despite 'Alt+O' was sent.")
                            else
                                TestsOK("Changed host, connection type and hit 'Open' button.")
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
    WinWaitActive, %szHostName% - PuTTY,,20 ; Give it some time
    if ErrorLevel
        TestsFailed("'" szHostName " - PuTTY' window failed to appear.")
    else
    {
        CoordMode, Relative ; Coordinates are relative to the active window.
        szGreenRectangle = 0x00FF00 ; pixel color of that green rectangle
        CoordX := 7
        CoordY := 35
        PixelGetColor, szRectangleColor, %CoordX%, %CoordY%
        if ErrorLevel
            TestsFailed("Unable to get '" CoordX "x" CoordY "' pixel color of '" szHostName " - PuTTY' window.")
        else
        {
            if (szGreenRectangle != szRectangleColor)
                TestsFailed("'" CoordX "x" CoordY "' pixel color of '" szHostName " - PuTTY' window doesn't match (is '" szRectangleColor "', should be '" szGreenRectangle "').")
            else
            {
                szBlackWindowColorHard = 0x000000 ; Color of PuTTY window (black)
                iTimeOut := 800 ; Sleep until pixel color changes
                while iTimeOut > 0
                {
                    PixelGetColor, BlackWindowColor, %CoordX%, %CoordY%
                    if ErrorLevel
                        break ; Unable to get pixel color
                    else
                    {
                        if (szBlackWindowColorHard != BlackWindowColor)
                        {
                            Sleep, 10
                            iTimeOut--
                        }
                        else
                            break ; colors match
                    }
                }
                
                PixelGetColor, BlackWindowColor, %CoordX%, %CoordY%
                if ErrorLevel
                    TestsFailed("Unable to get " CoordX "x" CoordY " pixel color (iTimeOut=" iTimeOut ").")
                else
                {
                    if (szGreenRectangle = BlackWindowColor)
                        TestsFailed("'" CoordX "x" CoordY "' pixel color of '" szHostName " - PuTTY' window did not change (iTimeOut=" iTimeOut ").")
                    else
                    {
                        if (szBlackWindowColorHard != BlackWindowColor)
                            TestsFailed("'" CoordX "x" CoordY "' pixel color of '" szHostName " - PuTTY' window changed to wrong one (is '" BlackWindowColor "', expected '" szBlackWindowColorHard "', iTimeOut=" iTimeOut ").")
                        else
                            TestsOK("Seems like we made successfull telnet connection to '" szHostName "'.")
                    }
                }
            }
        }
    }
}


; Test if can exit PuTTY application
TestsTotal++
if bContinue
{
    IfWinNotActive, %szHostName% - PuTTY
        TestsFailed("'" szHostName " - PuTTY' window is not active.")
    else
    {
        Sleep, 2500 ; Let it do its thing for a bit
        IfWinNotActive, %szHostName% - PuTTY
            TestsFailed("Slept for a while and '" szHostName " - PuTTY' window is not active anymore.")
        else
        {
            WinClose, %szHostName% - PuTTY
            WinWaitActive, PuTTY Exit Confirmation, Are you sure, 3
            if ErrorLevel
                TestsFailed("'PuTTY Exit Confirmation (Are you sure)' window failed to appear.")
            else
            {
                ControlClick, Button1, PuTTY Exit Confirmation, Are you sure ; Hit 'OK' button
                if ErrorLevel
                    TestsFailed("Unable to hit 'OK' button in 'PuTTY Exit Confirmation (Are you sure)' window.")
                else
                {
                    WinWaitClose, PuTTY Exit Confirmation, Are you sure, 3
                    if ErrorLevel
                        TestsFailed("'PuTTY Exit Confirmation (Are you sure)' window failed to close despite 'OK' button being clicked.")
                    else
                    {
                        WinWaitClose, %szHostName% - PuTTY,,3
                        if ErrorLevel
                            TestsFailed("'" szHostName " - PuTTY' window failed to close despite exit was confirmed.")
                        else
                        {
                            Process, WaitClose, %ProcessExe%, 4
                            if ErrorLevel
                                TestsFailed("'" ProcessExe "' process failed to close despite all application windows were closed.")
                            else
                                TestsOK("Closed all application windows and '" ProcessExe "' process closed too.")
                        }
                    }
                }
            }
        }
    }
}
