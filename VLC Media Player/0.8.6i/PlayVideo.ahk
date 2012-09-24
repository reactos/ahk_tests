/*
 * Designed for VLC 0.8.6i
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

TestName = 2.PlayVideo
szDocument =  %A_WorkingDir%\Media\Foundry accident.mp4 ; Case insensitive

; Test if can play video when opened by 'File -> Quick Open File' then close application
TestsTotal++
RunApplication("")
if not bContinue
    TestsFailed("We failed somewhere in prepare.ahk.")
else
{
    WinWaitActive, VLC media player,,3
    if ErrorLevel
        TestsFailed("Window 'VLC media player' failed to appear.")
    else
    {
        WinMenuSelectItem, VLC media player, , File, Quick Open File
        if ErrorLevel
            TestsFailed("Unable to click 'File -> Quick Open File' in 'VLC media player' window.")
        else
        {
            WinWaitActive, Open File, Look, 3
            if ErrorLevel
                TestsFailed("Window 'Open File (Look)' failed to appear.")
            else
            {
                ControlSetText, Edit1, %szDocument%, Open File, Look
                if ErrorLevel
                    TestsFailed("Unable to enter 'File name (" szDocument ")' in 'Open File (Look)' window.")
                else
                {
                    ControlClick, Button2, Open File, Look ; Hit 'Open' button
                    if ErrorLevel
                        TestsFailed("Unable to hit 'Open' button in 'Open File (Look)' window.")
                    else
                    {
                        WinWaitClose, Open File, Look, 3
                        if ErrorLevel
                            TestsFailed("Window 'Open File (Look)' failed to close.")
                        else
                        {
                            WinWaitActive, VLC media player,,3
                            if ErrorLevel
                                TestsFailed("Window 'VLC media player' failed to appear after opening '" szDocument "'.")
                            else
                            {
                                Sleep, 2500 ; Let it to load the video
                                ; ImageSeach does not work with videos in XP!
                                WinGetPos, X, Y, Width, Height, VLC media player
                                if not (Width > 439 AND Height > 359) ; Video is 440x360
                                    TestsFailed("Size of 'VLC media player' is not as expected when playing '" szDocument "'.")
                                else
                                {
                                    WinClose, VLC media player
                                    WinWaitClose, VLC media player,,3
                                    if ErrorLevel
                                        TestsFailed("Window 'VLC media player' failed to close.")
                                    else
                                        TestsOK("Size of 'VLC media player' window is " Width "x" Height ", so, probably we can play '" szDocument "'.")
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
