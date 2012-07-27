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
if bContinue
{
    IfWinActive, Mozilla Firefox Start Page - Mozilla Firefox
    {
        Sleep, 2500
        FileDelete, %A_Desktop%\livecd-56407-dbg.7z ; Make sure it doesn't exist before continuing
        Sleep, 2500
        IfNotExist, %A_Desktop%\livecd-56407-dbg.7z
        {
            SendInput, {CTRLDOWN}l{CTRLUP}http://iso.reactos.org/livecd/livecd-56407-dbg.7z{ENTER} ;Download some file
            
            WinWaitActive, Opening livecd-56407-dbg.7z,,25
            if not ErrorLevel
            {
                SendInput, {ALTDOWN}s{ALTUP} ; Check 'Save file' radio button
                Sleep, 1200
                SendInput, {ENTER} ; Save file by hitting 'OK'. The button is focused by default
                Sleep, 3500
                SetTitleMatchMode, 3 ; Exact match
                WinWaitActive, Downloads,,60 ; Should be enought time to download the file?
                if not ErrorLevel
                {
                    FileGetSize, DFileSize, %A_Desktop%\livecd-56407-dbg.7z ; Desktop is our download dir. See prepare.ahk
                    ExpectedSize = 23030114
                    if (InStr(%DFileSize%, %ExpectedSize%))
                    {
                        TestsOK++
                        OutputDebug, OK: %TestName%:%A_LineNumber%: File downloaded. Size the same as expected.`n
                        bContinue := true
                    }
                    else
                    {
                        TestsFailed++
                        OutputDebug, %TestName%:%A_LineNumber%: Test failed: Downloaded file size is NOT the same as expected [is %DFileSize% and should be %ExpectedSize%].`n
                        bContinue := false
                    }
                }
                else
                {
                    TestsFailed++
                    WinGetTitle, title, A
                    OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'Downloads' window failed to appear, so, downloading failed. Wasn't enough time?. Active window caption: '%title%'.`n
                    bContinue := false
                }
            }
            else
            {
                TestsFailed++
                WinGetTitle, title, A
                OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'Opening livecd-56407-dbg.7z' window failed to appear, so, downloading failed. Active window caption: '%title%'.`n
                bContinue := false
            }
        }
        else
        {
            TestsFailed++
            WinGetTitle, title, A
            OutputDebug, %TestName%:%A_LineNumber%: Test failed: Failed to delete '%A_Desktop%\livecd-56407-dbg.7z'. Active window caption: '%title%'.`n
            bContinue := false
        }
    }
    else
    {
        TestsFailed++
        WinGetTitle, title, A
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'Mozilla Firefox Start Page - Mozilla Firefox' is not active window. Active window caption: '%title%'.`n
        bContinue := false
    }
}

Process, Close, firefox.exe ; Teminate process
