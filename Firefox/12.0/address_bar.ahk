/*
 * Designed for Mozilla Firefox 12.0
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

TestName = 2.address_bar
 
; Check if can open some website by typing text in address bar
TestsTotal++
if bContinue
{
    IfWinActive, Mozilla Firefox Start Page - Mozilla Firefox
    {
        Sleep, 1000
        SendInput, {ALTDOWN}d{ALTUP} ; Go to address bar
        Sleep, 1200 ; Let it to respond
        SendInput, http{:}//dsx86{.}patrickaalto{.}com
        Sleep, 500
        SendInput, {ENTER}

        Sleep, 7500 ; Let it to load the page, maybe we will crash

        WinWaitActive, DSx86 by Patrick Aalto - Mozilla Firefox,, 7
        if not ErrorLevel
            TestsOK("'DSx86 by Patrick Aalto - Mozilla Firefox' window appeared, so typing URL works (Alt+D).")
        else
            TestsFailed("'DSx86 by Patrick Aalto - Mozilla Firefox' window failed to appear, so, typing URL failed (Alt+D).")
    }
    else
        TestsFailed("'Mozilla Firefox Start Page - Mozilla Firefox' is not active window.")
}
else
    TestsFailed("We failed somwehere in 'prepare.ahk'.")

Process, Close, firefox.exe ; Teminate process