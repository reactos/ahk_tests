/*
 * Designed for Mozilla Firefox 12.0
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

TestName = 3.download
 
; Check if can download some file
TestsTotal++
if not bContinue
    TestsFailed("We failed somwehere in 'prepare.ahk'.")
else
{
    IfWinNotActive, Mozilla Firefox Start Page - Mozilla Firefox
        TestsFailed("'Mozilla Firefox Start Page - Mozilla Firefox' is not active window.")
    else
    {
        FileDelete, %A_Desktop%\livecd-56407-dbg.7z ; Make sure it doesn't exist before continuing
        IfExist, %A_Desktop%\livecd-56407-dbg.7z
            TestsFailed("Failed to delete '" A_Desktop "\livecd-56407-dbg.7z'.")
        else
        {
            SendInput, {CTRLDOWN}l{CTRLUP}http://iso.reactos.org/livecd/livecd-56407-dbg.7z{ENTER} ;Download some file
            
            WinWaitActive, Opening livecd-56407-dbg.7z,,10
            if ErrorLevel
                TestsFailed("'Opening livecd-56407-dbg.7z' window failed to appear, so, downloading failed.")
            else
            {
                ; 'ControlClick' won't work here
                SendInput, {ALTDOWN}s{ALTUP} ; Check 'Save file' radio button
                ; 'OK' button is disabled for split of second. There is no way for us to find out
                ; is it enabled or not (there is no control name AHK could use), so, sleep is a must
                Sleep, 500 ; Depends on connection speed?
                SendInput, {ENTER} ; Save file by hitting 'OK'. The button is focused by default
                WinWaitClose,,,5
                if ErrorLevel
                    TestsFailed("'Opening livecd-56407-dbg.7z' window failed to close despite 'ENTER' was sent.")
                else
                {
                    SetTitleMatchMode, 2 ; A window's title can contain WinTitle anywhere inside it to be a match.
                    WinWaitActive, of 1 file - Downloads,,10
                    if ErrorLevel
                        TestsFailed("Window 'of 1 file - Downloads' failed to appear (SetTitleMatchMode=2).")
                    else
                    {
                        SetTitleMatchMode, 3 ; A window's title must exactly match WinTitle to be a match.
                        WinWaitActive, Downloads,,95 ; Should be enought time to download the file?
                        if ErrorLevel
                            TestsFailed("'Downloads' window failed to appear, so, downloading failed. Wasn't enough time?")
                        else
                        {
                            FileGetSize, DFileSize, %A_Desktop%\livecd-56407-dbg.7z ; Desktop is our download dir. See prepare.ahk
                            ExpectedSize := 23030114
                            if DFileSize <> %ExpectedSize%
                                TestsFailed("Downloaded file size is NOT the same as expected [is " DFileSize " and should be " ExpectedSize "].")
                            else
                            {
                                Process, Close, %ProcessExe%
                                Process, WaitClose, %ProcessExe%, 5
                                if ErrorLevel ; The PID still exists.
                                    TestsFailed("Unable to terminate '" ProcessExe "' process.")
                                else
                                    TestsOK("File downloaded. Size the same as expected, '" ProcessExe "' process closed.")
                            }
                        }
                    }
                }
            }
        } 
    }
}
