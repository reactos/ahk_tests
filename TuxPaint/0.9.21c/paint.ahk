/*
 * Designed for TuxPaint 0.9.21c
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

TestName = 2.paint

; Test if can paint black dot (default) using "Paint" tool (default one)
TestsTotal++
RunApplication()
if not bContinue
    TestsFailed("We failed somwehere in 'prepare.ahk'.")
else
{
    IfWinNotActive, Tux Paint
        TestsFailed("'Tux Paint' window is not active.")
    else
    {
        CoordMode, Pixel, Relative
        CoordMode, Mouse, Relative ; Sets coordinate mode to be relative to the active window
        SetFormat, float, 0.0 ; Format floats
        CoordX := 300
        CoordY := 100
        MouseMove, %CoordX%, %CoordY%
        Sleep, 200 ; Sleep is a must
        PixelGetColor, empty_color, %CoordX%, %CoordY%
        if ErrorLevel
            TestsFailed("Unable to get " CoordX "x" CoordY " pixel color.")
        else
        {
            MouseClick, left, %CoordX%, %CoordY% ; Paint a dot
            Sleep, 500 ; Sleep is a must, let dot to appear
            PixelGetColor, dot_color, %CoordX%, %CoordY%
            if ErrorLevel
                TestsFailed("Unable to get " CoordX "x" CoordY " pixel color after putting a black dot there.")
            else
            {
                if (empty_color = dot_color)
                    TestsFailed("Before painting a black dot " CoordX "x" CoordY " pixel color was '" empty_color "' and after it stayed the same (" dot_color ").")
                else
                    TestsOK("" CoordX "x" CoordY " pixel color before: '" empty_color "', after: '" dot_color "' Painting works.")
            }
        }
    }
}


; Test if can close window
TestsTotal++
if bContinue
{
    WinClose, Tux Paint ; Close window
    Sleep, 500 ; Some delay before 'Do you really want to quit?' appears
    IfWinNotActive, Tux Paint ; Check if window is still active, before sending keystrokes
        TestsFailed("'Tux Paint' window is not active anymore.")
    else
    {
        SendInput, {ENTER} ; hit 'Yes, I am done' button (no control name)
        Sleep, 500 ; Some delay before 'If you quit, youll lose your picture! Save it?' appears
        IfWinNotActive, Tux Paint
            TestsFailed("Slept and 'Tux Paint' window is not active anymore.")
        else
        {
            SendInput, {ESC} ; hit 'No, dont bother saving' (no control name either)
            WinWaitClose, Tux Paint,,3
            if ErrorLevel
                TestsFailed("Unable to close 'Tux Paint' window.")
            else
            {
                Process, WaitClose, %ProcessExe%, 4
                if ErrorLevel
                    TestsFailed("'" ProcessExe "' process failed to close despite 'Tux Paint' window being closed.")
                else
                    TestsOK("'Tux Paint' window and '" ProcessExe "' process closed.")
            }
        }
    }
}
