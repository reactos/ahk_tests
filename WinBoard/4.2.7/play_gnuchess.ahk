/*
 * Designed for WinBoard 4.2.7
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

TestName = 2.play_gnuchess

; Test if can select and move a chess
TestsTotal++
RunApplication()
if not bContinue
    TestsFailed("We failed somwehere in 'prepare.ahk'.")
else
{
    IfWinNotActive, WinBoard Startup, Play against
        TestsFailed("Window 'WinBoard Startup (Play against)' is not an active window.")
    else
    {
        ControlClick, Button5 ; Hit 'OK' button
        if ErrorLevel
            TestsFailed("Unable to clikc 'OK' button in 'WinBoard Startup (Play against)' window.")
        else
        {
            WinWaitClose, WinBoard Startup, Play against, 3
            if ErrorLevel
                TestsFailed("'WinBoard Startup (Play against)' window failed to close despite 'OK' button being clicked.")
            else
            {
                WinWaitActive, WinBoard: GNUChess,,3
                if ErrorLevel
                    TestsFailed("'WinBoard: GNUChess' window failed to appear.")
                else
                {
                    Sleep, 1500 ; Sleep until 'Starting chess program' goes away
                    ControlClick, x40 y490, WinBoard: GNUChess
                    if ErrorLevel
                        TestsFailed("Unable to select a chess.")
                    else
                    {
                        ControlClick, x40 y425, WinBoard: GNUChess
                        if ErrorLevel
                            TestsFailed("Unable to move a chess.")
                        else
                        {
                            WinWaitActive, Administrator vs. GNUChess,,3
                            if ErrorLevel
                                TestsFailed("Seems we failed to select and move a chess.")
                            else
                            {
                                WinClose
                                WinWaitClose,,3
                                if ErrorLevel
                                    TestsFailed("Unable to close 'Administrator vs. GNUChess' window.")
                                else
                                {
                                    Process, WaitClose, %ProcessExe%, 4
                                    if ErrorLevel
                                        TestsFailed("Closed 'Administrator vs. GNUChess' window, but '" ProcessExe "' process failed to close.")
                                    else
                                        TestsOK("Selected and moved a chess.")
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
