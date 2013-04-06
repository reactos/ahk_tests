/*
 * Designed for VLC Media Player 2.0.3
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

; Test if VLC media player can play video

TestName = 2.PlayVideo
szDocument =  %A_WorkingDir%\Media\Foundry accident.mp4 ; Case sensitive!

TestsTotal++
RunApplication(szDocument)
if not bContinue
    TestsFailed("We failed somewhere in prepare.ahk.")
else
{
    SplitPath, szDocument, NameExt
    WinWaitActive, %NameExt% - VLC media player,,3
    if ErrorLevel
        TestsFailed("'" NameExt " - VLC media player' window failed to appear.")
    else
    {
        WndW = 439
        WndH = 359
        WinGetPos, X, Y, Width, Height, %NameExt% - VLC media player
        if not ((Width > WndW) AND Height > WndH) ; Video is 440x360
            TestsFailed("Size of '" NameExt " - VLC media player' window is not as expected when playing '" szDocument "' (is '" Width "x" Height "', should be at least '" WndW "x" WndH "').")
        else
        {
            WinClose, %NameExt% - VLC media player
            WinWaitClose, %NameExt% - VLC media player,,7
            if ErrorLevel
                TestsFailed("'" NameExt " - Window 'VLC media player' failed to close.")
            else
                TestsOK("Size of '" NameExt " - VLC media player' window is " Width "x" Height ", so, probably we can play '" szDocument "'.")
        }
    }
}