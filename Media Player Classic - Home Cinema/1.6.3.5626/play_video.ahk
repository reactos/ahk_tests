/*
 * Designed for Media Player Classic - Home Cinema 1.6.3.5626
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

TestName = 2.play_video
szDocument =  %A_WorkingDir%\Media\Foundry accident.mp4 ; Case sensitive!

; Test if can play video file
TestsTotal++
RunApplication(szDocument)
if not bContinue
    TestsFailed("We failed somwehere in 'prepare.ahk'.")
else
{
    SplitPath, szDocument, NameExt
    IfWinNotActive, %NameExt%
        TestsFailed("'" NameExt "' is not an active window.")
    else
    {
        iPlayTime := 4
        iTimeOut := iPlayTime ; Copy variable
        TestsInfo("'" NameExt "' window appeared, gonna play video for '" iPlayTime "' seconds.")
        while iTimeOut > 0
        {
            IfWinActive, %NameExt%
            {
                Sleep, 1000
                iTimeOut--
            }
            else
                break ; exit the loop if something poped-up
        }

        IfWinNotActive, %NameExt%
            TestsFailed("'" NameExt "' is not an active window anymore.")
        else
        {
            WndW = 439
            WndH = 359
            WinGetPos, X, Y, Width, Height, %NameExt%
            if not ((Width > WndW) AND Height > WndH) ; Video is 440x360
                TestsFailed("Size of '" NameExt "' window is not as expected when playing '" szDocument "' (is '" Width "x" Height "', should be at least '" WndW "x" WndH "').")
            else
            {
                szTimeHard := "00:0" iPlayTime " / 00:46" ; The current position and total time
                ControlGetText, szTime, Static2 ; Get current time/total time (right bottom corner)
                if ErrorLevel
                    TestsFailed("Unable to get current time/total time text from bottom right corner of the window.")
                else
                {
                    if (szTime != szTimeHard)
                        TestsFailed("Current time/total time doesn't match (is '" szTime "', should be '" szTimeHard "')")
                    else
                    {
                        WinClose, %NameExt%
                        WinWaitClose, %NameExt%,,4
                        if ErrorLevel
                            TestsFailed("'" NameExt "' failed to close.")
                        else
                        {
                            Process, WaitClose, %ProcessExe%, 4
                            if ErrorLevel
                                TestsFailed("'" ProcessExe "' process failed to close despite '" NameExt "' window being reported as closed.")
                            else
                                TestsOK("Size of '" NameExt "' window is " Width "x" Height " and time '" szTime "', so, probably we can play '" szDocument "'.")
                        }
                    }
                }
            }
        }
    }
}
