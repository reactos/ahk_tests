/*
 * Designed for LBreakout2 2.4.1
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

TestName = 2.local_game

; Test if can shoot the ball
TestsTotal++
RunApplication()
if not bContinue
    TestsFailed("We failed somwehere in 'prepare.ahk'.")
else
{
    IfWinNotActive, LBreakout2
        TestsFailed("'LBreakout2' window is not active.")
    else
    {
        BallX := 323 ; Ball coordinates
        BallY := 457
        szBallColorHard = 0x315131 ; Ball color
        PixelGetColor, szBallColor, BallX, BallY, LBreakout2
        if ErrorLevel
            TestsFailed("Unable to get '" BallX "x" BallY "' (ball) pixel color.")
        else
        {
            if (szBallColor != szBallColorHard)
                TestsFailed("'" BallX "x" BallY "' (ball) pixel color doesn't match (is '" szBallColor "', should be '" szBallColorHard "').")
            else
            {
                MouseClick ; The ball is there, lets shoot it
                Sleep, 500 ; Let the ball to fly away
                PixelGetColor, szBallColor, BallX, BallY, LBreakout2
                if ErrorLevel
                    TestsFailed("Unable to get '" BallX "x" BallY "' (ball) pixel color (2nd time).")
                else
                {
                    if (szBallColor == szBallColorHard)
                        TestsFailed("'" BallX "x" BallY "' (ball) pixel color still matches after we tried to shoot the ball.")
                    else
                        TestsOK("Shot the ball.")
                }
            }
        }
    }
}


; Test if can exit application
 TestsTotal++
if bContinue
{
    WinClose, LBreakout2
    WinWaitClose,,,3
    if ErrorLevel
        TestsFailed("Unable to close 'LBreakout2' window.")
    else
    {
        Process, WaitClose, %ProcessExe%, 4
        if ErrorLevel
            TestsFailed("'" ProcessExe "' process failed to close despite 'LBreakout2' window being closed.")
        else
            TestsOK("We closed 'LBreakout2' window then '" ProcessExe "' process closed too.")
    }
}
