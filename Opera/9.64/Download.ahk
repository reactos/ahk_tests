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
    IfWinNotActive, Speed Dial - Opera
        TestsFailed("Window 'Speed Dial - Opera' is not active window.")
    else
    {
        IfExist, %A_MyDocuments%\livecd-56407-dbg.7z
            FileDelete, %A_MyDocuments%\livecd-56407-dbg.7z
        SendInput, {CTRLDOWN}l{CTRLUP}
        SendInput, http://iso.reactos.org/livecd/livecd-56407-dbg.7z{ENTER} ;Download some file
        
        iTimeOut := 45
        while iTimeOut > 0
        {
            IfWinActive, Blank page - Opera
            {
                WinWaitActive, Downloading file livecd-56407-dbg.7z,,1
                iTimeOut--
            }
            else
                break ; exit the loop if something poped-up
        }

        WinWaitActive, Downloading file livecd-56407-dbg.7z,, 1
        if ErrorLevel
            TestsFailed("Window 'Downloading file livecd-56407-dbg.7z' failed to appear (iTimeOut=" iTimeOut ").")
        else
        {
            TestsInfo("'Downloading file livecd-56407-dbg.7z' window appeared (iTimeOut=" iTimeOut ").")
            SendInput, {ENTER} ; Default option is 'Save' and Alt+S doesn't work here. :/
            SetTitleMatchMode, 1 ; ReactOS 'Save as', WinXP 'Save As', so match if wnd starts with 'Save'
            WinWaitActive, Save,, 7
            if ErrorLevel
                TestsFailed("'Save as' dialog failed to appear.")
            else
            {
                SendInput, !n ; Focus 'File name' field
                SendInput, %A_MyDocuments%\livecd-56407-dbg.7z
                SendInput, {ALTDOWN}s{ALTUP} ; Hit 'Save'
                WinWaitClose, Save,,3
                if ErrorLevel
                    TestsFailed("'Save' dialog failed to close.")
                else
                {
                    WinWaitActive, Blank page - Opera,, 3
                    if ErrorLevel
                        TestsFailed("'Blank page - Opera' window failed to appear.")
                    else
                    {
                        SendInput, {CTRLDOWN}{TAB}{CTRLUP} ; Navigate thru tabs to 'Transfers' tab
                        SetTitleMatchMode, 1 ; A window's title must start with the specified WinTitle to be a match.
                        WinWaitActive, Transfers 0,, 5 ; Expected window title is something like 'Transfers 03:12 - Opera'
                        if ErrorLevel
                            TestsFailed("Window 'Transfers 0' failed to appear ( SetTitleMatchMode=1).")
                        else
                        {
                            iTimeOut := 120
                            while iTimeOut > 0
                            {
                                IfWinActive, Transfers 0
                                {
                                    WinWaitActive, Transfers - Opera,,1
                                    iTimeOut--
                                }
                                else
                                    break ; exit the loop if something poped-up
                            }

                            WinWaitActive, Transfers - Opera,,1
                            if ErrorLevel
                                TestsFailed("Window 'Transfers - Opera' failed to appear (iTimeOut=" iTimeOut ").")
                            else
                            {
                                Sleep, 2000 ; Extra sleep is required, because download is not actually done
                                FileGetSize, DFileSize, %A_MyDocuments%\livecd-56407-dbg.7z
                                ExpectedSize := 23030114
                                if DFileSize <> %ExpectedSize%
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
        }
    }
}
