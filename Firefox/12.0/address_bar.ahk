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
if not bContinue
    TestsFailed("We failed somwehere in 'prepare.ahk'.")
else
{
    IfWinNotActive, Mozilla Firefox Start Page - Mozilla Firefox
        TestsFailed("'Mozilla Firefox Start Page - Mozilla Firefox' is not active window.")
    else
    {
        TestsTotal++
        EnterURL("http://dsx86.patrickaalto.com")
        if bContinue
        {
            WinWaitActive, DSx86 by Patrick Aalto - Mozilla Firefox,, 7
            if ErrorLevel
                TestsFailed("'DSx86 by Patrick Aalto - Mozilla Firefox' window failed to appear, so, typing URL failed (Alt+D).")
            else
            {
                TestsTotal++
                WaitForPageToLoad("DSx86 by Patrick Aalto - Mozilla Firefox", "5")
                if bContinue
                {
                    Sleep, 1500 ; Let it to load the page, maybe we will crash
                    Process, Close, %ProcessExe%
                    Process, WaitClose, %ProcessExe%, 5
                    if ErrorLevel ; The PID still exists.
                        TestsFailed("Unable to terminate '" ProcessExe "' process.")
                    else
                        TestsOK("'DSx86 by Patrick Aalto - Mozilla Firefox' window appeared, so typing URL works (Alt+D), '" ProcessExe "' process closed.")
                }
            }
        }
    }
}
