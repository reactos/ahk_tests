/*
 * Designed for mIRC 6.35
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

TestName = 2.ChatTest

; Test if can type some text in chat window (IRC channel) and exit application correctly
TestsTotal++
if not bContinue
    TestsFailed("We failed somwehere in 'prepare.ahk'.")
else
{
    WinWaitActive, mIRC,,3
    if ErrorLevel
        TestsFailed("Window 'mIRC' failed to appear.")
    else
    {
        iTimeOut := 45
        while iTimeOut > 0
        {
            IfWinActive, mIRC
            {
                ControlGet, OutputVar, Visible,, Static2, mIRC ; Wait until chat window appears
                if OutputVar = 1
                    break
                else
                {
                    Sleep, 1000
                    iTimeOut--
                }
            }
            else
                break ; exit the loop if something poped-up
        }

        if OutputVar <> 1
        {
            ControlGetText, szStatus, mIRC_Status1, mIRC
            TestsFailed("Chat window failed to appear. Status: '" szStatus "'. (iTimeOut=" iTimeOut ")")
        }
        else
        {
            ControlSetText, RichEdit20W1, I confirm that mIRC 7.25 is working on ReactOS, mIRC
            if ErrorLevel
                TestsFailed("Unable to set chat text in 'mIRC' window.")
            else
            {
                SendInput, {ENTER} ; Send text to IRC channel
                ; It would be best to check if text is really sent before closing window
                ; to make sure the test works, but seems there is no way to get text from chat window.
                WinClose, mIRC
                WinWaitActive, Confirm Exit, Are you sure,7
                if ErrorLevel
                    TestsFailed("Window 'Confirm Exit (Are you sure)' failed to appear.")
                else
                {
                    SendInput, !y ; Hit 'Yes' button
                    WinWaitClose, Confirm Exit, Are you sure, 3
                    if ErrorLevel
                        TestsFailed("'Confirm Exit (Are you sure)' window failed to close despite Alt+Y was sent.")
                    else
                    {
                        WinWaitClose, mIRC,,3
                        if ErrorLevel
                            TestsFailed("'mIRC' window failed to disappear after exit was confirmed.")
                        else
                            TestsOK("Connected to IRC server, entered some text in channel and closed application successfully.")
                    }
                }
            }
        }
    }
}
