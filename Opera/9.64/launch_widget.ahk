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

TestName = 7.launch_widget

; Test if can download widget and launch it
TestsTotal++
if bContinue
{
    IfWinNotActive, Speed Dial - Opera
        TestsFailed("Window 'Speed Dial - Opera' is not active window.")
    else
    {
        szURL = http://widgets.opera.com/widget/download/force/5062/1.1/
        SendInput, ^l ; Ctrl+L to focus addressbar
        SendInput, %szURL%{ENTER} ; Enter URL and start loading it
        WinWaitActive, Widget Download,,5
        if ErrorLevel
            TestsFailed("'Widget Download' window failed to appear.")
        else
        {
            TestsInfo("'Widget Download' window appeared, waiting for it to close.")
            iTimeOut := 20
            while iTimeOut > 0
            {
                IfWinActive, Widget Download
                {
                    WinWaitClose, Widget Download,, 1
                    iTimeOut--
                }
                else
                    break ; exit the loop if something poped-up
            }
            WinWaitClose, Widget Download,,1
            if ErrorLevel
                TestsFailed("'Widget Download' window failed to close.")
            else
            {
                WinWaitActive, Save downloaded widget,,5
                if ErrorLevel
                    TestsFailed("'Save downloaded widget' window failed to appear.")
                else
                {
                    SendInput, {ENTER} ; Hit 'Yes' button in 'Save downloaded widget' window.
                    WinWaitClose, Save downloaded widget,,2
                    if ErrorLevel
                        TestsFailed("'Save downloaded widget' window failed to close despite ENTER was sent to close 'Yes' button.")
                    else
                    {
                        WinWaitActive, Scientific Calculator,,2
                        if ErrorLevel
                            TestsFailed("'Scientific Calculator' window failed to appear. #CORE-4976?")
                        else
                            TestsOK("'Scientific Calculator' window appeared, so, can download and launch widgets. No #CORE-4976.")
                    }
                }
            }
        }
    }
}

bTerminateProcess("Opera.exe")
