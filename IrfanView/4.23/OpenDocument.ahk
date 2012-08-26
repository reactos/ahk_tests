/*
 * Designed for Foxit IrfanView 4.23
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

TestName = 2.GoToPage
szDocument =  %A_WorkingDir%\Media\BookPage29Img.jpg ; Case sensitive!

; Test if can open picture using File -> Open dialog and close application successfully
TestsTotal++
RunApplication("")
if not bContinue
    TestsFailed("We failed somwehere in 'prepare.ahk'.")
else
{
    SplitPath, szDocument, NameExt
    WinWaitActive, IrfanView,,7
    if not ErrorLevel
    {
        IfExist, %szDocument%
        {
            WinMenuSelectItem, IrfanView, , File, Open
            if not ErrorLevel
            {
                WinWaitActive, Open, Look &in,7
                if not ErrorLevel
                {
                    Sleep, 1500
                    ControlSetText, Edit1, %szDocument%, Open, Look &in
                    if not ErrorLevel
                    {
                        Sleep, 1500
                        ControlClick, Button2, Open, Look &in
                        if not ErrorLevel
                        {
                            Sleep, 1500
                            WinWaitActive, %NameExt% - IrfanView,,7
                            if not ErrorLevel
                            {
                                ImageSearch, FoundX, FoundY, 0, 0, A_ScreenWidth, A_ScreenHeight, *14 %szDocument%
                                if ErrorLevel = 2
                                    TestsFailed("Could not conduct the ImageSearch ('" szDocument "' exist).")
                                else if ErrorLevel = 1
                                    TestsFailed("The search image '" szDocument "' could NOT be found on the screen. Color depth not 32bit?")
                                else
                                {
                                    WinClose, %NameExt% - IrfanView
                                    WinWaitClose, %NameExt% - IrfanView,,7
                                    if not ErrorLevel
                                        TestsOK("Opened '" szDocument "' using 'File -> Open' and closed application successfully.")
                                    else
                                        TestsFailed("Unable to close '" NameExt " - IrfanView' window.")
                                }
                            }
                            else
                                TestsFailed("Window '" NameExt " - IrfanView' failed to appear.")
                        }
                        else
                            TestsFailed("Unable to click 'Open' button in 'Open (Look in)' window.")
                    }
                    else
                        TestsFailed("Unable to change 'File name' control text to '" szDocument "' in 'Open (Look in)' window, bug 7089?")
                }
                else
                    TestsFailed("Window 'Open (Look in)' failed to appear.")
            }
            else
                TestsFailed("Unable to hit 'File -> Open' in 'IrfanView' window.")
        }
        else
            TestsFailed("File '" szDocument "' was NOT found.")
    }
    else
        TestsFailed("Window 'IrfanView' failed to appear.")
}
