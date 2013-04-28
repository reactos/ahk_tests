/*
 * Designed for Diablo II 1.4
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

TestName = 2.player_walk

; Test if can load game and walk player on the map
TestsTotal++
RunApplication()
if bContinue
{
    IfWinNotActive, Diablo II
        TestsFailed("'Diablo II' is NOT active window.")
    else
    {
        ; FIXME
        Click, 50, 50 ; Walk
        Sleep, 1500
        SendInput, {ESC} ; Bring up the menu
        Sleep, 500
        SendInput, {UP}{ENTER} ; Select 'Save and exit game'
        Sleep, 500
        SendInput, {ESC} ; Close game completely
        Process, WaitClose, %ProcessExe%, 4
        if ErrorLevel
            TestsFailed("Unable to exit the game, because '" ProcessExe "' process still exists.")
        else
            TestsOK("Made player to walk and closed game using its menu.")
    }
}
