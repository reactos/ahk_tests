/*
 * Designed for Tile World 1.3.0
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

TestName = 2.move_tanks

; Test if can move down, take blue dot and move tanks
TestsTotal++
RunApplication()
if not bContinue
    TestsFailed("We failed somwehere in 'prepare.ahk'.")
else
{
    IfWinNotActive, Tile World - A Fleeting Memory
        TestsFailed("'Tile World' window is not active.")
    else
    {
        ; Go down, take blue dot
        loop, 6
        {
            SendInput, {DOWN}
            Sleep, 200 ; Sleep is required
        }

        szEmptyHard = 0xB3B3B3 ; Empty tile color
        EmptyX := 225
        EmptyY := 300
        iTimeOut := 30
        while iTimeOut > 0
        {
            PixelGetColor, szEmptyTileColor, %EmptyX%, %EmptyY%
            if ErrorLevel
                break ; Unable to get pixel color
            else
            {
                if (szEmptyTileColor != szEmptyHard)
                {
                    Sleep, 100
                    iTimeOut--
                }
                else
                    break ; colors match
            }
        }
        
        PixelGetColor, szEmptyTileColor, %EmptyX%, %EmptyY%
        if ErrorLevel
            TestsFailed("Unable to get " EmptyX "x" EmptyY " pixel color (iTimeOut=" iTimeOut ").")
        else
        {
            if (szEmptyTileColor != szEmptyHard)
                TestsFailed("Moved down, took blue dot, but tanks didn't move.")
            else
                TestsOK("Moved down, took blue dot and tanks moved.")
        }
    }
}


; Test if can exit application
TestsTotal++
if bContinue
{
    WinClose, Tile World - A Fleeting Memory
    WinWaitClose,,,3
    if ErrorLevel
        TestsFailed("Unable to close 'Tile World - A Fleeting Memory' window.")
    else
    {
         Process, WaitClose, %ProcessExe%, 4
        if ErrorLevel
            TestsFailed("'" ProcessExe "' process failed to close despite 'Tile World - A Fleeting Memory' window being closed.")
        else
            TestsOK("We closed 'Tile World - A Fleeting Memory' window then '" ProcessExe "' process closed too.")
    }
}
