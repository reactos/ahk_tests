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
    WinWaitActive, VLC media player,,7
    if not ErrorLevel
    {
        WinMenuSelectItem, VLC media player, , File, Quick Open File
        if not ErrorLevel
        {
            WinWaitActive, Open File, Look, 7
            if not ErrorLevel
            {
                Sleep, 1000
                ControlSetText, Edit1, %szDocument%, Open File, Look
                if not ErrorLevel
                {
                    ControlClick, Button2, Open File, Look ; Hit 'Open' button
                    if not ErrorLevel
                    {
                        WinWaitClose, Open File, Look, 7
                        if not ErrorLevel
                        {
                            WinWaitActive, VLC media player,,7
                            if not ErrorLevel
                            {
                                Sleep, 2500 ; Let it to load the video
                                ; ImageSeach does not work with videos in XP!
                                WinGetPos, X, Y, Width, Height, VLC media player
                                if Width > 439 AND Height > 359; Video is 440x360
                                {
                                    WinClose, VLC media player
                                    WinWaitClose, VLC media player,,7
                                    if not ErrorLevel
                                        TestsOK("Size of 'VLC media player' window is " Width "x" Height ", so, probably we can play '" szDocument "'.")
                                    else
                                        TestsFailed("Window 'VLC media player' failed to close.")
                                }
                                else
                                    TestsFailed("Size of 'VLC media player' is not as expected when playing '" szDocument "'.")
                            }
                            else
                                TestsFailed("Window 'VLC media player' failed to appear after opening '" szDocument "'.")
                        }
                        else
                            TestsFailed("Window 'Open File (Look)' failed to close.")
                    }
                    else
                        TestsFailed("Unable to hit 'Open' button in 'Open File (Look)' window.")
                }
                else
                    TestsFailed("Unable to enter 'File name (" szDocument ")' in 'Open File (Look)' window.")
            }
            else
                TestsFailed("Window 'Open File (Look)' failed to appear.")
        }
        else
            TestsFailed("Unable to click 'File -> Quick Open File' in 'VLC media player' window.")
    }
    else
        TestsFailed("Window 'VLC media player' failed to appear.")
}
