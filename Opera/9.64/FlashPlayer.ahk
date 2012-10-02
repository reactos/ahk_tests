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
    IfWinNotActive, Speed Dial - Opera
        TestsFailed("Window 'Speed Dial - Opera' is not active window.")
    else
    {
        IfNotExist, %A_WinDir%\System32\Macromed\Flash\*Plugin.exe ; Check if file pattern exist
            TestsFailed("Can NOT find any file in '" A_WinDir "\System32\Macromed\Flash' that matches file pattern '*Plugin.exe'.")
        else
        {
            SendInput, {CTRLDOWN}l{CTRLUP} ; Toggle address bar
            SendInput, http://beastybombs.com/play.php{ENTER}

            iTimeOut := 30
            while iTimeOut > 0
            {
                IfWinActive, Blank page - Opera
                {
                    WinWaitActive, Beasty Bombs - Cats & Dogs Fights - Play - Opera,,1
                    iTimeOut--
                }
                else
                    break ; exit the loop if something poped-up
            }

            WinWaitActive, Beasty Bombs - Cats & Dogs Fights - Play - Opera,,1
            if ErrorLevel
                TestsFailed("Window 'Beasty Bombs - Cats & Dogs Fights - Play - Opera' failed to appear (iTimeOut=" iTimeOut ").")
            else
            {
                Sleep, 3500 ; Let it to load more, maybe it will crash
                Process, Close, %ProcessExe%
                Process, WaitClose, %ProcessExe%, 4
                if ErrorLevel
                    TestsFailed("Process '" ProcessExe "' failed to close after opening website.")
                else
                    TestsOK("Window caption is 'Beasty Bombs - Cats & Dogs Fights - Play - Opera' that means no crash while opening Flash Game (iTimeOut=" iTimeOut ").")
            }
        }
    }
}
