/*
 * Designed for Mozilla Firefox 2.0.0.20
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
        Sleep, 2500
        FileDelete, %A_Desktop%\livecd-56407-dbg.7z ; Make sure it doesn't exist before continuing
        Sleep, 2500
        IfExist, %A_Desktop%\livecd-56407-dbg.7z
            TestsFailed("Failed to delete '" A_Desktop "\livecd-56407-dbg.7z'.")
        else
        {
            SendInput, {CTRLDOWN}l{CTRLUP}http://iso.reactos.org/livecd/livecd-56407-dbg.7z{ENTER} ;Download some file
            
            WinWaitActive, Opening livecd-56407-dbg.7z,,25
            if ErrorLevel
                TestsFailed("'Opening livecd-56407-dbg.7z' window failed to appear, so, downloading failed.")
            else
            {
                ; 'ControlClick' won't work here
                SendInput, {ALTDOWN}s{ALTUP} ; Check 'Save file' radio button
                Sleep, 1200
                SendInput, {ENTER} ; Save file by hitting 'OK'. The button is focused by default
                Sleep, 3500
                SetTitleMatchMode, 3
                WinWaitActive, Downloads,,65 ; Should be enought time to download the file?
                if ErrorLevel
                    TestsFailed("'Downloads' window failed to appear, so, downloading failed. Wasn't enough time?")
                else
                {
                    FileGetSize, DFileSize, %A_Desktop%\livecd-56407-dbg.7z ; Desktop is our download dir. See prepare.ahk
                    ExpectedSize = 23030114
                    if not (InStr(%DFileSize%, %ExpectedSize%))
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
