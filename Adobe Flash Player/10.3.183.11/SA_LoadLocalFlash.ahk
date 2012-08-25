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
if bContinue
{
    IfWinActive, Adobe Flash Player 10
    {
        IfExist, %szDocument%
        {
            WinMenuSelectItem, Adobe Flash Player 10, , File, Open ; File -> Open
            if not ErrorLevel
            {
                WinWaitActive, Open, Enter the, 7
                if not ErrorLevel
                {
                    ControlSetText, Edit1, %szDocument%, Open, Enter the ; Enter path in 'Open' dialog
                    if not ErrorLevel
                    {
                        ControlClick, Button1, Open, Enter the
                        if not ErrorLevel
                        {
                            Sleep, 2000 ; Give it some time to fail
                            IfWinActive, Adobe Flash Player 10
                            {
                                WinMenuSelectItem, Adobe Flash Player 10, , Control, Play ; Control -> Play
                                if not ErrorLevel
                                {
                                    SearchImg = %A_WorkingDir%\Media\SA_LoadLocalFlashIMG.jpg
                        
                                    IfExist, %SearchImg%
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
                                        
                                        if bFound
                                            TestsOK("Found '" SearchImg "' on the screen, so, we can play '" szDocument "'.")
                                        else
                                            TestsFailed("The search image '" SearchImg "' could NOT be found on the screen.")
                                    }
                                    else
                                        TestsFailed("Can NOT find '" SearchImg "'.")
                                }
                                else
                                    TestsFailed("Unable to click 'Control -> Play' in 'Adobe Flash Player 10' window.")
                            }
                            else
                                TestsFailed("Loaded '" szDocument "'. 'Adobe Flash Player 10' is not active anymore.")
                        }
                        else
                            TestsFailed("Unable to hit 'OK' button in 'Open (Enter the)' window.")
                    }
                    else
                        TestsFailed("Unable to enter path '" szDocument "' in 'Open (Enter the)' window.")
                }
                else
                    TestsFailed("'Open (Enter the)' window is not active window.")
            }
            else
                TestsFailed("Unable to click 'File -> Open' in 'Adobe Flash Player 10' window.")
        }
        else
            TestsFailed("Can NOT find '" szDocument "'.")
    }
    else
        TestsFailed("'Adobe Flash Player 10' window is not active window.")
}
else
    TestsFailed("We failed somwehere in 'prepare.ahk'.")

Process, Close, Standalone Flash Player 10.3.183.11.exe
