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

TestsTotal++
TestName = 2.PlayVideo
szDocument =  %A_WorkingDir%\Media\Foundry accident.mp4 ; Case sensitive!

if bContinue
{
    IfExist, %szDocument%
    {
        IfExist, %A_ProgramFiles%\VideoLAN\VLC\vlc.exe
        {
            Run, %A_ProgramFiles%\VideoLAN\VLC\vlc.exe "%szDocument%"
            WinWaitActive, Foundry accident.mp4 - VLC media player,, 8
            if not ErrorLevel
            {
                TestsOK++
                OutputDebug, %TestName%:%A_LineNumber%: VLC media player can play '%A_WorkingDir%\Media\Foundry accident.mp4'.`n
                bContinue := true
            }
            else
            {
                TestsFailed++
                WinGetTitle, title, A
                OutputDebug, %TestName%:%A_LineNumber%: Test failed: Window 'Foundry accident.mp4 - VLC media player' failed to appear. Active window caption: '%title%'`n
                bContinue := false
            }
        }
        else
        {
            TestsFailed++
            WinGetTitle, title, A
            OutputDebug, %TestName%:%A_LineNumber%: Test failed: Can NOT find '%A_ProgramFiles%\VideoLAN\VLC\vlc.exe'. Active window caption: '%title%'`n
            bContinue := false
        }
    }
    else
    {
        TestsFailed++
        WinGetTitle, title, A
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: Can NOT find '%szDocument%'. Active window caption: '%title%'`n
        bContinue := false
    }

    Process, close, vlc.exe ; We don't care now if application can close correctly, so, terminate
}