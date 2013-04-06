/*
 * Designed for VLC Media Player 2.0.3
 * Copyright (C) 2013 Edijs Kolesnikovics
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

; Test if can get codec information. Tools->Codec Information (Ctrl+J)

TestName = 4.codec_information
szDocument =  %A_WorkingDir%\Media\Foundry accident.mp4 ; Case sensitive!

TestsTotal++
RunApplication(szDocument)
if bContinue
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
            IfWinNotActive, %NameExt% - VLC media player
                TestsFailed("'" NameExt " - VLC media player' window became INACTIVE.")
            else
            {
                ; Codec information is available while video is playing.
                SendInput, ^j ; Ctrl+J aka Tools->Codec Information
                WinWaitActive, Media Information,,2
                if ErrorLevel
                    TestsFailed("Sent Ctrl+J to '" NameExt " - VLC media player' window, but 'Media Information' window failed to appear.")
                else
                {
                    ; Video is still playing
                    SendInput, {TAB} ; Focus the list. AHK can't get any control names.
                    clipboard = ; clean
                    SendInput, ^c ; Ctrl+C
                    szStream = Stream 0
                    ClipWait, 2
                    if ErrorLevel
                        TestsFailed("Unable to copy text (" szStream ") onto clipboard.")
                    else
                    {
                        IfNotInString, clipboard, %szStream%
                            TestsFailed("Clipboard contains wrong data. Is '" clipboard "', should be '" szStream "'.")
                        else
                            TestsOK("Copied '" clipboard "' to the clipboard.")
                    }
                }
            }
        }
    }
}


; Continue copying text
TestsTotal++
if bContinue
{
    IfWinNotActive, Media Information
        TestsFailed("'Media Information' window is NOT active anymore.")
    else
    {
        szLineText = Type: Video
        SendInput, {DOWN}
        clipboard = ; clean
        SendInput, ^c ; Ctrl+C
        ClipWait, 2
        if ErrorLevel
            TestsFailed("Unable to copy text (" szLineText ") onto clipboard.")
        else
        {
            IfNotInString, clipboard, %szLineText%
                TestsFailed("Clipboard contains wrong data. Is '" clipboard "', should be '" szLineText "'.")
            else
                TestsOK("Copied '" clipboard "' to the clipboard.")
        }
    }
}


TestsTotal++
if bContinue
{
    IfWinNotActive, Media Information
        TestsFailed("'Media Information' window is NOT active anymore.")
    else
    {
        szLineText = Codec: H264 - MPEG-4 AVC (part 10) (avc1)
        SendInput, {DOWN}
        clipboard = ; clean
        SendInput, ^c ; Ctrl+C
        ClipWait, 2
        if ErrorLevel
            TestsFailed("Unable to copy text (" szLineText ") onto clipboard.")
        else
        {
            IfNotInString, clipboard, %szLineText%
                TestsFailed("Clipboard contains wrong data. Is '" clipboard "', should be '" szLineText "'.")
            else
                TestsOK("Copied '" clipboard "' to the clipboard.")
        }
    }
}


TestsTotal++
if bContinue
{
    IfWinNotActive, Media Information
        TestsFailed("'Media Information' window is NOT active anymore.")
    else
    {
        szLineText = Resolution: 440x360
        SendInput, {DOWN}
        clipboard = ; clean
        SendInput, ^c ; Ctrl+C
        ClipWait, 2
        if ErrorLevel
            TestsFailed("Unable to copy text (" szLineText ") onto clipboard.")
        else
        {
            IfNotInString, clipboard, %szLineText%
                TestsFailed("Clipboard contains wrong data. Is '" clipboard "', should be '" szLineText "'.")
            else
                TestsOK("Copied '" clipboard "' to the clipboard.")
        }
    }
}


TestsTotal++
if bContinue
{
    IfWinNotActive, Media Information
        TestsFailed("'Media Information' window is NOT active anymore.")
    else
    {
        szLineText = Frame rate: 6
        SendInput, {DOWN}
        clipboard = ; clean
        SendInput, ^c ; Ctrl+C
        ClipWait, 2
        if ErrorLevel
            TestsFailed("Unable to copy text (" szLineText ") onto clipboard.")
        else
        {
            IfNotInString, clipboard, %szLineText%
                TestsFailed("Clipboard contains wrong data. Is '" clipboard "', should be '" szLineText "'.")
            else
                TestsOK("Copied '" clipboard "' to the clipboard.")
        }
    }
}


TestsTotal++
if bContinue
{
    IfWinNotActive, Media Information
        TestsFailed("'Media Information' window is NOT active anymore.")
    else
    {
        szLineText = Decoded format: Planar 4:2:0 YUV
        SendInput, {DOWN}
        clipboard = ; clean
        SendInput, ^c ; Ctrl+C
        ClipWait, 2
        if ErrorLevel
            TestsFailed("Unable to copy text (" szLineText ") onto clipboard.")
        else
        {
            IfNotInString, clipboard, %szLineText%
                TestsFailed("Clipboard contains wrong data. Is '" clipboard "', should be '" szLineText "'.")
            else
                TestsOK("Copied '" clipboard "' to the clipboard.")
        }
    }
}


TestsTotal++
if bContinue
{
    IfWinNotActive, Media Information
        TestsFailed("'Media Information' window is NOT active anymore.")
    else
    {
        szLineText = Stream 1
        SendInput, {DOWN}
        clipboard = ; clean
        SendInput, ^c ; Ctrl+C
        ClipWait, 2
        if ErrorLevel
            TestsFailed("Unable to copy text (" szLineText ") onto clipboard.")
        else
        {
            IfNotInString, clipboard, %szLineText%
                TestsFailed("Clipboard contains wrong data. Is '" clipboard "', should be '" szLineText "'.")
            else
                TestsOK("Copied '" clipboard "' to the clipboard.")
        }
    }
}


TestsTotal++
if bContinue
{
    IfWinNotActive, Media Information
        TestsFailed("'Media Information' window is NOT active anymore.")
    else
    {
        szLineText = Type: Audio
        SendInput, {DOWN}
        clipboard = ; clean
        SendInput, ^c ; Ctrl+C
        ClipWait, 2
        if ErrorLevel
            TestsFailed("Unable to copy text (" szLineText ") onto clipboard.")
        else
        {
            IfNotInString, clipboard, %szLineText%
                TestsFailed("Clipboard contains wrong data. Is '" clipboard "', should be '" szLineText "'.")
            else
                TestsOK("Copied '" clipboard "' to the clipboard.")
        }
    }
}


TestsTotal++
if bContinue
{
    IfWinNotActive, Media Information
        TestsFailed("'Media Information' window is NOT active anymore.")
    else
    {
        szLineText = Codec: MPEG AAC Audio (mp4a)
        SendInput, {DOWN}
        clipboard = ; clean
        SendInput, ^c ; Ctrl+C
        ClipWait, 2
        if ErrorLevel
            TestsFailed("Unable to copy text (" szLineText ") onto clipboard.")
        else
        {
            IfNotInString, clipboard, %szLineText%
                TestsFailed("Clipboard contains wrong data. Is '" clipboard "', should be '" szLineText "'.")
            else
                TestsOK("Copied '" clipboard "' to the clipboard.")
        }
    }
}


TestsTotal++
if bContinue
{
    IfWinNotActive, Media Information
        TestsFailed("'Media Information' window is NOT active anymore.")
    else
    {
        szLineText = Channels: Stereo
        SendInput, {DOWN}
        clipboard = ; clean
        SendInput, ^c ; Ctrl+C
        ClipWait, 2
        if ErrorLevel
            TestsFailed("Unable to copy text (" szLineText ") onto clipboard.")
        else
        {
            IfNotInString, clipboard, %szLineText%
                TestsFailed("Clipboard contains wrong data. Is '" clipboard "', should be '" szLineText "'.")
            else
                TestsOK("Copied '" clipboard "' to the clipboard.")
        }
    }
}


TestsTotal++
if bContinue
{
    IfWinNotActive, Media Information
        TestsFailed("'Media Information' window is NOT active anymore.")
    else
    {
        szLineText = Sample rate: 44100 Hz
        SendInput, {DOWN}
        clipboard = ; clean
        SendInput, ^c ; Ctrl+C
        ClipWait, 2
        if ErrorLevel
            TestsFailed("Unable to copy text (" szLineText ") onto clipboard.")
        else
        {
            IfNotInString, clipboard, %szLineText%
                TestsFailed("Clipboard contains wrong data. Is '" clipboard "', should be '" szLineText "'.")
            else
                TestsOK("Copied '" clipboard "' to the clipboard. Got all correct information.")
        }
    }
}


bTerminateProcess(ProcessExe)
