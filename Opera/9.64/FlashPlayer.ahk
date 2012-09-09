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

TestName = 4.FlashPlayer

; Test if can open flash
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
        SendInput, {CTRLDOWN}t{CTRLUP} ; Open new tab
        WinWaitActive, Speed Dial - Opera,, 15
        if ErrorLevel
            TestsFailed("Window 'Speed Dial - Opera' failed to appear.")
        else
        {
            IfNotExist, %A_WinDir%\System32\Macromed\Flash
                TestsFailed("Can NOT find '" A_WinDir "\System32\Macromed\Flash'.")
            else
            {
                SendInput, {CTRLDOWN}l{CTRLUP}
                Sleep, 1500
                SendInput, http://beastybombs.com/play.php{ENTER}
                Sleep, 10000 ; Let it to fully load. Maybe it will crash
                WinWaitActive, Beasty Bombs - Cats & Dogs Fights - Play - Opera,,20
                if ErrorLevel
                    TestsFailed("Window 'Beasty Bombs - Cats & Dogs Fights - Play - Opera' failed to appear.")
                else
                {
                    Process, Close, %ProcessExe%
                    Process, WaitClose, %ProcessExe%, 4
                    if ErrorLevel
                        TestsFailed("Process '" ProcessExe "' failed to close after opening website.")
                    else
                        TestsOK("Window caption is 'Beasty Bombs - Cats & Dogs Fights - Play - Opera' that means no crash while opening Flash Game.")
                }
            }
        }
    }
}
