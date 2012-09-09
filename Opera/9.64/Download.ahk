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

TestName = 3.Download

; Test if we can download some file
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
        IfExist, %A_MyDocuments%\livecd-56407-dbg.7z
            FileDelete, %A_MyDocuments%\livecd-56407-dbg.7z
        SendInput, {CTRLDOWN}l{CTRLUP}
        Sleep, 700
        SendInput, http://iso.reactos.org/livecd/livecd-56407-dbg.7z{ENTER} ;Download some file
        Sleep, 5000 ; Let it to respond
        WinWaitActive, Downloading file livecd-56407-dbg.7z,,25
        if ErrorLevel
            TestsFailed("Window 'Downloading file livecd-56407-dbg.7z' failed to appear.")
        else
        {
            SendInput, {ENTER} ; Default option is 'Save' and Alt+S doesn't work here. :/
            SetTitleMatchMode, 1 ; ReactOS 'Save as', WinXP 'Save As', so match if wnd starts with 'Save'
            WinWaitActive, Save,, 15 ; FIXME: add WinText, so we really know it is right dialog
            if ErrorLevel
                TestsFailed("'Save as' dialog failed to appear.")
            else
            {
                Sleep, 700
                SendInput, !n ; Focus 'File name' field
                SendInput, %A_MyDocuments%\livecd-56407-dbg.7z
                Sleep, 700
                SendInput, {ALTDOWN}s{ALTUP} ; Hit 'Save'
                Sleep, 2500
                SendInput, {CTRLDOWN}{TAB}{CTRLUP} ; Navigate thru tabs to 'Transfers' tab
                WinWaitActive, Transfers - Opera,,60 ; 1 minute
                if ErrorLevel
                    TestsFailed("Window 'Transfers - Opera' failed to appear.")
                else
                {
                    Sleep, 1500
                    FileGetSize, DFileSize, %A_MyDocuments%\livecd-56407-dbg.7z
                    ExpectedSize = 23030114
                    if not (InStr(%DFileSize%, %ExpectedSize%))
                        TestsFailed("Downloaded file size is NOT the same as expected [is " DFileSize " and should be " ExpectedSize "].")
                    else
                    {
                        Process, Close, %ProcessExe%
                        Process, WaitClose, %ProcessExe%, 4
                        if ErrorLevel
                            TestsFailed("Unable to terminate '" ProcessExe "' process.")
                        else
                            TestsOK("File downloaded. Size the same as expected.")
                    }
                }
            }
        }
    }
}
