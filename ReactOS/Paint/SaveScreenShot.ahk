/*
 * Designed for Paint
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

TestName = 1.SaveScreenShot

; Test if can take screenshot and save it to desktop (bug #CORE-6093)
TestsTotal++
RunApplication("")
if not bContinue
    TestsFailed("We failed somwehere in 'prepare.ahk'.")
else
{
    WinWaitActive, untitled - Paint,,5
    if ErrorLevel
        TestsFailed("Window 'untitled - Paint' failed to appear.")
    else
    {
        WinMinimize, untitled - Paint
        Process, Close, calc.exe
        Run, %A_WinDir%\System32\calc.exe
        WinWaitActive, Calculator,,7
        if ErrorLevel
            TestsFailed("Window 'Calculator' failed to appear.")
        else
        {
            clipboard = ; Empty the clipboard
            TestsInfo("In a sec will send Alt+PrintScreen, if BSOD, then bug #CORE-6093?.")
            SendInput, !{PrintScreen} ; Send Alt+PrintScreen
            WinRestore, untitled - Paint
            WinWaitActive, untitled - Paint,,3
            if ErrorLevel
                TestsFailed("Unable to restore 'untitled - Paint' window")
            else
            {
                FileDelete, %A_Desktop%\ActiveWnd.bmp ; Delete before saving
                WinMenuSelectItem, untitled - Paint, , Image, Attributes
                if ErrorLevel
                    TestsFailed("Unable to hit 'Image -> Attributes' in 'untitled - Paint' window.")
                else
                {
                    Process, Close, calc.exe ; We will run it again later
                    WinWaitActive, Attributes, File last, 7
                    if ErrorLevel
                        TestsFailed("Window 'Attributes (File last)' failed to appear.")
                    else
                    {
                        ControlSetText, Edit1, 10, Attributes, File last ; Set 'Width'
                        if ErrorLevel
                            TestsFailed("Unable to set 'Width' to '10' in 'Attributes (File last)' window.")
                        else
                        {
                            ControlSetText, Edit2, 10, Attributes, File last ; Set 'Height'
                            if ErrorLevel
                                TestsFailed("Unable to set 'Height' to '10' in 'Attributes (File last)' window.")
                            else
                                bContinue := true
                        }
                    }
                }
            }
        }
    }
}

if bContinue ; no need to have else part, since we output failures above
{
    ControlClick, Button11, Attributes, File last ; Hit 'OK' button
    if ErrorLevel
        TestsFailed("Unable to hit 'OK' button in 'Attributes (File last)' window.")
    else
    {
        WinWaitClose, Attributes, File last, 5
        if ErrorLevel
            TestsFailed("Window 'Attributes (File last)' failed to close.")
        else
        {
            WinWaitActive, untitled - Paint,,3
            if ErrorLevel
                TestsFailed("OS itselft was unable to focus 'untitled - Paint' window.")
            else
            {
                SendInput, ^v ; Send Ctrl+V
                SendInput, ^s ; Send Ctrl+S
                WinWaitActive, Save As, Save &in, 7
                if ErrorLevel
                    TestsFailed("Window 'Save As (Save in)' failed to appear.")
                else
                {
                    ControlSetText, Edit1, %A_Desktop%\ActiveWnd.bmp, Save As, Save &in ; Enter path in 'File name'
                    if ErrorLevel
                        TestsFailed("Unable to set 'File name' to '%A_Desktop%\ActiveWnd.bmp' in 'Save As (Save in)' window.")
                    else
                    {
                        ControlClick, Button2, Save As, Save &in ; Hit 'Save' button
                        if ErrorLevel
                            TestsFailed("Unable to hit 'Save' button in 'Save As (Save in)' window.")
                        else
                        {
                            IfNotExist, %A_Desktop%\ActiveWnd.bmp
                                TestsFailed("Can NOT find '" A_Desktop "\ActiveWnd.bmp'.")
                            else
                                bContinue := true
                        }
                    }
                }
            }
        }
    }
}


if bContinue
{
    Process, Close, mspaint.exe
    Process, WaitClose, mspaint.exe, 4
    if ErrorLevel
        TestsFailed("Unable to terminate 'mspaint.exe' process.")
    else
    {
        Run, %A_WinDir%\System32\calc.exe
        WinWaitActive, Calculator,,7
        if ErrorLevel
            TestsFailed("Window 'Calculator' failed to appear, but it worked before.")
        else
        {
            ImageSearch, FoundX, FoundY, 0, 0, %A_ScreenWidth%, %A_ScreenHeight%, *15 %A_Desktop%\ActiveWnd.bmp
            if ErrorLevel = 2
                TestsFailed("Could not conduct the search ('" A_Desktop "\ActiveWnd.bmp' exist).")
            else if ErrorLevel = 1
                TestsFailed("'" A_Desktop "\ActiveWnd.bmp' could not be found on the screen.")
            else
            {
                TestsOK("Seems like Alt+PrintScreen works well, so, no bug #CORE-6093.")
            }
        }
    }
}

Process, Close, calc.exe
