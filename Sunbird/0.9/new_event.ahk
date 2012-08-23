/*
 * Designed for Sunbird 0.9
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

TestName = 2.new_event
 
; Check if can create new event
TestsTotal++
if bContinue
{
    FormatTime, TimeString,, LongDate
    IfWinActive, %TimeString% - Sunbird
    {
        SendInput, {ALTDOWN}f{ALTUP} ; Open 'File' menu, WinMenuSelectItem does not work
        SendInput, n ; Select 'New Event' from 'File' menu
        WinWaitActive, New Event: New Event,,7
        if not ErrorLevel
        {
            Sleep, 1500
            SendInput, {ALTDOWN}t{ALTUP} ; Focus 'Title' field, ControlClick does not work here
            SendInput, Edijus birthday ; Set event title
            WinWaitActive, New Event: Edijus birthday,,5
            if not ErrorLevel
            {
                SendInput, {ALTDOWN}l{ALTUP} ; Focus 'Location' field
                SendInput, Lithuania
                SendInput, {ALTDOWN}y{ALTUP} ; Focus 'Category' field
                SendInput, b ; Select 'Birthday'
                Sleep, 1000
                SendInput, {ALTDOWN}d{ALTUP} ; Check 'All day Event' checkbox
                SendInput, {ALTDOWN}s{ALTUP}{TAB} ; Focus 'Start' field
                SendInput, 10/6/2012 ; Write the date
                SendInput, {ALTDOWN}n{ALTUP} ; Focus 'End' field
                SendInput, {ALTDOWN}r{ALTUP} ; Focus 'Repeat' field
                SendInput, y ; Select 'Yearly'
                SendInput, {ALTDOWN}m{ALTUP} ; Focus 'Reminder' field
                SendInput, 22 ; Select '2 days before'
                Sleep, 1000
                SendInput, {ALTDOWN}p{ALTUP} ; Focus 'Description' field
                SendInput, October 6th is Edijus birthday, don't forget to get something for him.
                Sleep, 1000
                SendInput, {CTRLDOWN}s{CTRLUP} ; Save event
                SendInput, {CTRLDOWN}w{CTRLUP} ; Close window
                WinWaitClose, New Event: Edijus birthday,,5
                if not ErrorLevel
                {
                    WinWaitActive, %TimeString% - Sunbird,,5
                    if not ErrorLevel
                    {
                        ; Event is saved encrypted in storage.sdb which is always there
                        TestsOK()
                    }
                    else
                    {
                        TestsFailed()
                        WinGetTitle, title, A
                        OutputDebug, %TestName%:%A_LineNumber%: Test failed: Window '%TimeString% - Sunbird' is not active. Active window caption: '%title%'.`n
                    }
                }
                else
                {
                    TestsFailed()
                    WinGetTitle, title, A
                    OutputDebug, %TestName%:%A_LineNumber%: Test failed: Window 'New Event: Edijus birthday' failed to close. Active window caption: '%title%'.`n
                }
            }
            else
            {
                TestsFailed()
                WinGetTitle, title, A
                OutputDebug, %TestName%:%A_LineNumber%: Test failed: Window 'New Event: Edijus birthday' failed to appear (Unable to focus 'Title' field?). Active window caption: '%title%'.`n
            }
        }
        else
        {
            TestsFailed()
            WinGetTitle, title, A
            OutputDebug, %TestName%:%A_LineNumber%: Test failed: Window 'New Event: New Event' failed to appear. Active window caption: '%title%'.`n
        }
    }
    else
    {
        TestsFailed()
        WinGetTitle, title, A
        OutputDebug, %TestName%:%A_LineNumber%: Test failed: '%TimeString% - Sunbird' is not active window. Active window caption: '%title%'.`n
    }
}
else
{
    TestsFailed()
    WinGetTitle, title, A
    OutputDebug, %TestName%:%A_LineNumber%: Test failed: We failed somewhere in prepare.ahk. Active window caption: '%title%'`n
}

; Process, Close, sunbird.exe ; Teminate process
