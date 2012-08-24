/*
 * Designed for SeaMonkey 1.1.17
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

TestName = 2.download

szFileURL = http://iso.reactos.org/livecd/livecd-57139-dbg.7z

; Test if can download file
TestsTotal++
if bContinue
{
    IfWinActive, Welcome to SeaMonkey - SeaMonkey
    {
        SendInput, {ALTDOWN}d{ALTUP} ; Go to address bar
        Sleep, 500
        SendInput, %szFileURL%{ENTER} 
        SplitPath, szFileURL, NameExt
        FileDelete, %A_Desktop%\%NameExt%
        WinWaitActive, Opening %NameExt%,, 10
        if not ErrorLevel
        {
            SendInput, {ALTDOWN}s{ALTUP} ; Check 'Save it to disk' radio button
            Sleep, 3000 ; wait until 'OK' gets enabled
            SendInput, {ENTER} ; Hit 'OK' button
            WinWaitActive, Enter name of file to save to...,,5
            if not ErrorLevel
            {
                ControlSetText, Edit1, %A_Desktop%\%NameExt%, Enter name of file to save to... ; Enter file path and name
                if not ErrorLevel
                {
                    Sleep, 1000
                    ControlClick, Button2, Enter name of file to save to... ; Hit 'Save' button
                    if not ErrorLevel
                    {
                        WinWaitActive, Download Manager,,5
                        if not ErrorLevel
                        {
                            Sleep, 1000
                            SendInput, {ALTDOWN}i{ALTUP} ; Hit 'Properties' in 'Download Manager'
                            SetTitleMatchMode, 2 ; A window's title can contain WinTitle anywhere inside it to be a match.
                            WinWaitActive, of %NameExt% Saved,,5
                            if not ErrorLevel
                            {
                                Sleep, 1000
                                TimeOut := 0
                                bDone := false
                                while TimeOut < 240
                                {
                                    Sleep, 1000
                                    TimeOut++
                                    bDone := false
                                    IfWinActive, 100`% of %NameExt% Saved ; Wait for 100%
                                    {
                                        TimeOut := 240
                                        bDone := true
                                    }
                                }
                                
                                if bDone
                                {
                                    TestsOK()
                                    SetTitleMatchMode, 3 ; A window's title must exactly match WinTitle to be a match.
                                    OutputDebug, OK: %TestName%:%A_LineNumber%: '%szFileURL%' downloaded, terminating application.`n
                                    Process, Close, seamonkey.exe
                                }
                                else
                                {
                                    TestsFailed()
                                    WinGetTitle, title, A
                                    OutputDebug, %TestName%:%A_LineNumber%: Test failed: Timed out. Active window caption: '%title%'.`n
                                }
                            }
                            else
                            {
                                TestsFailed()
                                WinGetTitle, title, A
                                OutputDebug, %TestName%:%A_LineNumber%: Test failed: Window 'of %NameExt% Saved' failed to appear (SetTitleMatchMode=2). Active window caption: '%title%'.`n
                            }
                        }
                        else
                        {
                            TestsFailed()
                            WinGetTitle, title, A
                            OutputDebug, %TestName%:%A_LineNumber%: Test failed: Window 'Download Manager' failed to appear. Active window caption: '%title%'.`n
                        }
                    }
                    else
                    {
                        TestsFailed()
                        WinGetTitle, title, A
                        OutputDebug, %TestName%:%A_LineNumber%: Test failed: Unable to hit 'Save' button in 'Enter name of file to save to...' window. Active window caption: '%title%'.`n
                    }
                }
                else
                {
                    TestsFailed()
                    WinGetTitle, title, A
                    OutputDebug, %TestName%:%A_LineNumber%: Test failed: Unable to enter path in 'Enter name of file to save to...' window. Active window caption: '%title%'.`n
                }
            }
            else
            {
                TestsFailed()
                WinGetTitle, title, A
                OutputDebug, %TestName%:%A_LineNumber%: Test failed: Window 'Enter name of file to save to...' failed to appear. Active window caption: '%title%'.`n
            }
        }
        else
        {
            TestsFailed()
            WinGetTitle, title, A
            OutputDebug, %TestName%:%A_LineNumber%: Test failed: Window 'Opening %NameExt%' failed to appear. Active window caption: '%title%'.`n
        }
    }
    else
    {
        TestsFailed()
        WinGetTitle, title, A
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: 'Welcome to SeaMonkey - SeaMonkey' is not active window. Active window caption: '%title%'.`n
    }
}
else
{
    TestsFailed()
    WinGetTitle, title, A
    OutputDebug, %TestName%:%A_LineNumber%: Test failed: We failed somwehere in 'prepare.ahk'. Active window caption: '%title%'.`n
}
