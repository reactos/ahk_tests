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


; Test if we can enter URL
TestsTotal++
if not bContinue
    TestsFailed("We failed somewhere in prepare.ahk")
else
{
    WinWaitActive, Welcome to Opera - Opera,, 4 ; Window caption might change?
    if not ErrorLevel
    {
        Sleep, 1000
        SendInput, {CTRLDOWN}l{CTRLUP} ; Toggle address bar
        Sleep, 1000
        SendInput, http{:}//dsx86{.}patrickaalto{.}com{ENTER}
        Sleep, 5000 ; Let it to sleep, maybe it will crash ;)
        
        WinWaitActive, DSx86 by Patrick Aalto - Opera,,15
        if not ErrorLevel
            TestsOK("Window caption is 'DSx86 by Patrick Aalto - Opera' that means we opened URL by sending Ctrl+L.")
        else
            TestsFailed("Window 'DSx86 by Patrick Aalto - Opera' was NOT found. Failed to open URL. Ctrl+L doesnt work?")
    }
    else
        TestsFailed("Window 'Welcome to Opera - Opera' was NOT found.")
}

Process, Close, Opera.exe ; Terminate process
