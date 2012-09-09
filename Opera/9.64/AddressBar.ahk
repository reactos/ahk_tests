/*
 * Designed for Opera 9.64
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

TestName = 2.AddressBar

; Test if we can enter URL
TestsTotal++
if not bContinue
    TestsFailed("We failed somewhere in prepare.ahk")
else
{
    WinWaitActive, Welcome to Opera - Opera,, 4 ; Window caption might change?
    if ErrorLevel
        TestsFailed("Window 'Welcome to Opera - Opera' was NOT found.")
    else
    {
        Sleep, 1000
        SendInput, {CTRLDOWN}l{CTRLUP} ; Toggle address bar
        Sleep, 1000
        SendInput, http{:}//dsx86{.}patrickaalto{.}com{ENTER}
        Sleep, 5000 ; Let it to sleep, maybe it will crash ;)
        
        WinWaitActive, DSx86 by Patrick Aalto - Opera,,15
        if ErrorLevel
            TestsFailed("Window 'DSx86 by Patrick Aalto - Opera' was NOT found. Failed to open URL. Ctrl+L doesnt work?")
        else
        {
            Process, Close, %ProcessExe%
            Process, WaitClose, %ProcessExe%, 4
            if ErrorLevel
                TestsFailed("Unable to terminate '" ProcessExe "' process.")
            else
                TestsOK("Window caption is 'DSx86 by Patrick Aalto - Opera' that means we opened URL by sending Ctrl+L.")
        }
    }
}
