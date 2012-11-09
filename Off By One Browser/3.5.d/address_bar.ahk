/*
 * Designed for Off By One Browser 3.5.d
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

TestName = 2.address_bar
szURL = http://dsx86.patrickaalto.com
szURL_Title = OffByOne - DSx86 by Patrick Aalto
SetTitleMatchMode, 3 ; A window's title must exactly match WinTitle to be a match

; Test if entering URL using Ctrl+W works
TestsTotal++
RunApplication("")
if not bContinue
    TestsFailed("We failed somwehere in 'prepare.ahk'.")
else
{
    IfWinNotActive, The OffByOne Browser
        TestsFailed("'The OffByOne Browser' window is not active.")
    else
    {
        SendInput, ^w ; Cltr+W aka File->Go to a Web Page
        WinWaitActive, Open URL, URL, 3
        if ErrorLevel
            TestsFailed("'Open URL (URL)' window failed to appear.")
        else
        {
            ControlSetText, Edit1, %szURL%, Open URL, URL ; Type address
            if ErrorLevel
                TestsFailed("Unable to enter '" szURL "' in 'Open URL (URL)' window.")
            else
            {
                ControlGetText, szTypedURL, Edit1, Open URL, URL
                if ErrorLevel
                    TestsFailed("Unable to get text from address field in 'Open URL (URL)' window.")
                else
                {
                    if (szTypedURL != szURL)
                        TestsFailed("Addresses doesn't match (is '" szTypedURL "', expected '" szURL "').")
                    else
                    {
                        SendInput, {ENTER} ; go to specified address
                        WinWaitClose, Open URL, URL, 3
                        if ErrorLevel
                            TestsFailed("'Open URL (URL)' window failed to close despite ENTER was sent.")
                        else
                        {
                            WinWaitActive, %szURL_Title%,,5
                            if ErrorLevel
                                TestsFailed("'" szURL_Title "' window is not an active window.")
                            else
                            {
                                Sleep, 3500 ; Sleep for a while, maybe something unexpected will happen
                                IfWinNotActive, %szURL_Title%
                                    TestsFailed("Slept for a while and '" szURL_Title "' window is not active anymore.")
                                else
                                    TestsOK("Entering URL by Ctrl+W works.")
                            }
                        }
                    }
                }
            }
        }
    }
}


; Test if can close application
TestsTotal++
if bContinue
{
    WinClose, %szURL_Title%
    WinWaitClose, %szURL_Title%,,3
    if ErrorLevel
        TestsFailed("Unable to close '" szURL_Title "' window.")
    else
    {
        Process, WaitClose, %ProcessExe%, 4
        if ErrorLevel
            TestsFailed("'" ProcessExe "' process failed to close despite '" szURL_Title "' window closed.")
        else
            TestsOK("Closing application works.")
    }
}
