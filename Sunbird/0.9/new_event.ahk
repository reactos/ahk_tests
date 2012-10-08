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
if not bContinue
    TestsFailed("We failed somewhere in prepare.ahk.")
else
{
    FormatTime, TimeString,, LongDate
    IfWinNotActive, %TimeString% - Sunbird
        TestsFailed("'%TimeString% - Sunbird' is not active window.")
    else
    {
        SendInput, {ALTDOWN}f{ALTUP} ; Open 'File' menu, WinMenuSelectItem does not work
        SendInput, n ; Select 'New Event' from 'File' menu
        WinWaitActive, New Event: New Event,,7
        if ErrorLevel
            TestsFailed("Window 'New Event: New Event' failed to appear.")
        else
        {
            SendInput, {ALTDOWN}t{ALTUP} ; Focus 'Title' field, ControlClick does not work here
            SendInput, Edijus birthday ; Set event title
            WinWaitActive, New Event: Edijus birthday,,5
            if ErrorLevel
                TestsFailed("Window 'New Event: Edijus birthday' failed to appear (Unable to focus 'Title' field?).")
            else
            {
                SendInput, {ALTDOWN}l{ALTUP} ; Focus 'Location' field
                SendInput, Lithuania
                SendInput, {ALTDOWN}y{ALTUP} ; Focus 'Category' field
                SendInput, b ; Select 'Birthday'
                SendInput, {ALTDOWN}d{ALTUP} ; Check 'All day Event' checkbox
                SendInput, {ALTDOWN}s{ALTUP}{TAB} ; Focus 'Start' field
                SendInput, 10/6/2013 ; Write the date
                SendInput, {ALTDOWN}n{ALTUP} ; Focus 'End' field
                SendInput, {ALTDOWN}r{ALTUP} ; Focus 'Repeat' field
                SendInput, y ; Select 'Yearly'
                SendInput, {ALTDOWN}m{ALTUP} ; Focus 'Reminder' field
                SendInput, 22 ; Select '2 days before'
                SendInput, {ALTDOWN}p{ALTUP} ; Focus 'Description' field
                SendInput, October 6th is Edijus birthday, don't forget to get something for him.
                SendInput, {CTRLDOWN}s{CTRLUP} ; Save event
                SendInput, {CTRLDOWN}w{CTRLUP} ; Close window
                WinWaitClose, New Event: Edijus birthday,,5
                if ErrorLevel
                    TestsFailed("Window 'New Event: Edijus birthday' failed to close.")
                else
                {
                    WinWaitActive, %TimeString% - Sunbird,,5
                    if ErrorLevel
                        TestsFailed("Window '" TimeString " - Sunbird' is not active.")
                    else
                    {
                        Process, Close, %ProcessExe%
                        Process, WaitClose, %ProcessExe%, 4
                        if ErrorLevel
                            TestsFailed("Unable to terminate '" ProcessExe "' process.")
                        else
                            TestsOK("FIXME: find a way to really make sure we saved the event, '" ProcessExe "' process terminated.") ; Event is saved encrypted in storage.sdb which is always there
                    }
                }
            }
        }
    }
}
