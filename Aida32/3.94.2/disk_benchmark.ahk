/*
 * Designed for Aida32 3.94.2
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

TestName = 4.disk_benchmark

; Test if can perform Quick Linear Read (Disk Benchmark)
TestsTotal++
RunApplication()
if bContinue
{
    IfWinNotactive, AIDA32 - Enterprise System Information
        TestsFailed("'AIDA32 - Enterprise System Information' window is NOT active.")
    else
    {
        SendInput, !p ; Alt+P. Drop down 'Plugin' from Main Menu. WinMenuSelectItem doesn't work here.
        SendInput, {DOWN}{ENTER} ; Select 'AIDA32 Disk Benchmark'
        WinWaitActive, Disk Benchmark - AIDA32,, 3
        if ErrorLevel
            TestsFailed("'Disk Benchmark - AIDA32 (Disk Benchmark Plugin for AIDA32)' window failed to appear despite Alt+P, DOWN, ENTER were sent.")
        else
        {
            ; Navigate to 'Quick Linear Read' tab
            SendMessage, 0x1330, 2,, TTabControl1, Disk Benchmark - AIDA32  ; 0x1330 is TCM_SETCURFOCUS.
            SendMessage, 0x130C, 2,, TTabControl1, Disk Benchmark - AIDA32  ; 0x130C is TCM_SETCURSEL.

            ControlGet, bEnabled, Enabled,, TButton4, Disk Benchmark - AIDA32 ; Check if 'Start' button is enabled
            if bEnabled != 1
                TestsFailed("'Start' button is not enabled in 'Disk Benchmark - AIDA32' window.")
            else
            {
                ControlClick, TButton4, Disk Benchmark - AIDA32 ; Hit 'Start' button
                if ErrorLevel
                    TestsFailed("Unable to click 'Start' button in 'Disk Benchmark - AIDA32' window. Button is reported enabled.")
                else
                {
                    iTimeOut := 30
                    while (iTimeOut > 0)
                    {
                        IfWinNotActive, Disk Benchmark - AIDA32
                            break
                        else
                        {
                            ControlGet, bEnabled, Enabled,, TButton1, Disk Benchmark - AIDA32 ; 'Save' button
                            if bEnabled = 1
                                break
                            else
                            {
                                Sleep, 500
                                iTimeOut--
                            }
                        }
                    }

                    IfWinNotActive, Disk Benchmark - AIDA32
                        TestsFailed("'Disk Benchmark - AIDA32' window is NOT active (iTimeOut=" iTimeOut ").")
                    else
                    {
                        SendInput, !s ; Alt+S aka click 'Save' button. ControlClick not always works here.
                        TestsOK("Benchmark completed. Alt+S sent to click 'Save' button in 'Disk Benchmark - AIDA32' window (iTimeOut=" iTimeOut ").")
                    }
                }
            }
        }
    }
}


TestsTotal++
if bContinue
{
    WinWaitActive, Save Screen Shot,,3
    if ErrorLevel
        TestsFailed("'Save Screen Shot' window failed to appear despite Alt+S being sent to click 'Save' button in 'Disk Benchmark - AIDA32' window.")
    else
    {
        szFilePath = %A_Desktop%\disk_benchmark.bmp
        ControlSetText, Edit1, %szFilePath%, Save Screen Shot
        if ErrorLevel
            TestsFailed("Unable to set 'File name' field text to '" szFilePath "' in 'Save Screen Shot' window.")
        else
        {
            SendInput, {ENTER} ; Hit 'Save' button in 'Save Screen Shot' window
            WinWaitClose, Save Screen Shot,,3
            if ErrorLevel
                TestsFailed("'Save Screen Shot' window failed to close despite ENTER being sent.")
            else
            {
                WinWaitActive, Disk Benchmark - AIDA32,,3
                if ErrorLevel
                    TestsFailed("'Disk Benchmark - AIDA32' window failed to activate.")
                else
                {
                    IfNotExist, %szFilePath%
                        TestsFailed("'" szFilePath "' does NOT exist, but it should.")
                    else
                    {
                        CoordMode, Pixel, Screen ; Coordinates are relative to the desktop (entire screen).
                        ImageSearch, FoundX, FoundY, 0, 0, A_ScreenWidth, A_ScreenHeight, *5 %szFilePath%
                        if ErrorLevel = 2
                            TestsFailed("Could not conduct the ImageSearch ('" szFilePath "' exist).")
                        else if ErrorLevel = 1
                            TestsFailed("The search image '" szFilePath "' could NOT be found on the screen.")
                        else
                        {
                            WinGetPos, WinX, WinY,,, Disk Benchmark - AIDA32
                            If ((FoundX != WinX) OR (FoundY != WinY))
                                TestsFailed("ImageSearch (" FoundX "x" FoundY ") and WinGetPos (" WinX "x" WinY ") returns different results.")
                            else
                                TestsOK("Disk Benchmark completed. ImageSearch and WinGetPos returned same results.")
                        }
                    }
                }
            }
        }
    }
}


bTerminateProcess("aida32.exe")
bTerminateProcess("aida32.bin")
