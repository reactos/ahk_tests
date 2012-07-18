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


; Test if can open flash
TestsTotal++
WinWaitActive, Welcome to Opera - Opera,, 15
if not ErrorLevel
{
    Flash10Exe = %A_WinDir%\system32\Macromed\Flash\FlashUtil10t_Plugin.exe
    IfExist, %Flash10Exe%
    {
        SendInput, {CTRLDOWN}t{CTRLUP} ; Open new tab
        WinWaitActive, Speed Dial - Opera,, 15
        if not ErrorLevel
        {
            SendInput, {CTRLDOWN}l{CTRLUP}
            Sleep, 1500
            SendInput, http://beastybombs.com/play.php{ENTER}
            Sleep, 10000 ; Let it to fully load. Maybe it will crash
            WinWaitActive, Beasty Bombs - Cats & Dogs Fights - Play - Opera,,20
            if not ErrorLevel
            {
                TestsOK++
                OutputDebug, OK: %Module%:%A_LineNumber%: Window caption is 'Beasty Bombs - Cats & Dogs Fights - Play - Opera' that means no crash while opening Flash Game.`n
                bContinue := true
            }
            else
            {
                TestsFailed++
                WinGetTitle, title, A
                OutputDebug, FAILED: %Module%:%A_LineNumber%: Window 'Yahoo! - Opera' failed to appear. Active window caption: '%title%'`n
                bContinue := false
            }
        }
        else
        {
            TestsFailed++
            WinGetTitle, title, A
            OutputDebug, FAILED: %Module%:%A_LineNumber%: Window 'Speed Dial - Opera' failed to appear. Active window caption: '%title%'`n
            bContinue := false
        }
    }
    else
    {
        TestsFailed++
        OutputDebug, FAILED: %Module%:%A_LineNumber%: Can NOT find '%Flash10Exe%'. Install it first!`n
        bContinue := false
    }
}
else
{
    TestsFailed++
    WinGetTitle, title, A
    OutputDebug, FAILED: %Module%:%A_LineNumber%: Window 'Welcome to Opera - Opera' was NOT found. Active window caption: '%title%'`n
    bContinue := false
}
