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

TestName = 5.CloseDownload

; Test if we can exit properly when download in progress. Bug #5651
TestsTotal++
if not bContinue
    TestsFailed("We failed somewhere in prepare.ahk")
else
{
    WinWaitActive, Welcome to Opera - Opera,, 5
    if ErrorLevel
        TestsFailed("Window 'Welcome to Opera - Opera' was NOT found.")
    else
    {
        SendInput, {CTRLDOWN}t{CTRLUP}
        WinWaitActive, Speed Dial - Opera,,15
        if ErrorLevel
            TestsFailed("Window 'Speed Dial - Opera' was NOT found. Failed to open new tab.")
        else
        {
            IfExist, %A_MyDocuments%\bootcd-54727-dbgwin.7z
                FileDelete, %A_MyDocuments%\bootcd-54727-dbgwin.7z
            Sleep, 1000
            SendInput, {CTRLDOWN}l{CTRLUP}
            Sleep, 700
            SendInput, http://iso.reactos.org/bootcd/bootcd-54727-dbgwin.7z{ENTER}
            WinWaitActive, Downloading file bootcd-54727-dbgwin.7z,,15
            if ErrorLevel
                TestsFailed("Window 'Downloading file bootcd-54727-dbgwin.7z' failed to appear.")
            else
            {
                Sleep, 700
                SendInput, !n ; Focus 'File name' field
                SendInput, %A_MyDocuments%\bootcd-54727-dbgwin.7z
                Sleep, 700
                SendInput, {ENTER} ; Hit 'Save' in Opera
                SetTitleMatchMode, 1 ; A window's title must start with the specified WinTitle to be a match.
                WinWaitActive, Save,, 15 
                if ErrorLevel
                    TestsFailed("'Save as' dialog failed to appear (SetTitleMatchMode=1).")
                else
                {
                    Sleep, 2500
                    SendInput, {ALTDOWN}s{ALTUP} ; Hit 'Save' in 'Save as'
                    Sleep, 3500 ; Download for 3.5 sec before closing Opera
                    WinClose, Blank page - Opera,,5
                    WinWaitActive, Active,,7 ; ROS 'Active transfers', WinXP 'Active Transfers'
                    if ErrorLevel
                        TestsFailed("'Active' dialog failed to appear(SetTitleMatchMode=1).")
                    else
                    {
                        Sleep, 1500
                        SendInput, {ENTER} ; Hit 'OK'
                        WinWaitClose, Blank page - Opera,,10
                        if ErrorLevel
                            TestsFailed("Window 'Blank page - Opera' failed to close.")
                        else
                            TestsOK("Closing Opera while download is in progress works.")
                    }
                }
            }
        }
    }
}
