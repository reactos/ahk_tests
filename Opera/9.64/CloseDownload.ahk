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
    IfWinNotActive, Speed Dial - Opera
        TestsFailed("Window 'Speed Dial - Opera' is not active window.")
    else
    {
        IfExist, %A_MyDocuments%\bootcd-54727-dbgwin.7z
            FileDelete, %A_MyDocuments%\bootcd-54727-dbgwin.7z
        SendInput, {CTRLDOWN}l{CTRLUP} ; Toggle address bar
        SendInput, http://iso.reactos.org/bootcd/bootcd-54727-dbgwin.7z{ENTER}
        
        iTimeOut := 45
        while iTimeOut > 0
        {
            IfWinActive, Blank page - Opera
            {
                WinWaitActive, Downloading file bootcd-54727-dbgwin.7z,,1
                iTimeOut--
            }
            else
                break ; exit the loop if something poped-up
        }

        WinWaitActive, Downloading file bootcd-54727-dbgwin.7z,, 1
        if ErrorLevel
            TestsFailed("Window 'Downloading file bootcd-54727-dbgwin.7z' failed to appear (iTimeOut=" iTimeOut ").")
        else
        {
            TestsInfo("'Downloading file bootcd-54727-dbgwin.7z' window appeared (iTimeOut=" iTimeOut ").")
            SendInput, !n ; Focus 'File name' field
            SendInput, %A_MyDocuments%\bootcd-54727-dbgwin.7z
            SendInput, {ENTER} ; Hit 'Save'
            SetTitleMatchMode, 1 ; A window's title must start with the specified WinTitle to be a match.
            WinWaitActive, Save,, 7
            if ErrorLevel
                TestsFailed("'Save as' dialog failed to appear (SetTitleMatchMode=1).")
            else
            {
                SendInput, {ALTDOWN}s{ALTUP} ; Hit 'Save' in 'Save as'
                Sleep, 3500 ; Download for 3.5 sec before closing Opera
                WinClose, Blank page - Opera,,5
                WinWaitActive, Active,,7 ; ROS 'Active transfers', WinXP 'Active Transfers'
                if ErrorLevel
                    TestsFailed("'Active' dialog failed to appear(SetTitleMatchMode=1).")
                else
                {
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
