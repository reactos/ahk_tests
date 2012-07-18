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
WinWaitActive, Welcome to Opera - Opera,, 15 ; Window caption might change?
if not ErrorLevel
{
    Sleep, 1000
    SendInput, {CTRLDOWN}l{CTRLUP} ; Toggle address bar
    Sleep, 1000
    SendInput, www{.}yahoo{.}com{ENTER}
    Sleep, 5000 ; Let it to sleep, maybe it will crash ;)
    
    WinWaitActive, Yahoo! - Opera,,25
    if not ErrorLevel
    {
        TestsOK++
        OutputDebug, OK: %Module%:%A_LineNumber%: Window caption is 'Yahoo! - Opera' that means we opened URL.`n

        bContinue := true 
    }
    else
    {
        TestsFailed++
        WinGetTitle, title, A
        OutputDebug, FAILED: %Module%:%A_LineNumber%: Window 'Yahoo! - Opera' was NOT found. Failed to open URL. Active window caption: '%title%'`n
        bContinue := false
    }
}
else
{
    TestsFailed++
    WinGetTitle, title, A
    OutputDebug, FAILED: %Module%:%A_LineNumber%: Window 'Welcome to Opera - Opera' was NOT found. Active window caption: '%title%'`n
    bContinue := false
}
