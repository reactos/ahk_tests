/*
 * Designed for SMPlayer 0.6.9
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

TestName = 2.play_file
szDocument = %A_WorkingDir%\Media\Foundry accident.mp4

; Test if can open picture using File -> Open dialog and close application successfully
TestsTotal++
RunApplication(szDocument)
if not bContinue
    TestsFailed("We failed somwehere in 'prepare.ahk'.")
else
{
    SplitPath, szDocument, NameExt
    IfWinNotActive, %NameExt% - SMPlayer
        TestsFailed("'" NameExt " - SMPlayer' window is not an active.")
    else
    {
        WinGetPos,,, Width, Height
        if ((Width < 440) || (Height < 480)) ; win2k3: 448x493. Using smaller values for purpose.
            TestsFailed("Window size is not the same as expected (is '" Width "x" Height "', should be more than '440x480').")
        else
        {
            Sleep, 3500 ; Play file for a while, maybe app will crash
            IfWinNotActive, %NameExt% - SMPlayer
                TestsFailed("Loaded '" szDocument "', slept and '" NameExt " - SMPlayer' window became inactive.")
            else
            {
                WinClose
                WinWaitClose,,,3
                if ErrorLevel
                    TestsFailed("Unable to close '" NameExt " - SMPlayer' window.")
                else
                {
                    Process, WaitClose, %ProcessExe%, 4
                    if ErrorLevel
                        TestsFailed("" ProcessExe " failed to close despite '" NameExt " - SMPlayer' window was closed.")
                    else
                        TestsOK("Window size was the same as expected, so, assuming SMPlayer can play '" szDocument "'.")
                }
            }
        }
    }
}
