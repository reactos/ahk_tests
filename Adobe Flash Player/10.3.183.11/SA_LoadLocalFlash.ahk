/*
 * Designed for Flash Player 10.3.183.11
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
            WinMenuSelectItem, Adobe Flash Player 10, , File, Open ; File -> Open
            if ErrorLevel
                TestsFailed("Unable to click 'File -> Open' in 'Adobe Flash Player 10' window.")
            else
            {
                WinWaitActive, Open, Enter the, 3
                if ErrorLevel
                    TestsFailed("'Open (Enter the)' window is not active window.")
                else
                {
                    ControlSetText, Edit1, %szDocument%, Open, Enter the ; Enter path in 'Open' dialog
                    if ErrorLevel
                        TestsFailed("Unable to enter path '" szDocument "' in 'Open (Enter the)' window.")
                    else
                    {
                        ControlClick, Button1, Open, Enter the
                        if ErrorLevel
                            TestsFailed("Unable to hit 'OK' button in 'Open (Enter the)' window.")
                        else
                        {
                            WinWaitClose,  Open, Enter the, 3
                            if ErrorLevel
                                TestsFailed("'Open (Enter the)' window failed to close despite 'OK' button being clicked.")
                            else
                            {
                                Sleep, 2000 ; Give it some time to fail
                                IfWinNotActive, Adobe Flash Player 10
                                    TestsFailed("Loaded '" szDocument "'. 'Adobe Flash Player 10' is not active anymore.")
                                else
                                {
                                    WinMenuSelectItem, Adobe Flash Player 10, , Control, Play ; Control -> Play
                                    if ErrorLevel
                                        TestsFailed("Unable to click 'Control -> Play' in 'Adobe Flash Player 10' window.")
                                    else
                                    {
                                        SearchImg = %A_WorkingDir%\Media\SA_LoadLocalFlashIMG.jpg
                            
                                        IfNotExist, %SearchImg%
                                            TestsFailed("Can NOT find '" SearchImg "'.")
                                        else
                                        {
                                            bFound := false
                                            while TimeOut < 400
                                            {
                                                ImageSearch, FoundX, FoundY, 0, 0, A_ScreenWidth, A_ScreenHeight, *35 %SearchImg% ; Works on both XP SP3 and win2k3 SP2
                                                if ErrorLevel = 2
                                                {
                                                    TestsFailed("Could not conduct the ImageSearch ('" SearchImg "' exist).")
                                                    TimeOut := 400 ; Exit the loop
                                                }
                                                else if ErrorLevel = 1
                                                {
                                                    bFound := false
                                                }
                                                else
                                                {
                                                    TimeOut := 400 ; Exit the loop
                                                    bFound := true
                                                }
                                                TimeOut++
                                                Sleep, 10
                                            }
                                            
                                            if not bFound
                                                TestsFailed("The search image '" SearchImg "' could NOT be found on the screen.")
                                            else
                                            {
                                                Process, Close, %MainAppFile%
                                                Process, WaitClose, %MainAppFile%, 4
                                                if ErrorLevel
                                                    TestsFailed("Unable to terminate '" MainAppFile "' process.")
                                                else
                                                    TestsOK("Found '" SearchImg "' on the screen, so, we can play '" szDocument "'.")
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
    }
}
