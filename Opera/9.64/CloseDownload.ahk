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


; Test if we can exit properly when download in progress. Bug #5651
TestsTotal++
if not bContinue
    TestsFailed("We failed somewhere in prepare.ahk")
else
{
    WinWaitActive, Welcome to Opera - Opera,, 5
    if not ErrorLevel
    {
        SendInput, {CTRLDOWN}t{CTRLUP}
        WinWaitActive, Speed Dial - Opera,,15
        if not ErrorLevel
        {
            IfExist, %A_MyDocuments%\bootcd-54727-dbgwin.7z
                FileDelete, %A_MyDocuments%\bootcd-54727-dbgwin.7z
            Sleep, 1000
            SendInput, {CTRLDOWN}l{CTRLUP}
            Sleep, 700
            SendInput, http://iso.reactos.org/bootcd/bootcd-54727-dbgwin.7z{ENTER}
            WinWaitActive, Downloading file bootcd-54727-dbgwin.7z,,15
            if not ErrorLevel
            {
                Sleep, 1500
                SendInput, {ENTER} ; Hit 'Save' in Opera
                SetTitleMatchMode, 1
                WinWaitActive, Save,, 15 
                if not ErrorLevel
                {
                    Sleep, 2500
                    SendInput, {ALTDOWN}s{ALTUP} ; Hit 'Save' in 'Save as'
                    Sleep, 3500 ; Download for 3.5 sec before closing Opera
                    WinClose, Blank page - Opera,,5
                    SetTitleMatchMode, 1
                    WinWaitActive, Active,,7 ; ROS 'Active transfers', WinXP 'Active Transfers'
                    if not ErrorLevel
                    {
                        Sleep, 1500
                        SendInput, {ENTER} ; Hit 'OK'
                        TestsOK("Closing Opera while download is in progress works.")
                    }
                    else
                        TestsFailed("'Active transfers' dialog failed to appear.")
                }
                else
                    TestsFailed("'Save as' dialog failed to appear.")
            }
            else
                TestsFailed("Window 'Downloading file bootcd-54727-dbgwin.7z' failed to appear.")
        }
        else
            TestsFailed("Window 'Speed Dial - Opera' was NOT found. Failed to open new tab.")
    }
    else
        TestsFailed("Window 'Welcome to Opera - Opera' was NOT found.")
}

Process, Close, Opera.exe ; Terminate process