/*
 * Designed for Thunderbird 2.0.0.18
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

TestName = 2.SendMail

; Test if can send e-mail
TestsTotal++
if not bContinue
    TestsFailed("We failed somwehere in 'prepare.ahk'.")
else
{
    IfWinNotActive, Inbox for reactos.dev@gmail.com - Thunderbird
        TestsFailed("'Inbox for reactos.dev@gmail.com - Thunderbird' is not active window.")
    else
    {
        SendInput, {ALTDOWN}m{ALTUP} ; Drop down 'Message' from file menu
        Sleep, 1000
        SendInput, n ; Select 'New Message' menu item
        WinWaitActive, Compose: (no subject),,10
        if ErrorLevel
            TestsFailed("Window 'Compose: (no subject)' failed to appear.")
        else
        {
            Sleep, 2200
            SendInput, reactos.dev@gmail.com ; Enter recipients e-mail
            SendInput, {ALTDOWN}s{ALTUP} ; Go to 'Subject' field
            Sleep, 800
            FormatTime, TimeString
            SendInput, %TimeString% ; Enter time and date into 'Subject' field
            Sleep, 500
            SendInput, {TAB}Congratulations, Thunderbird is working. ; Message body
            SendInput, {CTRLDOWN}{ENTER}{CTRLUP} ; Ctrl+Return to send message now
            WinWaitActive, Mail Server Password Required,,10
            if ErrorLevel
                TestsFailed("Window 'Mail Server Password Required' failed to appear.")
            else
            {
                Sleep, 1500
                SendInput, 3d1ju5test{ENTER} ; Enter password
                WinWaitActive, Inbox for reactos.dev@gmail.com - Thunderbird,,10
                if ErrorLevel
                    TestsFailed("Window 'Inbox for reactos.dev@gmail.com - Thunderbird' failed to appear after sending email.")
                else
                {
                    Sleep, 7000 ; Sleep to actually send the message
                    TestsOK("Composed and sent new email successfully.")
                }
            }
        }
    }
}

Process, Close, thunderbird.exe