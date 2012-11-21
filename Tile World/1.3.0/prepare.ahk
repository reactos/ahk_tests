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

TestName = prepare

bContinue = true
InstallLocation = %A_ProgramFiles%\Tile World
ModuleExe = %InstallLocation%\tworld.exe


; Terminate application
TestsTotal++
if bContinue
{
    SplitPath, ModuleExe, ProcessExe
    Process, Close, %ProcessExe%
    Process, WaitClose, %ProcessExe%, 4
    if ErrorLevel
        TestsFailed("Unable to terminate '" ProcessExe "' process.")
    else
        TestsOK("")
}


; Test if can start application
RunApplication()
{
    global ModuleExe
    global TestName
    global TestsTotal
    global bContinue
    global ProcessExe
    global InstallLocation

    TestsTotal++
    if bContinue
    {
        IfNotExist, %ModuleExe%
            TestsFailed("Can NOT find '" ModuleExe "'.")
        else
        {
            Run, %ModuleExe%, %InstallLocation% ; The game wants WorkingDir param
            WinWaitActive, Tile World,,5
            if ErrorLevel
            {
                Process, Exist, %ProcessExe%
                NewPID = %ErrorLevel%  ; Save the value immediately since ErrorLevel is often changed.
                if NewPID = 0
                    TestsFailed("Window 'Tile World' failed to appear. No '" ProcessExe "' process detected.")
                else
                    TestsFailed("Window 'Tile World' failed to appear. '" ProcessExe "' process detected.")
            }
            else
            {
                WinMove, 0, 0
                ; Now lets make sure it is a game window and not some error
                WinGetPos, X, Y, Width, Height, Tile World
                CoordMode, Pixel, Relative ; Sets coordinate mode to be relative to the active window
                SetFormat, float, 0.0 ; Format floats
                CoordX := Width / 2
                CoordY := Height / 2
                szColorHard = 0x000000 ; Black
                szWndHeight := 450 ; Game window height in Win2k3 SP2 is 505, WinXP SP3 - 512, specify less to be safe
                if (Height < szWndHeight)
                    TestsFailed("'Tile World' window height should be at least '" szWndHeight "', but got '" Height "'. This is not game window, is it?")
                else
                {
                    PixelGetColor, color, %CoordX%, %CoordY%
                    if ErrorLevel
                        TestsFailed("Unable to get " CoordX "x" CoordY " pixel color.")
                    else
                    {
                        if (color != szColorHard)
                            TestsFailed("Colors of '" CoordX "x" CoordY "' pixel doesn't match (is '" color "', should be '" szColorHard "').")
                        else
                        {
                            SendInput, {ENTER}
                            WinWaitActive, Tile World - A Fleeting Memory,,3
                            if ErrorLevel
                                TestsFailed("'Tile World - A Fleeting Memory' window failed to appear.")
                            else
                            {
                                szBorderHard = 0x707070 ; Border color
                                BorderX := 130
                                BorderY := 55
                                iTimeOut := 30
                                while iTimeOut > 0
                                {
                                    PixelGetColor, szBorderColor, %BorderX%, %BorderY%
                                    if ErrorLevel
                                        break ; Unable to get pixel color
                                    else
                                    {
                                        if (szBorderColor != szBorderHard)
                                        {
                                            Sleep, 100
                                            iTimeOut--
                                        }
                                        else
                                            break ; colors match
                                    }
                                }
                                
                                PixelGetColor, szBorderColor, %BorderX%, %BorderY%
                                if ErrorLevel
                                    TestsFailed("Unable to get " BorderX "x" BorderY " pixel color (iTimeOut=" iTimeOut ").")
                                else
                                    TestsOK("Window size is '" Width "x" Height "', '" BorderX "x" BorderY "' (border) pixel color is '" szBorderColor "'. Game is up and running.")
                            }
                        }
                    }
                }
            }
        }
    }
}
