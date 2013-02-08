/*
 * Designed for LBreakout2 2.4.1
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

; Test if the app is installed
TestsTotal++
RegRead, UninstallerPath, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\LBreakout2_is1, UninstallString
if ErrorLevel
    TestsFailed("Either registry key does not exist or we failed to read it.")
else
{
    UninstallerPath := ExeFilePathNoParam(UninstallerPath) ; Get rid of quotes
    SplitPath, UninstallerPath,, InstalledDir
    if (InstalledDir = "")
        TestsFailed("Either registry contains empty string or we failed to read it.")
    else
    {
        ModuleExe = %InstalledDir%\lbreakout2.exe
        TestsOK("")
    }
}


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
    global InstalledDir

    TestsTotal++
    if bContinue
    {
        IfNotExist, %ModuleExe%
            TestsFailed("RunApplication(): Can NOT find '" ModuleExe "'.")
        else
        {
            Run, %ModuleExe%, %InstalledDir% ; The game wants WorkingDir param
            WinWaitActive, LBreakout2,,5
            if ErrorLevel
            {
                Process, Exist, %ProcessExe%
                NewPID = %ErrorLevel%  ; Save the value immediately since ErrorLevel is often changed.
                if NewPID = 0
                    TestsFailed("RunApplication(): Window 'LBreakout2' failed to appear. No '" ProcessExe "' process detected.")
                else
                    TestsFailed("RunApplication(): Window 'LBreakout2' failed to appear. '" ProcessExe "' process detected.")
            }
            else
            {
                WinMove, 0, 0
                ; Now lets make sure it is a game window and not some error
                WinGetPos, X, Y, Width, Height, LBreakout2
                szWndHeight := 450 ; Game window height in Win2k3 SP2 is 505, specify less to be safe
                if (Height < szWndHeight)
                    TestsFailed("RunApplication(): 'LBreakout2' window height should be at least '" szWndHeight "', but got '" Height "'. This is not game window, is it?")
                else
                {
                    LocalGameCoordX := 189 ; Position of "Local Game" in "Menu"
                    LocalGameCoordY := 301
                    MouseMove, %LocalGameCoordX%, %LocalGameCoordY% ; Move mouse to 'Local Game' menu option
                    HintCoordX := 430 ; If mouse is in correct position, hint will appear. This is pixel of right side of hint window
                    HintCoordY := 250
                    szHintColorHard = 0x73CFE7 ; Hardcoded hint color
                    
                    iTimeOut := 200
                    while iTimeOut > 0
                    {
                        PixelGetColor, szHintColor, %HintCoordX%, %HintCoordY%, LBreakout2
                        if ErrorLevel
                            break ; Unable to get pixel color
                        else
                        {
                            if (szHintColor != szHintColorHard)
                            {
                                Sleep, 10
                                iTimeOut--
                            }
                            else
                                break ; colors match
                        }
                    }
                    
                    PixelGetColor, szHintColor, %HintCoordX%, %HintCoordY%, LBreakout2 ; Get pixel color of hint window
                    if ErrorLevel
                        TestsFailed("RunApplication(): Unable to get '" HintCoordX "x" HintCoordY "' ('A local game with up...' hint) pixel color of 'LBreakout2' window.")
                    else
                    {
                        if (szHintColor != szHintColorHard)
                            TestsFailed("RunApplication(): Color of '" HintCoordX "x" HintCoordY "' ('A local game with up...' hint) pixel doesn't match to hardcoded one (is '" szHintColor "', should be '" szHintColorHard "' iTimeOut=" iTimeOut ").")
                        else
                        {
                            MouseClick ; Hardcoded color and the one we got matches, so, we are at 'Local Game', so, click it
                            MouseMove, 1, 1 ; Move mouse away from Menu, so, hints would dissapear
                            Sleep, 250 ; MouseMove requires sleep
                            MouseMove, LocalGameCoordX-1, LocalGameCoordY-1 ; We need to move mouse again in order to get correct hint ('Lets get it on!')
                            Sleep, 25
                            iTimeOut := 200
                            while iTimeOut > 0
                            {
                                PixelGetColor, szHintColor, %HintCoordX%, %HintCoordY%, LBreakout2
                                if ErrorLevel
                                    break ; Unable to get pixel color
                                else
                                {
                                    if (szHintColor != szHintColorHard)
                                    {
                                        Sleep, 10
                                        iTimeOut--
                                    }
                                    else
                                        break ; colors match
                                }
                            }
                            
                            PixelGetColor, szHintColor, %HintCoordX%, %HintCoordY%, LBreakout2 ; Get pixel color of hint window
                            if ErrorLevel
                                TestsFailed("RunApplication(): Unable to get '" HintCoordX "x" HintCoordY "' ('Lets get in on!' hint) pixel color of 'LBreakout2' window.")
                            else
                            {
                                if (szHintColor != szHintColorHard)
                                    TestsFailed("RunApplication(): Color of '" HintCoordX "x" HintCoordY "' ('Lets get in on!' hint) pixel doesn't match to hardcoded one (is '" szHintColor "', should be '" szHintColorHard "' iTimeOut=" iTimeOut ").")
                                else
                                {
                                    MouseClick ; We are at 'Start Game', so, click it
                                    LiveSideX := 12
                                    LiveSideY := 300
                                    szLeftSideColorHard = 0xB5B6B5 ; Left side of game window (the place where lives are located in)
                                    Sleep, 1500 ; Ne need another second for game to properly initialize
                                    
                                    iTimeOut := 300
                                    while iTimeOut > 0
                                    {
                                        PixelGetColor, szLiveSideColor, %LiveSideX%, %LiveSideY%, LBreakout2
                                        if ErrorLevel
                                            break ; Unable to get pixel color
                                        else
                                        {
                                            if (szLiveSideColor != szLeftSideColorHard)
                                            {
                                                Sleep, 10
                                                iTimeOut--
                                            }
                                            else
                                                break ; colors match
                                        }
                                    }
                                    
                                    PixelGetColor, szLiveSideColor, %LiveSideX%, %LiveSideY%, LBreakout2
                                    if ErrorLevel
                                        TestsFailed("RunApplication(): Unable to get '" LiveSideX "x" LiveSideY "' pixel color of 'LBreakout2' window.")
                                    else
                                    {
                                        if (szLiveSideColor != szLeftSideColorHard)
                                            TestsFailed("RunApplication(): Color of '" LiveSideX "x" LiveSidey "' (left side) pixel doesn't match to hardcoded one (is '" szLiveSideColor "', should be '" szLeftSideColorHard "' iTimeOut=" iTimeOut ").")
                                        else
                                            TestsOK("RunApplication(): Started, hit 'Local Game' then 'Start Game' and game appeared.")
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
