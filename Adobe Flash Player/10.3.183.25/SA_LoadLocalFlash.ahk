/*
 * Designed for Flash Player 10.3.183.25
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

TestName = 2.SA_LoadLocalFlash
szDocument =  %A_WorkingDir%\Media\Shockwave_Flash_Object.swf ; Case insensitive.

; Test if can play locally located SWF
TestsTotal++
if not bContinue
    TestsFailed("We failed somwehere in 'prepare.ahk'.")
else
{
    IfWinNotActive, Adobe Flash Player 10
        TestsFailed("'Adobe Flash Player 10' window is not active window.")
    else
    {
        IfNotExist, %szDocument%
            TestsFailed("Can NOT find '" szDocument "'.")
        else
        {
            TestsInfo("FIXME: use one line when CORE-6737 is fixed.")
            SendInput, !f ; Alt+f aka File
            Sleep, 2
            SendInput, o ; Open
            ; SendInput, ^o ; Ctrl+O aka File->Open ; Disabled due CORE-6737
            WinWaitActive, Open, Enter the, 3
            if ErrorLevel
                TestsFailed("'Open (Enter the)' window failed to appear despite Ctrl+O was sent.")
            else
            {
                SendInput, %szDocument%{ENTER} ; Enter path in 'Open (Enter the)' dialog and hit 'OK' button
                WinWaitClose, Open, Enter the, 3
                if ErrorLevel
                    TestsFailed("'Open (Enter the)' window failed to close despite ENTER was sent.")
                else
                {
                    IfWinNotActive, Adobe Flash Player 10
                        TestsFailed("Loaded '" szDocument "'. 'Adobe Flash Player 10' is not active anymore.")
                    else
                    {
                        SendInput, ^{ENTER} ; Ctrl+Enter aka Control->Play
                        SearchImg = %A_WorkingDir%\Media\SA_LoadLocalFlashIMG.jpg
            
                        IfNotExist, %SearchImg%
                            TestsFailed("Can NOT find '" SearchImg "'.")
                        else
                        {
                            TimeOut = 500
                            while TimeOut > 0
                            {
                                IfWinActive, Adobe Flash Player 10
                                {
                                    ImageSearch, FoundX, FoundY, 0, 0, A_ScreenWidth, A_ScreenHeight, *35 %SearchImg%
                                    if ErrorLevel = 2
                                    {
                                        TestsFailed("Could not conduct the ImageSearch ('" SearchImg "' exist).")
                                        break
                                    }
                                    else if ErrorLevel = 1
                                    {
                                        bFound := false
                                        TimeOut--
                                        Sleep, 10
                                    }
                                    else
                                    {
                                        bFound := true
                                        break
                                    }
                                }
                                else
                                    break
                            }
                            
                            if not bFound
                                TestsFailed("The search image '" SearchImg "' could NOT be found on the screen (TimeOut=" TimeOut "). #CORE-7734?")
                            else
                            {
                                Process, Close, %MainAppFile%
                                Process, WaitClose, %MainAppFile%, 4
                                if ErrorLevel
                                    TestsFailed("Unable to terminate '" MainAppFile "' process.")
                                else
                                    TestsOK("Found '" SearchImg "' on the screen, so, we can play '" szDocument "' (TimeOut=" TimeOut ").")
                            }
                        }
                    }
                }
            }
        }
    }
}
