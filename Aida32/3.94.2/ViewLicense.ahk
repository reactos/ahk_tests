/*
 * Designed for Aida32 3.94.2
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

TestName = 2.ViewLicense

; Test if can view license "License -> License" and close application properly
TestsTotal++
RunApplication()
if bContinue
{
    WinWaitActive, AIDA32 - Enterprise System Information,,5
    if not ErrorLevel
    {
        ; Go to License -> License. WinMenuSelectItem doesn't work here.
        SendInput, {ALTDOWN}l{ALTUP}
        Sleep, 1000
        SendInput, l
        WinWaitActive, License Agreement - AIDA32, Registration Request, 10
        if not ErrorLevel
        {
            Sleep, 1000
            ControlClick, TListBox1, License Agreement - AIDA32
            if not ErrorLevel
            {
                ; Lets pretend we are reading the license
                iScroll := 0
                while iScroll < 15
                {
                    iScroll++
                    SendInput, {DOWN}
                    Sleep, 900
                }
                
                OutputDebug, %TestName%:%A_LineNumber%: In 1sec will close 'License Agreement - AIDA32' window, if BSOD then bug #6355?.`n
                ControlClick, TButton2, License Agreement - AIDA32 ; Click 'Close' button
                if not ErrorLevel
                {
                    WinWaitClose, License Agreement - AIDA32, Registration Request, 15
                    if not ErrorLevel
                    {
                        WinClose, AIDA32 - Enterprise System Information ; Send 0x112 = WM_SYSCOMMAND, 0xF060 = SC_CLOSE
                        WinWaitClose, AIDA32 - Enterprise System Information,, 10
                        if not ErrorLevel
                        {
                            Sleep, 2000
                            IfWinNotExist, aida32.bin - Application Error
                                TestsOK("License was read, application exited correctly.")
                            else
                                TestsFailed("'aida32.bin - Application Error (The exception)' window appeared, bug 7090?")
                        }
                        else
                        {
                            TestsFailed("'AIDA32 - Enterprise System Information' window failed to close. Terminating the app.")
                            Process, Close, aida32.bin
                            Process, Close, aida32.exe
                        }
                    }
                    else
                        TestsFailed("'License Agreement - AIDA32 (Registration Request)' window failed to close.")
                }
                else
                    TestsFailed("Unable to hit 'Close' button in 'License Agreement - AIDA32 (Registration Request)' window.")
            }
            else
                TestsFailed("Unable to click on first license field in 'License Agreement - AIDA32 (Registration Request)' window.")
        }
        else
            TestsFailed("Window 'License Agreement - AIDA32 (Registration Request)' failed to appear.")
    }
    else
        TestsFailed("Window 'AIDA32 - Enterprise System Information' failed to appear.")
}
else
    TestsFailed("We failed somwehere in 'prepare.ahk'.")
