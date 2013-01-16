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
RunApplication("","")
if not bContinue
    TestsFailed("We failed somwehere in 'prepare.ahk'.")
else
{
    WinWaitActive, K-Meleon 1.5.2 (K-Meleon),,7
    if ErrorLevel
        TestsFailed("Window 'K-Meleon 1.5.2 (K-Meleon)' failed to appear.")
    else
    {
        SendInput, {ALTDOWN}f{ALTUP} ; 'File' menu. WinMenuSelectItem doesn't work with K-Meleon
        Sleep, 250
        SendInput, o ; 'Open' from 'File' menu
        WinWaitActive, Open, Look, 5
        if ErrorLevel
            TestsFailed("Window 'Open (Look)' failed to appear, bug #CORE-4415?")
        else
        {
            ControlSetText, Edit1, %szDocument%, Open, Look
            if ErrorLevel
                TestsFailed("Unable to enter '%szDocument%' in 'Open (Look)' window.")
            else
            {
                ControlClick, Button2, Open, Look
                if ErrorLevel
                    TestsFailed("Unable to hit 'Open' button in 'Open (Look)' window.")
                else
                {
                    WinWaitClose, Open, Look, 3
                    if ErrorLevel
                        TestsFailed("'Open (Look)' window failed to dissapear.")
                    else
                    {
                        WinWaitActive, ReactOS HTML test (K-Meleon),,5
                        if ErrorLevel
                            TestsFailed("Window 'ReactOS HTML test (K-Meleon)' failed to appear.")
                        else
                        {
                            SearchImg = %A_WorkingDir%\Media\BookPage29Img.jpg
                            IfNotExist, %SearchImg%
                                TestsFailed("Can NOT find '" SearchImg "'.")
                            else
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
                                    if ErrorLevel
                                        TestsFailed("'ReactOS HTML test (K-Meleon)' window failed to close.")
                                    else
                                    {
                                        Process, WaitClose, %ProcessExe%
                                        TestsOK("Successfully opened '" szDocument "' and closed K-Meleon application.")
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