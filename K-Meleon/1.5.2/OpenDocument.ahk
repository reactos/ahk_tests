/*
 * Designed for K-Meleon 1.5.2
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

TestName = 2.OpenDocument
szDocument =  %A_WorkingDir%\Media\index.html ; Case insensitive

; Test if can open html document using File -> Open and close application
TestsTotal++
if not bContinue
    TestsFailed("We failed somwehere in 'prepare.ahk'.")
else
{
    WinWaitActive, K-Meleon 1.5.2 (K-Meleon),,7
    if not ErrorLevel
    {
        SendInput, {ALTDOWN}f{ALTUP} ; WinMenuSelectItem doesn't work with K-Meleon
        Sleep, 1500
        SendInput, o
        Sleep, 1500
        WinWaitActive, Open, Look, 7
        if not ErrorLevel
        {
            ControlSetText, Edit1, %szDocument%, Open, Look
            if not ErrorLevel
            {
                Sleep, 1000
                ControlClick, Button2, Open, Look
                if not ErrorLevel
                {
                    WinWaitClose, Open, Look, 7
                    if not ErrorLevel
                    {
                        WinWaitActive, ReactOS HTML test (K-Meleon),,7
                        if not ErrorLevel
                        {
                            Sleep, 1500
                            SearchImg = %A_WorkingDir%\Media\BookPage29Img.jpg
                            IfExist, %SearchImg%
                            {
                                ImageSearch, FoundX, FoundY, 0, 0, A_ScreenWidth, A_ScreenHeight, *14 %SearchImg%
                                if ErrorLevel = 2
                                    TestsFailed("Could not conduct the ImageSearch ('" SearchImg "' exist).")
                                else if ErrorLevel = 1
                                    TestsFailed("The search image '" SearchImg "' could NOT be found on the screen.")
                                else
                                {
                                    WinClose, ReactOS HTML test (K-Meleon)
                                    WinWaitClose, ReactOS HTML test (K-Meleon),,7
                                    if not ErrorLevel
                                        TestsOK("Successfully opened '" szDocument "' and closed K-Meleon application.")
                                    else
                                        TestsFailed("'ReactOS HTML test (K-Meleon)' window failed to close.")
                                }
                            }
                            else
                                TestsFailed("Can NOT find '" SearchImg "'.")
                        }
                        else
                            TestsFailed("Window 'ReactOS HTML test (K-Meleon)' failed to appear.")
                    }
                    else
                        TestsFailed("'Open (Look)' window failed to dissapear.")
                }
                else
                    TestsFailed("Unable to hit 'Open' button in 'Open (Look)' window.")
            }
            else
                TestsFailed("Unable to enter '%szDocument%' in 'Open (Look)' window.")
        }
        else
            TestsFailed("Window 'Open (Look)' failed to appear, bug 4779?")
    }
    else
        TestsFailed("Window 'K-Meleon 1.5.2 (K-Meleon)' failed to appear.")
}